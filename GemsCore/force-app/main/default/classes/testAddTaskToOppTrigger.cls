@isTest
public class testAddTaskToOppTrigger{
    static Opportunity opp;
    
        
    static{
        OppAddTaskHandler.checkTest = true;
        
        StageAutomation__c sa = new StageAutomation__c();
        sa.Name = 'CheckTrigger';
        sa.IsChecked__c = true;
        insert sa;
        
        //creating salesprocess
        createSalesProcess();
        
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
        
        
        opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.Product_Model__c = pm.Id;
        opp.StageName = 'Stage 1 - Qualified';
        opp.Business_Unit__c = 'GEMS_NA';
        opp.CloseDate = System.today();
        opp.Next_Step_Due_date__c = System.today();
        opp.NextStep = '2';
        insert opp;
        
        Opportunity op = new Opportunity();
        op.AccountId = acc.id;
        op.Product_Model__c = pm.id;
        op.Business_Unit__c = 'GEMS_NA';
        op.name = 'test';
        op.closeDate = System.today();
        op.StageName = 'Stage 1 - Qualified';
        op.Next_Step_Due_date__c = System.today();
        op.NextStep = '2';
        op.PCM_Q1__c = 'Prototypes Only';
        op.PCM_Q2__c = '0 – 40 ($4000 NRE)';
        op.PCM_Q3__c = 'Component only & core competency';
        op.PCM_Q4__c = 'Existing cell';
        op.PCM_Q5__c = '$0 - $1000 Fixtures & Gauges Off the shelf or existing';
        op.PCM_Q6__c = 'Current part, consistent usage';
        op.PCM_Q7__c = 'Current suppliers, standard lead-times';
        op.PCM_Q8__c = 'Existing Quality System';
        op.PCM_Q9__c = 'Sales, Eng, Purch';
        op.PCM_Q10__c = 'All';
        op.PCM_Q11__c = '24+ weeks';
        insert op;
        
        op = new Opportunity();
        op.AccountId = acc.id;
        op.Product_Model__c = pm.id;
        op.Business_Unit__c = 'GEMS_NA';
        op.name = 'test';
        op.closeDate = System.today();
        op.StageName = 'Stage 1 - Qualified';
        op.Next_Step_Due_date__c = System.today();
        op.NextStep = '2';
        op.PCM_Q1__c = 'Prototypes & internal or external test or approval';
        op.PCM_Q2__c = '40- 240 ($24,000 NRE)';
        op.PCM_Q3__c = 'Component or system; General expertise or technology in house';
        op.PCM_Q4__c = 'New Cell / Cell expansion or modification';
        op.PCM_Q5__c = '$0 - $20,000 Simple tooling (plastic mold) New Fixtures/Gages';
        op.PCM_Q6__c ='New part, must have consistent usage, medium volume';
        op.PCM_Q7__c = 'One new supplier, long lead-time, complex BOM';
        op.PCM_Q8__c = 'DFMEA, PFMEA and Control Plan Req\'d';
        op.PCM_Q9__c = 'Sales, Eng, Mfg Eng, Purch, Supply Chain, Quality';
        op.PCM_Q10__c = 'Need to bring in one outside skill';
        op.PCM_Q11__c = '8 – 24 weeks';
        insert op;
        
    }    
    @isTest
    private static void updateOppTask(){
        OppAddTaskHandler.checkTest = true;
        OppAddTaskHandler.runTrigger = true;
        
        //Update Opportunity Stage
        List<Task> tskList = [select id,WhatId,Opportunity_Stage__c,Status from task where Opportunity_Stage__c =: opp.StageName AND whatid =: opp.Id];
        //System.assert(tskList.size() > 0);
        
        for(task tk:tskList){
            tk.Status = 'Completed';
        }
        Test.startTest();
            update tskList;
        Test.stopTest();
        
        OppAddTaskHandler.runTrigger = true;
        
        /*approval.ProcessSubmitRequest aprlPrcs = new Approval.ProcessSubmitRequest();     
        aprlPrcs.setComments('Submitting record for approval.');
        aprlPrcs.setObjectId(opp.Id);
        approval.ProcessResult result = Approval.process(aprlPrcs);
        
        //Approved Approval Process
        ProcessInstanceWorkitem workItem  = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: opp.Id];
        System.assert(workItem != null);
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request using test');
        req.setAction('Approve');
        req.setWorkitemId(workItem.Id);
        Approval.ProcessResult result1 =  Approval.process(req);*/
        opp.ApproveStatus__c = 'Approved';
        opp.Type = 'Project';
        update opp;
        
        //System.assert(opp.Stagename == 'Stage 2 - Needs Identified & Accepted');
        
    }
    
    @isTest
    private static void updateOppTaskToStage(){
        OppAddTaskHandler.checkTest = true;
        Test.startTest();
        //Update Opportunity Stage
        opp.StageName = 'Stage 3 - Solution Presented & Accepted';
        opp.Type='Project';
        update opp;
        OppAddTaskHandler.runTrigger = true;
        
        //Update Opportunity Stage
        opp.StageName = 'Closed Lost';
        opp.OPP_closing_note__c = 'Closed';
        opp.Reason__c = 'Price';
        update opp;
        
        OppAddTaskHandler.runTrigger = true;
        //Update Opportunity Stage
        opp.StageName = 'Stage 2 - Needs Identified & Accepted';
        update opp;
        Test.stopTest();
    }
    
    
    
    
    @isTest
    private static void updateOppOwner(){
        OppAddTaskHandler.checkTest = true;
        OppAddTaskHandler.runTrigger = true;
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testuser', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='cloud.user123@cloud1certitude.com');
        insert u;
        //Update opportunity owner
        opp.OwnerId = u.Id;
        update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOldOpportunities(){
        OppAddTaskHandler.checkTest = true;
        Test.startTest();
        //Update Opportunity Stage
        opp.StageName = 'Closed Lost';
        opp.OPP_closing_note__c = 'Closed';
        opp.Reason__c = 'Price';
        opp.Type='Project';
        update opp;
        
        OppAddTaskHandler.runTrigger = true;
        
        List<Task> taskList = [select id,WhatId,Opportunity_Stage__c,Status 
                                        from Task 
                                        Where WhatId =: opp.Id
                                  ];
        delete taskList;
        //Update Opportunity Stage
        opp.StageName = 'Stage 2 - Needs Identified & Accepted';
        update opp;
        Test.stopTest();
    }
    
    private static void createSalesProcess(){
        List<Sales_Processes__c> spList = new List<Sales_Processes__c>();
        
        Sales_Processes__c sp = new Sales_Processes__c();
        sp.Name = 'Funnel 2.0 Task 9';
        sp.Business_Unit__c = 'GEMS_NA';
        sp.Must_complete_on_Stage__c = false;
        sp.Description__c = 'This task is required for stage 1';
        sp.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        sp.Subject__c = 'Opp Update';
        sp.Due_Date_From__c = 'Task Create Date';
        sp.Due_Date__c = 30.0;
        sp.Assignee__c = 'Owner';
        sp.Stage__c = 'Stage 1 - Qualified';
        sp.Type__c = 'Funnel Management';
        sp.Object__c = 'Opportunity';
        sp.Is_Active__c = true;
        spList.add(sp);
        
        Sales_Processes__c spp = new Sales_Processes__c();
        spp.Name = 'Funnel 2.0 Task 9';
        spp.Business_Unit__c = 'GEMS_NA';
        spp.Must_complete_on_Stage__c = false;
        spp.Description__c = 'This task is required for stage 1';
        spp.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        spp.Subject__c = 'Opp Update';
        spp.Due_Date_From__c = 'Task Create Date';
        spp.Due_Date__c = 30.0;
        spp.Assignee__c = 'Owner';
        spp.Stage__c = 'Stage 1 - Qualified';
        spp.Type__c = 'Funnel Management';
        spp.Object__c = 'Opportunity';
        spp.Is_Active__c = true;
        spList.add(spp);
        
        Sales_Processes__c sp1 = new Sales_Processes__c();
        sp1.Name = 'Funnel 2.0 Task 9';
        sp1.Business_Unit__c = 'GEMS_NA';
        sp1.Must_complete_on_Stage__c = false;
        sp1.Description__c = 'This task is required for stage 1';
        sp1.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        sp1.Subject__c = 'Opp Update';
        sp1.Due_Date_From__c = 'Task Create Date';
        sp1.Due_Date__c = 30.0;
        sp1.Assignee__c = 'Owner';
        sp1.Stage__c = 'Stage 2 - Needs Identified & Accepted';
        sp1.Type__c = 'Funnel Management';
        sp1.Object__c = 'Opportunity';
        sp1.Is_Active__c = true;
        spList.add(sp1);
        
        Sales_Processes__c sp12 = new Sales_Processes__c();
        sp12.Name = 'Funnel 2.0 Task 9';
        sp12.Business_Unit__c = 'GEMS_NA';
        sp12.Must_complete_on_Stage__c = false;
        sp12.Description__c = 'This task is required for stage 1';
        sp12.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        sp12.Subject__c = 'Opp Update';
        sp12.Due_Date_From__c = 'Task Create Date';
        sp12.Due_Date__c = 30.0;
        sp12.Assignee__c = 'Owner';
        sp12.Stage__c = 'Stage 2 - Needs Identified & Accepted';
        sp12.Type__c = 'Funnel Management';
        sp12.Object__c = 'Opportunity';
        sp12.Is_Active__c = true;
        spList.add(sp12);
        
        Sales_Processes__c sp2 = new Sales_Processes__c();
        sp2.Name = 'Funnel 2.0 Task 9';
        sp2.Business_Unit__c = 'GEMS_NA';
        sp2.Must_complete_on_Stage__c = false;
        sp2.Description__c = 'This task is required for stage 1';
        sp2.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        sp2.Subject__c = 'Opp Update';
        sp2.Due_Date_From__c = 'Task Create Date';
        sp2.Due_Date__c = 30.0;
        sp2.Assignee__c = 'Owner';
        sp2.Stage__c = 'Stage 3 - Solution Presented & Accepted';
        sp2.Type__c = 'Funnel Management';
        sp2.Object__c = 'Opportunity';
        sp2.Is_Active__c = true;
        spList.add(sp2);
        
        Sales_Processes__c sp3 = new Sales_Processes__c();
        sp3.Name = 'Funnel 2.0 Task 9';
        sp3.Business_Unit__c = 'GEMS_NA';
        sp3.Must_complete_on_Stage__c = true;
        sp3.Description__c = 'This task is required for stage 1';
        sp3.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        sp3.Subject__c = 'Opp Update';
        sp3.Due_Date_From__c = 'Task Create Date';
        sp3.Due_Date__c = 30.0;
        sp3.Assignee__c = 'Owner';
        sp3.Stage__c = 'Stage 4 - Specific Price / Budget';
        sp3.Type__c = 'Funnel Management';
        sp3.Object__c = 'Opportunity';
        sp3.Is_Active__c = true;
        spList.add(sp3);
        
        Sales_Processes__c sp4 = new Sales_Processes__c();
        sp4.Name = 'Funnel 2.0 Task 9';
        sp4.Business_Unit__c = 'GEMS_NA';
        sp4.Must_complete_on_Stage__c = false;
        sp4.Description__c = 'This task is required for stage 1';
        sp4.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        sp4.Subject__c = 'Opp Update';
        sp4.Due_Date_From__c = 'Task Create Date';
        sp4.Due_Date__c = 30.0;
        sp4.Assignee__c = 'Owner';
        sp4.Stage__c = 'Stage 5 - Order Placement';
        sp4.Type__c = 'Funnel Management';
        sp4.Object__c = 'Opportunity';
        sp4.Is_Active__c = true;
        spList.add(sp4);
        
        insert spList;
    }
    
    
}