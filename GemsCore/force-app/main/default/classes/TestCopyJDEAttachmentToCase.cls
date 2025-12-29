@isTest
public class TestCopyJDEAttachmentToCase {
       static testMethod void copyAttachment() {
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account acc = new Account(Name = 'Acc',Conexiom_User__c=false);
        test.startTest();
        insert acc;
        ID acctID = acc.ID;
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com',AccountId=acctID);
        insert con;
        Case c = new Case(ContactId = con.id, AccountId = acc.id, Type = 'RA' ,Gems_SO_Number__c='SO123');
        insert c;
        
           //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'SO123:Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
          
        Attachment attachment = new Attachment();
        Blob bodyBlob  = Blob.valueOf('Unit Test Attachment Body');
        attachment.body       = bodyBlob;
        attachment.Name       = 'attach';
        attachment.ParentId = email.Id;
        Insert attachment;
                  
        List<string> emailIds = new list<string>();
        emailIds.add(email.Id);
        copyJDEAttachmentToCase.parseCase(emailIds);
          
        Test.stopTest();
       } 
   }