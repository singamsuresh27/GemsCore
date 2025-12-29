@isTest
public class TestBarcodeGenClass {
    @isTest static void genBarcode(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        case cObj = new Case();
        cObj.AccountId = acc.ID;
        cObj.Status = 'In Processes';
        cObj.Description = '123';
        insert cObj;
        
        Case_Detail__c li = new Case_Detail__c();
        li.Amount__c = 1;
        li.Line_Number__c = 1;
        insert li;
        
        generateBarcode gg = new generateBarcode();
        gg.caseDetailId  = li.id;
        Case_Detail__c LineItem = gg.LineItem;
        
        lineItemController lic = new lineItemController();
        lic.caseDetailId = li.Id;
        Case_Detail__c LineItem2 = lic.LineItem;
    }
}