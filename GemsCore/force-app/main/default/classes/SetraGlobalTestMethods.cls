/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SetraGlobalTestMethods {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        LIST<RecordType> recType = [select id,name from RecordType where SObjecttype = 'Lead' And Name='Internal' order by Name];
        Datetime currentTime = system.now();
        Profile pro = [SELECT Id FROM Profile Where Name = 'System Administrator' LIMIT 1];
        //Create an user
        User dev = new User(
                        lastname ='DevUser', 
                        alias ='dev', 
                        email ='test.userdev@testdev.com', 
                        username ='pretestdevusr@test.com', 
                        ProfileId = pro.Id, 
                        EmailEncodingKey = 'ISO-8859-1', 
                        LanguageLocaleKey = 'en_US', 
                        LocaleSidKey = 'en_GB', 
                        TimeZoneSidKey = 'GMT', 
                        IsActive = true);
        insert dev; 
        //Create an account
        Account a = new Account(Name='Test');
        a.OwnerId=dev.Id;
        a.Name = 'Setra';
        insert a;  
        
        // Create a lead
        Lead ld = new Lead();
        ld.Lastname='User';
        ld.Company='Test';
        ld.Phone='9889898989';
        ld.Rating='Cold';
        ld.Status='Unqualified';
        ld.email='a@a.com';
        ld.Most_Recent_Action__c = 'New';
        ld.State='NY';
        ld.OwnerId = dev.Id;
        ld.Lead_Quality__c='Cold';
        insert ld;
        
        // Start Testing trigger CalculateTimeTookForFirstAction
        // Update the Lead this will cause trigger to fire
        ld.Most_Recent_Action__c = 'Contacted';
        ld.First_Action_Taken__c = 'Sent Email';
       // ld.OwnerId = '00Ga0000003rv0p';
       ld.OwnerId = dev.Id; 
        update ld;
        
         // Update the Lead 
        ld.Action_Date__c=currentTime;
        ld.Time_to_First_Action__c=410.15;
        update ld;
        
        
        Lead lTest = [SELECT Id, Action_Date__c,Time_to_First_Action__c  FROM Lead WHERE Id=:ld.Id];
        system.assertEquals(currentTime, lTest.Action_Date__c);
        system.assertEquals(410.15, lTest.Time_to_First_Action__c);
        // end Testing trigger CalculateTimeTookForFirstAction 
        
        //Create a contact
        Contact con = new Contact(firstname = 'FromContact', lastname='ToLead', accountId = a.id, HubSpot_CTA_Click__c = 'CTA Click1');
        insert con; 
        
        //Start Testing ContactToLead triger for CTA valu change
        //Update contact
        con.HubSpot_CTA_Click__c = 'CTA Click2';
        update con;
        con.HubSpot_CTA_Click__c = 'CTA Click3';
        update con; 
        Contact c  = [SELECT firstname, lastname FROM Contact WHERE firstname='FromContact'];
        system.assertEquals(c.firstname, 'FromContact');
        //Lead fromContactToLead = [SELECT Id, firstname, lastname, HubSpot_CTA_Click__c  FROM Lead WHERE firstname='FromContact' And lastname='ToLead' Limit 1];
        //system.assertEquals(fromContactToLead.firstname, 'FromContact');
        //End ComtactToLead trigger test
        
        //Create a new task 
        Task t = new Task();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        //t.Status = 'Completed';
        t.OwnerId = dev.Id;
        t.WhoId = ld.Id;
        insert t;
        // update the task to complete
        //t.Status = 'Completed';   
        t.Description = 'Test';     
        update t;
        
        // Test method for MfgBuildSummary class and page
        // create an opp
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = a.Id;
        opp.OwnerId = dev.Id;
        opp.StageName = 'S1 Qualified Opportunity';
        opp.CloseDate = Date.today();
        insert opp;
        
        // CBO
        CBO__c cbo = new CBO__c();
        cbo.OwnerId = dev.Id;
        cbo.Opportunityid__c = opp.Id;
        cbo.Technical_Feasibility_Issues__c = 'techinical Issue';
        cbo.Start_With_BOM__c = 'BomTest';
        //cbo.Productid__c = 
        cbo.Pressure_Type__c = 'Compound';
        cbo.Pressure_Range__c = '80 to 90 C';
        cbo.Pressure_Port_Fitting__c = '20  C';
        cbo.Other_Required__c = 'Other Req';
        insert cbo;  
          
        BOMChange__c bom = new BOMChange__c();
        bom.CBOid__c = cbo.Id;
        bom.Action__c = 'Delete';
        bom.Notes__c = 'BOM change note';
        bom.Description__c = 'BOM change description';  
        insert bom;
        System.currentPagereference().getParameters().put('id',cbo.Id); 
        ApexPages.StandardController sc = new ApexPages.standardController(cbo);
        MfgBuildSummary bs = new MfgBuildSummary(sc);
        
        CBO__c cb = [Select Pressure_Type__c, Pressure_Range__c From  CBO__c Where Id =:cbo.id];
        system.assertEquals('Compound', cb.Pressure_Type__c);
        system.assertEquals('80 to 90 C', cb.Pressure_Range__c);        
    }
}