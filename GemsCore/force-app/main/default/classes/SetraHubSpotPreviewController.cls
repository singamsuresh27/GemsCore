public class SetraHubSpotPreviewController {
    
    public Account acc {get;set;}
    public Account thisAcc {get;set;}
    public list<Contact> listContact {get;set;}
    public Contact primaryContact {get;set;}
    public Contact financeContact {get;set;}
    public Contact shipContact {get;set;}
    public string sameAddress{get;set;}
    
	//Constructor 
    public SetraHubSpotPreviewController(ApexPages.StandardController controller) {
        acc = (Account)controller.getRecord();
        listContact = new list<Contact>();
        primaryContact = new Contact();
        financeContact = new Contact();
        shipContact = new Contact();
		
         listContact = [Select Id,accountid,FirstName,LastName,Phone,Email from Contact where accountid=:acc.id and Role__c includes ('Primary') limit 1];
        
    	if(listContact.size()>0)
        primaryContact = listContact[0];
        
        listContact= [Select Id,accountid,FirstName,LastName,Phone,Email from Contact where accountid=:acc.id and Role__c includes ('Finance') limit 1];
        if(listContact.size()>0)
        financeContact = listContact[0];
        
        listContact= [Select Id,accountid,FirstName,LastName,Phone,Email from Contact where accountid=:acc.id and Role__c includes ('Shipping') limit 1];
       	if(listContact.size()>0)
    		shipContact = listContact[0];
    }
    /*public PageReference Close()
    {
     return new PageReference('javascript:window.close()');   
    }*/
}