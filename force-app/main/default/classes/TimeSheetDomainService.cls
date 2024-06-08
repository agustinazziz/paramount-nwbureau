public with sharing class TimeSheetDomainService {

    /**
     * Calculates the cost for a specific field in the Timesheet if the payroll field is changed and TimesheetRate field is not null.
     * 
     * @param timeWrapper The wrapper containing Timesheet information.
     * @param timeSheetCostField The field for which the cost is calculated.
     * @param timeSheetRateField The field used for the rate calculation.
     * @param timeSheetPayrollField The field used for payroll information.
     * @return The calculated cost.
     */
    public static Decimal calculateCost(
        TimeSheetWrapper timeWrapper,
        String timeSheetCostField,
        String timeSheetRateField,
        String timeSheetPayrollField
    ) {
        Timesheet__c currentTimeSheet = timeWrapper.currentTimeSheet;
        TimesheetRate__c timeSheetRate = timeWrapper.timeSheetRate;
        Map<Id, Timesheet__c> timeSheetMap = timeWrapper.timeSheetMap;
        Decimal fxRate = timeWrapper.fxRate;
    
        System.debug('COME ONNNN');
        System.debug(currentTimesheet.get(timeSheetPayrollField));

        if (timeSheetRate.get(timeSheetRateField) == null ||
            currentTimesheet.get(timeSheetPayrollField) == null) {
            return null;
        }
    
        if (timeSheetMap == null ||
            currentTimeSheet.get(timeSheetCostField) == timeSheetMap.get(currentTimeSheet.Id).get(timeSheetCostField) &&
            currentTimeSheet.get(timeSheetPayrollField) != timeSheetMap.get(currentTimeSheet.Id).get(timeSheetPayrollField)) {
    
            System.debug('LOGGGGG');
            System.debug(timeSheetPayrollField);
            System.debug(timeSheetRate);
            System.debug(fxRate);    
            return ((Decimal)currentTimeSheet.get(timeSheetPayrollField) * (Decimal)timeSheetRate.get(timeSheetRateField) * fxRate);
        }
    
        return (Decimal)currentTimeSheet.get(timeSheetCostField);
    }

    /**
     * Calculates the straight cost for a Timesheet based on certain conditions.
     * 
     * @param timeWrapper The wrapper containing Timesheet information.
     * @param isSpecificLocation Indicates if the location is specific.
     * @param allBureausMap A map of all bureaus.
     * @param currentTimesheetLocation The current location of the Timesheet.
     * @return The calculated straight cost.
     */
    public static Decimal calculateStraightCost(
            TimeSheetWrapper timeWrapper,
            String isSpecificLocation,
            Map<Id, Bureau__c> allBureausMap,
            Location__c currentTimesheetLocation
         ){
        Timesheet__c currentTimesheet = timeWrapper.currentTimeSheet;
        TimesheetRate__c timeSheetRate = timeWrapper.timeSheetRate;
        Map<Id, Timesheet__c> timeSheetOldMap = timeWrapper.timeSheetMap;
        Decimal fxRateValue = timeWrapper.fxRate;
        
        if(
            
            timeSheetOldMap == null ||
            (currentTimesheet.Straight_Time_Cost__c == timeSheetOldMap.get(currentTimesheet.Id).Straight_Time_Cost__c &&
            currentTimesheet.Straight_Time__c != timeSheetOldMap.get(currentTimesheet.Id).Straight_Time__c) 
        ){   
            System.debug('Meeting conditions for calculation');
            //GC BUG 341 - 04/28/2022: Added logic to skip if values to calculate are null.
            if (currentTimesheet.Straight_Time__c != null) {
                Decimal rate = null;
                
                if (currentTimesheet.Bank_Holiday_Time__c && timeSheetRate.Bank_Holiday_Rate__c != null) {

                    rate = timeSheetRate.Bank_Holiday_Rate__c;

                } else if (currentTimesheet.Christams_New_Year_TIme__c && timeSheetRate.Christams_New_Day_Rate__c != null) {
                    
                    rate = timeSheetRate.Christams_New_Day_Rate__c;
                    
                } else if (currentTimesheet.Weekend_Time__c && !currentTimesheet.Bank_Holiday_Time__c && !currentTimesheet.Christams_New_Year_TIme__c) {
                    
                    if (allBureausMap.get(currentTimesheet.Bureau__c).Name == 'LONDON/EUROPEAN OPERATIONS') {
                     
                        if (isSpecificLocation != null && timeSheetRate.Weekend_Rate__c != null && currentTimesheetLocation.Is_Specific_Location__c == 'LONDON') {
                     
                            rate = timeSheetRate.Weekend_Rate__c;
                     
                        } else if (isSpecificLocation == null && timeSheetRate.Out_of_Town_Flat_Day_rate__c != null && timeSheetRate.Out_of_Town_Flat_Day_rate__c != 0) {
                     
                            rate = timeSheetRate.Out_of_Town_Flat_Day_rate__c;
                        }
                    }
                } else {
                  
                    if (allBureausMap.get(currentTimesheet.Bureau__c).Name == 'LONDON/EUROPEAN OPERATIONS') {
                  
                        if (isSpecificLocation != null && timeSheetRate.Weekday_Rate__c != null && currentTimesheetLocation.Is_Specific_Location__c == 'LONDON') {
                        
                            rate = timeSheetRate.Weekday_Rate__c;
                        
                        } else if (isSpecificLocation == null && timeSheetRate.Out_of_Town_Flat_Day_rate__c != null && timeSheetRate.Out_of_Town_Flat_Day_rate__c != 0) {
                        
                            rate = timeSheetRate.Out_of_Town_Flat_Day_rate__c;
                        
                        }
                    }
                }
                
                if (rate != null) {
                    return (currentTimesheet.Straight_Time__c * rate) * fxRateValue;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        }            
        return currentTimesheet.Straight_Time_Cost__c;
    }


    /**
     * Calculates the Night Unit (NU) Timesheet based on certain conditions.
     * 
     * @param timesheet The timesheet to calculate.
     * @param targetRate The target rate for the timesheet.
     * @param ratesMap A map of rates.
     * @param employee The employee associated with the timesheet.
     * @return The calculated Night Unit (NU) Timesheet.
     */
    public static Timesheet__c calculateNUTimesheet(
        Timesheet__c timesheet,
        TimesheetRate__c targetRate,
        Map<Id, TimesheetRate__c> ratesMap,
        Contact employee
    ) {
        //GC 09/22/2021: New field "Overnight" added
        if(
            timesheet.Automated_Process__c == true ||
            timesheet.Foreign_Rates_Cost__c != null ||
            timesheet.Holiday_Pay_100_Cost__c != null ||
            timesheet.Holiday_Pay_200_Cost__c != null ||
            timesheet.Holiday_Pay_50_Cost__c != null ||
            timesheet.Meal_Penalties_Cost__c != null ||
            timesheet.Night_Differential_Cost__c != null ||
            timesheet.Over_Time_Cost__c != null ||
            timesheet.Penalty_Time_Cost__c != null ||
            timesheet.Straight_Time_Cost__c != null ||
            timesheet.Vacation_Allowance_Cost__c != null ||
            timesheet.Overnight_Cost__c != null
        ) {
            return timesheet;
        }
        List<Timesheet__c> timesheetClones = new List<Timesheet__c>();
        TimesheetRate__c specificTimesheetRate = new TimesheetRate__c();
        TimesheetRate__c genericTimesheetRate = new TimesheetRate__c();
        TimesheetRate__c rate = new TimesheetRate__c();
        for(TimesheetRate__c currentRate : ratesMap.values()) {
            if(validateRate(targetRate, currentRate, timesheet)){
                rate = currentRate;
            }
        }
        if(rate.Id != null) {
            Timesheet__c timesheetClone = timesheet.clone(true, true, true, true);
            if(employee.Employee_Type__c == 'Freelancer') {
                timesheetClone.Fringe__c = rate.Foreign_Rates__c;
            }

            List<List<String>> fieldsToUpdate = new List<List<String>>{
                new List<String>{'Straight_Time_Cost__c', 'Straight_Time__c', 'Straight_Time__c'},
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

            TimeSheetWrapper timeWrapper = new TimeSheetWrapper();
            timeWrapper.currentTimeSheet = timesheetClone;
            timeWrapper.timeSheetRate = rate;
            timeWrapper.employee = employee;

            for (List<String> field : fieldsToUpdate ){

                timesheetClone.put(field[0], calculateNUTTimesheetCost(timeWrapper, field[0], field[1], field[2]));
            }
            return timesheetClone;
        } else {
            System.debug('No rate found for timesheet ' + timesheet + 'no process done!' );
            return timesheet;
        }
    }

    /**
     * Calculates the Night Unit (NU) Timesheet cost based on certain conditions.
     * 
     * @param timeWrapper The time wrapper containing necessary data.
     * @param timeSheetCostField The field representing the timesheet cost.
     * @param timeSheetRateField The field representing the timesheet rate.
     * @param timeSheetPayrollField The field representing the timesheet payroll.
     * @return The calculated Night Unit (NU) Timesheet cost.
     */
    private static Decimal calculateNUTTimesheetCost(
        TimeSheetWrapper timeWrapper,
        String timeSheetCostField,
        String timeSheetRateField,
        String timeSheetPayrollField
    ) {
        Timesheet__c timesheet = timeWrapper.currentTimeSheet;
        TimesheetRate__c rate = timeWrapper.timeSheetRate;
        Contact employee = timeWrapper.employee;


        if(
            timesheet.get(timeSheetPayrollField) != null &&
            rate.get(timeSheetRateField) != null &&
            timesheet.get(timeSheetCostField) == null
        ) {
            if(employee.Employee_Type__c == 'Freelancer' && rate.Fringe__c != null && rate.Fringe__c != 0) {
                return ((Decimal)timesheet.get(timeSheetPayrollField) * (Decimal)rate.get(timeSheetRateField)) * (1 + (rate.Fringe__c / 100));
            } else {
                return (Decimal)rate.get(timeSheetRateField) * (Decimal)timesheet.get(timeSheetPayrollField);
            }
        }
        return timesheet.Premium_Time_Cost__c;
    }

    /**
     * Checks if the provided timesheet rate is valid based on certain conditions.
     * 
     * @param rate The timesheet rate to validate.
     * @param timesheet The timesheet associated with the rate.
     * @param allEmployeesMap A map containing all employees.
     * @return True if the timesheet rate is valid, false otherwise.
     */
    public static boolean isValidTimesheetRate(TimesheetRate__c rate, Timesheet__c timesheet, Map<Id,Contact> allEmployeesMap) {
        Contact employee = allEmployeesMap.get(timesheet.Employee__c);
        return rate.Employee_Title__c != null &&
               rate.Bureau__c.equals(timesheet.Bureau__c) &&
               rate.Employee_Title__c.equals(employee.Employee_Title__c) &&
               rate.Employee_Type__c.equals(employee.Employee_Type__c) &&
               rate.Union__c.equals(employee.Union__c) &&
               timesheet.Date__c >= rate.Start_Date__c &&
               timesheet.Date__c <= rate.End_Date__c;
    }
    
    /**
     * Checks if the provided timesheet rate is a generic rate based on certain conditions.
     * 
     * @param rate The timesheet rate to check.
     * @param timesheet The timesheet associated with the rate.
     * @param allEmployeesMap A map containing all employees.
     * @return True if the timesheet rate is generic, false otherwise.
     */
    public static boolean isGenericTimesheetRate(TimesheetRate__c rate, Timesheet__c timesheet, Map<Id,Contact> allEmployeesMap) {
        Contact employee = allEmployeesMap.get(timesheet.Employee__c);
        return rate.Bureau__c.equals(timesheet.Bureau__c) &&
               rate.Employee_Type__c.equals(employee.Employee_Type__c) &&
               rate.Union__c.equals(employee.Union__c) &&
               timesheet.Date__c >= rate.Start_Date__c &&
               timesheet.Date__c <= rate.End_Date__c &&
               rate.Employee_Title__c == null;
    }

    /**
     * Validates if the current rate matches the target rate based on certain conditions.
     * 
     * @param targetRate The target timesheet rate to match against.
     * @param currentRate The current timesheet rate to validate.
     * @param timesheet The timesheet associated with the rates.
     * @return True if the current rate is valid, false otherwise.
     */
    public static boolean validateRate(TimesheetRate__c targetRate, TimesheetRate__c currentRate, Timesheet__c timesheet) {
        if(
            currentRate.Employee_Title__c != null &&
            (targetRate.Employee_Title__c == currentRate.Employee_Title__c &&
            targetRate.Bureau__c == currentRate.Bureau__c &&
            targetRate.Employee_Type__c == currentRate.Employee_Type__c &&
            targetRate.Union__c == currentRate.Union__c &&
            timesheet.Date__c >= currentRate.Start_Date__c &&
            timesheet.Date__c <= currentRate.End_Date__c)
        ){
            return true;
        }else if (
            targetRate.Bureau__c == currentRate.Bureau__c &&
            targetRate.Employee_Type__c == currentRate.Employee_Type__c &&
            targetRate.Union__c == currentRate.Union__c &&
            timesheet.Date__c >= currentRate.Start_Date__c &&
            timesheet.Date__c <= currentRate.End_Date__c &&
            currentRate.Employee_Title__c == null
        ){
            return true;
        }

        return false; 
    }

    /**
     * Calculates international rates for the given list of timesheets.
     * 
     * @param timeSheetNewList The list of timesheets to calculate international rates for.
     * @param fxRates The map of FX rates.
     */
    public static void internationalRatesCalculation(List<Timesheet__c> timeSheetNewList, Map<Id, FX_Rate__c> fxRates) {
        
        //holiday maps uses Bureau Id for key set
        Map<Id, Map<String, HolidayCustom__c>> holidaysMap = new Map<Id, Map<String, HolidayCustom__c>>();
        //Timesheet Id - Location Id
        Map<Id, Id> timesheetWithLocationMap = new Map<Id, Id>();
        Map<Id, TimesheetRate__c> allTimeSheetRates= new Map<Id, TimesheetRate__c>();
        Map<Id, Contact> allEmployeesMap = new Map<Id, Contact>();
        Map<Id, Bureau__c> allBureausMap = new Map<Id, Bureau__c>();
        Map<Id, Location__c> allLocationMap = new Map<Id, Location__c>();
        set<id> employeeIds = new set<Id>();
        set<id> bureauIds =new set<Id>();
        Set<String> internationalBureauNames = new Set<String>();
        //GC 10/29/2021: New variables to hold the value from FX Rate.
        List<FX_Rate__c> fxRatesList = new List<FX_Rate__c>();
        Id fxRateId;
        Boolean fxRateActive;
        Date fxRateStartDate;
        Date fxRateEndDate;
        Double fxRateValue;
        Date fxEarliestDate;
        Date fxLatestDate;
        List<Timesheet_Rate_Calculation__mdt> timesheetCustomMetadata = 
            [SELECT Bureau_Name__c FROM Timesheet_Rate_Calculation__mdt];
        for(Timesheet_Rate_Calculation__mdt bureau : timesheetCustomMetadata) {
            internationalBureauNames.add(bureau.Bureau_Name__c);
        }
        Set<Id> timesheetIdSet = new Set<Id>();
        //GC 10/29/2021: New logic: FX Rate
        for(Timesheet__c timesheet: timeSheetNewList) {
            bureauIds.add(timesheet.Bureau__c);
            holidaysMap.put(timesheet.Bureau__c, new Map<String, HolidayCustom__c>());
            employeeIds.add(timesheet.Employee__c);
            timesheetIdSet.add(timesheet.Id);
        }
        List<Timesheet__c> timesheetsWithLocation = [
            SELECT Id, Story_Employee_Association__r.Story_Schedule_Association__r.Location__c, 
                   Date__c
            FROM Timesheet__c
            WHERE Id IN: timesheetIdSet
        ];
        Set<Id> locationIdSet = new Set<Id>();
        for(Timesheet__c timesheet : timesheetsWithLocation) {
            locationIdSet.add(timesheet.Story_Employee_Association__r.Story_Schedule_Association__r.Location__c);
            timesheetWithLocationMap.put(timesheet.id, timesheet.Story_Employee_Association__r.Story_Schedule_Association__r.Location__c);
            if(fxEarliestDate == null) fxEarliestDate = timesheet.Date__c;
            if(fxLatestDate == null) fxLatestDate = timesheet.Date__c;
            fxEarliestDate = timesheet.Date__c < fxEarliestDate ? timesheet.Date__c : fxEarliestDate;
            fxLatestDate = timesheet.Date__c > fxLatestDate ? timesheet.Date__c : fxLatestDate;
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
        System.debug('customHolidays: ' + customHolidays);
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
        TimesheetDomain.fxRates = new Map<Id,FX_Rate__c>(fXRate);

        List<Timesheet__c> clonedTimesheets = new List<Timesheet__c>();
        for(Timesheet__c timesheet : timeSheetNewList){
            Timesheet__c currentTimesheet = timesheet.clone(true, true, true, true);
            Contact currentEmployee = allEmployeesMap.get(currentTimesheet.Employee__c);
            if( !internationalBureauNames.contains(allBureausMap.get(currentTimesheet.Bureau__c).Name) ) {
                continue;
            }
            Map<String, HolidayCustom__c> currentBureauHolidays = new Map<String, HolidayCustom__c>();
            currentBureauHolidays = holidaysMap.get(currentTimesheet.Bureau__c);
            Location__c currentTimesheetLocation = new Location__c();
            currentTimesheetLocation = allLocationMap.get(
                timesheetWithLocationMap.get(
                    currentTimesheet.Id
                )
            );
            System.debug('RC currentTimesheetLocation ' + currentTimesheetLocation);
            String isSpecificLocation;
            if(currentTimesheetLocation.Is_Specific_Location__c !=null) {
                isSpecificLocation = currentTimesheetLocation.Is_Specific_Location__c;
            }

            System.debug('currentBureauHolidays: ' + currentBureauHolidays);
            if(
                currentBureauHolidays.containsKey(currentTimesheet.Date__c.format()) &&
                currentBureauHolidays.get(currentTimesheet.Date__c.format()).Bureau__c == currentTimesheet.Bureau__c 
            ) {
                if(
                    currentBureauHolidays.get(currentTimesheet.Date__c.format()).Name.containsignorecase('Christmas') || 
                    currentBureauHolidays.get(currentTimesheet.Date__c.format()).Name.containsignorecase('New Year')
                ){
                    currentTimesheet.Christams_New_Year_TIme__c = true;
                }else{
                    currentTimesheet.Christams_New_Year_TIme__c = false;
                    currentTimesheet.Bank_Holiday_Time__c = true;
                }
            }
            //GC 10/29/2021: Adds the fXRate value to the lookup if found
            if(!fXRate.isEmpty()){
                
                FX_Rate__c fxRateFound = TimesheetDomain.assignFXRate(currentTimesheet, currentEmployee);
                if(fxRateFound.Id != null) {
                    currentTimesheet.FX_Rate_Lookup__c = fxRateFound.Id;
                    fxRateValue = fxRateFound.FX_Rate__c == null ? 1 : fxRateFound.FX_Rate__c;
                    fxRateStartDate = fxRateFound.Start_Date__c;
                    fxRateEndDate = fxRateFound.End_Date__c;
                } else {
                    fxRateValue = 1;
                }
            } else{
                fxRateValue = 1;

            } 
            Datetime dt =  DateTime.newInstance(currentTimesheet.Date__c, Time.newInstance(0, 0, 0, 0));             
            String dayOfWeek = dt.format('EEEE');
            if( 
                (dayOfWeek == 'Saturday' ||  dayOfWeek =='Sunday') &&
                currentTimesheet.Bank_Holiday_Time__c == false &&
                currentTimesheet.Christams_New_Year_TIme__c == false
            ){
                currentTimesheet.Weekend_Time__c=true;
            }else{
                currentTimesheet.Weekend_Time__c=false;
            }
            TimesheetRate__c specificTimesheetRate = new TimesheetRate__c();
            TimesheetRate__c genericTimesheetRate = new TimesheetRate__c();
            TimesheetRate__c timesheetRate = new TimesheetRate__c();
            for(TimesheetRate__c currentTimeSheetRate : allTimeSheetRates.values()){
                if(
                    currentTimeSheetRate.Employee_Title__c != null &&
                    ( 
                        currentTimesheet.Bureau__c.equals(currentTimeSheetRate.Bureau__c) && 
                        currentTimeSheetRate.Employee_Title__c.equals(allEmployeesMap.get(currentTimesheet.Employee__c).Employee_Title__c) && 
                        currentTimeSheetRate.Employee_Type__c.equals(allEmployeesMap.get(currentTimesheet.Employee__c).Employee_Type__c) &&
                        currentTimeSheetRate.Union__c.equals(allEmployeesMap.get(currentTimesheet.Employee__c).Union__c) &&
                        currentTimesheet.Date__c >= currentTimeSheetRate.Start_Date__c &&
                        currentTimesheet.Date__c <= currentTimeSheetRate.End_Date__c
                    ) 
                ){
                    specificTimesheetRate = currentTimeSheetRate;
                }

                if(
                    currentTimesheet.Bureau__c.equals(currentTimeSheetRate.Bureau__c) && 
                    currentTimeSheetRate.Employee_Type__c.equals(allEmployeesMap.get(currentTimesheet.Employee__c).Employee_Type__c) &&
                    currentTimeSheetRate.Union__c.equals(allEmployeesMap.get(currentTimesheet.Employee__c).Union__c) &&
                    currentTimesheet.Date__c >= currentTimeSheetRate.Start_Date__c &&
                    currentTimesheet.Date__c <= currentTimeSheetRate.End_Date__c &&
                    currentTimeSheetRate.Employee_Title__c == null
                ){
                    genericTimesheetRate = currentTimeSheetRate;
                }
            }
            if(specificTimesheetRate.Id != null) {
                timesheetRate = specificTimesheetRate;
                System.debug('Specific timesheet Rate Found!');
            }
            if(specificTimesheetRate.Id == null && genericTimesheetRate.Id != null) {
                timesheetRate = genericTimesheetRate;
                System.debug(timesheetRate.Id);
                System.debug('Generic timesheet Rate Found!');
            }
            if(timesheetRate.Id == null) {
                System.debug('No international timesheet Rate Found!');
            }
            if(timesheetRate.Id != null) {
                if(currentTimesheet.Timesheet_Rate__c == null){
                    currentTimesheet.Timesheet_Rate__c = timeSheetRate.id;
                }
                //GC BUG 341 - 04/28/2022: Added logic to skip if values to calculate are null.
                if(
                    //timeSheetRate.Weekday_Rate__c != null && currentTimesheet.Straight_Time__c != null
                    currentTimesheet.Straight_Time__c != null &&
                    ((currentTimesheet.Bank_Holiday_Time__c && timeSheetRate.Bank_Holiday_Rate__c != null) ||
                    (currentTimesheet.Christams_New_Year_TIme__c && timeSheetRate.Christams_New_Day_Rate__c != null) || 
                    (currentTimesheet.Weekend_Time__c && timeSheetRate.Weekend_Rate__c != null) || 
                    (!currentTimesheet.Bank_Holiday_Time__c && !currentTimesheet.Christams_New_Year_TIme__c && 
                     !currentTimesheet.Weekend_Time__c && timeSheetRate.Weekday_Rate__c != null) ||
                    (allBureausMap.get(currentTimesheet.Bureau__c).Name == 'LONDON/EUROPEAN OPERATIONS' &&
                     isSpecificLocation == null && 
                     timeSheetRate.Out_of_Town_Flat_Day_rate__c != null))
                ){

                    TimeSheetDomainService.TimeSheetWrapper straightTimeWrapper = new TimeSheetDomainService.TimeSheetWrapper();
                    straightTimeWrapper.currentTimeSheet = currentTimeSheet;
                    straightTimeWrapper.timeSheetRate = timesheetRate;
                    straightTimeWrapper.fXRate = fxRateValue;
                    
                    //Calculating Straight Time Cost
                    currentTimesheet.Straight_Time_Cost__c = TimeSheetDomainService.calculateStraightCost(straightTimeWrapper, isSpecificLocation, allBureausMap, currentTimesheetLocation);
                    
                }

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
                    new List<String>{'Over_Time_Cost__c', 'Over_Time_Rate__c', 'Over_Time__c'},
                    new List<String>{'Out_of_Town_Flat_Day_Cost__c', 'Out_of_Town_Flat_Day_rate__c', 'Out_of_Town_Flat_Time__c'}
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
                    
                    currentTimesheet.put(timeSheetCostField, calculateCost(timeWrapper, timeSheetCostField, timeSheetRateField, timeSheetPayrollField));

                }

                if(
                    (
                        timeSheetRate.X6_7_Days__c != null &&
                        timeSheetRate.X6_7_Days__c != 0
                    ) &&
                    currentTimesheet.X6_7_Days__c == null &&
                    allBureausMap.get(currentTimesheet.Bureau__c).Name == 'LONDON/EUROPEAN OPERATIONS' &&
                    (
                        currentTimesheet.Weekend_Time__c == true ||
                        currentTimesheet.Bank_Holiday_Time__c == true
                    )
                 ) {
                    currentTimesheet.X6_7_Days__c = 1;
                }

                if(
                    timeSheetRate.X6_7_Days__c != null &&
                    currentTimesheet.X6_7_Days__c != null &&
                    currentTimesheet.X6_7_Days_Total__c == null
                ){
                    //GC 10/29/2021: If the value of fxRateValue is not null, calculate the value with that FX Rate
                    if(fxRateValue != null){
                        currentTimesheet.X6_7_Days_Total__c = (currentTimesheet.X6_7_Days__c * timeSheetRate.X6_7_Days__c) * fxRateValue;
                    } else {
                        currentTimesheet.X6_7_Days_Total__c = currentTimesheet.X6_7_Days__c * timeSheetRate.X6_7_Days__c;
                    }
                }

                clonedTimesheets.add(currentTimesheet);

            }
        }
        update clonedTimesheets;
    }

    /**
     * Calculates and updates the costs of a union timesheet.
     * 
     * @param timesheet The timesheet to process.
     * @param targetRate The specific rate to target for calculation.
     * @param ratesMap A map containing all available rates, with IDs as keys.
     * @param employee The employee contact associated with the timesheet.
     * @return A modified copy of the original timesheet with updated costs.
     */
    public static Timesheet__c calculateUnionTimesheet(
        Timesheet__c timesheet,
        TimesheetRate__c targetRate,
        Map<Id, TimesheetRate__c> ratesMap,
        Contact employee
    ) {
        //GC 09/22/2021: New field "Overnight" added
        if(
            timesheet.Automated_Process__c == true ||
            timesheet.Foreign_Rates_Cost__c != null ||
            timesheet.Holiday_Pay_100_Cost__c != null ||
            timesheet.Holiday_Pay_200_Cost__c != null ||
            timesheet.Holiday_Pay_50_Cost__c != null ||
            timesheet.Meal_Penalties_Cost__c != null ||
            timesheet.Night_Differential_Cost__c != null ||
            timesheet.Over_Time_Cost__c != null ||
            timesheet.Premium_Time_Cost__c != null ||
            timesheet.Penalty_Time_Cost__c != null ||
            timesheet.Straight_Time_Cost__c != null ||
            timesheet.Vacation_Allowance_Cost__c != null ||
            timesheet.Overnight_Cost__c != null
        ) {
            if(timesheet.Automated_Process__c == true) System.debug('Automated process Timesheet');
            System.debug('Skipping timesheet calculation because because at least one of the cost fields is populated');
            return timesheet;
        }
        TimesheetRate__c specificTimesheetRate = new TimesheetRate__c();
        TimesheetRate__c genericTimesheetRate = new TimesheetRate__c();
        TimesheetRate__c rate = new TimesheetRate__c();
        for(TimesheetRate__c currentRate : ratesMap.values()) {
            if(
                currentRate.Employee_Title__c != null &&
                (
                    targetRate.Employee_Title__c == currentRate.Employee_Title__c &&
                    targetRate.Bureau__c == currentRate.Bureau__c &&
                    targetRate.Employee_Type__c == currentRate.Employee_Type__c &&
                    targetRate.Union__c == currentRate.Union__c &&
                    timesheet.Date__c >= currentRate.Start_Date__c &&
                    timesheet.Date__c <= currentRate.End_Date__c
                )
                
            ) {
                specificTimesheetRate = currentRate;
            }
            if(
                targetRate.Bureau__c == currentRate.Bureau__c &&
                targetRate.Employee_Type__c == currentRate.Employee_Type__c &&
                targetRate.Union__c == currentRate.Union__c &&
                timesheet.Date__c >= currentRate.Start_Date__c &&
                timesheet.Date__c <= currentRate.End_Date__c &&
                currentRate.Employee_Title__c == null
            ) {
                genericTimesheetRate = currentRate;
            }
        }
        if(specificTimesheetRate.Id != null) {
            rate = specificTimesheetRate;
            System.debug('Specific timesheet Rate Found!');
        }
        if(specificTimesheetRate.Id == null && genericTimesheetRate.Id != null) {
            rate = genericTimesheetRate;
            System.debug('Generic timesheet Rate Found!');
        }
        if(rate.Id == null) {
            System.debug('No timesheet Rate Found!');
        }
        if(rate.Id != null) {
            Timesheet__c timesheetClone = timesheet.clone(true, true, true, true);
            if(employee.Employee_Type__c == 'Freelancer') {
                timesheetClone.Fringe__c = rate.Fringe__c;
            }

            List<List<String>> fieldsToUpdate = new List<List<String>>{
                new List<String>{'Straight_Time_Cost__c', 'Straight_Time__c', 'Straight_Time__c'},
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
                new List<String>{'Over_Time_Cost__c', 'Over_Time_Rate__c', 'Over_Time__c'},
                new List<String>{'Out_of_Town_Flat_Day_Cost__c', 'Out_of_Town_Flat_Day_rate__c', 'Out_of_Town_Flat_Time__c'},
                new List<String>{'Premium_Time_Cost__c', 'Premium_Time__c', 'Premium_Time__c'}
            };

            TimeSheetWrapper timeWrapper = new TimeSheetWrapper();
            timeWrapper.currentTimeSheet = timesheetClone;
            timeWrapper.timeSheetRate = rate;
            timeWrapper.employee = employee;

            for (List<String> field : fieldsToUpdate ){

                timesheetClone.put(field[0], calculateNUTTimesheetCost(timeWrapper, field[0], field[1], field[2]));
            }


            return timesheetClone;
        } else {
            System.debug('No rate found for timesheet ' + timesheet + 'no process done!' );
            return timesheet;
        }
    }



    public class TimeSheetWrapper {
        public Timesheet__c currentTimeSheet {get; set;}
        public TimesheetRate__c timeSheetRate {get; set;}
        public Map<Id,Timesheet__c> timeSheetMap {get; set;}
        public Contact employee {get; set;}
        public Decimal fxRate {get; set;}  
    }

}
