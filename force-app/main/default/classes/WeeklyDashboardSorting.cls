public class WeeklyDashboardSorting {

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

    public WeeklyDashboardSorting(
        List<weeklyDashboardService.WeekData> weekData,
        List<Contact> employees
    ){
        this.weekData = weekData;
        this.employees = employees;
        this.sortedWeekData = new List<weeklyDashboardService.WeekData>();
        this.sortWeekData();
    }

    public void sortWeekData() {
        this.pickCorrespondents();
        this.pickProducers();
        this.pickDigitals();
        this.pickSortingGroup3();
        this.pickSortingGroup4();
        this.pickSortingGroup5();
        this.pickSortingGroup6();
        this.pickSortingGroup7();
        this.pickSortingGroup8();
        this.pickSortingGroup8(); 
        this.pickSortingGroup9();
        this.pickSortingGroup10();
        this.pickSortingGroup11();
        this.pickSortingGroup12();
        this.pickSortingGroup13();
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

    public void pickCorrespondents(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(employeeMap.get(employee.employeeId).Employee_Title__c == 'CORRESPONDENT') {
                employee.sortingGroup = 'CORRESPONDENTS';
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
            if(employeeMap.get(employee.employeeId).Employee_Title__c.contains('PRODUCER')) {
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

    public void pickDigitals(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(employeeMap.get(employee.employeeId).Employee_Title__c.contains('DIGITAL')) {
                employee.sortingGroup = 'DIGITAL';
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
    
    public void pickSortingGroup3(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Staff' &&
                (
                    employeeMap.get(employee.employeeId).Union__c == '510' ||
                    employeeMap.get(employee.employeeId).Union__c == '512'
                )
            ) {
                employee.sortingGroup = 'STAFF 510 & 512';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        //
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup4(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Freelancer' &&
                (
                    employeeMap.get(employee.employeeId).Union__c == '510' ||
                    employeeMap.get(employee.employeeId).Union__c == '512'
                )
            ) {
                employee.sortingGroup = 'FREELANCERS 510 & 512';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
        
    }

    public void pickSortingGroup5(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Staff' &&
                employeeMap.get(employee.employeeId).Union__c == 'NU'
            ) {
                employee.sortingGroup = 'STAFF NU';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup6(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Freelancer' &&
                employeeMap.get(employee.employeeId).Union__c == 'NU' &&
                employeeMap.get(employee.employeeId).Employee_Title__c != 'CONSULTANT' &&
                employeeMap.get(employee.employeeId).Employee_Title__c != 'INTERN' &&
                employeeMap.get(employee.employeeId).Employee_Title__c != 'NEWS ASSOCIATE' &&
                !employeeMap.get(employee.employeeId).Employee_Title__c.contains('ARTIST') &&
                !employeeMap.get(employee.employeeId).Employee_Title__c.contains('STYLIST')
                
            ) {
                employee.sortingGroup = 'FREELANCER NU ARTIST & STYLIST';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup7(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Staff' &&
                employeeMap.get(employee.employeeId).Union__c == '247'
            ) {
                employee.sortingGroup = 'STAFF 247';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup8(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Freelancer' &&
                employeeMap.get(employee.employeeId).Union__c == '247'
            ) {
                employee.sortingGroup = 'FREELANCER 247';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup9(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Staff' &&
                employeeMap.get(employee.employeeId).Union__c == '320'
            ) {
                employee.sortingGroup = 'STAFF 320';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }

    }

    public void pickSortingGroup10(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Freelancer' &&
                employeeMap.get(employee.employeeId).Union__c == '320'
            ) {
                employee.sortingGroup = 'FREELANCER 320';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup11(){
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Staff' &&
                employeeMap.get(employee.employeeId).Union__c == '666'
            ) {
                employee.sortingGroup = 'STAFF 666';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup12(){

        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Freelancer' &&
                employeeMap.get(employee.employeeId).Union__c == '666'
            ) {
                employee.sortingGroup = 'FREELANCER 666';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
        }
    }

    public void pickSortingGroup13(){

        //Employee Type = Freelance, Union = NU, Employee Role == "Consultant",== "Intern",== "News Associate",CONTAINS "Artist",CONTAINS "Stylist"
        List<weeklyDashboardService.WeekData> tempoWeekData = new List<weeklyDashboardService.WeekData>();
        Map<Id, Contact> employeeMap = new Map<Id, Contact>(this.employees);
        List<weeklyDashboardService.WeekData> weekDataInstance = this.weekData.clone();
        for (weeklyDashboardService.WeekData employee : weekDataInstance) {
            if(
                employeeMap.get(employee.employeeId).Employee_Type__c == 'Freelancer' &&
                employeeMap.get(employee.employeeId).Union__c == 'NU' &&
                (
                    employeeMap.get(employee.employeeId).Employee_Title__c == 'CONSULTANT' ||
                    employeeMap.get(employee.employeeId).Employee_Title__c == 'INTERN' ||
                    employeeMap.get(employee.employeeId).Employee_Title__c == 'NEWS ASSOCIATE' ||
                    employeeMap.get(employee.employeeId).Employee_Title__c.contains('ARTIST') ||
                    employeeMap.get(employee.employeeId).Employee_Title__c.contains('STYLIST')
                )
            ) {
                employee.sortingGroup = 'FREELANCER NU CONSULTANT, INTERN, NEWS ASSOCIATE, ARTIST & STYLIST';
                tempoWeekData.add(employee);
                this.weekData.remove(this.weekData.indexOf(employee));
            }
        }
        
        try {
            this.sortedWeekData.addAll(tempoWeekData);
        } catch (Exception e) {
            //No employees for this group
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