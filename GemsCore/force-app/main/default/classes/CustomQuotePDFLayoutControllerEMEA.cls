public class CustomQuotePDFLayoutControllerEMEA {
public List<Quotation_Setra_LineItem__c> quoteLineItems{get;set;}
    public Quotation_Setra__c quotes {get;set;} 
    public Quotation_Setra__c quote {get;set;}
    public string showContent {get;set;}
    string quoteID;
    
    //Constructor 
    public CustomQuotePDFLayoutControllerEMEA(ApexPages.StandardController controller) {
        quote = (Quotation_Setra__c)controller.getRecord(); 
        quotes = [SELECT id,Contact__c,Validity__c,QuoteNumber__c,GrandTotal__c,OwnerId,Payment__c,Incoterms__c FROM Quotation_Setra__c WHERE id=: quote.id LIMIT 1]; 
        quoteLineItems = [SELECT id,List_Price__c,NetPrice__c, Product__c,LeadTime__c, Quantity__c,JDE_Part_Number__c,Product_Description__c,Name,CustomerPartNumber__c,Surcharge__c,SalesPrice__c,List_Price_Unit__c,CurrencyIsoCode FROM Quotation_Setra_LineItem__c WHERE quote__c = :quotes.id ORDER BY Name];
         for (Quotation_Setra_LineItem__c item: quoteLineItems) { 
                        if(item.Surcharge__c != null)
                        {
                            showContent = 'Yes';
                            break;
                        }
         }
    }
}