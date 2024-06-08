@SuppressWarnings('PMD')
/**
 * @description apex class to get delivery and future dates for checkout
 * @author Salesforce
 * @since May 2023
 */
public without sharing class CONA_B2BDisplayDatesController {
    @TestVisible
    public static CONA_B2BAccountSelector accountSelector = new CONA_B2BAccountSelector();
    @TestVisible
    public static CONA_B2BDeliveryDatesSelector deliveryDatesSelector = new CONA_B2BDeliveryDatesSelector();
    @TestVisible
    public static CONA_B2BHolidayManagementSelector holidaySelector = new CONA_B2BHolidayManagementSelector();
    @TestVisible
    public static CONA_B2BSalesOfficeDispatchSelector dispatchSelector = new CONA_B2BSalesOfficeDispatchSelector();
    @TestVisible
    public static CONA_B2BOrderSelector orderSelector = new CONA_B2BOrderSelector();

    /**
     * @description Check if delivery days is populated or nor  
     * @param accountId accountId
     * @return boolean
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean checkAccountWithVisitPlan(String accountId) {
        try {
            Account account = accountSelector.getByIdAsAdminUser(accountId);
            Boolean acountWithVisitPlan = String.isNotEmpty(account.DeliveryHours__c);
            System.debug('account :::: ');
            System.debug(account);

            return acountWithVisitPlan;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static DeliveryDatesWrapper getDeliveryDatesWithOffDays(String effectiveAccountId,String webStoreId) {
        try {
            return getDeliveryDates(effectiveAccountId, true,webStoreId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static DeliveryDatesWrapper getDeliveryDatesWithoutOffDays(String effectiveAccountId,String webStoreId) {
        try {
            return getDeliveryDates(effectiveAccountId, false,webStoreId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Check DeliveryDate exist and get result
     * @param effectiveAccountId accountId
     * @param deliveryDateString deliveryDate
     * @return ExistingDeliveryDateWrapper
     */
    @AuraEnabled
    public static ExistingDeliveryDateWrapper getUserExistingDeliveryDate(String effectiveAccountId, String deliveryDate) {
        try {
            return getExistingDeliveryDate(effectiveAccountId, deliveryDate);
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description method to get delivery dates
     * @param effectiveAccountId get the effectiveAccountId of User
     * @param retrieveOffDays retrieve also off days
     * @param webStoreId webstore id to process
     * @return `DeliveryDatesWrapper` Wrapper class to get various delivery dates
     */
    public static DeliveryDatesWrapper getDeliveryDates(String effectiveAccountId, Boolean retrieveOffDays, String webStoreId) {
        DeliveryDatesWrapper datesWrapper = new DeliveryDatesWrapper();
        Account account = accountSelector.getByIdAsAdminUser(effectiveAccountId);

        setShippingConditions(datesWrapper, account);
        setTimeZoneAndAvailableDeliveryDates(datesWrapper, account);
        setFutureDeliveryDate(datesWrapper, account);
        setHolidays(datesWrapper, account);

        setActualTimeAndNextDeliveryDate(datesWrapper, account,webStoreId);

        if (retrieveOffDays) {
            setOffDays(datesWrapper, account);
        }

        if (datesWrapper.nextDelDate != null && datesWrapper.availableDeliveryDates.size() > 0 && datesWrapper.futureDeliveryDates.size() > 0) {
            removeUnOrderableDates(datesWrapper, datesWrapper.nextDeliveryDatetime);
        }

        return datesWrapper;
    }

    private static void setShippingConditions(DeliveryDatesWrapper datesWrapper, Account account) {
        List<CONA_ShippingCondition__mdt> shippingConditionMetadata = CONA_ShippingCondition__mdt.getAll().values();
        Map<String, String> shippingConditionsMap = new Map<String, String>();

        for (CONA_ShippingCondition__mdt shippingCondition : shippingConditionMetadata) {
            shippingConditionsMap.put(shippingCondition.Shipping_Condition__c, shippingCondition.Shipping_Condition_Days__c);
        }

        datesWrapper.shippingConditions = shippingConditionsMap.get(account.ShippingCondition__c);
    }

    private static void setTimeZoneAndAvailableDeliveryDates(DeliveryDatesWrapper datesWrapper, Account account) {
        if (account.deliveryHours__c != null) {
            List<String> availableTimeSlots = new List<String>();
            List<Date> availableDatesList = new List<Date>();

            List<OperatingHours> deliveryHours = deliveryDatesSelector.getDeliveryHours(account.DeliveryHours__c, CONA_B2BConstants.DELIVERY_HOURS);
            datesWrapper.timeZoneDifference = getTimeZoneDifference(deliveryHours[0].TimeZone);

            Map<String, String> timeZoneMap = new Map<String, String>();
            List<TimeZone__mdt> timeZoneMetadata = TimeZone__mdt.getAll().values();

            for (TimeZone__mdt timeZone : timeZoneMetadata) {
                timeZoneMap.put(timeZone.SalesforceTimeZone__c, timeZone.MasterLabel);
            }

            datesWrapper.timeZone = timeZoneMap?.get(deliveryHours[0].TimeZone);

            if (deliveryHours.size() > 0 && deliveryHours[0]?.TimeSlots.size() > 0) {
                for (TimeSlot slots : deliveryHours[0].TimeSlots) {
                    availableTimeSlots.add(slots.DayOfWeek);
                }

                availableDatesList = returnDates(deliveryHours[0], availableTimeSlots);
                datesWrapper.availableDeliveryDates = availableDatesList;
            }
        }
    }

    private static void setFutureDeliveryDate(DeliveryDatesWrapper datesWrapper, Account account) {
        if (account.FutureDeliveryHours__c != null) {
            List<String> futureTimeSlots = new List<String>();
            List<Date> futureDatesList = new List<Date>();

            List<OperatingHours> futureDeliveryHours = deliveryDatesSelector.getDeliveryHours(account.FutureDeliveryHours__c, CONA_B2BConstants.FUTURE_HOURS);
            if (futureDeliveryHours.size() > 0 && futureDeliveryHours[0]?.TimeSlots.size() > 0) {
                for (TimeSlot slots : futureDeliveryHours[0].TimeSlots) {
                    futureTimeSlots.add(slots.DayOfWeek);
                }
                futureDatesList = returnDates(futureDeliveryHours[0], futureTimeSlots);
                datesWrapper.futureDeliveryDates = futureDatesList;
            }
        }
    }

    private static void setHolidays(DeliveryDatesWrapper datesWrapper, Account account) {
        if (account.SalesOffice__c != null && account.BottlerId__c != null) {
            List<Date> holidaysList = new List<Date>();
            Id distributionHolidayRecTypeId = holidaySelector.getRecordTypeId(CONA_B2BConstants.HOLIDAY_RECORD_TYPE);
            List<HolidayManagement__c> holidayDates = holidaySelector.getHoldayDates(
                account.BottlerId__c,
                account.SalesOffice__c,
                distributionHolidayRecTypeId
            );

            if (holidayDates.size() > 0) {
                holidaysList = returnHolidays(holidayDates);
                datesWrapper.holidays = holidaysList;
            }
        }
    }

    private static void setOffDays(DeliveryDatesWrapper datesWrapper, Account account) {
        if (account.OffDayDelInd__c != null) {
            String partitionName = CONA_B2BConstants.ORG_CACHE_B2B_NAMESPACE + '.' + CONA_B2BConstants.ORG_CACHE_B2B_PARTITION;

            if (CONA_B2BCacheUtils.getOrgCacheByPartition(partitionName, String.valueOf(account.Id)) == null) {
                datesWrapper.offDays = CONA_B2BOffDayController.returnOffDays(account);
            } else {
                datesWrapper.offDays = (List<Date>) CONA_B2BCacheUtils.getOrgCacheByPartition(partitionName, String.valueOf(account.Id));
            }
        }
    }

    private static void setActualTimeAndNextDeliveryDate(DeliveryDatesWrapper datesWrapper, Account account,String webstoreId) {
        List<SalesOfficeDispatchCutoffTime__c> sodDispatchList = dispatchSelector.getMatchingDispatchTime(
            account.SalesOffice__c,
            account.DistributionMode__c,
            account.ShippingCondition__c
        );
        CONA_B2BWebstoreSelector webstoreSelector = new CONA_B2BWebstoreSelector();
        List<WebStore> listWebStore = new List<WebStore>();
        listWebStore = webstoreSelector.getWebstoreDetails(webstoreId);

        if (sodDispatchList != null && sodDispatchList.size() > 0 && sodDispatchList[0].CutoffTime__c!=null) {
            SalesOfficeDispatchCutoffTime__c sodDispatch = sodDispatchList[0];
            datesWrapper.actualTime = String.valueOf(sodDispatch.CutoffTime__c);
            datesWrapper.cutOffTime = sodDispatch.CutoffTime__c;
            datesWrapper = getNextDeliveryDate(datesWrapper, sodDispatch.CutoffTime__c);
        }
        else if(listWebStore!=null && listWebStore.size() > 0){
            WebStore webStoreRecord = listWebStore[0];
            datesWrapper.actualTime = String.valueOf(webStoreRecord.CONA_B2BBottlerDefaultTime__c);
            datesWrapper.cutOffTime = webStoreRecord.CONA_B2BBottlerDefaultTime__c;
            datesWrapper = getNextDeliveryDate(datesWrapper, webStoreRecord.CONA_B2BBottlerDefaultTime__c);
        }
    }

    /**
     * @description method to retrieve dates
     * @param operatingHours operatingHours Record
     * @param timeSlot timeslot of dates
     * @return `List<Date>` returns the list of dates returned
     */
    public static List<Date> returnDates(OperatingHours operatingHours, List<String> timeSlot) {
        List<Date> selectedDatesList = new List<Date>();

        if (operatingHours.ValidFrom__c != null && operatingHours.ValidTo__c != null && operatingHours.Frequency__c != null) {
            Date startDate = operatingHours.ValidFrom__c;
            String frequency = operatingHours.Frequency__c;
            Date endDate = operatingHours.ValidTo__c;
            Integer additionalYear_Month =Integer.valueOf(system.label.CONA_B2BAdditionalYear_Month);
            if (endDate!=null && endDate.year() > (Date.Today().addYears(additionalYear_Month)).year()) {
                endDate = Date.newInstance((Date.Today().addYears(additionalYear_Month)).year(),endDate.month(),endDate.day());
            }else if (endDate!=null && endDate.monthsBetween(Date.Today())<= additionalYear_Month) {
                endDate = Date.newInstance(endDate.year(),endDate.month(),endDate.day());
            }else if (endDate!=null) {
                endDate = Date.newInstance(endDate.year(),(endDate.addMonths(additionalYear_Month)).month(),endDate.day());
            }
            else if(endDate ==  null){
                endDate = Date.newInstance(Date.today().year(),(Date.today().addMonths(additionalYear_Month)).month(),Date.today().day());
            }
            Date currentDate = Date.today();
            Integer frequencyCount = CONA_B2BConstants.FREQUENCY_COUNT_MAP.get(frequency);

            while (currentDate <= endDate) {
                Integer weekNumber = (currentDate.daysBetween(startDate) / 7);
                if (timeSlot.contains(((DateTime) currentDate).formatGMT('EEEE')) && Math.Mod(weekNumber, frequencyCount) == 0) {
                    selectedDatesList.add(currentDate);
                }
                currentDate = currentDate.addDays(1);
            }
        }
        return selectedDatesList;
    }

    /**
     * @description   gets Holidays
     * @param holidays  holidayManagement Records
     * @return `List<Date>` returns list of Dates
     */
    public static List<Date> returnHolidays(List<HolidayManagement__c> holidays) {
        List<Date> selectedHolidays = new List<Date>();
        for (HolidayManagement__c holiday : holidays) {
            if (
                holiday.ValidFrom__c != null &&
                holiday.ValidTo__c != null &&
                holiday.HolidayDate__c != null &&
                holiday.HolidayDate__c >= holiday.ValidFrom__c &&
                holiday.HolidayDate__c <= holiday.ValidTo__c
            ) {
                selectedHolidays.add(holiday.HolidayDate__c);
            }
        }

        return selectedHolidays;
    }

    /**
     * @description  gets timeZine Difference of current user with sales office
     * @param operatingHoursTimeZoneValue timezone value of operatingHours
     * @return `Integer` returns difference in hours
     */
    public static Integer getTimeZoneDifference(String operatingHoursTimeZoneValue) {
        TimeZone userTimeZone = UserInfo.getTimeZone();
        TimeZone operatingHoursTimeZone = TimeZone.getTimeZone(operatingHoursTimeZoneValue);
        Integer timezoneDifference = (userTimeZone.getOffset(System.now()) - operatingHoursTimeZone.getOffset(System.now())) / (1000 * 60);
        return timezoneDifference;
    }

    /**
     * @description gets the next available delivery date
     * @param dateWrapper send dateWrapper Object
     * @param cutOffTime  send cutoffTime
     * @return `DeliveryDatesWrapper` returns deliveryDate Wrapper
     */
    public static DeliveryDatesWrapper getNextDeliveryDate(DeliveryDatesWrapper dateWrapper, Time cutOffTime) {

        for (Date deliveryDate : dateWrapper.availableDeliveryDates) {
            if (deliveryDate >= System.today() && !dateWrapper.holidays.contains(deliveryDate)) {
                Date newdeliveryDate = deliveryDate.addDays(getNegativeValue(Integer.valueOf(dateWrapper.shippingConditions)));
                Time correctedTime = cutOffTime.addMinutes(dateWrapper.timeZoneDifference);


                Datetime deliveryDateTime = Datetime.newInstanceGmt(
                    newdeliveryDate.year(),
                    newdeliveryDate.month(),
                    newdeliveryDate.day(),
                    correctedTime.hour(),
                    correctedTime.minute(),
                    correctedTime.second()
                );


                Datetime userDateTime = getUserDateTime();
                if (userDateTime < deliveryDateTime) {
                    dateWrapper.nextDeliveryDate = deliveryDate.format();
                    dateWrapper.nextDelDate = deliveryDate;
                    dateWrapper.nextDeliveryDatetime = Datetime.newInstanceGmt(deliveryDate, correctedTime);
                    dateWrapper.nextOrderBy = (Date.newInstance(deliveryDateTime.year(), deliveryDateTime.month(), deliveryDateTime.day())).format();
                    break;
                }
            }
        }
        return dateWrapper;
    }

    /**
     * @description removes future unorderable dates
     * @param dateWrapper dateWrapper param
     * @param nextDeliveryDateTime nextDeliveryDate
     */
    private static void removeUnOrderableDates(DeliveryDatesWrapper dateWrapper, Datetime nextDeliveryDateTime){
        List<Date> filteredeDates = new List<Date>();
        List<Date> filteredFutureDates = new List<Date>();
        List<Date> filteredOffDates = new List<Date>();

        Time correctedTime = dateWrapper.cutOffTime.addMinutes(dateWrapper.timeZoneDifference);

        Datetime userDateTime = getUserDateTime();
        userDateTime.addDays(Integer.valueOf(dateWrapper.shippingConditions));

        if (dateWrapper != null && dateWrapper.availableDeliveryDates.size() > 0) {
            for (Date deliveryDate : dateWrapper.availableDeliveryDates) {
                Datetime deliveryDateTime = Datetime.newInstanceGmt(
                        deliveryDate.year(),
                        deliveryDate.month(),
                        deliveryDate.day(),
                        correctedTime.hour(),
                        correctedTime.minute(),
                        correctedTime.second()
                );

                if (deliveryDateTime >= nextDeliveryDateTime && deliveryDateTime > userDateTime) {
                    filteredeDates.add(deliveryDate);
                } 
            }
            dateWrapper.availableDeliveryDates = filteredeDates;
        }

        if (dateWrapper != null && dateWrapper.futureDeliveryDates.size() > 0) {
            for (Date deliveryDate : dateWrapper.futureDeliveryDates) {
                Datetime deliveryDateTime = Datetime.newInstanceGmt(
                        deliveryDate.year(),
                        deliveryDate.month(),
                        deliveryDate.day(),
                        correctedTime.hour(),
                        correctedTime.minute(),
                        correctedTime.second()
                );

                if (deliveryDateTime >= nextDeliveryDateTime && deliveryDateTime > userDateTime) {
                    filteredFutureDates.add(deliveryDate);
                } 
            }
            dateWrapper.futureDeliveryDates = filteredFutureDates;
        }

        if (dateWrapper != null && dateWrapper.offDays != null && dateWrapper.offDays.size() > 0) {
            for (Date deliveryDate : dateWrapper.offDays) {
                Datetime deliveryDateTime = Datetime.newInstanceGmt(
                        deliveryDate.year(),
                        deliveryDate.month(),
                        deliveryDate.day(),
                        correctedTime.hour(),
                        correctedTime.minute(),
                        correctedTime.second()
                );

                if (deliveryDateTime >= nextDeliveryDateTime && deliveryDateTime > userDateTime) {
                    filteredOffDates.add(deliveryDate);
                }
            }
            dateWrapper.offDays = filteredOffDates;
        }
    }

    /**
     * @description Check DeliveryDate exist and get result
     * @param effectiveAccountId accountId
     * @param deliveryDateString deliveryDate
     * @return ExistingDeliveryDateWrapper
     */
    private static ExistingDeliveryDateWrapper getExistingDeliveryDate(String effectiveAccountId, String deliveryDateString) {
        ExistingDeliveryDateWrapper wrapper = new ExistingDeliveryDateWrapper();
        wrapper.isScheduledDeliveryDate = false;

        if(String.isNotEmpty(deliveryDateString)) {
            Date deliveryDate = Date.valueOf(deliveryDateString);
            List<Order> orders = orderSelector.getOrderByAccountAndDeliveryDate(effectiveAccountId, deliveryDate);

            if(!orders.isEmpty()) {
                wrapper.isScheduledDeliveryDate = true;
                wrapper.userName = orders[0].CreatedBy.FirstName + ' ' + orders[0].CreatedBy.LastName;
            }
        }

        return wrapper;
    }

    /**
     * @description  method returns negative of Integer
     * @param positiveValue send positive value as param
     * @return `integer` returns negative Value
     */
    public static Integer getNegativeValue(Integer positiveValue) {
        return positiveValue * -1;
    }

    /**
     * @description parses timezone offset for user
     * @return returns userDateTime with timezoneoffset
     */
    private static Datetime getUserDateTime() {
        Datetime userDateTime = Datetime.parse(Datetime.now().format());
        Timezone usertz = UserInfo.getTimeZone();
        Integer offset = ((usertz.getOffset(userDateTime)) / 1000);
        userDateTime = userDateTime.addSeconds(offset);
        return userDateTime;
    }

    /**
     * @description wrapper sub class to send dates
     */
    public class DeliveryDatesWrapper {
        @AuraEnabled
        public list<Date> availableDeliveryDates;
        @AuraEnabled
        public list<Date> futureDeliveryDates;
        @AuraEnabled
        public list<Date> holidays;
        @AuraEnabled
        public String shippingConditions;
        @AuraEnabled
        public Integer timeZoneDifference;
        @AuraEnabled
        public String actualTime;
        @AuraEnabled
        public Time correctedTime;
        @AuraEnabled
        public String nextDeliveryDate;
        @AuraEnabled
        public String nextOrderBy;
        @AuraEnabled
        public String timeZone;
        @AuraEnabled
        public List<Date> offDays;
        @AuraEnabled
        public Date nextDelDate;

        public Datetime nextDeliveryDatetime;
        public Time cutOffTime;

        /**
         * @description default Constructor
         */
        public DeliveryDatesWrapper(){
            this.availableDeliveryDates = new List<Date>();
            this.futureDeliveryDates = new List<Date>();
            this.holidays = new List<Date>();
            this.offDays = new List<Date>();
        }
    }

    public class ExistingDeliveryDateWrapper {
        @AuraEnabled
        public String userName {get; set;}
        @AuraEnabled
        public Boolean isScheduledDeliveryDate {get; set;}
    }
}