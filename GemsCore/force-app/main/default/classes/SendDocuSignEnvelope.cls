// Apex class to send docusign envelope
//Test class : TestSendDocuSignEnvelope


public class SendDocuSignEnvelope {
  
    public class FlowInputs {
        @InvocableVariable
        public Contact record;
        @InvocableVariable
        public String formName; 
    }
    
   @InvocableMethod
  public static List<String> sendEnvelope(FlowInputs[] currentInput) {
      
    Contact mySource = currentInput[0].record;  
    string formName = currentInput[0].formName;
    sendEnvelopeInFuture(mySource.Id,formName);
    String emailSubject = '';
    String emailBody = '';
    return Null;
  }

   @future(callout = true)
  public static void sendEnvelopeInFuture(Id mySourceId, string formName) {
    createAndSendEnvelope(mySourceId,formName);
  }
   
   public static Id createAndSendEnvelope(Id mySourceId,string formName) {
       
    List<dfsle__EnvelopeConfiguration__c> envlope = new List<dfsle__EnvelopeConfiguration__c>();
    string templateName;   
    dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
      new dfsle.Entity(mySourceId)
    );
    Contact myContact = [SELECT Name, Email FROM Contact WHERE Id = :mySourceId LIMIT 1];
    dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
      myContact.Name,
      myContact.Email,
      null,
      'Signer1',
      new dfsle.Entity(myContact.Id)
    );
       
    myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });
    dfsle.UUID myTemplateId;
       if(formName == 'Contact')
       {
           templateName = 'CEMS Contact Form';
           myTemplateId = dfsle.UUID.parse('8fd83ca7-aca9-4f07-b084-559556111480');
       }
       else if (formName == 'MSA')
       {
           templateName='MSA';
           myTemplateId = dfsle.UUID.parse('d3fffd1f-7b37-4234-a77b-b46e78c8cdd1');
       }
       else
       {
           templateName = '';
       }
    
   // dfsle__EnvelopeConfiguration__c DocuSignEnvelope = [SELECT dfsle__EmailMessage__c,dfsle__EmailSubject__c,dfsle__DocuSignId__c FROM dfsle__EnvelopeConfiguration__c WHERE Name =: templateName LIMIT 1];
	    	envlope = [SELECT id,Name,dfsle__EmailMessage__c, dfsle__EmailSubject__c,dfsle__DocuSignId__c FROM dfsle__EnvelopeConfiguration__c WHERE Name =: templateName LIMIT 1];
           if(envlope.size() > 0)
    			myEnvelope = myEnvelope.withEmail(envlope[0].dfsle__EmailSubject__c,envlope[0].dfsle__EmailMessage__c);
       
            dfsle.Document myDocument = dfsle.Document.fromTemplate(
              myTemplateId,
              'Master Services Agreement'
            );
               
            myEnvelope = myEnvelope.withDocuments(
              new List<dfsle.Document> { myDocument }
            );
            myEnvelope = dfsle.EnvelopeService.sendEnvelope(
              myEnvelope,
              true
            );
            return myEnvelope.Id;
   		/*}
       else
       {
           system.debug(' DocuSign envelope not available for form : '+formName);
            
           return null;
       }*/
  }
}