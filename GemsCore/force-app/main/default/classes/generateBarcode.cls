public class generateBarcode{
    public string rmaNumberForBarcode{get; set;}
    public string caseDetailId{get; set;}
    public Case_Detail__c LineItem{
        get{
            Case_Detail__c li = new Case_Detail__c(); 
            if(caseDetailId != null){
                li = [Select Id, Barcode__c, Quantity__c ,Gems_PartNumber__c,Name,Case__r.Account.Name,Case__r.Account.ShippingStreet,Case__r.Account.ShippingCity,Case__r.Account.ShippingState,Case__r.Account.ShippingPostalCode,Case__r.Account.ShippingCountry From Case_Detail__c where id = :caseDetailId];
            }
             return li;
        }
    }
    public generateBarcode(){}
}