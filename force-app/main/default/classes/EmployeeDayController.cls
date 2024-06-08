public with sharing class EmployeeDayController {
    
    public static EmployeeDayService service = new EmployeeDayService();

    @AuraEnabled
    public static String assignStory(
        String storyId,
        String locationId,
        String assignmentInformation,
        String scheduleId,
        String costCenterId,
        String employeeId,
        String dayDate,
        String bureauId,
        String liveShot,
        String prosumerUsed,
        String breakingNews,
        String endDate
    ) {
        System.debug('endDate: ' + endDate);
        String assignationResult;
        if(endDate == null){
            assignationResult = service.assignStory(
                storyId, locationId, assignmentInformation, scheduleId,
                costCenterId, employeeId, dayDate, bureauId, liveShot, 
                prosumerUsed, breakingNews
            );
        } else {
            assignationResult = service.assignStory(
                storyId, locationId, assignmentInformation, scheduleId,
                costCenterId, employeeId, dayDate, bureauId, liveShot, 
                prosumerUsed, breakingNews, endDate
            );
        }
         
        return assignationResult;
    }

    @AuraEnabled
    public static Boolean deleteStoryAssignation(
        String storyEmployeeAssociationId
    ) {
        ScheduleAssociation__c storyEmployeeAssociation = new ScheduleAssociation__c();
        Boolean result = false;

        try {
            storyEmployeeAssociation.Id = storyEmployeeAssociationId;
            List<Story_Schedule_Association__c> ssaIdList = new List<Story_Schedule_Association__c>();
            String ssaId = service.canDeleteSSA(storyEmployeeAssociationId);
            if(ssaId != 'NOT DELETABLE') 
                ssaIdList.add(
                    new Story_Schedule_Association__c(Id = (Id) ssaId)
                );
            delete storyEmployeeAssociation;
            if (ssaId != 'NOT DELETABLE') {
                delete ssaIdList;
                result = true;
            }
            result = true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            result = false;
        }
        return result;
    }
    
    //LR: Returns the cost center form a story
    @AuraEnabled
    public static Id getCostCenterFromStory(String storyId) {
        Id profileId=userinfo.getProfileId();
        String profileName = [ SELECT Id, Name FROM Profile WHERE Id =: profileId ].Name;
        if(
            profileName == 'System Administrator' || 
            profileName == 'Bureau Weekly Users - INT'
        ){
            Id storyCostCenterId = [
                SELECT Cost_Center__c 
                FROM Story__c 
                WHERE Id =: storyId
            ].Cost_Center__c;
            return storyCostCenterId;
        } else {
            return null;
        }
        
    }

}