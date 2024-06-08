public with sharing class StoryScheduleAssociationSelector {
    
    public static List<Story_Schedule_Association__c> selectById(Id StoryScheduleAssociationId){
        
        List<Story_Schedule_Association__c> storyScheduleAssociation = 
            [
                SELECT Cost_Center__c, Its_the_cost_center_invalid__c, Location__c,
                    Schedule__c, Name, Story__c
                FROM Story_Schedule_Association__c
                WHERE Id =: StoryScheduleAssociationId
            ];

        return storyScheduleAssociation;
    }

    public static List<Story_Schedule_Association__c> selectById(Set<Id> StoryScheduleAssociationId){
        
        List<Story_Schedule_Association__c> storyScheduleAssociations = new List<Story_Schedule_Association__c>();
        storyScheduleAssociations = [
                SELECT Cost_Center__c, Its_the_cost_center_invalid__c, Location__c,
                    Schedule__c, Name, Story__c
                FROM Story_Schedule_Association__c
                WHERE Id IN: StoryScheduleAssociationId
            ];

        return storyScheduleAssociations;
    }
    
    
    
    public static List<Story_Schedule_Association__c> selectByScheduleId(Id scheduleId){
        
        List<Story_Schedule_Association__c> storyScheduleAssociation = 
            [
                SELECT Cost_Center__c, Its_the_cost_center_invalid__c, Location__c,
                    Schedule__c, Name, Story__c
                FROM Story_Schedule_Association__c
                WHERE Schedule__c = :scheduleId
            ];

        return storyScheduleAssociation;
    }

    public static List<Story_Schedule_Association__c> selectByScheduleId(Set<Id> scheduleId){
        
        List<Story_Schedule_Association__c> storyScheduleAssociation = 
            [
                SELECT Cost_Center__c, Its_the_cost_center_invalid__c, Location__c,
                    Schedule__c, Name, Story__c
                FROM Story_Schedule_Association__c
                WHERE Schedule__c IN :scheduleId
            ];

        return storyScheduleAssociation;
    }

    public static List<Story_Schedule_Association__c> selectByStoryLocationScheduleAndCostCenter(
        Id storyId,
        Id locationId,
        Id scheduleId,
        Id costCenterId
    ) {
        
        return [
                SELECT Id, Name
                FROM Story_Schedule_Association__c
                WHERE Story__c =: storyId
                AND Location__c =: locationId
                AND Schedule__c =: scheduleId
                AND Cost_Center__c =: costCenterId
            ];
    }

    public static List<Story_Schedule_Association__c> selectByStoryLocationScheduleDatesAndCostCenter(
        Id storyId,
        Id locationId,
        Id costCenterId,
        List<Schedule__c> scheduleList
    ) {
        List<Story_Schedule_Association__c> result = new List<Story_Schedule_Association__c>();
        result = [
            SELECT Id, Name, Location__c, Story__c, Schedule__c, Cost_Center__c, Schedule__r.Date__c,
                   Schedule__r.Bureau__c
            FROM Story_Schedule_Association__c
            WHERE Story__c =: storyId
            AND Location__c =: locationId
            AND Schedule__c IN: (new Map<Id, Schedule__c>(scheduleList).keySet())
            AND Cost_Center__c =: costCenterId
        ];
        return result;
    }

    public static Story_Schedule_Association__c insertRecord(
        Id storyId,
        Id locationId,
        Id scheduleId,
        Id costCenterId 
    ) {
        Story_Schedule_Association__c storyScheduleAssociation =
            new Story_Schedule_Association__c(
                Story__c = storyId,
                Location__c = locationId,
                Schedule__c = scheduleId,
                Cost_Center__c = costCenterId
            );
        insert storyScheduleAssociation;
        return storyScheduleAssociation;
    }

    public static List<Story_Schedule_Association__c> selectByUniqueIdentifier(Set<String> uniqueIdentifiers){
        
        List<Story_Schedule_Association__c> storyScheduleAssociation = 
            [
                SELECT Cost_Center__c, Its_the_cost_center_invalid__c, Location__c,
                    Schedule__c, Name, Story__c, Unique_Identifier__c
                FROM Story_Schedule_Association__c
                WHERE Unique_Identifier__c IN :uniqueIdentifiers
            ];

        return storyScheduleAssociation;
    }
}