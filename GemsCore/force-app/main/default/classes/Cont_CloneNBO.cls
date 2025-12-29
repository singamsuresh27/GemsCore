public with sharing class Cont_CloneNBO 
{
	public string RecordId{get;set;}
	public string CloneFieldId{get;set;}
	
	public string NBOStatus;
	public string NBODueDate;
	public string NBOPromiseDate;
	public string ApprovalsNeededBy;
	public string FeasibilityDueDate;
	public string DrawingDueDate;
	public string PrototypeDueDate;
	public string QuotationDueDate;
	public string EvaluationDuedate;
	public string ProjectEngineerName;
	public string ProjectEngineerId;
	public string ChiefEngineerName;
	public string ChiefEngineerId;
	
	public Cont_CloneNBO(ApexPages.StandardController stdController){
		RecordId=ApexPages.currentPage().getParameters().get('id');
	}
	
	public Pagereference RedirectToNBOClone(){
		
		Map<String,CloneVariable__c> mapClonevariable=CloneVariable__c.getAll();
		
		CloneFieldId=mapClonevariable.get('CloneFieldId').ContId__c;
		NBOStatus=mapClonevariable.get('NBOStatus').ContId__c;
		NBODueDate=mapClonevariable.get('NBODueDate').ContId__c;
		NBOPromiseDate=mapClonevariable.get('NBOPromiseDate').ContId__c;
		ApprovalsNeededBy=mapClonevariable.get('ApprovalsNeededBy').ContId__c;
		FeasibilityDueDate=mapClonevariable.get('FeasibilityDueDate').ContId__c;
		DrawingDueDate=mapClonevariable.get('DrawingDueDate').ContId__c;
		PrototypeDueDate=mapClonevariable.get('PrototypeDueDate').ContId__c;
		QuotationDueDate=mapClonevariable.get('QuotationDueDate').ContId__c;
		EvaluationDuedate=mapClonevariable.get('EvaluationDuedate').ContId__c;
		ProjectEngineerName=mapClonevariable.get('ProjectEngineerName').ContId__c;
		ProjectEngineerId=mapClonevariable.get('ProjectEngineerId').ContId__c;
		ChiefEngineerName=mapClonevariable.get('ChiefEngineerName').ContId__c;
		ChiefEngineerId=mapClonevariable.get('ChiefEngineerId').ContId__c;
		
			
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&'+NBODueDate+'=&'+NBOPromiseDate+'=&'+ApprovalsNeededBy+'=&'+FeasibilityDueDate+'=&'+DrawingDueDate+'=&'+PrototypeDueDate+'=&'+QuotationDueDate+'=&'+EvaluationDuedate+'=&'+ProjectEngineerName+'=&'+ProjectEngineerId+'=&'+ChiefEngineerName+'=&'+ChiefEngineerId+'=&'+NBOStatus+'=Not Started&'+CloneFieldId+'='+RecordId+'&retURL=/'+RecordId);
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
}