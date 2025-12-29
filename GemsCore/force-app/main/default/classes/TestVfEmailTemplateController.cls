@isTest
public class TestVfEmailTemplateController{
    
    @isTest
    private static void testTemplate(){
        Account acc = new Account();
        acc.Name = 'test account';          
        insert acc;
        
        Product_Type__c pt = new Product_Type__c();
        pt.Name = 'test product type';
        pt.CurrencyIsoCode = 'USD';
        insert pt;
        
        Product_Model__c pm = new Product_Model__c();
        pm.Name = 'test product model';
        pm.CurrencyIsoCode = 'USD';
        pm.Product_Type__c = pt.Id;
        insert pm;
        
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.Product_Model__c = pm.Id;
        opp.StageName = 'Stage 1 - Qualified';
        opp.Business_Unit__c = 'GEMS_NA';
        opp.CloseDate = System.today();
        opp.Next_Step_Due_date__c = System.today();
        opp.NextStep = '2';
        insert opp;
        
        TaskComment__c tc = new TaskComment__c();
        tc.Body__c = 'test body';
        tc.Opportunityid__c = opp.Id;
        insert tc;
        
        VfEmailTemplateController obj = new VfEmailTemplateController();
        obj.oppId = opp.Id;
        Opportunity oppList = obj.Opp;
        System.assert(oppList != null);
        
        obj = new VfEmailTemplateController();
        oppList = obj.Opp;
        
        
    }
}