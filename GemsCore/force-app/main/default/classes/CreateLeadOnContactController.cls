public class CreateLeadOnContactController{
    
    public Id contactID{get; set;}
    private Contact contact;
    
    public CreateLeadOnContactController(){
        contactID = Apexpages.currentpage().getparameters().get('id');
        if(contactID != null)
            contact = [select id,Business_Unit__c,AccountId,Account.Name,FirstName, LastName, Email, Phone, LeadSource, Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact where id = :contactID ];
    }
    
    public pageReference createLead(){
        if(contact != null && contact.AccountId != null){
            Lead newLead = new Lead();
            
            if(contact.AccountId != null)
                newLead.Account__c = contact.AccountId;
            
            newLead.LastName = contact.LastName;
            newLead.LeadSource = contact.LeadSource;
            newLead.Company = contact.Account.Name;
            newLead.Business_Unit__c = contact.Business_Unit__c; 
            newLead.firstName = contact.FirstName != null ? contact.FirstName : '';
            newLead.Email = contact.Email != null ? contact.Email : '';
            newLead.Phone = contact.Phone != null ? contact.Phone : '';
            
            List<OpportunityContactRole> oppConRoleList = [select id,OpportunityId from OpportunityContactRole where contactID = :contact.id];
            if(oppConRoleList.size() > 0){
                String oppId = oppConRoleList.get(0).OpportunityId;
                opportunity opp = [Select Id,Market__c,Category_Sources__c From opportunity where id = :oppId];
                newLead.Market__c = opp.Market__c != null ? opp.Market__c : 'No Value';
                newLead.Category_Sources__c = opp.Category_Sources__c != null ? opp.Category_Sources__c : 'No Value';
                //Gazi made changes on 9/30/2016. This is to refere the original OPP on the lead. If OPP exists.
                newLead.Opp_ID__c = oppId;
            }else{
                newLead.Market__c = 'No Value';
                newLead.Category_Sources__c = 'No Value';
            }
            
            if(contact.MailingStreet != null || contact.MailingCity != null || contact.MailingState != null || contact.MailingCountry != null){
                newLead.Street = contact.MailingStreet != null ? contact.MailingStreet : '';
                newLead.City = contact.MailingCity != null ? contact.MailingCity : '';
                newLead.State = contact.MailingState != null ? contact.MailingState : '';
                newLead.PostalCode = contact.MailingPostalCode != null ? contact.MailingPostalCode : '';
                newLead.Country = contact.MailingCountry != null ? contact.MailingCountry : '';
            }else{
                newLead.Street = contact.Account.BillingStreet != null ? contact.Account.BillingStreet : '';
                newLead.City = contact.Account.BillingCity != null ? contact.Account.BillingCity : '';
                newLead.State = contact.Account.BillingState != null ? contact.Account.BillingState : '';
                newLead.PostalCode = contact.Account.BillingPostalCode != null ? contact.Account.BillingPostalCode : '';
                newLead.Country = contact.Account.BillingCountry != null ? contact.Account.BillingCountry : '';
            }
            
            insert newLead;
            PageReference pageRef = new PageReference('/'+newLead.id);
            return pageRef;
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contact must be attached to an account for this operation.'));
        }
        return null;
    }
}