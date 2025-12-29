@isTest
private class oppTriggerHandlerClass_Test {
    
    static testMethod void unitTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='kkstandarduser@cloudcertitude.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Job_Title__c = 'Project Sales Manager',
                           TimeZoneSidKey='America/Los_Angeles', UserName='kkstandarduser@cloudcertitude.com');
        
        insert u1;
        
        //Account Insert
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        // Product Model Insert
        Product_Type__c objType = new Product_Type__c();
        objType.Is_Disable__c = false;
        insert objType;
        
        Product_Model__c objpm1 = new Product_Model__c();
        objpm1.Legacy_ID__c = 'a001dsxvxc';
        objpm1.Product_Model__c = 'test';
        objpm1.Product_Type__c = objType.id;
        insert objpm1;
        
        
        
        
        Opportunity opp = new Opportunity();
        opp.Account = acc;
        opp.name = 'test';
        opp.Business_Unit__c = 'GEMS_NA';
        opp.Product_Model__c = objpm1.id ;
        opp.Market__c = 'OHV';
        opp.StageName = 'Stage 1 - Qualified';
        opp.Project_Manager__c = u1.id;
        opp.CloseDate = Date.today();
        opp.Application_Detail__c = 'test';
        opp.Estimated_Quantity__c = 100;
        opp.OwnerId = u1.id;
        opp.OPP_closing_note__c = 'test';
        opp.Unit_Price__c = 10;
        opp.Type = 'Project';
        opp.Reason__c = 'Stage 1 - Qualified';
        // opp.Is_Feasibility_Approved__c = true;
        insert opp;
        
        
        opp.S1SD1__c = true;
        opp.S1SD3__c = true;
        opp.S1SD2__c = true;
        update opp;
        
        
        System.Debug('Approval Stage-------- '+opp.ApproveStatus__c + ' S1SD1--- '+ opp.S1SD1__c + 'S1SD3__c--- '+ opp.S1SD3__c + 'S1SD2__c--- '+ opp.S1SD2__c );
        opp.StageName = 'Stage 1 - Qualified';
        opp.S1SD1__c = true;
        opp.S1SD3__c = true;
        opp.S1SD2__c = true;
        update opp;
        
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Submitting request for approval.');
req1.setObjectId(opp.Id);
req1.setSubmitterId(u1.Id); 
req1.setProcessDefinitionNameOrId('Approve_Stage_1_to_Stage_2_RSM_PSM');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
List<Id> newWorkItemIds = result.getNewWorkitemIds();
Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
req2.setComments('Approving request.');
req2.setAction('Approve');
req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
req2.setWorkitemId(newWorkItemIds.get(0));
Approval.ProcessResult result2 =  Approval.process(req2); */
        
        system.assertEquals(opp.StageName,'Stage 1 - Qualified');
        System.debug('--^^^^^^^^^^---- '+opp.ApproveStatus__c);
        
        
        Opportunity oppp = new Opportunity();
        oppp.Account = acc;
        oppp.name = 'test';
        oppp.Business_Unit__c = 'GEMS_NA';
        oppp.Product_Model__c = objpm1.id ;
        oppp.Market__c = 'OHV';
        oppp.StageName = 'Stage 4 - Specific Price / Budget';
        oppp.Project_Manager__c = u1.id;
        oppp.CloseDate = Date.today();
        oppp.Application_Detail__c = 'test';
        oppp.Estimated_Quantity__c = 100;
        oppp.OwnerId = u1.id;
        oppp.OPP_closing_note__c = 'test';
        oppp.Unit_Price__c = 10;
        oppp.Type = 'Project';
        oppp.Reason__c = 'Stage 1 - Qualified';
        //oppp.Is_Feasibility_Approved__c = True;
        oppp.S1SD1__c = true;
        oppp.S1SD3__c = true;
        oppp.S1SD2__c = true;
        oppp.S2SD1__c = true;
        oppp.S5SD1__c = true;
        oppp.S5SD3__c = false;
        
        insert oppp;
        System.debug('==========> '+oppp.ApproveStatus__c);
        
        
        List<String> lstSalesField = oppTriggerHandlerClass.salesField();
        
        Opportunity opp1 = new Opportunity();
        opp1.Account = acc;
        opp1.name = 'test';
        opp1.Business_Unit__c = 'GEMS_NA';
        opp1.Product_Model__c = objpm1.id ;
        opp1.Market__c = 'OHV';
        opp1.StageName = 'Stage 2 - Needs Identified & Accepted';
        opp1.Project_Manager__c = u1.id;
        opp1.CloseDate = Date.today();
        opp1.Application_Detail__c = 'test';
        opp1.Estimated_Quantity__c = 100;
        opp1.OwnerId = u1.id;
        opp1.OPP_closing_note__c = 'test';
        opp1.Unit_Price__c = 10;
        opp1.Type = 'Project';
        opp1.Reason__c = 'Stage 1 - Qualified';
        //opp1.Is_Feasibility_Approved__c = True;
        
        insert opp1;
        
        opp1.StageName = 'Stage 3 - Solution Presented & Accepted';
        update opp1;
        
        oppTriggerHandlerClass.moveStageBackward(opp,opp1,'1','2');
        oppTriggerHandlerClass.moveStageForward(opp,opp1,'1','2');
        
        oppTriggerHandlerClass.moveStageForward(opp,opp1,'2','1');
        
        Map<Integer,String> index = oppTriggerHandlerClass.stageMapWithIndex();    
        
    }
    
    
    static testMethod void unitTest1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='kkstandarduser@cloudcertitude.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Job_Title__c = 'Project Sales Manager',
                           TimeZoneSidKey='America/Los_Angeles', UserName='kkstandarduser@cloudcertitude.com');
        
        insert u1;
        
        //Account Insert
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        // Product Model Insert
        Product_Type__c objType = new Product_Type__c();
        objType.Is_Disable__c = false;
        insert objType;
        
        Product_Model__c objpm1 = new Product_Model__c();
        objpm1.Legacy_ID__c = 'a001dsxvxc';
        objpm1.Product_Model__c = 'test';
        objpm1.Product_Type__c = objType.id;
        insert objpm1;
        
        
        Opportunity oppp = new Opportunity();
        oppp.Account = acc;
        oppp.name = 'test';
        oppp.Business_Unit__c = 'GEMS_NA';
        oppp.Product_Model__c = objpm1.id ;
        oppp.Market__c = 'OHV';
        oppp.StageName = 'Stage 1 - Qualified';
        oppp.Project_Manager__c = u1.id;
        oppp.CloseDate = Date.today();
        oppp.Application_Detail__c = 'test';
        oppp.Estimated_Quantity__c = 100;
        oppp.OwnerId = u1.id;
        oppp.OPP_closing_note__c = 'test';
        oppp.Unit_Price__c = 10;
        oppp.Type = 'Project';
        oppp.Reason__c = 'Stage 1 - Qualified';
        //oppp.Is_Feasibility_Approved__c = True;
        oppp.S2SD1__c = true;
        oppp.S5SD1__c = true;
        
        insert oppp;
        System.debug('==========> '+oppp.ApproveStatus__c);
        
        /*oppp.StageName = 'Stage 1 - Qualified';
oppp.S1SD1__c = true;
oppp.S1SD2__c = true;
oppp.S1SD3__c = true;

update oppp;*/
        system.assertEquals(oppp.StageName,'Stage 1 - Qualified');
        
        oppp.StageName = 'Stage 2 - Needs Identified & Accepted'; 
        oppp.S2SD1__c = true;
        oppp.S2SD2__c = true;
        oppp.S2SD3__c = true;
        oppp.S2SD4__c = true;
        update oppp;
        
        oppp.StageName ='Stage 1 - Qualified';
        update oppp;
        
        Opportunity opp1 = new Opportunity();
        opp1.Account = acc;
        opp1.name = 'test';
        opp1.Business_Unit__c = 'GEMS_NA';
        opp1.Product_Model__c = objpm1.id ;
        opp1.Market__c = 'OHV';
        opp1.StageName = 'Stage 2 - Needs Identified & Accepted';
        opp1.Project_Manager__c = u1.id;
        opp1.CloseDate = Date.today();
        opp1.Application_Detail__c = 'test';
        opp1.Estimated_Quantity__c = 100;
        opp1.OwnerId = u1.id;
        opp1.OPP_closing_note__c = 'test';
        opp1.Unit_Price__c = 10;
        opp1.Type = 'Project';
        opp1.Reason__c = 'Stage 1 - Qualified';
        //opp1.Is_Feasibility_Approved__c = True;
        
        insert opp1;
        
        opp1.StageName = 'Stage 3 - Solution Presented & Accepted';
        update opp1;
        
        oppTriggerHandlerClass.moveStageBackward(opp1,oppp,'1','2');
        
        
    }
    
    static testMethod void unitTest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt1', Email='kkstandarduser@cloudcertitude.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Job_Title__c = 'Project Sales Manager',
                           TimeZoneSidKey='America/Los_Angeles', UserName='kkstandarduser@cloudcertitude.com');
        
        insert u1;
        
        //Account Insert
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        // Product Model Insert
        Product_Type__c objType = new Product_Type__c();
        objType.Is_Disable__c = false;
        insert objType;
        
        Product_Model__c objpm1 = new Product_Model__c();
        objpm1.Legacy_ID__c = 'a001dsxvxc';
        objpm1.Product_Model__c = 'test';
        objpm1.Product_Type__c = objType.id;
        insert objpm1;
        
        
        Opportunity oppp = new Opportunity();
        oppp.Account = acc;
        oppp.name = 'test';
        oppp.Business_Unit__c = 'GEMS_NA';
        oppp.Product_Model__c = objpm1.id ;
        oppp.Market__c = 'OHV';
        oppp.StageName = 'Stage 4 - Specific Price / Budget';
        oppp.Project_Manager__c = u1.id;
        oppp.CloseDate = Date.today();
        oppp.Application_Detail__c = 'test';
        oppp.Estimated_Quantity__c = 100;
        oppp.OwnerId = u1.id;
        oppp.OPP_closing_note__c = 'test';
        oppp.Unit_Price__c = 10;
        oppp.Type = 'Project';
        oppp.Reason__c = 'Stage 1 - Qualified';
        //oppp.Is_Feasibility_Approved__c = True;
        oppp.S1SD1__c = true;
        oppp.S1SD3__c = true;
        oppp.S1SD2__c = true;
        oppp.S2SD1__c = true;
        oppp.S5SD1__c = true;
        //oppp.S5SD3__c = false;
        
        insert oppp;
        System.debug('==========> '+oppp.ApproveStatus__c);
        
        Opportunity opp = new Opportunity();
        opp.Account = acc;
        opp.name = 'test';
        opp.Business_Unit__c = 'GEMS_NA';
        opp.Product_Model__c = objpm1.id ;
        opp.Market__c = 'OHV';
        opp.StageName = 'Stage 1 - Qualified';
        opp.Project_Manager__c = u1.id;
        opp.CloseDate = Date.today();
        opp.Application_Detail__c = 'test';
        opp.Estimated_Quantity__c = 100;
        opp.OwnerId = u1.id;
        opp.OPP_closing_note__c = 'test';
        opp.Unit_Price__c = 10;
        opp.Type = 'Project';
        opp.Reason__c = 'Stage 1 - Qualified';
        //opp.Is_Feasibility_Approved__c = true;
        insert opp;
        
        
        opp.S1SD1__c = true;
        opp.S1SD3__c = true;
        opp.S1SD2__c = true;
        update opp;
        
        
        System.Debug('Approval Stage-------- '+opp.ApproveStatus__c + ' S1SD1--- '+ opp.S1SD1__c + 'S1SD3__c--- '+ opp.S1SD3__c + 'S1SD2__c--- '+ opp.S1SD2__c );
        opp.StageName = 'Stage 1 - Qualified';
        opp.S1SD1__c = true;
        opp.S1SD3__c = true;
        opp.S1SD2__c = true;
        update opp;
        
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Submitting request for approval.');
req1.setObjectId(opp.Id);
req1.setSubmitterId(u1.Id); 
req1.setProcessDefinitionNameOrId('Approve_Stage_1_to_Stage_2_RSM_PSM');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
List<Id> newWorkItemIds = result.getNewWorkitemIds();
Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
req2.setComments('Approving request.');
req2.setAction('Approve');
req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
req2.setWorkitemId(newWorkItemIds.get(0));
Approval.ProcessResult result2 =  Approval.process(req2); */
        
        system.assertEquals(opp.StageName,'Stage 1 - Qualified');
    }
    
    
}