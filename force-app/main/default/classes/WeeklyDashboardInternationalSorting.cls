public class WeeklyDashboardInternationalSorting {
    public List<weeklyDashboardService.WeekData> weekData {
        get { return weekData; }
        set { weekData = value; }
    }
    public List<weeklyDashboardService.WeekData> sortedWeekData {
        get { return sortedWeekData; }
        set { sortedWeekData = value; }
    }

    public List<Contact> employees {
        get { return employees; }
        set { employees = value; }
    }

    public WeeklyDashboardInternationalSorting(
        List<weeklyDashboardService.WeekData> weekData,
        List<Contact> employees
    ){
        this.weekData = weekData;
        this.employees = employees;
        this.sortedWeekData = new List<weeklyDashboardService.WeekData>();
        this.sortWeekData();
    }

    public void sortWeekData() {
        //this.pickCorrespondents();
        this.pickManagers();
        this.pickDesks();
        this.pickCorrespondents();
        this.pickProducers();
        this.pickTXs();
        this.pickLibrary();
        this.pickEditors();
        this.pickCameraOrSound();
        this.pickEngineering();
        this.pickITs();
        this.pickSecurity();
        this.pickFixersAndLocalProducers();
        this.pickFinance();
        this.pickTraffic();
        this.pickSortingGroup14();
    }

    public List<weeklyDashboardService.WeekData> sortSelectedEmployees(
        List<weeklyDashboardService.WeekData> weekData
    ) {
        Map<String, Integer> sortingMap = new Map<String, Integer>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> sortedWeekData = new List<weeklyDashboardService.WeekData>();
        
        for(weeklyDashboardService.WeekData employee : weekData) {
            sortingMap.put(
                employeeMap.get(employee.employeeId).LastName,
                weekData.indexOf(employee)
            );
        }
        List<String> lastNameList = new List<String>(sortingMap.keySet());
        lastNameList.sort();
        for(String lastName : lastNameList) {
            sortedWeekData.add(weekData[sortingMap.get(lastName)]);
        }
        return sortedWeekData;
    }

    public void pickManagers(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'ASSISTANT BUREAU CHIEF' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'BUREAU CHIEF' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'DIRECTOR NEWS ASSIGNMENTS'
            ) {
                employee.sortingGroup = 'MANAGERS';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        tempoWeekData = this.sortSelectedEmployees(tempoWeekData);
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
        
    }

    public void pickDesks(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'ASSIGNMENT DESK PRODUCER' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'BUREAU ASSISTANT' ||
                employeeMap.get(employee.employeeId).Employee_Title__c=='ASSIGNMENT EDITOR' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'DESK ASSISTANT' ||
                employeeMap.get(employee.employeeId).Employee_Title__c.contains('DESK ASSISTANT') ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL CO-ORDINATOR' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'RESEARCHER'
            ) {
                employee.sortingGroup = 'DESK';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        tempoWeekData = this.sortSelectedEmployees(tempoWeekData);
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
        
    }

    public void pickCorrespondents(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'CORRESPONDENT' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL REPORTER' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'ON-AIR CORRESPONDENT' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'RADIO CORRESPONDENT'
            ) {
                employee.sortingGroup = 'CORRESPONDENT';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        tempoWeekData = this.sortSelectedEmployees(tempoWeekData);
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
        
    }

    public void pickProducers(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'PRODUCER' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL PRODUCER'
            ) {
                employee.sortingGroup = 'PRODUCERS';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }

        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No producers
        }
        
    }

    public void pickTXs(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'COORDINATOR'
            ) {
                employee.sortingGroup = 'TXs';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }

        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No producers
        }
        
    }

    public void pickLibrary(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'TAPE LIBRARIAN' 
            ) {
                employee.sortingGroup = 'LIBRARY';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }

        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No producers
        }
        
    }

    public void pickEditors(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(employeeMap.get(employee.employeeId).Employee_Title__c.contains('EDITOR')) {
                if(employeeMap.get(employee.employeeId).Employee_Title__c == 'ASSIGNMENT EDITOR'){
            
                    
                }else{
                    employee.sortingGroup = 'EDITORS';
                    tempoWeekData.add(employee);
                    this.weekData.remove(this.weekData.indexOf(employee));
                }
            }
        }
        tempoWeekData = this.sortSelectedEmployees(tempoWeekData);
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
        
    }

    public void pickCameraOrSound(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == '403-G' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL CAMERA'||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL SOUND' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'STAFF CAMERA' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'STAFF SOUND'||
                employeeMap.get(employee.employeeId).Employee_Title__c.contains('CAMERA')||
                employeeMap.get(employee.employeeId).Employee_Title__c.contains('SOUND')
            ) {
                employee.sortingGroup = 'CAMERA, SOUND OR 403-G';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No digitals
        }
        
    }

    public void pickEngineering(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL TECH' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'STAFF TECH'
            ) {
                employee.sortingGroup = 'ENGINEERING';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No digitals
        }
        
    }

    public void pickITs(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL I T TECH'
            ) {
                employee.sortingGroup = 'IT';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No digitals
        }
        
    }

    public void pickSecurity(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'CONSULTANT'
            ) {
                employee.sortingGroup = 'SECURITY';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No digitals
        }
        
    }


    public void pickFixersAndLocalProducers(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL FIXER' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FL STRINGER' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'FOR FL NON-TECH NEWSROOM EXTRA' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'STAFF ONE MAN BAND' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'TRANSLATOR' ||
                employeeMap.get(employee.employeeId).Employee_Title__c == 'ASSOCIATE PRODUCER'
            ) {
                employee.sortingGroup = 'FIXERS AND LOCAL PRODUCERS';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No digitals
        }
        
    }

    public void pickFinance(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'BUSINESS MANAGER'
            ) {
                employee.sortingGroup = 'FINANCE';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No digitals
        }
        
    }

    public void pickTraffic(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Title__c == 'TRANSPORT'
            ) {
                employee.sortingGroup = 'TRAFFIC';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No digitals
        }
        
    }

    public void pickSortingGroup14(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            employee.sortingGroup = 'MISC';
            tempoWeekData.add(employee);
            this.weekData.remove(this.weekData.indexOf(employee));
            
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }
}