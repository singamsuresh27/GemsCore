@isTest
public class TestGenBarcodeNAClass {
    @isTest static void genBarcodeNA(){
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        case cObj = new Case();
        cObj.AccountId = acc.ID;
        cObj.Status = 'In Processes';
        cObj.Description = '123';
        insert cObj;
                       
        generateBarcodeNA genBarcode = new generateBarcodeNA();
        genBarcode.caseId  = cObj.id;
        Case caseObject = genBarcode.CaseObj;
        
    }
}