global class ProcessStagingTableTimesheets implements Database.Batchable<Timesheet__c>
{
    global final List<Timesheet__c> tmRecordsUpsert;
    public ProcessStagingTableTimesheets(List<Timesheet__c> tmRecordsUpsert)
    {
        this.tmRecordsUpsert = tmRecordsUpsert;
    }
    public Iterable<Timesheet__c> start(Database.BatchableContext BC)
    {
        return tmRecordsUpsert;
    }
    public void execute(Database.BatchableContext BC, List<Timesheet__c> scope)
    {
        Map<String, Timesheet__c> tmRecordsMap = new Map<String, Timesheet__c>();
        Map<String, Timesheet__c> tmFullRecordsMap = new Map<String, Timesheet__c>();
        List<Timesheet__c> tmRecordsUpdate = new List<Timesheet__c>();
        List<Timesheet__c> tmRecordsAutoUpdate = new List<Timesheet__c>();
        for(Timesheet__c tmST : scope)
        {
			Timesheet__c timesheet = new Timesheet__c();
            timesheet.Id = tmST.Id;
            timesheet.Bureau__c = tmST.Bureau__c;
            timesheet.CostCenter__c = tmST.CostCenter__c;
            system.debug('tmST.CostCenter__c: '+tmST.CostCenter__c);
            timesheet.Date__c = tmST.Date__c;
            timesheet.Employee__c = tmST.Employee__c;
            timesheet.Story__c = tmST.Story__c;
            timesheet.Story_Employee_Association__c = tmST.Story_Employee_Association__c;
            timesheet.Year__c = tmST.Year__c;
			timesheet.Straight_Time__c = tmST.Straight_Time__c;
            timesheet.Straight_Time_Cost__c = tmST.Straight_Time_Cost__c;
            timesheet.Paid_Time_Off__c = tmST.Paid_Time_Off__c;
            timesheet.Automated_Process__c = True;
            
            system.debug(tmST.Date__c);
            
            //GC: Holds the Timesheet Key
            String tmKeyMap;
            //GC: Holds the Employee Id from Timesheet
            String tmEmpId;
            //GC: Converts the Date so takes out the hours
            Date tmDate = Date.newInstance(timesheet.Date__c.year(), 
                                           timesheet.Date__c.month(), 
                                           timesheet.Date__c.day());
            tmEmpId = tmST.Employee__c;
            tmKeyMap = String.valueOf(tmDate) + String.valueOf(tmST.Bureau__c) + tmEmpId;
            tmRecordsMap.put(tmKeyMap, timesheet);
            tmFullRecordsMap.put(tmKeyMap, tmST);
        }
        upsert tmRecordsMap.values();
		for(Timesheet__c timesheet : tmRecordsMap.values())   
        {
            
            //GC: Holds the Timesheet Key
            String tmKeyMap;
            //GC: Holds the Employee Id from Timesheet
            String tmEmpId;
            //GC: Converts the Date so takes out the hours
            Date tmDate = Date.newInstance(timesheet.Date__c.year(), 
                                           timesheet.Date__c.month(), 
                                           timesheet.Date__c.day());
            tmEmpId = timesheet.Employee__c;
            tmKeyMap = String.valueOf(tmDate) + String.valueOf(timesheet.Bureau__c) + tmEmpId;

            Timesheet__c tmST = tmFullRecordsMap.get(tmKeyMap);
            timesheet.Earnings_Code__c = tmST.Earnings_Code__c;
            timesheet.Foreign_Rates__c = tmST.Foreign_Rates__c;
            timesheet.Gross_Pay__c = tmST.Gross_Pay__c;
            timesheet.Holiday_Pay_100__c = tmST.Holiday_Pay_100__c;
            timesheet.Holiday_Pay_200__c = tmST.Holiday_Pay_200__c;
            timesheet.Holiday_Pay_50__c = tmST.Holiday_Pay_50__c;
            timesheet.Hours__c = tmST.Hours__c;
            timesheet.Internal_Notes__c = tmST.Internal_Notes__c;
            timesheet.Meal_Penalties__c = tmST.Meal_Penalties__c;
            timesheet.Missed_Meal__c = tmST.Missed_Meal__c;
            timesheet.Network_ID__c = tmST.Network_ID__c;
            timesheet.Night_Differential__c = tmST.Night_Differential__c;
            timesheet.Out_of_Town_Flat_Time__c = tmST.Out_of_Town_Flat_Time__c;
            timesheet.Over_Time__c = tmST.Over_Time__c;
            timesheet.PayRate_OVR__c = tmST.PayRate_OVR__c;
            timesheet.Penalty_Time__c = tmST.Penalty_Time__c;
            timesheet.Rest_Penalty__c = tmST.Rest_Penalty__c;
            timesheet.Show__c = tmST.Show__c;
            timesheet.Vacation_Allowance__c = tmST.Vacation_Allowance__c;
            timesheet.Overnight__c = tmST.Overnight__c;
            timesheet.Premium_Time__c = tmST.Premium_Time__c;
            timesheet.Fees__c = tmST.Fees__c;
            timesheet.Vacation_Allowance_Cost__c = tmST.Vacation_Allowance_Cost__c;
            timesheet.Foreign_Rates_Cost__c = tmST.Foreign_Rates_Cost__c;
            timesheet.Holiday_Pay_50_Cost__c = tmST.Holiday_Pay_50_Cost__c;
            timesheet.Holiday_Pay_100_Cost__c = tmST.Holiday_Pay_100_Cost__c;
            timesheet.Holiday_Pay_200_Cost__c = tmST.Holiday_Pay_200_Cost__c;
            timesheet.Rest_Penalty_Cost__c = tmST.Rest_Penalty_Cost__c;
            timesheet.Over_Time_Cost__c = tmST.Over_Time_Cost__c;
            timesheet.Night_Differential_Cost__c = tmST.Night_Differential_Cost__c;
            timesheet.Meal_Penalties_Cost__c = tmST.Meal_Penalties_Cost__c;
            timesheet.Penalty_Time_Cost__c = tmST.Penalty_Time_Cost__c;
            timesheet.Overnight_Cost__c = tmST.Overnight_Cost__c;
            timesheet.Premium_Time_Cost__c = tmST.Premium_Time_Cost__c;
            timesheet.Out_of_Town_Flat_Day_Cost__c = tmST.Out_of_Town_Flat_Day_Cost__c;
            timesheet.WFS_Sourced__c = true;
            tmRecordsUpdate.add(timesheet);
        }
        update tmRecordsUpdate;
        //GC: Updates the Timesheets for Automated_Process false.
        //This let's the timesheet process new Totals if the user changes the values.
        for(Timesheet__c tmAuto : tmRecordsUpdate){
            tmAuto.Automated_Process__c = False;
            tmRecordsAutoUpdate.add(tmAuto);
        }
        update tmRecordsAutoUpdate;
    }
    public void finish(Database.BatchableContext BC)
    {}
}