public class ReprocessWorkforceQueueInvocable {
    
    @InvocableMethod(label='Reprocess Workforce Queue')
    public static void reprocessQueue() {

        ApexClass batchClassName = [
            SELECT Id
            FROM ApexClass 
            WHERE Name='WeekCloningBatchProcess'
        ]; 
        List<AsyncApexJob>  cloningBatchJobs = [
            SELECT JobType, Id, Status, ApexClassId 
            FROM AsyncApexJob
            WHERE ApexClassId =: batchClassName.Id
            AND Status = 'Queued'
        ];
        if(cloningBatchJobs.size() == 0) {
            Database.executeBatch(
                new ProcessStagingTableBatch()
            );
        }
        
    }
}