public with sharing class MfgBuildSummary {
	public CBO__c cbo{get;set;}
    public string cboId{get;set;}
    public string cboLabel{get;set;}
    
     public MfgBuildSummary(ApexPages.StandardController stdController){
        
        cboId=stdController.getId();
        if(cboId==null || cboId==''){
            cboId=ApexPages.currentPage().getParameters().get('id');
            //ApexPages.currentPage().getParameters().get('id')           
       	}
       	if(cboId!=null && cboId!=''){
     		cbo = [Select c.Technical_Feasibility_Issues__c, c.Start_With_BOM__c, c.Productid__c, c.Pressure_Type__c, c.Pressure_Range__c, c.Pressure_Port_Fitting__c, c.Other_Required__c, c.Referred_Part__c, c.OPP_Name__c, c.Name, c.Excitation_Supply_Voltage__c, c.Electrical_Termination__c, c.Electrical_Signal_Output__c, c.Design_Notes_ME__c, c.Design_Notes_DE__c, c.Agency_Approvals__c, c.Accuracy__c, c.Account_Name__c, (Select Name, Quantity__c, Description__c, Notes__c, Action__c From BOM_Changes__r) From CBO__c c where id=:cboId];
     	}
     }
}