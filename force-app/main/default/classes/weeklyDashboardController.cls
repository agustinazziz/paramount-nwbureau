public with sharing class weeklyDashboardController {
    
    public static weeklyDashboardService service = new weeklyDashboardService();

    @AuraEnabled
    public static string getAllWeekData(
        String weekStart,
        String weekEnd,
        String bureau
    ) {   
        List<weeklyDashboardService.WeekData> weekData = service.getWeekData(
            service.parseDateString(weekStart),
            service.parseDateString(weekEnd),
            (Id) bureau
        );
        return (String) JSON.serialize(weekData);
    }

    @AuraEnabled
    public static string getActiveBureaus() {
        List<Bureau__c> bureaus = BureauSelector.selectActiveBureaus();
        return (String) JSON.serialize(bureaus);
    }

    @AuraEnabled
    public static String getBureauWithUser(){
        BureauWithUser__c bureau = BureauWithUser__c.getInstance(UserInfo.getUserId());
        return BureauWithUser__c.getInstance().BureauID__c;
    }

    @AuraEnabled
    public static String getEmployeeData(
        String employeeId, 
        String currentWeek, 
        String bureau
    ) {

        CurrentWeek deserializedCurrentWeek = 
            (weeklyDashboardController.CurrentWeek) JSON.deserialize(
                currentWeek, 
                weeklyDashboardController.CurrentWeek.class
            );
        Contact employee = EmployeeSelector.selectById(new Set<Id>{(Id) employeeId})[0];
        System.debug('Retrieved employee data: ' + employee);
        ContactData employeeData = new ContactData();
        employeeData.employee = employee;
        employeeData.weekDates = service.getWeekDates(
            service.parseDateString(deserializedCurrentWeek.weekStart.subString(0, 10)),
            service.parseDateString(deserializedCurrentWeek.weekEnd.subString(0, 10)),
            (Id) bureau
        );
        System.debug('employeeData');
        System.debug(employeeData);
        return JSON.serialize(employeeData);
    }
    
    public class ContactData {
        Contact employee;
        Map<String, Schedule__c> weekDates;
    }

    public class CurrentWeek {
        String weekStart;
        String weekEnd;
    }
    
    //GC: Returns the list view from Assignments Import
    @AuraEnabled
	public static List<ListView> getListViews() {
    	List<ListView> listviews =
        	[SELECT Id, Name FROM ListView WHERE SobjectType = 'Assignment_Import__c'];
    	return listviews;
	}
}