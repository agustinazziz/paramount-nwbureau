public with sharing class weeklyDashboardService {
    
    //<Day, Schedule__c.Id>
    public Map<String, Schedule__c> weekDates = new Map<String, Schedule__c>();
    //Schedule__c date, Schedule__c
    Map<Date, Schedule__c> scheduleMap =new Map<Date, Schedule__c>();
    Map<Id, CostCenter__c> costCentersMap = 
        new Map<Id, CostCenter__c>(CostCenterSelector.selectAll());

    public void setWeekDates(Date weekStart, Date weekEnd) {
        List<String> days = new List<String>{
            'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'
        };

        for(String day : days) {

            this.weekDates.put(
                day,
                this.scheduleMap.get(weekStart.addDays(days.indexOf(day)))
            );
        }
    }

    public Map<String, Schedule__c> getWeekDates(Date weekStart, Date weekEnd, Id bureau) {
        List<Schedule__c> weekSchedules = 
            ScheduleSelector.selectByDateRangeAndBureau(weekStart, weekEnd, bureau);
        Set<Id> weekScheduleIds = new Set<Id>();
        
        for (Schedule__c schedule : weekSchedules) {
            weekScheduleIds.add(schedule.Id);
            this.scheduleMap.put(schedule.Date__c, schedule);
        }

        this.setWeekDates(weekStart, weekEnd);
        return this.weekDates;
    }

    public List<weeklyDashboardService.WeekData> getWeekData(
        Date weekStart,
        Date weekEnd,
        Id bureau
    ) {
        List<Schedule__c> weekSchedules = 
            ScheduleSelector.selectByDateRangeAndBureau(weekStart, weekEnd, bureau);
        Set<Id> weekScheduleIds = new Set<Id>();
        
        for (Schedule__c schedule : weekSchedules) {
            weekScheduleIds.add(schedule.Id);
            this.scheduleMap.put(schedule.Date__c, schedule);
        }
        this.setWeekDates(weekStart, weekEnd);
        List<Story_Schedule_Association__c> storyScheduleAssociations =
            StoryScheduleAssociationSelector.selectByScheduleId(weekScheduleIds);
        Set<Id> storyIds = new Set<Id>();
        Set<Id> storyScheduleAssociationIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        
        for (Story_Schedule_Association__c storyScheduleAssociation: storyScheduleAssociations) {
            storyScheduleAssociationIds.add(storyScheduleAssociation.Id);
            storyIds.add(storyScheduleAssociation.Story__c);
            locationIds.add(storyScheduleAssociation.Location__c);
        }
        Map<Id, Location__c> locations = 
            new Map<Id, Location__c>(LocationSelector.selectById(locationIds));

        List<ScheduleAssociation__c> storyEmployeeAssociations = 
            StoryEmployeeAssociationSelector.selectByStoryScheduleAssociationId(storyScheduleAssociationIds);
        
        Set<Id> employeeIds = new Set<Id>();
        for (ScheduleAssociation__c storyEmployeeAssociation : storyEmployeeAssociations) {
            employeeIds.add(storyEmployeeAssociation.Employee__c);
        }
        List<Contact> employees = EmployeeSelector.selectById(employeeIds);
        Map<Id, Story__c> stories = new Map<Id, Story__c>(StorySelector.selectById(storyIds));

        //Schedule__c Id => Story_Schedule_Association__c 
        Map<Id, Story_Schedule_Association__c> scheduleStoryScheduleAssociationsMap =
            new Map<Id, Story_Schedule_Association__c>();
        //Story_Schedule_Association__c Id => Story_Schedule_Association__c 
        Map<Id, Story_Schedule_Association__c> storyScheduleAssociationsMap =
            new Map<Id, Story_Schedule_Association__c>();
        //Employee__c Id => ScheduleAssociation__c
        Map<Id, ScheduleAssociation__c> storyEmployeeAssociationsMap =
            new Map<Id, ScheduleAssociation__c>();
        
        for(Story_Schedule_Association__c storyScheduleAssociation : storyScheduleAssociations){
            scheduleStoryScheduleAssociationsMap.put(
                storyScheduleAssociation.Schedule__c,
                storyScheduleAssociation
            );
            storyScheduleAssociationsMap.put(
                storyScheduleAssociation.Id,
                storyScheduleAssociation
            );
        }

        for(ScheduleAssociation__c storyEmployeeAssociation : storyEmployeeAssociations){
            storyEmployeeAssociationsMap.put(
                storyEmployeeAssociation.Id,
                storyEmployeeAssociation
            );
        }
        
        List<WeekData> weekDataList = new List<WeekData>();
        User user = [SELECT Id, ScreenResolution__c FROM User WHERE Id =: userInfo.getUserId()];
        Integer labelMaxWidth;
        switch on user.ScreenResolution__c {
            when 'Full HD 1920x1080' {
                labelMaxWidth = 30;
            }
            when 'HD+ 1600x900' {
                labelMaxWidth = 23;
            }
            when 'HD 1366x768' {
                labelMaxWidth = 18;
            }
        }
 
        for(Contact employee : employees) {
            WeekData tempoWeekData = new WeekData();
            tempoWeekData.employeeId = employee.Id;
            tempoWeekData.employeeName = employee.Name;
            // AA 03/29/2024 Added LastName to the employee data to order the employees by lastname.
            tempoWeekData.employeeLastName = employee.LastName;
            tempoWeekData.employeeTitle = employee.Employee_Title__c;
            tempoWeekData.employeeLocation = employee.Location__c;
            List<ScheduleAssociation__c> currentEmployeeStoryEmployeeAssociations = 
                new List<ScheduleAssociation__c>();
            for(ScheduleAssociation__c storyEmployeeAssociation : storyEmployeeAssociations) {
                if(storyEmployeeAssociation.Employee__c == employee.Id) {
                    currentEmployeeStoryEmployeeAssociations.add(storyEmployeeAssociation);
                }
            }
            for(String day : weekDates.keySet()) {
                List<StoryData> tempoStoriesList = new List<StoryData>();
                for(
                    ScheduleAssociation__c currentStoryEmployeeAssociation :
                    currentEmployeeStoryEmployeeAssociations
                ) {
                    StoryData tempoStoryData = new StoryData();
                    Id currentStoryScheduleAssociation = 
                        currentStoryEmployeeAssociation.Story_Schedule_Association__c;

                    Id currentCostCenter = 
                        storyScheduleAssociationsMap.get(currentStoryScheduleAssociation).Cost_Center__c;

                    Id storyScheduleAssociationScheduleId = 
                        storyScheduleAssociationsMap.get(currentStoryScheduleAssociation).Schedule__c;

                    String currentLocation = 
                        locations.get(
                            storyScheduleAssociationsMap.get(currentStoryScheduleAssociation).Location__c
                        ).Name;

                    tempoStoryData.alternativeText = currentLocation;

                    tempoStoryData.label = this.costCentersMap.get(currentCostCenter).Name + ' - ' +
                        stories.get(storyScheduleAssociationsMap.get(currentStoryScheduleAssociation).Story__c).Name;
                    if(tempoStoryData.label.length() > labelMaxWidth) {
                        tempoStoryData.label = tempoStoryData.label.substring(0, (labelMaxWidth - 1)) + '...';
                    }
                    
                    tempoStoryData.href = '/' + storyEmployeeAssociationsMap.get(currentStoryEmployeeAssociation.Id).Id;
                    tempoStoryData.name = storyEmployeeAssociationsMap.get(currentStoryEmployeeAssociation.Id).Id;

                    tempoStoryData.schedule = storyScheduleAssociationsMap.get(
                        storyEmployeeAssociationsMap.get(currentStoryEmployeeAssociation.Id).Story_Schedule_Association__c
                    ).Schedule__c;

                    tempoStoryData.location = currentLocation;
                    try {
                        Id currentSchedule = weekDates.get(day).Id;
                        if(
                            currentSchedule == storyScheduleAssociationScheduleId &&
                            currentStoryEmployeeAssociation.Employee__c == employee.Id
                        ) {
                            tempoStoriesList.add(tempoStoryData);
                        }else {
                            tempoWeekData.stories.put(day, new List<StoryData>());
                        }
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                        tempoWeekData.stories.put(day, new List<StoryData>());
                    }
                }//story Employee  end
                tempoWeekData.stories.put(day, tempoStoriesList);
                tempoWeekData.weekDates = weekDates;
            }
            weekDataList.add(tempoWeekData);
        }
        List<String> internationalBureaus  = new List<String>(System.Label.International_Ids.split(','));
        String bureauId = String.valueOf(bureau);
        Profile currentUserProfile = [
            SELECT Id, Name
            FROM Profile
            WHERE Id =: UserInfo.getProfileId()
        ];
        
        if(currentUserProfile.Name == 'Bureau Weekly Users - INT'){
            WeeklyDashboardInternationalSorting sortWeekData = 
                new WeeklyDashboardInternationalSorting(weekDataList.clone(), employees);
            return sortWeekData.sortedWeekData;
        }else{
            WeeklyDashboardSorting sortWeekData = 
                new WeeklyDashboardSorting(weekDataList.clone(), employees);
            return sortWeekData.sortedWeekData;
        }   
    }

    public Date parseDateString(String dateString) {
        List<String> dateStringData = dateString.split('-');
        Date parsedDateString = 
            Date.newInstance(
                Integer.valueOf(dateStringData[0]), 
                Integer.valueOf(dateStringData[1]), 
                Integer.valueOf(dateStringData[2])
            );
        return parsedDateString;
    }


    public class WeekData {
        public String sortingGroup;
        public Id employeeId;
        public String employeeName;
        public String employeeLastName;
        public String employeeTitle;
        public String employeeLocation;
        public Map<String, Schedule__c> weekDates = new Map<String, Schedule__c>();
        Map<String, List<StoryData>> stories = new Map<String, List<StoryData>>();
    }
    public class StoryData {
        final String type = 'avatar';
        String alternativeText;
        final String fallbackIconName = 'standard:address';
        String label;
        String href;
        String name;
        String schedule;
        String location;
    }
     
}