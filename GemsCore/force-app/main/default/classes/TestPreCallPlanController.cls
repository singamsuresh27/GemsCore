@isTest
public class TestPreCallPlanController{
    public static testMethod void unitTest1(){
        LIST<RecordType> recType = [select id,name from RecordType where SObjecttype = 'Percall_Plan__c' order by Name];
        Account act = new Account(name='testAcc');
        act.Current_Year_Forecast__c =5000;
        insert act;
        
        Contact con = new Contact(firstname = 'test', lastname='test', accountId = act.id);
        insert con;
        
        MachineMatrix__c machine = new MachineMatrix__c();
        machine.Name = 'First Machine';
        machine.Estimated_Annual_Volume__c = 10.0;
        machine.account__c = act.id;
        insert machine;
        
        Application__c app1 = new Application__c();
        app1.Machine_Matrix__c = machine.id;
        app1.Name = 'App1';
        app1.Sell_Price__c = 230.0;
        app1.Units_per_machine__c = 300;
        app1.Supplier__c = 'GEMS';
        insert app1;
        
        Percall_Plan__c  preCallPlanObj = new Percall_Plan__c ();
        preCallPlanObj.Name = 'TestPrecall';
        preCallPlanObj.Account__c = act.id;
        preCallPlanObj.recordTypeId = recType[1].id;
        insert preCallPlanObj;

        ApexPages.StandardController sc = new ApexPages.StandardController(preCallPlanObj );
        PreCallPlanController obj = new PreCallPlanController(sc);
        ApexPages.currentPage().getParameters().put('id',preCallPlanObj.id);
        ApexPages.currentPage().getParameters().put('RecordType',recType[1].Name);
        ApexPages.currentPage().getParameters().put('actId',act.id);
        ApexPages.currentPage().getParameters().put('opId','null');
        obj = new PreCallPlanController(sc);
        obj.openAccount();
        obj.openPreCallPlan();  
        obj.editPreCallPlan();
        obj.addingMorePreCallPlanContactModel();
        obj.cancelMoreContact();
        obj.addingMoreCallObjectiveModel();
        obj.cancelMoreObjective();
        obj.addingMoreQuestions();
        obj.cancelMoreQuestions();
        obj.addingMoreObjections();
        obj.cancelMoreObjection();
        obj.addingMoreTask();
        obj.cancelMoreTask();
        obj.cancelPage();
        obj.justCalling();
        obj.editTripSummary();
        obj.saveTripSummary();
        obj.cancelTripSummary();
        obj.openPDFPage();
        obj.savePreCallPlan();
        obj.preCallPlan.Date_of_Visit__c  = System.today();
        obj.savePreCallPlan();
        obj.lstPreCallContactModel[0].tempConObj.FirstName = 'TestFirst';
        obj.lstPreCallContactModel[0].tempConObj.LastName = 'TestLast';
        obj.lstPreCallContactModel[0].tempConObj.email = 'TestFirst@test.com';
        obj.lstPreCallContactModel[0].donotAddContact  = false;   
        obj.lstPreCallContactModel[1].tempConObj.FirstName = 'TestSecond';
        obj.lstPreCallContactModel[1].tempConObj.LastName = 'TestSecond';
        obj.lstPreCallContactModel[1].tempConObj.email = 'TestSecond@test.com';
        obj.lstPreCallContactModel[1].donotAddContact  = true;   
        obj.savePreCallPlanContact();
        obj.lstConModel[0].flg = true;
        obj.saveContact();
        obj.lstCallObjectiveModel[0].objectiveText = 'test Objective';
        obj.saveCallObjectives();
        obj.lstKeyQuestionsModel[0].questions = 'test Questions';
        obj.lstKeyQuestionsModel[0].notes = 'test notes';        
        obj.saveKeyQuestions();
        obj.lstObjectionModel[0].objectiontext = 'test objection';
        obj.lstObjectionModel[0].responsetext = 'test response';        
        obj.saveObjections();
        obj.lstTaskModel[0].tasksubject = 'test subject';
        obj.saveTask();
        obj.preCallPlanContactId = obj.lstPreCallContactModel[0].preConObj.id;
        obj.removeContact(); 
        obj.callObjectiveId = obj.lstCallObjectiveModel[0].callObjectiveObj.id;
        obj.removeCallObjective(); 
        obj.questionId = obj.lstKeyQuestionsModel[0].qstObj.id;
        obj.removeQuestion();
        obj.objectionId = obj.lstObjectionModel[0].objectionObj.id;
        obj.removeObjection();
        obj.taskId = obj.lstTaskModel[0].taskObj.id;
        obj.removeTask();
        
        Percall_Plan__c  preCallPlanObj1 = new Percall_Plan__c ();
        preCallPlanObj1.Name = 'TestPrecall2';
        preCallPlanObj1.Account__c = act.id;
        preCallPlanObj1.recordTypeId = recType[0].id;
        insert preCallPlanObj1;
    }
    
    public static testMethod void unitTest2(){
        LIST<RecordType> recType = [select id,name from RecordType where SObjecttype = 'Percall_Plan__c' order by Name];
        Account act = new Account(name='testAcc');
        insert act;
        
        Contact con = new Contact(firstname = 'test', lastname='test', accountId = act.id);
        insert con;
        Percall_Plan__c  preCallPlanObj = new Percall_Plan__c ();
        preCallPlanObj.Name = 'TestPrecall';
        preCallPlanObj.Account__c = act.id;
        preCallPlanObj.recordTypeId = recType[1].id;
        insert preCallPlanObj;
        
        Percall_Plan__c  preCallPlanObj1 = new Percall_Plan__c ();
        preCallPlanObj1.Name = 'TestPrecall2';
        preCallPlanObj1.Account__c = act.id;
        preCallPlanObj1.recordTypeId = recType[0].id;
        insert preCallPlanObj1;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(preCallPlanObj );
        ApexPages.currentPage().getParameters().put('id',preCallPlanObj1.id);
        ApexPages.currentPage().getParameters().put('RecordType',recType[0].Name);
        ApexPages.currentPage().getParameters().put('actId',act.id);
        ApexPages.currentPage().getParameters().put('opId','null');
        PreCallPlanController obj1 = new PreCallPlanController(sc1);
        obj1.saveAccountPlan();
        obj1.preCallPlan.name ='test';
        obj1.saveAccountPlan();
        obj1.initializeMachineObject();
        obj1.addMachineMatrixRow();
        obj1.machineObj.Name = 'test Machine';
        obj1.machineObj.Estimated_Annual_Volume__c = 10.0;
        obj1.saveMachiMatrix();
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(new Percall_Plan__c ());
        ApexPages.currentPage().getParameters().put('RecordType',recType[1].Name);
        ApexPages.currentPage().getParameters().put('actId',act.id);
        ApexPages.currentPage().getParameters().put('opId','null');
        PreCallPlanController obj3 = new PreCallPlanController(sc3);
        obj3.preCallPlan.name ='test';
        obj3.preCallPlan.Date_of_Visit__c  = System.today();
        obj3.savePreCallPlan();
        obj3.openPreCallPlan();
    }
    
    public static testMethod void unitTest3(){
        LIST<RecordType> recType = [select id,name from RecordType where SObjecttype = 'Percall_Plan__c' order by Name];
        System.debug('--------> recType    ' +  recType );
        Account act = new Account(name='test');
        insert act;
        
        Contact con = new Contact(firstname = 'test', lastname='test', accountId = act.id);
        insert con;
        
        MachineMatrix__c machine = new MachineMatrix__c();
        machine.Name = 'First Machine';
        machine.Estimated_Annual_Volume__c = 10.0;
        machine.account__c = act.id;
        insert machine;
        
        Application__c app1 = new Application__c();
        app1.Machine_Matrix__c = machine.id;
        app1.Name = 'App1';
        app1.Sell_Price__c = 230.0;
        app1.Units_per_machine__c = 300;
        app1.Supplier__c = 'GEMS';
        insert app1;
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(new Percall_Plan__c ());
        ApexPages.currentPage().getParameters().put('RecordType',recType[0].Name);
        ApexPages.currentPage().getParameters().put('actId',act.id);
        ApexPages.currentPage().getParameters().put('opId','null');
        PreCallPlanController obj2 = new PreCallPlanController(sc2);
        obj2.preCallPlan.name ='test';
        obj2.saveAccountPlan();
        obj2.initializeMachineObject();
        obj2.addMachineMatrixRow();
        obj2.cancelMachineMartixRow();
        obj2.machineObj.Name = 'test Machine';
        obj2.machineObj.Estimated_Annual_Volume__c = 10.0;
        obj2.saveMachiMatrix();
        obj2.machineObjId = obj2.machineObj.id;
        obj2.gettingApplicationRecords();
        obj2.lstMachineMatrixModelNew[0].machApp.Sell_Price__c = 20;
        obj2.lstMachineMatrixModelNew[0].machApp.Units_per_machine__c = 20;
        obj2.saveMachiMatrixNew();
        obj2.justCalling1();
        obj2.openPreCallPlan();
        //obj2.openOpportunity();
        obj2.saveReportsToSetting();
        obj2.saveNewContact();
    }

    public static testMethod void unitTest4(){
        LIST<RecordType> recType = [select id,name from RecordType where SObjecttype = 'Percall_Plan__c' order by Name];
        System.debug('--------> recType    ' +  recType );
        Account act = new Account(name='test');
        act.Current_Year_Forecast__c = 5000;
        insert act;
        
        Contact con = new Contact(firstname = 'test', lastname='test', accountId = act.id);
        insert con;
        
        Percall_Plan__c  preCallPlanObj = new Percall_Plan__c ();
        preCallPlanObj.Name = 'Test';
        preCallPlanObj.Account__c = act.id;
        preCallPlanObj.recordTypeId = recType[1].id;
        insert preCallPlanObj;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(preCallPlanObj );
        PreCallPlanController obj = new PreCallPlanController(sc);
        ApexPages.currentPage().getParameters().put('id',preCallPlanObj.id);
        obj.checkingRecordTypes();
        ApexPages.currentPage().getParameters().put('RecordType',recType[1].id);
        obj = new PreCallPlanController(sc);
        
        obj.checkingRecordTypes(); 
        ApexPages.currentPage().getParameters().put('id',preCallPlanObj.id);
        obj = new PreCallPlanController(sc);
        obj.checkingRecordTypes(); 
        
        Percall_Plan__c  preCallPlanObj1 = new Percall_Plan__c ();
        preCallPlanObj1.Name = 'Test';
        preCallPlanObj1.Account__c = act.id;
        preCallPlanObj1.recordTypeId = recType[0].id;
        insert preCallPlanObj1;
        
        ApexPages.currentPage().getParameters().put('id',preCallPlanObj1.id);
        ApexPages.currentPage().getParameters().put('RecordType',recType[0].id);
        obj = new PreCallPlanController(sc);
        
        obj.checkingRecordTypes(); 
        
        /*ApexPages.currentPage().getParameters().put('id',preCallPlanObj1.id);
        ApexPages.currentPage().getParameters().put('actId',act.id);
        ApexPages.currentPage().getParameters().put('opId','null');
        ApexPages.StandardController sc1 = new ApexPages.StandardController(preCallPlanObj1);
        PreCallPlanController obj1 = new PreCallPlanController(sc1);
        obj1.checkingRecordTypes(); 
        obj1.AddOneRowAtc();  
        obj1.AddOneMoreRow(); 
        obj1.cancelForAttach();
        obj1.AddOneRowAtc();
        obj1.lstAttachs[0].atcObj.name = 'testatc';
        obj1.lstAttachs[0].atcObj.body = blob.valueOf('test');
        obj1.saveAttachs();
        List<Attachment> lstAtac = [ select id from Attachment where name='testatc'];
        if(lstAtac.size() > 0 ){
            obj1.removeAtcId = lstAtac[0].id;
            obj1.removeAttach(); 
        }*/
    }
    
    //BuildOrgChartController
    public static testMethod void unitTest5(){
        Account act = new Account(name='test');
        insert act;
        
        Contact con = new Contact(firstname = 'test', lastname='test', accountId = act.id);
        insert con;
        
        Contact con2 = new Contact(firstname = 'test', lastname='test', accountId = act.id,ReportsToid=con.id);
        insert con2;
        
        ApexPages.currentPage().getParameters().put('id',act.id);        
        BuildOrgChartController obj2 = new BuildOrgChartController();
        obj2.saveReportsToSetting();
        obj2.saveNewContact();
        
        con.Contact_Status__c = 'Disable';
        con.AccountId= null;
        update con;
        delete con2;
        
    }
    
    public static testMethod void unitTest6(){
        LIST<RecordType> recType = [select id,name from RecordType where SObjecttype = 'Percall_Plan__c' order by Name];
        System.debug('--------> recType    ' +  recType );
        Account act = new Account(name='test');
        act.Current_Year_Forecast__c = 5000;
        insert act;
        
        Contact con = new Contact(firstname = 'test', lastname='test', accountId = act.id);
        insert con;
        
        Percall_Plan__c  preCallPlanObj = new Percall_Plan__c ();
        preCallPlanObj.Name = 'Test';
        preCallPlanObj.Account__c = act.id;
        preCallPlanObj.recordTypeId = recType[1].id;
        insert preCallPlanObj;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(preCallPlanObj );
        PreCallPlanController obj = new PreCallPlanController(sc);
        ApexPages.currentPage().getParameters().put('id',preCallPlanObj.id);
        obj.checkingRecordTypes();
        ApexPages.currentPage().getParameters().put('RecordType',recType[1].id);
        obj = new PreCallPlanController(sc);
        
        obj.checkingRecordTypes(); 
        /*ApexPages.currentPage().getParameters().put('id',preCallPlanObj.id);
        obj = new PreCallPlanController(sc);
        obj.checkingRecordTypes(); */
        
        Percall_Plan__c  preCallPlanObj1 = new Percall_Plan__c ();
        preCallPlanObj1.Name = 'Test';
        preCallPlanObj1.Account__c = act.id;
        preCallPlanObj1.recordTypeId = recType[0].id;
        insert preCallPlanObj1;
        
        /*ApexPages.currentPage().getParameters().put('id',preCallPlanObj1.id);
        ApexPages.currentPage().getParameters().put('RecordType',recType[0].id);
        obj = new PreCallPlanController(sc);
        
        obj.checkingRecordTypes(); 
        */
        
        ApexPages.currentPage().getParameters().put('id',preCallPlanObj1.id);
        ApexPages.currentPage().getParameters().put('actId',act.id);
        ApexPages.currentPage().getParameters().put('opId','null');
        ApexPages.StandardController sc1 = new ApexPages.StandardController(preCallPlanObj1);
        PreCallPlanController obj1 = new PreCallPlanController(sc1);
        obj1.checkingRecordTypes(); 
        obj1.AddOneRowAtc();  
        obj1.AddOneMoreRow(); 
        obj1.cancelForAttach();
        obj1.AddOneRowAtc();
        obj1.lstAttachs[0].atcObj.name = 'testatc';
        obj1.lstAttachs[0].atcObj.body = blob.valueOf('test');
        obj1.saveAttachs();
        List<Attachment> lstAtac = [ select id from Attachment where name='testatc'];
        if(lstAtac.size() > 0 ){
            obj1.removeAtcId = lstAtac[0].id;
            obj1.removeAttach(); 
        }
    }
}