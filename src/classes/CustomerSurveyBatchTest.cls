@IsTest
private class CustomerSurveyBatchTest {

    @IsTest
    static void sendEmailsThroughBatch(){
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            accounts.add(new Account(Name='Survey'+i));
        }
        insert accounts;

        Datetime dt = System.Now().addDays(-3);
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < accounts.size(); i++) {
            for (Integer j = 0; j < 1; j++) {
                if(Math.mod(i,2) == 0){
                    contacts.add(new Contact(FirstName = 'TestDen'+i,LastName = 'LastDen'+i, Email = 'testDen'+i+'@testDen'+i+'.com',language__c = 'de',
                            survey_date__c = dt, AccountId = accounts.get(i).Id ));
                } else
                        contacts.add(new Contact(FirstName = 'SurveyEna'+i,LastName = 'SurEne'+i, Email = 'recipientEna'+i+'@survey'+i+'.com',language__c = 'en',
                        survey_date__c = dt, AccountId = accounts.get(i).Id ));
            }
        }
        insert contacts;

        Test.startTest();
        Database.executeBatch(new CustomerSurveyBatch(),100);
        Test.stopTest();


        List<Contact> contactsProcessed = [SELECT Id, survey_date__c FROM Contact WHERE survey_date__c = null];
        System.assertEquals(100, contactsProcessed.size());
    }
}