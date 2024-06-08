public with sharing class ScheduleSelector {
    
    public static Schedule__c selectById(Id scheduleId) {
        
        Schedule__c clonedSchedule = 
        [
            SELECT Bureau__c, Date__c, Location__c, OwnerId
            FROM Schedule__c
            WHERE Id = :scheduleId 
        ];
        return clonedSchedule;
    }

    public static List<Schedule__c> selectById(Set<Id> scheduleIds) {
        
        List<Schedule__c> clonedSchedule = 
        [
            SELECT Bureau__c, Date__c, Location__c, OwnerId
            FROM Schedule__c
            WHERE Id IN: scheduleIds 
        ];
        return clonedSchedule;
    }

    public static List<Schedule__c> selectByDateRangeAndBureau(
        Date weekStart, 
        Date weekEnd,
        Id bureau
    ) {
        List<Schedule__c> weekData = 
        [
            SELECT Id, Date__c, Location__c, Name
            FROM Schedule__c
            WHERE Date__c >=: weekStart 
            AND Date__c <=: weekEnd
            AND Bureau__c =: bureau 
        ];
        return weekData;
    }

    public static List<Schedule__c> selectByDateAndBureau(
        Date scheduleDate, 
        Id bureau
    ) {
        List<Schedule__c> weekData = 
        [
            SELECT Id, Date__c, Location__c, Name
            FROM Schedule__c
            WHERE Date__c =: scheduleDate 
            AND Bureau__c =: bureau 
        ];
        return weekData;
    }

    public static List<Schedule__c> selectByDatesAndBureau(
        Date startDate, Date endDate,
        Id bureau
    ) {
        List<Schedule__c> weekData = new List<Schedule__c>();
        weekData = [
            SELECT Id, Date__c, Location__c, Name
            FROM Schedule__c
            WHERE Date__c >=: startDate
            AND Date__c <=: endDate
            AND Bureau__c =: bureau 
        ];
        return weekData;
    }

}