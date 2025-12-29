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
private class TestMethods {

    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
        Datetime currentTime = system.now();
        Profile pro = [SELECT Id FROM Profile Where Name = 'System Administrator' LIMIT 1];
        
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

		User dev2 = new User(
				        lastname ='DevUser2', 
				        alias ='dev', 
				        email ='test.userdev@testdev2.com', 
				        username ='pretestdevusr@test2.com', 
				        ProfileId = pro.Id, 
				        EmailEncodingKey = 'ISO-8859-1', 
				        LanguageLocaleKey = 'en_US', 
				        LocaleSidKey = 'en_GB', 
				        TimeZoneSidKey = 'GMT', 
				        Job_Title__c ='Territory Manager', 
				        Managerid=dev.Id,
				        IsActive = true);
		insert dev2;
		
		User projectManager = new User(
				        lastname ='ProjectManager', 
				        alias ='dev', 
				        email ='projectManager@testdev3.com', 
				        username ='projectManager@test3.com', 
				        ProfileId = pro.Id, 
				        EmailEncodingKey = 'ISO-8859-1', 
				        LanguageLocaleKey = 'en_US', 
				        LocaleSidKey = 'en_GB', 
				        TimeZoneSidKey = 'GMT',
				        Job_Title__c ='Project Manager', 
				        Managerid=dev.Id,
				        IsActive = true);
		insert projectManager;
		
	    User projectManager2 = new User(
				        lastname ='ProjectManager2', 
				        alias ='Pro', 
				        email ='projectManager2@testdev3.com', 
				        username ='projectManager2@test3.com', 
				        ProfileId = pro.Id, 
				        EmailEncodingKey = 'ISO-8859-1', 
				        LanguageLocaleKey = 'en_US', 
				        LocaleSidKey = 'en_GB', 
				        TimeZoneSidKey = 'GMT',
				        Job_Title__c ='Project Manager', 
				        Managerid=dev.Id,
				        IsActive = true);
		insert projectManager2;
				        
        Account a = new Account(Name='Test');
        a.Is_Distributor__c = true;
        a.OwnerId=dev2.Id;
        insert a;
        
        Lead ld = new Lead();
		ld.Lastname='User';
		ld.Company='Test';
		ld.Phone='9889898989';
		ld.Rating='Cold';
		ld.Status='Disqualified';
		ld.email='a@a.com';
		ld.Reason__c = 'Sent To Distributor';
		ld.Account__c = a.Id;
		ld.Business_Unit__c = 'GEMS_NA';
		//ld.Status = 'Raw Lead';
		ld.Most_Recent_Action__c = 'New';
        ld.Lead_Disposition_Start_Time__c = currentTime; 
		//ld.Action_Date__c=system.now();
		//ld.Time_to_First_Action__c=410.15;
		ld.OwnerId = dev.Id;
		insert ld;
		
		// Start Testing trigger CalculateTimeTookForFirstAction
		// Create a new lead
		Lead ld2 = new Lead();
        ld2.Lastname='TestLastname';
        ld2.Firstname = 'Testfirstname';
		ld2.Company='Test';
		ld2.Phone='9889898989';
		ld2.Rating='Cold';
		ld2.Status='Suspect';
		ld2.email='test@test.com';
		ld2.Business_Unit__c = 'GEMS_NA';
        ld2.First_Action_After_Qualification__c = 'New';
		//ld.Most_Recent_Action__c = Null;
        //ld.Lead_Disposition_Start_Time__c = currentTime; 
		//ld.Action_Date__c=system.now();
		//ld.Time_to_First_Action__c=410.15;
		ld2.OwnerId = dev.Id;
		insert ld2;
        //Update the lead
        ld2.Status = 'Raw Lead';
        ld2.Most_Recent_Action__c = 'New';
        ld2.Lead_Disposition_Start_Time__c = currentTime;
        update ld2;
        // Update the Lead this will cause trigger to fire
        ld2.Most_Recent_Action__c = 'Sent Email';
        ld2.First_Action_Taken__c = 'Sent Email';
        ld2.Status = 'Suspect';
		update ld2;
		
		 //Update the Lead 
		ld2.Action_Date__c=currentTime;       
		ld2.Time_to_First_Action__c=410.15;
		update ld2;
		
		Lead lTest = [SELECT Id, Action_Date__c,Time_to_First_Action__c, Lead_Disposition_Start_Time__c  FROM Lead WHERE Id=:ld2.Id];
        system.assertEquals(currentTime, lTest.Action_Date__c);
        system.assertEquals(currentTime, lTest.Lead_Disposition_Start_Time__c);
        system.assertEquals(410.15, lTest.Time_to_First_Action__c);
        // Update lead again to test action after qualification
        ld2.First_Action_After_Qualification__c = 'Sent Email';
        ld2.Action_Taken_After_Qualification__c = 'Sent Email';
        ld2.Status = 'Qualified';
        update ld2;
        ld2.Action_Date_After_Qualification__c=currentTime;  
        ld2.Time_to_First_Action_after_Qualification__c = 410.15;
        update ld2;
        Lead lTest2 = [SELECT Id, Action_Date_After_Qualification__c, Time_to_First_Action_after_Qualification__c  FROM Lead WHERE Id=:ld2.Id];
        system.assertEquals(currentTime, lTest2.Action_Date_After_Qualification__c);
        system.assertEquals(410.15, lTest2.Time_to_First_Action_after_Qualification__c);
        // end Testing trigger CalculateTimeTookForFirstAction 
				
        // convert the lead
		Lead ld1 = new Lead();
		ld1.Lastname='User1';
		ld1.Company='Test';
		ld1.Phone='9889898989';
		ld1.Rating='Cold';
		ld1.Status='Open';
		ld1.email='a@a.com';
		ld1.Business_Unit__c = 'GEMA_US';
		insert ld1;
		
		Note nt = new Note();
		nt.Body = 'Sample Body';
		nt.Title = 'Title';
		nt.IsPrivate = true;
		nt.ParentId = ld1.Id;
		insert nt;
		
		Attachment att = new Attachment();
		att.Name = 'Dummy Attachment';
		//att.ContentType = '';
		att.IsPrivate = true;
		att.ParentId = ld1.Id;
		att.Description = 'Some Description';
		att.Body = Blob.valueOf('Hello');
		insert att;
		
		Database.LeadConvert lc = new database.LeadConvert(); 
		lc.setLeadId(ld1.Id);

		LeadStatus convertstatus = [select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];		
		lc.setConvertedStatus(convertStatus.MasterLabel); 
		Database.LeadConvert[] lcArray = new Database.LeadConvert[] {lc}; 
		Database.LeadConvertResult[] results = Database.convertLead(lcArray);
		System.assert(results[0].IsSuccess());

        
        Opportunity opp = new Opportunity();
        opp.AccountId = a.Id;
        opp.Name = 'Test Opp';
        opp.PCM_Q1__c = 'Prototypes Only';
        opp.PCM_Q2__c = '0 – 40 ($4000 NRE)';
        opp.PCM_Q3__c = 'Component only & core competency';
        opp.PCM_Q4__c = 'Existing cell';
        opp.PCM_Q5__c = '$0 - $1000 Fixtures & Gauges Off the shelf or existing';
        opp.PCM_Q6__c = 'Current part, consistent usage';
        opp.PCM_Q7__c = 'Current suppliers, standard lead-times';
        opp.PCM_Q8__c = 'Existing Quality System';
        opp.PCM_Q9__c = 'Sales, Eng, Purch';
        opp.PCM_Q10__c = 'All';
        opp.PCM_Q11__c = '24+ weeks';
        opp.StageName = 'Stage 0 - Pre Project';
        opp.CloseDate = Date.today();
        opp.Project_Manager__c = projectManager.Id;
        opp.OwnerId = projectManager.Id;
        insert opp;
        
        opp.PCM_Q1__c = 'Prototypes & internal or external test or approval';
        opp.PCM_Q2__c = '40- 240 ($24,000 NRE)';
        opp.PCM_Q3__c = 'Component or system; General expertise or technology in house';
        opp.PCM_Q4__c = 'New Cell / Cell expansion or modification';
        opp.PCM_Q5__c = '$0 - $20,000 Simple tooling (plastic mold) New Fixtures/Gages';
        opp.PCM_Q6__c = 'New part, must have consistent usage, medium volume';
        opp.PCM_Q7__c = 'One new supplier, long lead-time, complex BOM';
        opp.PCM_Q8__c = 'DFMEA, PFMEA and Control Plan Req\'d';
        opp.PCM_Q9__c = 'Sales, Eng, Mfg Eng, Purch, Supply Chain, Quality';
        opp.PCM_Q10__c = 'Need to bring in one outside skill';
        opp.PCM_Q11__c = '8 – 24 weeks';
        opp.Project_Manager__c = projectManager2.Id;
        opp.OwnerId = dev2.Id;
        update opp;
        
        opp.PCM_Q1__c = 'Prototypes, reliabilty testing and agency approvals';
        opp.PCM_Q2__c = '240+ ($50,000 NRE)';
        opp.PCM_Q3__c = 'Full system; limited or no expertise or technology in house';
        opp.PCM_Q4__c = 'New Value stream to New building';
        opp.PCM_Q5__c = '$20,000 + (Significant capital investment)';
        opp.PCM_Q6__c = 'New part, inconsistent usage, low volume';
        opp.PCM_Q7__c = 'Find and qualify new suppliers, new to Gems parts';
        opp.PCM_Q8__c = 'DFMEA, PFMEA, Control Plan and PPAP Req\'d or ISO13485 req\'ts';
        opp.PCM_Q9__c = 'Mktg., Sales, Eng, Mfg Eng, Purch, Supply Chain, Quality';
        opp.PCM_Q10__c = 'Need to bring in two outside skills';
        opp.PCM_Q11__c = '0 – 8 weeks';
        opp.Project_Manager__c = projectManager.Id;
        opp.OwnerId = projectManager2.Id;
        update opp;
                
        Note nt1 = new Note();
		nt1.Body = 'Sample Body';
		nt1.Title = 'Title';
		nt1.IsPrivate = true;
		nt1.ParentId = opp.Id;
		insert nt1;
		
		Attachment att1 = new Attachment();
		att1.Name = 'Dummy Attachment';
		att1.IsPrivate = true;
		att1.ParentId = opp.Id;
		att1.Description = 'Some Description';
		att1.Body = Blob.valueOf('Hello');
		insert att1;
		
		nt1.Title = 'Note Created On';
		update nt1; 
		
		//Test Method of ViewAllNotes_Attachments_Cls
		test.startTest();
		ApexPages.currentPage().getParameters().put('RecordId',opp.id);
		ApexPages.StandardController scOpp = new ApexPages.StandardController(opp);
		ViewAllNotes_Attachments_Cls  vac=new ViewAllNotes_Attachments_Cls(scOpp);
		vac.cancel();
		vac.NewNote();
		vac.AttachFile();
		
		//Test Method of NotesAttachments_Cls
		ApexPages.currentPage().getParameters().put('RecordId',opp.id);
		ApexPages.currentPage().getParameters().Put('Notes','Yes');
		ApexPages.StandardController scOpp1 = new ApexPages.StandardController(opp);
		NotesAttachments_Cls  NAC=new NotesAttachments_Cls(scOpp1);
		NAC.RedirectToNotes();
		NotesAttachments_Cls.AttachmentWrapper ntsWrap = new NotesAttachments_Cls.AttachmentWrapper();
		ntsWrap.fileName = 'Test File';
		ntsWrap.Description='Test Description';
		ntsWrap.fileBody = Blob.valueOf('Hello');
		NAC.AttachmentWrapperList=new list<NotesAttachments_Cls.AttachmentWrapper>();
		NAC.AttachmentWrapperList.add(ntsWrap);
		
		NAC.AttachFile();
		NAC.AddOneMoreRow();
		NAC.cancel();
				
		//Test coverage for LastChatterDate Trigger 		
		FeedItem post = new FeedItem();
        post.parentId = opp.Id;
        post.body = 'Test chatter post';
        insert post;
        
        Integer cnt = [Select count() from FeedItem Where ParentId = :opp.Id];
        system.assertEquals(1, cnt);
        
        FeedComment postComment = new FeedComment();
        postComment.FeedItemId=post.id;
        postComment.CommentBody = 'Test chatter Comment post';
        insert postComment;
        
        Integer cnt1 = [Select count() from FeedComment Where ParentId = :opp.Id];
        system.assertEquals(1, cnt1);
        test.stopTest();       
    }
    //Test mathod to test batch apex class ActionPlanBatchTaskDueStatusUpdate
    static testmethod void APBatchTaskDueTest(){
    	//APTaskTemplate__c         Action Plan Task detail
    	//APTTaskTemplate__c        Action Plan Template Task detail
    	//String ids = UserInfo.getUserId();
    	ActionPlansTestUtilities apTUtil = new ActionPlansTestUtilities();
		ActionPlan__c ap =   apTUtil.createNewActionPlan('accounts',1);
    	APTaskTemplate__c at = new APTaskTemplate__c();
	   	at.Action_Plan__c 	 = ap.Id;
	   	at.Dependent__c		 = 'None';
	   	at.DaysFromStart__c  = 2.0;
	   	at.User__c			 = Userinfo.getUserId();
	   	at.SendEmail__c		 = false;
	   	at.Subject__c		 = 'Test ';
	   	at.Type__c			 = 'Email';
	   	at.Priority__c		 = 'Low';
	   	at.Comments__c		 = 'Test';
	   	at.Reminder__c		 = true;
	   	at.Minutes_Reminder__c = '510';
	   	insert at;

    	test.startTest(); 
    	ActionPlanBatchTaskDueStatusUpdate APT = new ActionPlanBatchTaskDueStatusUpdate();
        ID batchprocessid = Database.executeBatch(APT);
    	
    	test.stopTest();   	
    }
    //test method for schadulable ActionPlanBatchTaskDueStatusSchedular          
	static testMethod void ActionPlanBatchTaskDueStatusSchedularTest() {
        test.startTest();
		ActionPlanBatchTaskDueStatusSchedular apts = new ActionPlanBatchTaskDueStatusSchedular();
		String schedule = '0 0 23 * * ?';
		system.schedule('Nightly Update', schedule, apts);
		test.stopTest();
    }
   
       
}