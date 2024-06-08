public class batchProcessMonitorController {
    
    @AuraEnabled
    public static string getBatchStatus() {

        List<User> userBureaus = new List<User>();
        List<AsyncApexJob> inProgressJobs = new List<AsyncApexJob>();
        BatchStatusResponse responseObject = new BatchStatusResponse();
        Set<Id> currentBureauUsers = new Set<Id>();
        Set<String> apexClasses = new Set<String>{
            'WeekCloningBatchProcess', 'StoryCloneBatchProcess', 
            'StoryCloneBatchInsertProcess', 'DayCloneBatchProcess'
        };
        Id currentUserBureau;
        String responseString;

        Id currentUserId = System.UserInfo.getUserId();
        userBureaus = [
            SELECT Id, Dashboard_Bureau__c 
            FROM User
        ];

        Map<Id, User> usersMap = new Map<Id, User>(userBureaus);
        currentUserBureau = usersMap.get(currentUserId).Dashboard_Bureau__c;

        for (User user : userBureaus) {
            if(user.Dashboard_Bureau__c == currentUserBureau) {
                currentBureauUsers.add(user.Id);
            }
        }

        inProgressJobs = [
            SELECT ApexClass.Name, CreatedById, JobItemsProcessed, Status, TotalJobItems 
            FROM AsyncApexJob
            WHERE Status IN ('Queued', 'Processing', 'Preparing', 'Holding')
            AND CreatedById IN: currentBureauUsers
            AND ApexClass.Name IN: apexClasses
        ];

        Integer totalNumber = 0;
        Integer processed = 0;

        if(inProgressJobs.size() > 0){
            for (AsyncApexJob job : inProgressJobs) {
                totalNumber = totalNumber + job.TotalJobItems;
                processed = processed + job.JobItemsProcessed;
            }
            responseObject.jobsInProgress = true;
            responseObject.total = totalNumber;
            responseObject.processed = processed;
        } else {
            responseObject.jobsInProgress = false;
            responseObject.processed = 0;
            responseObject.total = 0;
        }
        responseString = JSON.serialize(responseObject);
        return responseString;
    }

    public class BatchStatusResponse {
        public Boolean jobsInProgress;
        public Integer total;
        public Integer processed;
    }
}