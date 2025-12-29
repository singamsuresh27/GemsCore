public with sharing class TestClass_NewOppty 
{
	public static testMethod void testMethod_NewOppty ()
	{	
		newOpportunityController newopc=new newOpportunityController();
		newopc.count=0;
		newopc.getAccount();
		newopc.getContact();
		newopc.getOpportunity();
		newopc.getRole();
		newopc.step1();
		newopc.step2();
		newopc.step3();
		newopc.cancel();
		newopc.save();
	}

}