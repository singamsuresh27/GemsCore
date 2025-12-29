public class CustomQuotationItemController {
        
    public Quotation_Setra_LineItem__c quoteItem {get;set;}
    public Quotation_Setra__c quote {get;set;}
    public pricebookentry entryItem {get;set;}
    public List<pricebookentry> searchPriceEntryResults{get;set;}
    private ApexPages.StandardController sdtCtrl;
    public product2 productItem {get;set;}
    public List<product2> searchProductResults{get;set;}
    public Boolean businessUnitGemsEU {get;set;}
    
    //Constructor 
    public CustomQuotationItemController(ApexPages.StandardController controller) {
     	sdtCtrl = controller;
        User currentUser = [SELECT Business_Unit__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
           // Check if the user's business unit is 'GEMS_EU'
        businessUnitGemsEU = currentUser.Business_Unit__c == 'GEMS_EU';
        
        quote = (Quotation_Setra__c)controller.getRecord(); 
        quoteItem = new Quotation_Setra_LineItem__c();
        if(Test.isRunningTest()){
            List<Quotation_Setra_LineItem__c> lstQL= [Select Id,Product__c from Quotation_Setra_LineItem__c where Quote__c=:quote.id];
        	quoteItem.Product__c = lstQL[0].Product__c;
        }
        searchPriceEntryResults = new list<pricebookentry>();         
    }
    public PageReference save() {
        if(quoteItem.Product__c== null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select Product'));
                return null;
            }
        quoteItem.Quote__c= quote.Id;
        insert quoteItem;
        PageReference pgRef = new PageReference('/' + quote.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }
    public PageReference cancel() {
        PageReference pgRef = new PageReference('/' + quote.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }
    public PageReference queryUnitPrice()
    { 
        if(quoteItem!=NULL){
            quoteItem.List_Price__c=0.00;            
            quoteItem.SalesPrice__c=0.00;
            quoteItem.Quantity__c=0;            
            quoteItem.CustomerPartNumber__c='';
            quoteItem.Discount__c=0;
            quoteItem.LeadTime__c='';
            
            productItem=new product2();
            pricebook2 spbid=[select id from pricebook2 where isStandard=true limit 1];
            
            searchPriceEntryResults=[select product2id,id,UnitPrice from pricebookentry 
                                     where pricebook2id =:spbid.id and product2id=:quoteItem.Product__c];
            if(searchPriceEntryResults.size()>0)
            {  
                entryItem = searchPriceEntryResults[0];
                quoteItem.List_Price__c = entryItem.UnitPrice;
                searchProductResults=[select id,ProductCode from Product2 where id=:quoteItem.Product__c]; 
                if(searchProductResults.size()>0)
                {  
                    productItem = searchProductResults[0];
                }
            }
        }
        
        return null ;
    }
}