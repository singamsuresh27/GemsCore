@isTest(SeeAllData=true)
public class TestCustomQuotationItemController {
	public static testMethod void createNewQuoteItem() {
       // Insert Account
    Account act = new Account();
    act.Name = 'Test Account';
    insert act;

    Contact  con = new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = act.id);
    insert con;
        
    // Insert Product
    Product2 p = new Product2();
    p.Name = ' Test Product ';
    p.Description='Test Product Entry 1';
    p.productCode = 'ABC';
    p.isActive = true;
    insert p;
    

    //Id pricebookId = Test.getStandardPricebookId();
    Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
    // Insert PricebookEntry

    PricebookEntry entryItem = new PricebookEntry();
    entryItem.Pricebook2Id = Test.getStandardPricebookId();
    entryItem.Product2Id = p.Id;
    entryItem.UnitPrice = 1;
    entryItem.IsActive = true;
    //entryItem.UseStandardPrice = false;
    insert entryItem;
    
    // Insert Quote    
    Quotation_Setra__c quote = new Quotation_Setra__c(Account__c=act.id,
                            Name ='TestQuote',
                            Contact__c = con.Id,
                            Status__c='Draft',
                            Validity__c='30',
                            Incoterms__c='EXW - Ex Works',
                            Payment__c='To be agreed');    
    insert quote;
    
    // Insert Quote Item
	Quotation_Setra_LineItem__c quoteItem = new Quotation_Setra_LineItem__c(Quote__c=quote.Id,Product__c= p.Id,SalesPrice__c=100);
    insert quoteItem;
          
        system.debug('quote.Id : '+quote.Id);
    Test.startTest();
    CustomQuotationItemController cont = new CustomQuotationItemController(new ApexPages.StandardController(quote));
             
	PageReference testPage = Page.CustomQuotationItem;
    Test.setCurrentPage(testPage);
   	//testPage.getParameters().put('Id', quote.Id);
    cont.queryUnitPrice();
    cont.cancel();
    cont.save();
	Test.stopTest();
    }
    
}