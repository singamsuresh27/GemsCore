@isTest(SeeAllData=true)
public class TestCustomQuoteItemNewEdit {
	public static testMethod void createEditQuoteItem() {
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
    

    Id pricebookId = Test.getStandardPricebookId();
    
    // Insert PricebookEntry

    PricebookEntry standardPrice = new PricebookEntry();
    standardPrice.Pricebook2Id = pricebookId;
    standardPrice.Product2Id = p.Id;
    standardPrice.UnitPrice = 1;
    standardPrice.IsActive = true;
    standardPrice.UseStandardPrice = false;
    insert standardPrice ;
    
    // Insert Quote    
    Quotation_Setra__c quote = new Quotation_Setra__c(Account__c=act.id,
                            Name ='TestQuote',
                            Contact__c = con.id,
                            Status__c='Draft',
                            Validity__c='30',
                            Incoterms__c='EXW - Ex Works',
                            Payment__c='To be agreed');    
    insert quote;
    
    // Insert Quote Item
	Quotation_Setra_LineItem__c quoteItem = new Quotation_Setra_LineItem__c(Quote__c=quote.id,Product__c= p.Id,SalesPrice__c=100);
    insert quoteItem;
        CustomQuoteItemNewEditController cont = new CustomQuoteItemNewEditController(new ApexPages.StandardController(quoteItem));   
        PageReference testPage = Page.CustomQuoteItemNewEdit;
        Test.setCurrentPage(testPage);  
        cont.selectedId='test';
        cont.queryUnitPrice();
        cont.cancel();
        cont.save();

    }
}