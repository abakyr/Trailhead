global class CustomerSurveyBatch implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        DateTime currentTime = System.now();
        return Database.getQueryLocator('SELECT Id, Email, FirstName, language__c, survey_date__c FROM Contact ' +
                'WHERE survey_date__c != null AND survey_date__c <: currentTime AND Email != null LIMIT 5000');
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

        EmailTemplate de_Survey = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = 'DE_SurveyTemplate'];
        EmailTemplate en_Survey = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = 'EN_SurveyTemplate'];
        List<Messaging.SingleEmailMessage> allMessages = new List<Messaging.SingleEmailMessage>();
        Map<Id,Contact> allRespondentsMap = new Map<Id,Contact>();

        for ( Contact respondent : scope ){
            allRespondentsMap.put(respondent.Id, respondent);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if( respondent.language__c == 'de' ){
                mail.setHtmlBody(de_Survey.HtmlValue);
                mail.setPlainTextBody(de_Survey.Body);
                mail.setTemplateId(de_Survey.Id);
                mail.setSubject(de_Survey.Subject);
            } else {
                mail.setHtmlBody(en_Survey.HtmlValue);
                mail.setPlainTextBody(en_Survey.Body);
                mail.setTemplateId(en_Survey.Id);
                mail.setSubject(en_Survey.Subject);
            }
            mail.setSenderDisplayName('N26 Survey');
            mail.setReplyTo('support@n26.com');
            mail.setUseSignature(false);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(respondent.Id);
            mail.setWhatId(respondent.Id);
            allMessages.add(mail);
        }

        try{
            if( !allMessages.isEmpty() ){
                Messaging.SendEmailResult[] results = Messaging.sendEmail( allMessages );
                for (Integer i = 0; i < allMessages.size(); i++) {
                    Messaging.SendEmailResult result = results[i];
                    Id contactId = allMessages[i].targetObjectId;
                    if( !result.isSuccess() ){
                        allRespondentsMap.remove(contactId);
                    } else {
                        allRespondentsMap.get(contactId).survey_date__c = null;
                    }
                }
            }
        } catch (Exception e){
            System.debug(e.getMessage());
        }

        update allRespondentsMap.values();
    }

    global void finish(Database.BatchableContext BC){}
}