@isTest
public class TestCaseReturnLabelController {
     public static testMethod void createNewPreview() {
      	User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
        case caseObj1 = new case(AccountId=act.id,
                            ContactId = con.id);
        insert caseObj1;
         
      CaseReturnLabelController cont = new CaseReturnLabelController(new ApexPages.StandardController(caseObj1));
      Test.startTest();    
      PageReference testPage = Page.CaseReturnLabel;
      Test.setCurrentPage(testPage);
         
      Test.stopTest();
   }

}