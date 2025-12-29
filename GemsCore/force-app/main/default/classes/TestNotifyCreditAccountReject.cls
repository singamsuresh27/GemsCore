@isTest
public class TestNotifyCreditAccountReject {
     public static testMethod void notifyOwner() {
    	String contactId;
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test1@gmail.com', role__c='Primary', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
              
      	contactId = con.id;
         NotifyCreditAccountReject.FlowInputs firstInput = new NotifyCreditAccountReject.FlowInputs();
         firstInput.contactId=contactId;
         firstInput.accountId=act.id;
         NotifyCreditAccountReject.SendEmail(
            new List<NotifyCreditAccountReject.FlowInputs>{firstInput}
        );
       	Test.startTest();   
     }
}