@isTest
public class TestGBASController{
    @isTest
    private static void test(){
        LIST<Case> caseList = [Select id,SuppliedName from Case LIMIT 1];
        
        GBASController obj = new GBASController();
        obj.checkTermsAndCondtion = true;
        obj.saveCase();
       
        
        obj.caseObj.SuppliedCompany = 'testcompany';
        obj.saveCase();
        
        obj.caseObj.SuppliedName = 'testrequestor';
        obj.saveCase();
        
        obj.caseObj.SuppliedPhone = '1234567890';
        obj.saveCase();
        
        obj.caseObj.SuppliedEmail = 'test@gmail.com';
        obj.saveCase();
        
        obj.caseObj.Product_Number__c = '12345';
        obj.saveCase();
        //obj1.caseObj.Product_Number__c = '12345';
        //obj1.saveCase();
        
        obj.caseObj.Quantity__c = 2;
        obj.saveCase();
        
        obj.caseObj.PO_No__c  = '12345';
        obj.saveCase();
        
        obj.caseObj.Media__c = 'testmedia';
        obj.saveCase();
        
        obj.warSecondVal = false;
        obj.nonWarThirdVal = false;
        obj.warFirstVal = false;
        obj.nonWarSecondVal = false;
        
        obj.warThirdVal = true;
        obj.nonWarFirstVal = true;
        obj.saveCase();
        
        obj.warThirdVal = false;
        obj.nonWarFirstVal = false;
        obj.warFirstVal = false;
        obj.nonWarSecondVal = false;
        
        obj.warSecondVal = true;
        obj.nonWarThirdVal = true;
        obj.returnCW = 'testing';
        obj.AccCW = 'testing';
        obj.saveCase();
        
        obj.warSecondVal = false;
        obj.nonWarThirdVal = false;
        obj.warThirdVal = false;
        obj.nonWarFirstVal = false;
        
        obj.caseObj.Description = 'testdesp';
        obj.warFirstVal = true;
        obj.nonWarSecondVal = true;
        obj.caseObj.Max_Repair_Cost__c = 500;
        obj.returnCW = 'testing';
        obj.AccCW = 'testing';
        obj.atchList[0] .name='test.jpg';
        obj.atchList[0].body = Blob.valueOf('testing');
        obj.saveCase();
        obj.openCaseRecord();
        
        
        Account act = new Account(name='testaccoout');
        insert act;
        
        Contact con = new Contact(lastname='test',email='test@gmail.com',accountId = act.id);
        insert con;
        
        
        CaseForPaperCreditController obj1 = new CaseForPaperCreditController();
        obj1.saveCase();
        
        obj1.caseObj.SuppliedCompany = 'testcompany';
        obj1.saveCase();
        
        obj1.caseObj.SuppliedName = 'testrequestor';
        obj1.saveCase();
        
        obj1.caseObj.SuppliedEmail = 'test@gmail.com';
        obj1.saveCase();
        
        obj1.caseObj.PO_No__c  = '12345';
        obj1.saveCase();
        
        obj1.caseObj.Gems_Invoice_Number__c = '111';
        obj1.saveCase();
        
        obj1.caseObj.Description = 'testdesp';
        obj1.saveCase();
        
        obj1.atchList[0] .name='test.jpg';
        obj1.atchList[0].body = Blob.valueOf('testing');
        obj1.saveCase();
        
        obj1.openCaseRecord();
        
    }
}