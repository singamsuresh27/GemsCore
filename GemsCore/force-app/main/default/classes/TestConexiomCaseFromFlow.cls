@isTest
public class TestConexiomCaseFromFlow {
	static testMethod void createNewCase() {
    	test.startTest();
      	User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      	Account acc = new Account(Name = 'Acc',Business_Unite__c='GEMS_NA',type='Global Account',Bill_To_Acct_No__c='123',Conexiom_User__c=true);
       
        insert acc;        
        ID acctID = acc.ID;
        Account acc2 = new Account(Name = 'Acc2',Business_Unite__c='GEMS_NA',ParentId = acc.Id);
        insert acc2;
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com',AccountId=acc2.Id);
        insert con;
        Case c = new Case(Item_Return_PO__c='24134',ContactId = con.id, AccountId = acc2.id,Product_Number__c = '1q2w3e', Type = 'RA',Status='New' );
        insert c;
        
           //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.TextBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
          
        Attachment attachment = new Attachment();
        attachment.ParentId   = email.Id;
        Blob bodyBlob  = Blob.valueOf('Unit Test Attachment Body');
        attachment.body       = bodyBlob;
        attachment.Name       = 'attach1.pdf';
        attachment.ContentType = 'application/pdf';
        Insert attachment;
        
        Attachment attachment2 = new Attachment();
        attachment2.ParentId   = email.Id;
        bodyBlob  = Blob.valueOf('Unit Test Attachment Body');
        attachment2.body       = bodyBlob;
        attachment2.Name       = 'attach2';
        attachment2.ContentType = 'application/pdf';
        Insert attachment2;
        
        Messaging.EmailFileAttachment emailAttachment;
           if (attachment.Body != null) {
                emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setBody(attachment.Body);
                emailAttachment.setFileName(attachment.Name);
            }
         if (attachment2.Body != null) {
                emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setBody(attachment2.Body);
                emailAttachment.setFileName(attachment2.Name);
            }
      List<id> Ids= New List<Id>();
      Ids.add(email.id);
      
        conexiomCaseFromFlow.flowInputs inpt = new conexiomCaseFromFlow.flowInputs();
    	inpt.currentRecordId = email.Id;
    	inpt.myCustomString='Conexiom';
        
    	conexiomCaseFromFlow.parseCase(new List<conexiomCaseFromFlow.flowInputs>{inpt});
        
        inpt = new conexiomCaseFromFlow.flowInputs();
    	inpt.currentRecordId = email.Id;
    	inpt.myCustomString='Esker';
        
    	conexiomCaseFromFlow.parseCase(new List<conexiomCaseFromFlow.flowInputs>{inpt});
        
      Test.stopTest();
   }
}