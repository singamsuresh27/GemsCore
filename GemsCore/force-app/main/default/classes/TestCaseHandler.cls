@isTest
public class TestCaseHandler{
      static testMethod void emailConexiom() {
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account acc = new Account(Name = 'Acc',Conexiom_User__c=true);
        insert acc;
        ID acctID = acc.ID;
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com',AccountId=acctID);
        insert con;
        Case c = new Case();
        c.Subject = 'TestCaseHandler'; 
        c.ContactId = con.id;
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;
        system.debug(' C : '+c.id);
          
        //Insert emailmessage for case
      EmailMessage email = new EmailMessage();
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.FromAddress = 'test@abc.org';
        email.Incoming = false;
        email.ToAddress= 'conexiom.net@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
        system.debug(' RelatedTo : '+email.RelatedTo.Id);
          system.debug(' emailParent : '+email.ParentId);
          test.startTest();
        List<EmailMessage> emailLst = new List<EmailMessage>();
        emailLst.add(email);
        CaseHandlerClass.updateConexiomCaseStatus(emailLst);
          test.stopTest();
   }
 
}