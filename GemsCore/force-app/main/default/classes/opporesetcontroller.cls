public with sharing class opporesetcontroller{
    
    private ApexPages.StandardSetController standardSetController;
    Id recordId;
    public  opporesetcontroller(ApexPages.StandardController standardController){
        try{
                this.standardSetController = standardSetController;
                recordId = standardController.getId();
                System.debug(recordid);
        }
      catch(Exception e){
          System.debug('In constructor:  '+e);
           apexpages.addmessages(e);   
      }          
    }
    public pagereference reset(){
        opportunity obj1=new opportunity();
        obj1=[select id,Clock_Start_Date__c ,Clock_End_date__c ,TM_Com_Rate__c ,PM_Com_rate__c ,OPP_Approval_Status__c ,Final_Com_Approval_Date__c ,Total_New_Business__c from opportunity where id =: recordid limit 1 ];
        list<LineItem__c>	invlist=new list<LineItem__c>();
        invlist=[select id,Opportunityid__c ,Is_Additional_Ship_To_Deleted__c ,Is_Account_Deleted__c  ,Date_Accepted__c ,Commissionable_Unit_Price__c ,Commission_Pay_Date__c  from LineItem__c where Opportunityid__c=: recordid];
        if(obj1 != null){
            obj1.Clock_Start_Date__c = null;
        	obj1.Clock_End_date__c = null;
        	obj1.TM_Com_Rate__c = null;
        	obj1.PM_Com_rate__c = null;
        	obj1.OPP_Approval_Status__c = null;
        	obj1.Final_Com_Approval_Date__c = null;
        	obj1.Total_New_Business__c = null;
            update obj1;
        }
        if(invlist.size()>0 && invlist != null){
            for(LineItem__c invobj:invlist){
                invobj.Opportunityid__c = null;
				invobj.Is_Additional_Ship_To_Deleted__c = false;
				invobj.Is_Account_Deleted__c = false;
				invobj.Date_Accepted__c = null;
				invobj.Commissionable_Unit_Price__c = null;
				invobj.Commission_Pay_Date__c = null;
			}
        }
        if(invlist.size()>0 && invlist != null){
            update invlist;
        }
        //Pagereference mypage=new pagereference('/apex/InvoiceBalasir');
        //mypage.getParameters().put('recordid',recordid);
        	return new pagereference('/'+recordid);
      }
}