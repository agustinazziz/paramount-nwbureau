global class ProcessStagingTableBatch implements Database.Batchable<sObject>, 
                                                 Database.Stateful, 
                                                 Database.AllowsCallouts{

    //Map<earningCode,  Map<'GrossPay', mappingField>
    //                  Map<'Hours', mappingField>
    public Map<String, Map<String, String>> earningCodesMap = new Map<String, Map<String, String>>();
    public Map<String, Staging_Table__c> temporaryTimesheets = new Map<String, Staging_Table__c>();
    public Map<String, Staging_Table__c> errorTimesheets = new Map<String, Staging_Table__c>();
    public Map<Id, Bureau__c> bureauMap;
    public Map<String, String> bureauNamesMap = new Map<String, String>();
    public Set<String> employeeIds;
    public Map<String, Contact> employeesMap;//Employee ID, Employee
	public Map<String, bureau__c> bureausMap;
    public Integer amountOfRecordsToProcess;
    public Integer batchNumber;
    public Integer lastBatch;
    public List<Timesheet__c> tmrecordstoupsert = new List<Timesheet__c>();                                                  
    
    public ProcessStagingTableBatch() {
        this.employeesMap = new Map<String, Contact>();
        this.bureausMap = new Map<String, bureau__c>();
        //Insert missing picklist values
        List<Staging_Table__c> stagingRecords = StagingTableSelector.selectAllButFinished();
        system.debug('stagingRecords size: '+ stagingRecords.size());
        Set<String> unprocessedEmployeesIDs = new Set<String>();
        for(Staging_Table__c record : stagingRecords) {
            system.debug('record: '+record.Status__c.toUpperCase());
            if(
                (record.Status__c.toUpperCase()  == 'MERGED') &&
                record.Error_Code__c == null
            ){
                temporaryTimesheets.put(record.News_Bureau__c + record.Employee_ID__c + record.Work_Date__c, record);
            }
            if (
                record.Status__c.toUpperCase() == 'UNPROCESSED' && 
                !unprocessedEmployeesIDs.contains(record.Employee_ID__c)
            ) {
                unprocessedEmployeesIDs.add(record.Employee_ID__c);
            }
            if (
                record.Status__c.toUpperCase() == 'MERGED' &&
                record.Error_Code__c == 500 &&
                record.Reprocess__c == true &&
                !unprocessedEmployeesIDs.contains(record.Employee_ID__c)
            ) {
                unprocessedEmployeesIDs.add(record.Employee_ID__c);
            }
        }
        
        List<Contact> employeeList = new List<Contact>();
        employeeList = [
            SELECT Id, Employee_ID__c, Employee_Title__c
            FROM Contact
            WHERE Employee_ID__c IN:unprocessedEmployeesIDs
        ];
        for(Contact employee : employeeList) this.employeesMap.put(employee.Employee_ID__c, employee);
        
        //GC 01/26/2022: Gets the Bureau information to match with the News_Bureau__c
        List<bureau__c> bureausList = new List<bureau__c>();
        bureausList = [
            SELECT Id, Name 
            FROM bureau__c
        ];
        for(bureau__c bureau : bureausList) this.bureausMap.put(bureau.Name, bureau);

        amountOfRecordsToProcess = stagingRecords.size();
        lastBatch = integer.valueOf(((amountOfRecordsToProcess / 200) + 0.4).round());
        batchNumber = 0;

        //populate earnings codes map
    	List<Earnings_Code__c> earningscodeList = [
            SELECT Gross_Pay__c, Hours__c, Payroll_Earnings_Code__c 
            FROM Earnings_Code__c
        ];

        for(Earnings_Code__c ec : earningscodeList)
        {
            Map<String, String> earningscodeInnerMap = new Map<String, String>();
            earningscodeInnerMap.put(ec.Gross_Pay__c, ec.Hours__c);
            List<String> earningscode = new List<String>();
            earningscode.addAll(ec.Payroll_Earnings_Code__c.split(';'));
            for(String s : earningscode)
            {
                System.debug('GC Earnings Code Map s: ' + s);
                System.debug('GC Earnings Code Map earningscodeInnerMap: ' + earningscodeInnerMap);
                earningCodesMap.put(s, earningscodeInnerMap);
            }
        }
        //populate Bureaus maps 
        List<Bureau_Mapping__c> bureauList = [ SELECT DL_Dept__c, Bureau_Name__c FROM Bureau_Mapping__c ];
        for(Bureau_Mapping__c bp:bureauList)
        {
            bureauNamesMap.put(bp.DL_Dept__c, bp.Bureau_Name__c);
        }
        //get StagingTable records with no errors
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('Start');
        string finish = 'Finished';
        string query = 'SELECT Id, OwnerId, IsDeleted, Name, D_L__c, Dept__c, Dollars__c, Employee_Type__c,' + 
                               ' Gross_Pay__c, Internal_Notes__c, PayRate_OVR__c, Show__c, Assignment_Group_s__c,' +
                                'Employee_ID__c, Episode__c, First_Name__c, Hours__c, Last_Name__c, Fees__c,' +
                                'Union__c, Work_Date__c, Year__c, Earnings_Code__c, Network_ID__c, ' +
                                'Meal_Penalties_Cost__c, Meal_Penalties__c, Missed_Meal__c, ' +
                                'Night_Differential_Cost__c, Night_Differential__c, Over_Time_Cost__c, ' +
                                'Over_Time__c, Penalty_Time_Cost__c, Penalty_Time__c, Rest_Penalty__c, ' +
                                'Straight_Time_Cost__c, Straight_Time__c, Vacation_Allowance_Cost__c, ' +
                                'Vacation_Allowance__c, Premium_Time__c, Premium_Time_Cost__c, ' +
                                'Rest_Penalty_Cost__c, Employee_Title__c, Error_Code__c, Error_Message__c, ' +
                                'News_Bureau__c, Status__c, Reprocess__c, Assignment_Information__c, Cost_Center__c, ' +
            					'Location__c, Story__c, Employee__c, Foreign_Rates__c, Foreign_Rates_Cost__c, ' +
            					'Holiday_Pay_100_Cost__c, Holiday_Pay_100__c, Holiday_Pay_200_Cost__c, Holiday_Pay_200__c, ' +
            					'Holiday_Pay_50_Cost__c, Holiday_Pay_50__c, '+
            					'Out_of_Town_Flat_Time__c, Out_of_Town_Flat_Day_Cost__c, '+
            					'Overnight_Cost__c, Overnight__c, Paid_Time_Off__c, Merged_WFQ_records__c '+
                        'FROM Staging_Table__c ' + 
                        'WHERE Status__c !=: finish';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Staging_table__c> scope)
    {
        
        List<Staging_Table__c> stagingNoError = StagingTableDomain.mapMissingNewsBureau(scope, this.bureauNamesMap, this.earningCodesMap, this.bureausMap);
        this.errorTimesheets.putAll(StagingTableDomain.segregateRecords(stagingNoError, errorTimesheets));
        this.temporaryTimesheets.putAll(StagingTableDomain.mergeRecords(stagingNoError, temporaryTimesheets, errorTimesheets));
        this.employeesMap.putAll(StagingTableDomain.matchEmployees(scope, this.temporaryTimesheets, this.bureausMap));
        this.temporaryTimesheets.putAll(StagingTableDomain.createSEA(scope, temporaryTimesheets, this.employeesMap));
       	if(batchNumber == lastBatch) 
        {   
            System.debug('Executing last batch');
            this.tmrecordstoupsert.addAll(StagingTableDomain.createTimesheets(this.temporaryTimesheets, this.employeesMap)); 
        }
        lastBatch--;
    }
    public void finish(Database.BatchableContext BC)
    {
        system.debug('finish');
        Database.executeBatch(new ProcessStagingTableTimesheets(tmrecordstoupsert), 10);

    }
}