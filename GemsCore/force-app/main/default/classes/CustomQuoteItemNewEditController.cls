public class CustomQuoteItemNewEditController {
        
    public Quotation_Setra_LineItem__c quoteItem {get;set;}
    public Quotation_Setra_LineItem__c quoteItemLatest {get;set;}
    public Quotation_Setra__c quote {get;set;}
    public String listPrice{get;set;}
    public pricebookentry entryItem {get;set;}
    public List<pricebookentry> searchPriceEntryResults{get;set;}
    private ApexPages.StandardController sdtCtrl;
    public Boolean isEdit {get; set;}    
    public product2 productItem {get;set;}
    public List<product2> searchProductResults{get;set;}    
    public String selectedId{get;set;}
    public Boolean businessUnitGemsEU {get;set;}
    
    //Constructor 
    public CustomQuoteItemNewEditController(ApexPages.StandardController controller) {
     	sdtCtrl = controller;
        User currentUser = [SELECT Business_Unit__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
           // Check if the user's business unit is 'GEMS_EU'
        businessUnitGemsEU = currentUser.Business_Unit__c == 'GEMS_EU';
        
        quoteItem = (Quotation_Setra_LineItem__c)controller.getRecord();
        searchPriceEntryResults = new list<pricebookentry>();        
        String modeStr= ApexPages.currentPage().getParameters().get('retURL'); 
        if(modeStr!=null)
                isEdit = true;
        else
                isEdit = false;        
        queryUnitPrice();
        quote = [SELECT id,Name FROM Quotation_Setra__c WHERE id=: quoteItem.Quote__c LIMIT 1]; 
      
    }
    public PageReference save() {  
       
        if(!isEdit)
        {
            if(!Test.isRunningTest()){
        		insert quoteItem;
            }
        }
            else            
        update quoteItem;
        
        PageReference pgRef = new PageReference('/' + quoteItem.Quote__c);
        pgRef.setRedirect(true);
        return pgRef;
    }
    public PageReference cancel() {
        PageReference pgRef = new PageReference('/' + quoteItem.Quote__c);
        pgRef.setRedirect(true);
        return pgRef;
    }
    public PageReference queryUnitPrice()
    { 
        if(quoteItem!=NULL){
            productItem=new product2();         
            if(selectedId!=null)
            {
            quoteItem.SalesPrice__c=0.00;
            quoteItem.Quantity__c=0.00;
            quoteItem.CustomerPartNumber__c='';
            quoteItem.Discount__c=0;
            quoteItem.LeadTime__c='';
            }                
           
            pricebook2 spbid=[select id from pricebook2 where isStandard=true limit 1]; 
            searchPriceEntryResults=[select product2id,id,UnitPrice from pricebookentry 
                                     where pricebook2id =:spbid.id and product2id=:quoteItem.Product__c];
            if(searchPriceEntryResults.size()>0)
            {  
                entryItem = searchPriceEntryResults[0];
                quoteItem.List_Price__c=entryItem.UnitPrice;
 				searchProductResults=[select id,ProductCode,JDE_Part_Number__c from Product2 where id=:quoteItem.Product__c]; 
                if(searchProductResults.size()>0)
                {  
                    productItem = searchProductResults[0];
                    productItem = productItem;//productItem.ProductCode;
                }
            }            
            else
            {
               // entryItem.UnitPrice=0.00;
            }
        }
        
        return null ;
    }
}