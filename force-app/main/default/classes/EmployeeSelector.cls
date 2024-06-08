public with sharing class EmployeeSelector {
    
    public static List<Contact> selectById(Set<Id> employeeIds) {
        return [
            SELECT Id, Name, LastName, Employee_Title__c, Employee_Type__c,
                   Union__c, Location__c, Disable_Calculation__c, Currency__c 
            FROM Contact
            WHERE Id IN: employeeIds
        ];
    }
}