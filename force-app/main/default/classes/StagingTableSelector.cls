public with sharing class StagingTableSelector {

    public static List<Staging_Table__c> selectAllButFinished(){
        
        List<Staging_Table__c> allRecords = new List<Staging_Table__c>();
        allRecords = [
            SELECT Id, OwnerId, IsDeleted, Name, D_L__c, Dept__c, Dollars__c, Employee_Type__c, 
                   Gross_Pay__c, Internal_Notes__c, PayRate_OVR__c, Show__c, Assignment_Group_s__c, 
                   Employee_ID__c, Episode__c, First_Name__c, Hours__c, Last_Name__c, Fees__c, 
                   Union__c, Work_Date__c, Year__c, Earnings_Code__c, Network_ID__c, 
                   Meal_Penalties_Cost__c, Meal_Penalties__c, Missed_Meal__c, 
                   Night_Differential_Cost__c, Night_Differential__c, Over_Time_Cost__c, 
                   Over_Time__c, Penalty_Time_Cost__c, Penalty_Time__c, Rest_Penalty__c, 
                   Straight_Time_Cost__c, Straight_Time__c, Vacation_Allowance_Cost__c, 
                   Vacation_Allowance__c, Premium_Time__c, Premium_Time_Cost__c, 
                   Rest_Penalty_Cost__c, Employee_Title__c, Error_Code__c, Error_Message__c, 
                   News_Bureau__c, Status__c, Reprocess__c, Assignment_Information__c, Cost_Center__c, 
            	   Location__c, Story__c, Foreign_Rates__c, Foreign_Rates_Cost__c, Holiday_Pay_100_Cost__c, 
                   Holiday_Pay_100__c, Holiday_Pay_200_Cost__c, Holiday_Pay_200__c, Holiday_Pay_50_Cost__c, 
                   Holiday_Pay_50__c, Out_of_Town_Flat_Time__c, Out_of_Town_Flat_Day_Cost__c, 
            	   Overnight_Cost__c, Overnight__c, Paid_Time_Off__c
            FROM Staging_Table__c
            WHERE Status__c != 'Finished'
        ];
        return allRecords;
    }
    
    //GC: Query to get the Id from Bureaus with their Names
    public static List<bureau__c> queryBureausIds(
        Set<String> bureausName
    ){
        List<bureau__c> bureaus = new List<bureau__c>();
        bureaus = [
            SELECT Id, Name
            FROM bureau__c
            WHERE Name IN: bureausName
        ];
        
        return bureaus;
    }
    
    //GC: Query to get the possible available SEAs
    public static List<ScheduleAssociation__c> querySEAs(
        Set<Id> bureaus,
        Set<Id> employees,
        Set<Date> timesheetsDates
    ){
        List<ScheduleAssociation__c> seas = new List<ScheduleAssociation__c>();
        seas = [
            SELECT Id, IsDeleted, Name, Assignment_Information__c, 
            X9MaxValidationCheckbox__c, Story_Schedule_Association__c, 
            Employee__c, Location__c, Employee__r.Employee_ID__c,
            Story_Schedule_Association__r.Schedule__r.Bureau__c,
            Story_Schedule_Association__r.Schedule__r.Date__c,
            Story_Schedule_Association__r.Cost_Center__c,            
            Story_Schedule_Association__r.Story__c
            FROM ScheduleAssociation__c
            WHERE Story_Schedule_Association__r.Schedule__r.Bureau__c IN: bureaus
            AND Employee__c IN: employees
            AND Story_Schedule_Association__r.Schedule__r.Date__c IN: timesheetsDates
        ];
        
        return seas;
    }
    
    //GC: Query to check if there's any placeholders on Timesheet that we can update
    public static List<Timesheet__c> queryTimesheetPlaceholders(
        Set<Id> bureaus,
        Set<Id> employees,
        Set<Date> timesheetsDates
    ){
        List<Timesheet__c> timesheetPlaceholders = new List<Timesheet__c>(); 
        timesheetPlaceholders = [
            SELECT Id, Automated_Process__c, Bank_Holiday_Time__c, Bureau__c, Christams_New_Year_TIme__c, 
            CostCenter__c, CreatedDate, Date__c, Dollars__c, Earnings_Code__c, Employee__c, 
            Episode__c, Fees__c, Foreign_Rates_Cost__c, Foreign_Rates__c, Gross_Pay__c, Holiday_Pay_100_Cost__c, 
            Holiday_Pay_100__c, Holiday_Pay_200_Cost__c, Holiday_Pay_200__c, Holiday_Pay_50_Cost__c, 
            Holiday_Pay_50__c, Holiday_Pay__c, Hours_Rate__c, Hours__c, Internal_Notes__c, Meal_Penalties_Cost__c, 
            Meal_Penalties__c, Missed_Meal__c, Name, Network_ID__c, Night_Differential_Cost__c, 
            Night_Differential__c, Out_of_Town_Flat_Day_Cost__c, Out_of_Town_Flat_Time__c, Over_Time_Cost__c, 
            Over_Time__c, PayRate_OVR__c, Penalty_Time_Cost__c, Penalty_Time__c, Rest_Penalty_Cost__c, 
            Rest_Penalty__c, Show__c, Start_Date__c, Story_Employee_Association__c, Story__c, 
            Straight_Time_Cost__c, Straight_Time__c, Timesheet_Rate__c, Total_Cost__c, 
            Total_Hours__c, Vacation_Allowance_Cost__c, Vacation_Allowance__c, Weekend_Time__c, Year__c,
            Overnight_Cost__c, Overnight__c, Story_Employee_Association__r.Story_Schedule_Association__r.Story__c,
            Employee__r.Employee_ID__c, Paid_Time_Off__c, Story_Employee_Association__r.Story_Schedule_Association__r.Cost_Center__c
            FROM Timesheet__c
            WHERE Bureau__c IN: bureaus
            AND Employee__c IN: employees
            AND Date__c IN: timesheetsDates
            AND Foreign_Rates_Cost__c = NULL
            AND Holiday_Pay_50_Cost__c = NULL
            AND Holiday_Pay_100_Cost__c = NULL
            AND Holiday_Pay_200_Cost__c = NULL
            AND Meal_Penalties_Cost__c = NULL
            AND Night_Differential_Cost__c = NULL
            AND Out_of_Town_Flat_Day_Cost__c = NULL
            AND Over_Time_Cost__c = NULL
            AND Penalty_Time_Cost__c = NULL
            AND Rest_Penalty_Cost__c = NULL
            AND Straight_Time_Cost__c = NULL
            AND Vacation_Allowance_Cost__c = NULL
            FOR UPDATE
        ];
        return timesheetPlaceholders;
    }
    
    //TP: Query to get the possible available Timesheets
    public static List<Timesheet__c> queryAllTimesheets(
        Set<Id> bureaus,
        Set<Id> employees,
        Set<Date> timesheetsDates
    ){
        List<Timesheet__c> allTimesheets = new List<Timesheet__c>(); 
        allTimesheets = [
            SELECT Id, Bureau__c, CostCenter__c, CreatedDate, Date__c, Employee__c, Name, Story_Employee_Association__c, Story__c, 
            Timesheet_Rate__c, Story_Employee_Association__r.Story_Schedule_Association__r.Story__c,
            Employee__r.Employee_ID__c, Story_Employee_Association__r.Story_Schedule_Association__r.Cost_Center__c
            FROM Timesheet__c
            WHERE Bureau__c IN: bureaus
            AND Employee__c IN: employees
            AND Date__c IN: timesheetsDates
        ];
        return allTimesheets;
    }
    
    public static List<Schedule__c> querySchedules(
        List<Id> bureausIds,
        Set<Date> dateList
    )
    {
    	List<Schedule__c> scheduleList = [SELECT id, Bureau__c, Date__c FROM Schedule__c WHERE Bureau__c in : bureausIds AND Date__c in : dateList];
        return scheduleList;
    }
    public static List<Story_Schedule_Association__c> queryStorySchedules(
        Set<id> listStoryId,
        List<Schedule__c> scheduleList,
        Set<id> listLocationId,
        Set<id> listCostCenterId
    )
    {
    	List<Story_Schedule_Association__c> stryScheList = [SELECT id, Story__c, Schedule__c, Location__c, Cost_Center__c FROM Story_Schedule_Association__c 
                                                            WHERE Story__c in : listStoryId  
                                                            AND  Schedule__c in : scheduleList 
                                                           	AND  Location__c in : listLocationId 
                                                           	AND  Cost_Center__c in : listCostCenterId];
        return stryScheList;
    }
    public static List<ScheduleAssociation__c> queryStoryEmployees(
        List<Story_Schedule_Association__c> stryScheList,
        List<Contact> empList
    )
    {
    	List<ScheduleAssociation__c> stryEmpList = [SELECT id, Story_Schedule_Association__c, Employee__c, Employee__r.Employee_ID__c FROM ScheduleAssociation__c
                                                   	WHERE Story_Schedule_Association__c in : stryScheList AND
                                                   		  Employee__c in : empList];
        return stryEmpList;
    }
}