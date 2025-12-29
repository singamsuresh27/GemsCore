@isTest
public class TestClassForCreateLeadController {
    @isTest static void createLeadTestCase(){
        Account acc = new Account();
        acc.name = 'Testing Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Testing';
        con.lastName = 'CreateLead';
        con.AccountId = acc.id;
        con.Email = 'test@test.com';
        con.Phone = '1234567890';
        con.LeadSource = 'Internet/Search Engine';
        con.OtherCity = 'testCity';
        con.OtherCountry = 'testCountry';
        con.OtherPostalCode = '123456';
        con.OtherStreet = 'testStreet';
        con.MailingCity = 'test';
        con.MailingCountry = 'test';
        con.MailingPostalCode = '123456';
        con.MailingStreet = 'testing';
        con.MailingStreet = 'testing';
        insert con;
        
        Opportunity op = new Opportunity();
        op.AccountId = acc.id;
        op.Business_Unit__c = 'GEMS_NA';
        op.name = 'test';
        op.closeDate = System.today();
        op.StageName = 'Stage 1 - Qualified';
        op.Next_Step_Due_date__c = System.today();
        op.NextStep = '2';
        op.Market__c = 'Marine';
        op.Category_Sources__c = '3100';
        insert op;
        
        OpportunityContactRole oppconrole = new OpportunityContactRole();
        oppconrole.ContactId = con.Id;
        oppconrole.OpportunityId = op.Id;
        insert oppconrole;
        
        ApexPages.currentPage().getParameters().put('Id',con.id);
        CreateLeadOnContactController clc = new CreateLeadOnContactController();
        pageReference leadId = clc.createLead();
        system.assertNotEquals(leadId,null);
    }
    
    @isTest static void createLeadTestCase2(){
        Account acc = new Account();
        acc.name = 'Testing Account';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'test';
        acc.BillingPostalCode = '123456';
        acc.BillingState = 'test';
        acc.BillingStreet = 'test';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Testing';
        con.lastName = 'CreateLead';
        con.AccountId = acc.id;
        con.Email = 'test@test.com';
        con.Phone = '1234567890';
        con.LeadSource = 'Internet/Search Engine';
        insert con;
        
        Opportunity op = new Opportunity();
        op.AccountId = acc.id;
        op.Business_Unit__c = 'GEMS_NA';
        op.name = 'test';
        op.closeDate = System.today();
        op.StageName = 'Stage 1 - Qualified';
        op.Next_Step_Due_date__c = System.today();
        op.NextStep = '2';
        op.Market__c = 'Marine';
        op.Category_Sources__c = '3100';
        insert op;
        
        OpportunityContactRole oppconrole = new OpportunityContactRole();
        oppconrole.ContactId = con.Id;
        oppconrole.OpportunityId = op.Id;
        insert oppconrole;
        
        ApexPages.currentPage().getParameters().put('Id',con.id);
        CreateLeadOnContactController clc = new CreateLeadOnContactController();
        pageReference leadId = clc.createLead();
        system.assertNotEquals(leadId,null);
    }
}