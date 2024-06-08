public with sharing class BureauSelector {
    
    public static List<Bureau__c> selectAll() {
        return [SELECT Id, Name FROM Bureau__c];
    }

    public static List<Bureau__c> selectActiveBureaus() {
        return [SELECT Id, Name FROM Bureau__c where Active__c = true];
    }
    
    public static List<Bureau__c> selectById(Set<Id> bureauIds) {
        return [SELECT Id, Name FROM Bureau__c WHERE Id IN: bureauIds];
    }

}