public class CaseHandlerClass {
  public static void updateConexiomCaseStatus(List<EmailMessage> caseEmail) {
        User conexUser = [SELECT Id FROM User WHERE Name = 'User Conexiom' LIMIT 1];
        List<Id> listIds = new List<Id>();
        List<Case> caseToUpdate = new List<Case>();
        for (EmailMessage eMsg : caseEmail) {            
            listIds.add(eMsg.ParentId);
        }
        system.debug(' updateConexiomCaseStatus : '+listIds);
        List<Case> emailCases = [select id,status,accountid,CreatedDate, CaseNumber,OwnerId,Sent_to_Conexiom__c,account.Conexiom_User__c FROM Case WHERE Id IN :listIds and Sent_to_Conexiom__c = false];
        for (Case cas : emailCases) {
            cas.Sent_to_Conexiom__c=true;
            cas.Status='In Progress';
            cas.OwnerId=conexUser.Id;
            caseToUpdate.add(cas);
        }        
        update caseToUpdate;
    }
}