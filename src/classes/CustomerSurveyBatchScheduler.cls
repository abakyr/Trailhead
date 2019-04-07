public with sharing class CustomerSurveyBatchScheduler implements Schedulable{

    public void execute(SchedulableContext sc){

        CustomerSurveyBatch batchProcess = new CustomerSurveyBatch();
        BulkBatchSize__c bulkObj = BulkBatchSize__c.getInstance('defaultBatch');
        Integer batchSize;
        if( bulkObj != null ) batchSize = Integer.ValueOf(bulkObj.SurveyBatch__c);
        if((batchSize != null && (batchSize > 100 || batchSize <= 0)) || batchSize == null ) {
            batchSize = 100;
        }

        try {
            Database.executeBatch(batchProcess, batchSize);
        } catch(Exception ex) {
            return;
        }
    }
}