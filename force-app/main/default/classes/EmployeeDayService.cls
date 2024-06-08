public with sharing class EmployeeDayService {
    
    public String assignStory(
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
        String breakingNews
    ) {
        if(scheduleId == '') {
            List<String> dateData = dayDate.split('-');
            Date scheduleDate = Date.newInstance(
                Integer.valueOf(dateData[0]), 
                Integer.valueOf(dateData[1]), 
                Integer.valueOf(dateData[2]));
            List<Schedule__c> scheduleSearchResult =
                ScheduleSelector.selectByDateAndBureau(scheduleDate, (Id) bureauId);

            if(scheduleSearchResult.size() == 1) {
                scheduleId = scheduleSearchResult[0].Id;
            }else{
                Schedule__c schedule = new Schedule__c (
                    Date__c = scheduleDate,
                    Bureau__c = bureauId
                );
                insert schedule;
                scheduleId = schedule.Id;
            }
        }

        StoryAssignationResult assignationResult = new StoryAssignationResult();
        List<Story_Schedule_Association__c> storyScheduleAssociation = 
        this.verifyStorySchduleAssociationExist(
            (Id) storyId,
            (Id) locationId,
            (Id) scheduleId,
            (Id) costCenterId
        );
        
        if(storyScheduleAssociation.size() == 0){
            storyScheduleAssociation.add(
                StoryScheduleAssociationSelector.insertRecord(
                    (Id) storyId,
                    (Id) locationId,
                    (Id) scheduleId,
                    (Id) costCenterId
                )
            );
        }
        assignationResult.storyScheduleAssociation = storyScheduleAssociation[0];
        ScheduleAssociation__c storyEmployeeAssociation = new ScheduleAssociation__c();
        storyEmployeeAssociation.Story_Schedule_Association__c = storyScheduleAssociation[0].Id;
        storyEmployeeAssociation.Assignment_Information__c = assignmentInformation;
        storyEmployeeAssociation.Employee__c = employeeId;
        storyEmployeeAssociation.Live_Shot__c = liveShot;
        storyEmployeeAssociation.Prosumer_Used__c = prosumerUsed;
        storyEmployeeAssociation.Breaking_News__c = breakingNews;
        insert storyEmployeeAssociation;
        assignationResult.storyEmployeeAssociation = storyEmployeeAssociation;
        return (String) JSON.serialize(assignationResult);
    
    }

    //multiple assignments
    public String assignStory(
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
        List<String> endDateComponents = new List<String>();
        List<Schedule__c> newSchedules = new List<Schedule__c>();
        List<Date> dateList = new List<Date>();
        List<Date> missingScheduleDates = new List<Date>();
        List<Date> missingSSADates = new List<Date>();
        List<Story_Schedule_Association__c> storyScheduleAssociations = new List<Story_Schedule_Association__c>();
        List<Story_Schedule_Association__c> newStoryScheduleAssociations = new List<Story_Schedule_Association__c>();
        List<StoryAssignationResult> assignationResults = new List<StoryAssignationResult>();
        Map<Date, StoryAssignationResult> assignationResultsMap = new Map<Date, StoryAssignationResult>();
        List<ScheduleAssociation__c> seaList = new List<ScheduleAssociation__c>();
        Map<Date, Schedule__c> scheduleSearchResultMap = new Map<Date, Schedule__c>();
        Map<Date, Story_Schedule_Association__c> ssaSearchResultMap = new Map<Date, Story_Schedule_Association__c>();

        endDateComponents = endDate.split('-');
        Date parsedEndDate = Date.newInstance(
            Integer.valueOf(endDateComponents[0]), 
            Integer.valueOf(endDateComponents[1]), 
            Integer.valueOf(endDateComponents[2])
        );

        List<String> dateData = dayDate.split('-');
        Date scheduleDate = Date.newInstance(
            Integer.valueOf(dateData[0]), 
            Integer.valueOf(dateData[1]), 
            Integer.valueOf(dateData[2]));

        Date startDateIndex = scheduleDate;

        while (startDateIndex <= parsedEndDate) {
            dateList.add(startDateIndex);
            startDateIndex = startDateIndex.addDays(1);
        }   
        
        List<Schedule__c> scheduleSearchResult =
            ScheduleSelector.selectByDatesAndBureau(scheduleDate, parsedEndDate, (Id) bureauId);

        for (Schedule__c sch : scheduleSearchResult) scheduleSearchResultMap.put(sch.Date__c, sch);


        
        for (Date day : dateList) {
            if(!scheduleSearchResultMap.containsKey(day)) missingScheduleDates.add(day);
        }

        for(Date missingDate : missingScheduleDates){
            if(!scheduleSearchResultMap.containsKey(missingDate)) {
                Schedule__c schedule = new Schedule__c (
                    Date__c = missingDate,
                    Bureau__c = bureauId
                );
                newSchedules.add(schedule);
            }
        }
        insert newSchedules;

        for (Schedule__c sch : newSchedules) scheduleSearchResultMap.put(sch.Date__c, sch);

        storyScheduleAssociations = 
            StoryScheduleAssociationSelector.selectByStoryLocationScheduleDatesAndCostCenter(
                (Id) storyId, 
                (Id) locationId, 
                (Id) costCenterId, 
                scheduleSearchResultMap.values()
            );

        System.debug('storyScheduleAssociations: ' + storyScheduleAssociations);
        
        for (Story_Schedule_Association__c ssa : storyScheduleAssociations) {
            ssaSearchResultMap.put(ssa.Schedule__r.Date__c, ssa);
        }

        for (Date day : dateList) {
            if(!ssaSearchResultMap.containsKey(day)) missingSSADates.add(day); 
        }

        for(Date missingDate : missingSSADates){
            if(!ssaSearchResultMap.containsKey(missingDate)) {
                Story_Schedule_Association__c storyScheduleAssociation =
                    new Story_Schedule_Association__c(
                        Story__c = storyId,
                        Location__c = locationId,
                        Schedule__c = scheduleSearchResultMap.get(missingDate).Id,
                        Cost_Center__c = costCenterId
                    );
                newStoryScheduleAssociations.add(storyScheduleAssociation);
            }
        }
        insert newStoryScheduleAssociations;
        Map<Id, Schedule__c> scheduleIdMap = new Map<Id, Schedule__c>(scheduleSearchResultMap.values());
        for(Story_Schedule_Association__c ssa : newStoryScheduleAssociations){
            ssaSearchResultMap.put(scheduleIdMap.get(ssa.Schedule__c).Date__c, ssa);
        }
        

        for (Date currentDate : dateList) {
            EmployeeDayService.StoryAssignationResult result = new EmployeeDayService.StoryAssignationResult();
            result.schedule = scheduleSearchResultMap.get(currentDate);
            result.storyScheduleAssociation = ssaSearchResultMap.get(currentDate);
            ScheduleAssociation__c storyEmployeeAssociation = new ScheduleAssociation__c();
            storyEmployeeAssociation.Story_Schedule_Association__c = ssaSearchResultMap.get(currentDate).Id;
            storyEmployeeAssociation.Assignment_Information__c = assignmentInformation;
            storyEmployeeAssociation.Employee__c = employeeId;
            storyEmployeeAssociation.Live_Shot__c = liveShot;
            storyEmployeeAssociation.Prosumer_Used__c = prosumerUsed;
            storyEmployeeAssociation.Breaking_News__c = breakingNews;

            seaList.add(storyEmployeeAssociation);
            assignationResultsMap.put(currentDate, result);
        }

        Set<Id> newSeaSetId = new Set<Id>();
        List<Database.SaveResult> assignmentsInsertResult = Database.insert(seaList, false);

        for (Database.SaveResult res : assignmentsInsertResult) {
            if(res.isSuccess()) newSeaSetId.add(res.getId());
        }

        List<ScheduleAssociation__c> newSeaList = new List<ScheduleAssociation__c>();
        newSeaList = StoryEmployeeAssociationSelector.selectById(newSeaSetId);

        for (ScheduleAssociation__c sea : newSeaList) {
            assignationResultsMap.get(sea.Schedule_Date__c).storyEmployeeAssociation = sea;
        }

        return (String) JSON.serialize(assignationResultsMap.values());  
    }

    public List<Story_Schedule_Association__c> verifyStorySchduleAssociationExist(
        Id storyId,
        Id locationId,
        Id scheduleId,
        Id costCenterId
    ) {
        List<Story_Schedule_Association__c> result = 
            StoryScheduleAssociationSelector.selectByStoryLocationScheduleAndCostCenter(
                storyId,
                locationId,
                scheduleId,
                costCenterId
            );

        return result;
    }

    public String canDeleteSSA(String seaId) {
        ScheduleAssociation__c sea = new ScheduleAssociation__c();
        Story_Schedule_Association__c ssa = new Story_Schedule_Association__c();
        List<ScheduleAssociation__c> otherRelatedSEAs = new List<ScheduleAssociation__c>();
        String result = 'NOT DELETABLE';
        sea = [
            SELECT Id, Story_Schedule_Association__c
            FROM ScheduleAssociation__c
            WHERE Id =: seaId
        ];
        Set<Id> ssaIdSet = new Set<Id>();
        ssaIdSet.add(sea.Story_Schedule_Association__c);
        otherRelatedSEAs = StoryEmployeeAssociationSelector.selectByStoryScheduleAssociationId(ssaIdSet);
        
        if(otherRelatedSEAs.size() <= 1) result = String.valueOf(sea.Story_Schedule_Association__c);
        
        return result;
    }


    public class StoryAssignationResult {
        Schedule__c schedule;
        Story_Schedule_Association__c storyScheduleAssociation;
        ScheduleAssociation__c storyEmployeeAssociation;
    }

}