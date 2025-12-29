public class generateBarcodeNA{
    public string caseId{get; set;}
    public string LineItemId {get; set;}
    
    public Case CaseObj{
        get{
            Case cs = new Case(); 
            if(caseId != null){
                cs = [Select Id,CaseNumber,Quantity__c,Product_Number__c,Account.Name, Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry From Case where Id = :caseId];
            }
             return cs;
        }
    } 
    
      public generateBarcodeNA(){}
}