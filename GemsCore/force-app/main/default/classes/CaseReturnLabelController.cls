public class CaseReturnLabelController {
    public Case thisCase {get;set;} 
    public case CaseObj {get;set;} 
    string caseID;
    
    //Constructor 
    public CaseReturnLabelController(ApexPages.StandardController controller) {
        thisCase = (Case)controller.getRecord(); 
        CaseObj = [SELECT CaseNumber,Quantity__c,Product_Number__c,Account.Name, Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry FROM Case WHERE id=: thisCase.id LIMIT 1]; 
	 }
   
}