@isTest
public class CaseAutoResponseTest {
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
        Case newCase = new Case(Item_Return_PO__c='24134',ContactId = con.id, AccountId = acc2.id,Product_Number__c = '1q2w3e', Type = 'RA',Status='New' );
        insert newCase;
      	List<id> Ids= New List<Id>();
      	Ids.add(newCase.id);
        
    	CaseAutoResponse.sendAutoResponseEmail(Ids);
        
      Test.stopTest();
   }
}