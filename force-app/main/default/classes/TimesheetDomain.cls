public with sharing class TimesheetDomain {

    public static Map<Id, FX_Rate__c> fxRates;

    /**
     * Assigns an FX Rate to the Timesheet based on employee currency and date.
     * 
     * @param targetTimesheet The target Timesheet.
     * @param employee The employee associated with the Timesheet.
     * @return The FX Rate assigned to the Timesheet.
     */
    public static FX_Rate__c assignFXRate(
        Timesheet__c targetTimesheet,
        Contact employee
    ) {
        if(targetTimesheet.FX_Rate_Lookup__c == null) {
            for(FX_Rate__c fx : fxRates.values()) {

                if(
                    fx.Currency__c == employee.Currency__c &&
                    (
                        targetTimesheet.Date__c >= fx.Start_Date__c &&
                        targetTimesheet.Date__c <= fx.End_Date__c
                    )
                ) {

                    return fx;
                }
            }
        } else {
            if(fxRates.containsKey(targetTimesheet.FX_Rate_Lookup__c)) {
                return fxRates.get(targetTimesheet.FX_Rate_Lookup__c);
            }else{
                for(FX_Rate__c fx : fxRates.values()) {
                    if(
                        fx.Currency__c ==  employee.Currency__c &&
                        (
                            targetTimesheet.Date__c >= fx.Start_Date__c &&
                            targetTimesheet.Date__c <= fx.End_Date__c
                        )
                    ) {
                        return fx;
                    }
                }
            }
        }
        System.debug('No FX rate found: ');
        return new FX_Rate__c();
    }


    /**
     * Calculates rates for Timesheets based on certain conditions.
     * Used for Timesheet after insert Trigger.
     * 
     * @param newMap A map of new Timesheets.
     */
    public static void ratesCalculation(Map<Id, Timesheet__c> newMap){
        set<Id> employeeIds = new Set<Id>();
        Set<Id> bureauFilterForRates = new Set<Id>();
        Map<String, Date> dateFilterForRates = new Map<String, Date>();
        dateFilterForRates.put('earliestDate', null);
        dateFilterForRates.put('latestDate', null);
        List<Timesheet_Rate_Calculation__mdt> customMetadata = [
            SELECT Bureau_Name__c
            FROM Timesheet_Rate_Calculation__mdt 
        ];
        Set<String> internationalBureaus = new Set<String>();
        for(Timesheet_Rate_Calculation__mdt currentbureau : customMetadata) {
            internationalBureaus.add(currentbureau.Bureau_Name__c);
        }
        //GC 10/18/2021: New logic for preventing old timesheets to being processed
        List<Timesheet_Rate_Setting__mdt> customMetadataDate = [
            SELECT Start_Date__c
            FROM Timesheet_Rate_Setting__mdt 
        ];
        Date timesheetsStarDate;
        for(Timesheet_Rate_Setting__mdt currentDate : customMetadataDate) {
            timesheetsStarDate = currentDate.Start_Date__c;
        }
        List<Timesheet__c> newTimesheetList = newMap.values();
        for(Timesheet__c timesheet : newTimesheetList ) {
            bureauFilterForRates.add(timesheet.Bureau__c);
            employeeIds.add(timesheet.Employee__c);
            if(
                dateFilterForRates.get('earliestDate') == null ||
                timesheet.Date__c < dateFilterForRates.get('earliestDate')
            ) {
                dateFilterForRates.put('earliestDate', timesheet.Date__c);
            }
            if(
                dateFilterForRates.get('latestDate') == null ||
                timesheet.Date__c > dateFilterForRates.get('latestDate')
            ) {
                dateFilterForRates.put('latestDate', timesheet.Date__c);
            }
        }
        Map<Id, Bureau__c> bureauMap = new Map<Id, Bureau__c>(BureauSelector.selectById(bureauFilterForRates));
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(EmployeeSelector.selectById(employeeIds));
        Map<Id, Timesheet__c> internationalTimesheets = new Map<Id, Timesheet__c>();
        Map<Id, TimesheetRate__c> ratesMap = new Map<Id, TimesheetRate__c>(
            TimesheetRatesSelector.selectTimesheetBatchRates(
                bureauFilterForRates,
                dateFilterForRates.get('earliestDate'),
                dateFilterForRates.get('latestDate')
            )
        );
        List<Timesheet__c> calculatedNUTimesheets = new List<Timesheet__c>();
        List<Timesheet__c> calculatedUnionTimesheets = new List<Timesheet__c>();
        for(Timesheet__c timesheet : newMap.values()){
            //GC Devops 328 04/20/2022: Added new logic to skip calculation if Employee has "Disable Calculation = true"
            Boolean disableCalculation = employeeMap.get(timesheet.Employee__c).Disable_Calculation__c;
            if(
                internationalBureaus.contains(bureauMap.get(timesheet.Bureau__c).Name) && 
                timesheet.Date__c >= timesheetsStarDate &&
                disableCalculation == false
            ){  
                System.debug('RC: is international timesheet');
                internationalTimesheets.put(timesheet.Id, timesheet);
                continue;
            }
            Contact employee = employeeMap.get(timesheet.Employee__c);
            TimesheetRate__c targetRate = new TimesheetRate__c();
            targetRate.Bureau__c = timesheet.Bureau__c;
            targetRate.Employee_Type__c = employee.Employee_Type__c;
            targetRate.Union__c = employee.Union__c;
            targetRate.Employee_Title__c = employee.Employee_Title__c;
            //GC 10/18/2021: Added logic for skipping the Timesheet if the Date is less than the one on the Custom Metadata Type
            //GC Devops 328 04/20/2022: Added new logic to skip calculation if Employee has "Disable Calculation = true"
            if(employee.Union__c == 'NU' && timesheet.Date__c >= timesheetsStarDate && disableCalculation == false) {
                calculatedNUTimesheets.add(
                    TimeSheetDomainService.calculateNUTimesheet(timesheet, targetRate, ratesMap, employee)
                );
            //GC 10/18/2021: Added logic for skipping the Timesheet if the Date is less than the one on the Custom Metadata Type
            //GC Devops 328 04/20/2022: Added new logic to skip calculation if Employee has "Disable Calculation = true"
            }else if(employee.Union__c != 'NU' && timesheet.Date__c >= timesheetsStarDate && disableCalculation == false){
                calculatedUnionTimesheets.add(
                    TimesheetDomainService.calculateUnionTimesheet(timesheet, targetRate, ratesMap, employee)
                );
            }
        }
        if(calculatedNUTimesheets.size() > 0) {
            update calculatedNUTimesheets.deepClone(true, true, true);
        }
        if(calculatedUnionTimesheets.size() > 0) {
            update calculatedUnionTimesheets.deepClone(true, true, true);
        }
        if(internationalTimesheets.size() >= 1) {
            TimeSheetDomainService.internationalRatesCalculation(internationalTimesheets.values(), fxRates);
        }
    }

    /**
     * Updates international Timesheets based on certain conditions.
     * Used for Timesheet before update Trigger
     * 
     * @param timeSheetNewList A list of new Timesheets.
     * @param timeSheetOldMap A map of old Timesheets.
     */
    public static void updateInternationalTimesheet(
        List<Timesheet__c> timeSheetNewList, 
        Map<id,Timesheet__c> timeSheetOldMap    
    ) {
        Map<Id, TimesheetRate__c> allTimeSheetRates= new Map<Id, TimesheetRate__c>();
        Map<Id, Contact> allEmployeesMap = new Map<Id, Contact>();
        //holiday maps uses Bureau Id for key set
        Map<Id, Map<String, HolidayCustom__c>> holidaysMap = new Map<Id, Map<String, HolidayCustom__c>>();
        //Timesheet Id - Location Id
        Map<Id, Id> timesheetWithLocationMap = new Map<Id, Id>();
        Map<Id, Bureau__c> allBureausMap = new Map<Id, Bureau__c>();
        Map<Id, Location__c> allLocationMap = new Map<Id, Location__c>();
        set<id> employeeIds = new set<Id>();
        set<id> bureauIds =new set<Id>();
        Set<String> internationalBureauNames = new Set<String>();
        //GC 10/29/2021: New variables to hold the value from FX Rate.
        Id fxRateId;
        Boolean fxRateActive;
        Date fxRateStartDate;
        Date fxRateEndDate;
        Double fxRateValue;
        Boolean fxRateActiveByDate;
        Date fxRateStartDateByDate;
        Date fxRateEndDateByDate;
        Double fxRateValueByDate;
        String fxCurrency;
        Set<Id> timesheetIdSet = new Set<Id>();
        Date fxEarliestDate;
        Date fxLatestDate;
        List<Timesheet_Rate_Calculation__mdt> timesheetCustomMetadata = [
                SELECT Bureau_Name__c 
                FROM Timesheet_Rate_Calculation__mdt
            
            ];


        for(Timesheet_Rate_Calculation__mdt bureau : timesheetCustomMetadata) {
            internationalBureauNames.add(bureau.Bureau_Name__c);
        }

           Date timesheetsStarDate = Timesheet_Rate_Setting__mdt.getInstance('Start_Date').Start_Date__c;
           
        for(Timesheet__c timesheet: timeSheetNewList) {

            bureauIds.add(timesheet.Bureau__c);
            holidaysMap.put(timesheet.Bureau__c, new Map<String, HolidayCustom__c>());
            employeeIds.add(timesheet.Employee__c);
            timesheetIdSet.add(timesheet.Id);
            if(fxEarliestDate == null) fxEarliestDate = timesheet.Date__c;
            if(fxLatestDate == null) fxLatestDate = timesheet.Date__c;
            fxEarliestDate = timesheet.Date__c < fxEarliestDate ? timesheet.Date__c : fxEarliestDate;
            fxLatestDate = timesheet.Date__c > fxLatestDate ? timesheet.Date__c : fxLatestDate;
        }
        List<Timesheet__c> timesheetsWithLocation = [
            SELECT Id, Story_Employee_Association__r.Story_Schedule_Association__r.Location__c
            FROM Timesheet__c
            WHERE Id IN: timesheetIdSet
        ];
        Set<Id> locationIdSet = new Set<Id>();
        for(Timesheet__c timesheet : timesheetsWithLocation) {
            locationIdSet.add(timesheet.Story_Employee_Association__r.Story_Schedule_Association__r.Location__c);
            timesheetWithLocationMap.put(timesheet.id, timesheet.Story_Employee_Association__r.Story_Schedule_Association__r.Location__c);
        }
        allBureausMap.putAll(BureauSelector.selectById(bureauIds));
        allEmployeesMap.putAll(EmployeeSelector.selectById(employeeIds));
        allTimeSheetRates.putAll(TimesheetRatesSelector.selectByBureauId(bureauIds));
        allLocationMap.putAll(LocationSelector.selectById(locationIdSet));
        List<HolidayCustom__c> customHolidays = [
           SELECT Bureau__c, Name, Date__c 
           FROM HolidayCustom__c
           WHERE Bureau__c IN: bureauIds
        ];
        for(HolidayCustom__c holiday : customHolidays){
            holidaysMap.get(holiday.Bureau__c).put(
                holiday.Date__c.format(), 
                holiday
            );
        }
        //GC 10/29/2021: New logic: FX Rate
        List<FX_Rate__c> fXRate = new List<FX_Rate__c>(); 
        fXRate = [
           SELECT Id, FX_Rate__c, Start_Date__c, End_Date__c, CreatedDate, Currency__c
           FROM FX_Rate__c
           WHERE Start_Date__c <=: fxEarliestDate
           AND End_Date__c >=: fxLatestDate
           ORDER BY CreatedDate DESC
        ];
        fxRates = new Map<Id,FX_Rate__c>(fXRate);
        for(Timesheet__c currentTimesheet : timeSheetNewList){
            Contact currentEmployee = allEmployeesMap.get(currentTimesheet.Employee__c);
            System.debug('Looping timesheets');
            Boolean disableCalculation = allEmployeesMap.get(currentTimesheet.Employee__c).Disable_Calculation__c;
            if(
                currentTimesheet.Automated_Process__c ||
                !internationalBureauNames.contains(allBureausMap.get(currentTimesheet.Bureau__c).Name) ||
                currentTimesheet.Date__c < timesheetsStarDate ||
                disableCalculation == true
            ){
                System.debug(currentTimesheet.Automated_Process__c);
                System.debug(!internationalBureauNames.contains(allBureausMap.get(currentTimesheet.Bureau__c).Name));
                System.debug(currentTimesheet.Date__c < timesheetsStarDate);
                System.debug(disableCalculation == true);
                continue;
            }
            
            Location__c currentTimesheetLocation = new Location__c();
            currentTimesheetLocation = allLocationMap.get(
                timesheetWithLocationMap.get(
                    currentTimesheet.Id
                )
            );
            String isSpecificLocation;
            isSpecificLocation = currentTimesheetLocation?.Is_Specific_Location__c;

            Map<String, HolidayCustom__c> currentBureauHolidays = new Map<String, HolidayCustom__c>();
            currentBureauHolidays = holidaysMap.get(currentTimesheet.Bureau__c);
            if (
                currentBureauHolidays.containsKey(currentTimesheet.Date__c.format()) &&
                currentBureauHolidays.get(currentTimesheet.Date__c.format()).Bureau__c == currentTimesheet.Bureau__c
                ){
                    if (
                        currentBureauHolidays.get(currentTimesheet.Date__c.format()).Name.containsignorecase('Christmas') || 
                        currentBureauHolidays.get(currentTimesheet.Date__c.format()).Name.containsignorecase('New Year')
                    ) {
                            currentTimesheet.Christams_New_Year_TIme__c = true;
                    }else {
                        currentTimesheet.Christams_New_Year_TIme__c = false;
                        currentTimesheet.Bank_Holiday_Time__c = true;
                }
            }

            Datetime dt =  DateTime.newInstance(currentTimesheet.Date__c, Time.newInstance(0, 0, 0, 0));             
            String dayOfWeek = dt.format('EEEE');
            if ((dayOfWeek == 'Saturday' ||  dayOfWeek =='Sunday') &&
                currentTimesheet.Bank_Holiday_Time__c == false &&
                currentTimesheet.Christams_New_Year_TIme__c == false) {
                currentTimesheet.Weekend_Time__c = true;
            }else {
                currentTimesheet.Weekend_Time__c = false;
            }

            TimesheetRate__c timesheetRate = new TimesheetRate__c();

            for (TimesheetRate__c currentTimeSheetRate : allTimeSheetRates.values()) {
                if (
                    TimeSheetDomainService.isValidTimesheetRate(currentTimeSheetRate, currentTimesheet, allEmployeesMap) ||
                    TimeSheetDomainService.isGenericTimesheetRate(currentTimeSheetRate, currentTimesheet, allEmployeesMap)) {
                        timesheetRate = currentTimeSheetRate;
                }
            
            }


            if(timesheetRate.Id != null ) {
                if(currentTimesheet.Timesheet_Rate__c == null){
                    currentTimesheet.Timesheet_Rate__c = timeSheetRate.id;
                }

                FX_Rate__c fxRateFound = assignFXRate(currentTimesheet, currentEmployee);
                if(fxRateFound.Id != null) {
                    currentTimesheet.FX_Rate_Lookup__c = fxRateFound.Id;
                    fxRateValue = fxRateFound.FX_Rate__c > 0 ? fxRateFound.FX_Rate__c : 1;
                    fxRateStartDate = fxRateFound.Start_Date__c;
                    fxRateEndDate = fxRateFound.End_Date__c;
                } else {
                    fxRateValue = 1;
                }
                

                TimeSheetDomainService.TimeSheetWrapper straightTimeWrapper = new TimeSheetDomainService.TimeSheetWrapper();
                straightTimeWrapper.currentTimeSheet = currentTimeSheet;
                straightTimeWrapper.timeSheetRate = timesheetRate;
                straightTimeWrapper.timeSheetMap = timeSheetOldMap;
                straightTimeWrapper.fXRate = fxRateValue;
                
                //Calculating Straight Time Cost
                currentTimesheet.Straight_Time_Cost__c = TimeSheetDomainService.calculateStraightCost(straightTimeWrapper, isSpecificLocation, allBureausMap, currentTimesheetLocation);
                
                //List compuest by Field to Update (TimeSheet Cost) - TimeSheet Rate Field - TimeSheet Payroll section field.
                List<List<String>> fieldsToUpdate = new List<List<String>>{
                    new List<String>{'Foreign_Rates_Cost__c', 'Foreign_Rates__c', 'Foreign_Rates__c'},
                    new List<String>{'Holiday_Pay_100_Cost__c', 'Holiday_Pay_100__c', 'Holiday_Pay_100__c'},
                    new List<String>{'Holiday_Pay_200_Cost__c', 'Holiday_Pay_200__c', 'Holiday_Pay_200__c'},
                    new List<String>{'Holiday_Pay_50_Cost__c', 'Holiday_Pay_50__c', 'Holiday_Pay_50__c'},
                    new List<String>{'Meal_Penalties_Cost__c', 'Meal_Penalties__c', 'Meal_Penalties__c'},
                    new List<String>{'Night_Differential_Cost__c', 'Night_Differential__c', 'Night_Differential__c'},
                    new List<String>{'Vacation_Allowance_Cost__c', 'Vacation_Allowance__c', 'Vacation_Allowance__c'},
                    new List<String>{'Rest_Penalty_Cost__c', 'Rest_Penalty__c', 'Rest_Penalty__c'},
                    new List<String>{'Penalty_Time_Cost__c', 'Penalty_Rate__c', 'Penalty_Time__c'},
                    new List<String>{'Overnight_Cost__c', 'Overnight__c', 'Overnight__c'},
                    new List<String>{'X6_7_Days_Total__c', 'X6_7_Days__c', 'X6_7_Days__c'},
                    new List<String>{'Over_Time_Cost__c', 'Over_Time_Rate__c', 'Over_Time__c'},
                    new List<String>{'Out_of_Town_Flat_Day_Cost__c', 'Out_of_Town_Flat_Day_rate__c', 'Out_of_Town_Flat_Time__c'},
                    new List<String>{'Premium_Time_Cost__c', 'Premium_Time__c', 'Premium_Time__c'}
                };
                
                //Fields that needs FX Rate in the calculate.
                List<String> fieldsWithFXRate = new List<String>{
                    'X6_7_Days_Total__c',
                    'Overnight_Cost__c',
                    'Over_Time_Cost__c',
                    'Out_of_Town_Flat_Day_Cost__c'
                };

                TimeSheetDomainService.TimeSheetWrapper timeWrapper = new TimeSheetDomainService.TimeSheetWrapper();
                timeWrapper.currentTimeSheet = currentTimeSheet;
                timeWrapper.timeSheetRate = timesheetRate;
                timeWrapper.timeSheetMap = timeSheetOldMap;
                timeWrapper.fxRate = 1;

                String timeSheetCostField; 
                String timeSheetRateField;
                String timeSheetPayrollField;


                for(List<String> field : fieldsToUpdate){
                    timeSheetCostField = field[0];
                    timeSheetRateField = field[1];
                    timeSheetPayrollField = field[2];
                    
                    if(fieldsWithFXRate.contains(timeSheetCostField)){
                        timeWrapper.fxRate = fxRateValue;
                    }
                    
                    currentTimesheet.put(timeSheetCostField, TimeSheetDomainService.calculateCost(timeWrapper, timeSheetCostField, timeSheetRateField, timeSheetPayrollField));

                }
                

            }
        }
    }


    
}