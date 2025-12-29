@isTest
public class ApprovalControllerTest {
    @isTest
    public static void testRunAs() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', 
                          LastName='kulak', LanguageLocaleKey='en_US',job_title__c='Project Sales Manager',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='mi@test.com',
                          companyid__c='00015');
        insert u;
        
        System.runAs(u) {
            account acc=new account();
            acc.name='test account 1';
            acc.BU_ID__c=u.Companyid__c;
            insert acc;
            
            lead lad = new lead ();
            lad.lastname='testLead1';
            lad.company='test pvt ltd.';
            lad.Phone='9875647';
            lad.Email='test@leadtest.com';
            lad.Lead_Project_Name__c='testing';
            lad.Product_Of_Interest__c='3600';
            lad.Estimated_Annual_Revenue__c='12';
            lad.Media__c='test meadia';
            lad.Unit_Price__C=23.0;
            lad.Application_Detail__c='for testing purpose what about 10 and testing this is a good idea';
            lad.Project_Timeline__c='1 to 12';
            lad.Market__c='OHV';
            lad.Sub_Market__c='MRO';
            lad.Project_Manager__c=u.Id;
            lad.Lead_Qualifier__c='Linda Collin';
            lad.Qualified_On__c= system.today();
            lad.Limiting_Factors__c='testing factors';
            lad.Commercial_Triggers__c='this is for testing only !';
            lad.Budget_Availability__c=true;
            lad.Key_Decision_Maker__c='testing';
            lad.Opportunity_Type__c='project';
            lad.Next_Step__c='test';
            lad.Next_Step_Due_date__c=system.today();
            lad.Project_Start_Date__c=system.today();
            lad.Proto_Type_Need_by__c=system.today();
            lad.Product_Launch__c=system.today();
            lad.Pre_production_Launch__c=system.today();
            lad.Unit_Price__c=32.0;
            lad.Units__c=23.0;
            insert lad;
            
            database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lad.id);
            lc.setOpportunityName('Cole Swain');
            lc.setAccountID(acc.Id);
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);      
            System.assert(lcr.isSuccess());
            
            opportunity opt = new opportunity ();
            opt =[select name,id from opportunity where name='Cole Swain'];
            opt.OPP_Approval_Status__c = 'Pending Approval';
            opt.StageName = 'Closed Won' ;
            opt.TM_Com_Rate__c=null;
            opt.PM_Com_rate__c=null;
            update opt;
            
            ApprovalController ac=new ApprovalController();
            ac.save();
        }
    }
}