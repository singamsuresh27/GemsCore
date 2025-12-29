/**  @isTest
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
private class gemsCommonTest {	
	/*Private class to create a Account and Opportunity  */
	 static Opportunity createAccAndOpp()
	{
		Account acc = new Account();
		acc.Name='TestAcc';
		acc.Account_Type__c='New Customer';
		acc.Business_Unite__c='GEMS_NA';
		acc.CurrencyIsoCode='USD';
		insert acc;
		
		Opportunity Opp = new Opportunity();
		Opp.Name='Test';
		Opp.AccountId=acc.Id;
		Opp.Business_Unit__c='GEMS_NA';
		Opp.Type='New Business (Existing Account)';
		//Opp.Quantity=20.0;
		Opp.Unit_Price__c=10;
		Opp.CurrencyIsoCode='USD';
		Opp.CloseDate=Date.today().addDays(25);
		Opp.StageName='Stage 0 - Pre Project';
		 
		//Opp.ForecastCategory='Pipeline';
		insert Opp;
		
		return Opp;
	}

	
	static testMethod void testEmailTemplate_TestClass()
	{
		Lead led = new Lead();
		led.LastName='testLed';
		led.Company='Comp';
		led.Phone='9811098110';
		led.Rating='Cold';
		led.Business_Unit__c='GEMS_AS';
		LED.Status='Open';
		LED.PostalCode='50051';
		led.Email='aa@bb.com';
		led.CurrencyIsoCode='USD';
		//lead.Distributor_Email__c='test@test.com';
		insert led;
		
	//	ApexPages.currentPage().getParameters().put('id',led.Id);
		VF_Distributor_EmailTemplate VFTemplate = new VF_Distributor_EmailTemplate();		
		VFTemplate.setleadId(led.id);
		VFTemplate.getleadId();
        Note note =new Note();
        note.Body='idididiwdwdwd';
        note.Title='Hi';
        note.ParentId=led.Id;
        insert note;
        			                
		VFTemplate.leadDetails();
		VFTemplate.relatedNotes();
		
		//Code Coverage of AddDistributor class
		//Insert record in Zip Range
		Account acc = new Account();
		acc.Name='TestAcc1';
		acc.Account_Type__c='New Customer';
		acc.Business_Unite__c='GEMS_NA';
		acc.CurrencyIsoCode='USD';
		acc.Is_Distributor__c=true;
		acc.Total_Lead_Sent_This_Year__c=10;
		acc.Total_Number_of_Lead_Sent__c=5;
		insert acc;
		
		//Insert record in Zip Range
		Zip_Range__c zip=new Zip_Range__c();
		zip.Name='500';
		zip.Zip_To__c='529';
		zip.Account__c=acc.id;
		insert zip;
		
		ApexPages.currentPage().getParameters().put('TotalLeadSent','1');
		ApexPages.currentPage().getParameters().put('LeadsentThisYear','2');
		ApexPages.currentPage().getParameters().put('LeadId',led.id);
		ApexPages.currentPage().getParameters().put('ActId',acc.id);
		AddDistributor_Cls ads=new AddDistributor_Cls();
		ads.GetLeadDetail(led.id);
		ads.getAccountRangeList();
		ads.Back();
		//ads.UpdateLead();
		ads.isNaN('');
		
	}
	static testMethod void Clone_ClsTest()
	{
		Account acc = new Account();
		acc.Name='TestAcc';
		acc.Account_Type__c='New Customer';
		acc.Business_Unite__c='GEMS_NA';
		acc.CurrencyIsoCode='USD';
		insert acc;
		
		Opportunity Opp = new Opportunity();
		Opp.Name='Test';
		Opp.AccountId=acc.Id;
		Opp.Business_Unit__c='GEMS_NA';
		Opp.Type='New Business (Existing Account)';
		//Opp.Quantity=20.0;
		Opp.Unit_Price__c=10;
		Opp.CurrencyIsoCode='USD';
		Opp.CloseDate=Date.today().addDays(25);
		Opp.StageName='Stage 0 - Pre Project';
		//Opp.Project_Number__c='1234';
		//Opp.ForecastCategory='Pipeline';
		insert Opp;
		
		ApexPages.currentPage().getParameters().put('id',Opp.Id);
		ApexPages.StandardController std = new ApexPages.StandardController(Opp);
		 
		Clone_Cls cls = new Clone_Cls(std);
		
		cls.GetOppDetail(Opp.Id);
		ApexPages.currentPage().getParameters().put('CF00N600000022llz_lkid',Opp.Id);
		cls.RedirectToLESNewPage();
		cls.RedirectToLESClonePage();
		ApexPages.currentPage().getParameters().put('CF00N600000022oA2_lkid',Opp.Id);
		cls.RedirectToTSWClonePage();
		cls.RedirectToTSWNewPage();
		ApexPages.currentPage().getParameters().put('CF00N600000022oSr_lkid',Opp.Id);
		cls.RedirectToLECNewPage();
		cls.RedirectToLECClonePage();
		ApexPages.currentPage().getParameters().put('CF00N600000022p07_lkid',Opp.Id);
		cls.RedirectToFLONewPage();
		cls.RedirectToFLOClonePage();
		ApexPages.currentPage().getParameters().put('CF00N600000022pZO_lkid',Opp.Id);
		cls.RedirectToVALNewPage();
		cls.RedirectToVALClonePage();
		ApexPages.currentPage().getParameters().put('CF00N600000022qpY_lkid',Opp.Id);
		cls.RedirectToPRENewPage();
		cls.RedirectToPREClonePage();
		ApexPages.currentPage().getParameters().put('CF00N600000022rpB_lkid',Opp.Id);
		cls.RedirectToFTLNewPage();
		cls.RedirectToFTLClonePage(); 
	}
	
}