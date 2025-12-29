/*
###########################################################################
# Project Name..........: <<GEMS Sensors >>
# File..................: <<AddDistributor_Cls>>
# Version...............: <<1.0>>
# Created by............: <<Simplion Technologies>>
# Created Date..........: <<10th July 2012>>
# Last Modified by......: <<Simplion Technologies>>
# Last Modified Date....: <<11th July 2012>>
# Description...........: <<Using this class we are selecting Distributor Account on Led Object>>
###########################################################################
*/
public with sharing class AddDistributor_Cls 
{
    public string LeadId{get;set;}
    public integer ZipCode{get;set;}
    public boolean AlreadyMailSent{get;set;}
    //public Lead reasons {get;set;}
    public list<AccountRange> objAccountRangeList {get;set;}
    public Lead objLead{get;set;}
    //public List<Account> AccountList=new List<Account>();
    //Gazi Made change on 1/24/2013. Added business unit logic for EU leads
    public string BusinessUnit{get;set;}
    
    public AddDistributor_Cls()
    {
        objLead=new Lead();
        objAccountRangeList = new list<AccountRange>();
        AlreadyMailSent=false;
        LeadId=ApexPages.currentPage().getParameters().get('LeadId');
        GetLeadDetail(LeadId);
        getAccountRangeList();
    }
    
    public void GetLeadDetail(string LeadId)
    {
        if(LeadId!=null && LeadId!=''){
            objLead=[select Id,Reason__c,Date_Sent_to_Distributor__c,Other_Reason__c,Is_Email_Sent_to_Distributor__c,PostalCode, Business_Unit__c from Lead where id=:LeadId limit 1];
            if(objLead!=null){
                AlreadyMailSent=objLead.Is_Email_Sent_to_Distributor__c;
                BusinessUnit = objLead.Business_Unit__c;                
                if(objLead.PostalCode!=null && objLead.PostalCode!='' && objLead.Business_Unit__c=='GEMS_NA'){
                    string strZip=objLead.PostalCode.substring(0,3);
                    if(isNaN(strZip)==false){
                        ZipCode=Math.round(double.valueOf(strZip));
                    }   
                }
                
                if(objLead.Date_Sent_to_Distributor__c==null){
                    objLead.Date_Sent_to_Distributor__c=Datetime.Now();
                }
            }
        }
    }
    
      public List<SelectOption> getReasonList(){  
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('', '--None--'));
      options.add(new SelectOption('Low Volume OEM','Low Volume OEM'));
      options.add(new SelectOption('Low Volume End-User', 'Low Volume End-User'));
      options.add(new SelectOption('Other', 'Other'));
      return options;
    }
    
    public boolean isNaN(String value)
    {
        try
        {
            Integer d = Integer.valueOf(value);
        }
        catch(Exception e)
        {
        return true;
        }
    return false;
    }

    public void getAccountRangeList()
    {
        List<Account> AccountList=new List<Account>();
        Set<Id> AccountId=new Set<Id>();
        
        if(ZipCode!=null && BusinessUnit=='GEMS_NA'){
            List<Zip_Range__c> ZipList1=[Select Zip_To__c,Zip_To_Num__c, Zip_From__c, Account__c, Account__r.Email_Address__c From Zip_Range__c where Account__c!=null and Account__r.Is_Distributor__c=true and  Zip_From__c<=:ZipCode];
            if(ZipList1.size()>0){
                for(Zip_Range__c zrc:ZipList1){
                    if(zrc.Zip_To_Num__c>ZipCode){
                        AccountId.add(zrc.Account__c);
                    }
                }
            }
            
        }
        string SqlQuery='Select ShippingStreet, Id,OwnerId, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity, Name, Email_Address__c, AccountNumber, Total_Lead_Sent_This_Year__c, Total_Number_of_Lead_Sent__c, Distributors_Type__c   From Account where Is_Distributor__c=true';
        if(AccountId!=null && AccountId.size()>0){
            SqlQuery=SqlQuery + ' and id in : AccountId ';
        }
        SqlQuery= SqlQuery + ' order by Name';      
        AccountList = Database.query(SqlQuery);
        for(Account ac:AccountList){
            objAccountRangeList.add(new AccountRange(ac)); 
        }
    //  return AccountList;
    }   
    
    public Pagereference UpdateLead()
    {
        string ActId=ApexPages.currentPage().getParameters().get('ActId');
        for(AccountRange acr: objAccountRangeList){
            if(acr.AccountRange.Id==ActId){
                //Reason to do update under loop that only one record will come at a time.
                //Update Lead
                if(objLead.Reason__c != 'Other'){
                    objLead.Other_Reason__c=null;
                }
                objLead.Distributor_Email__c=acr.AccountRange.Email_Address__c;
                objLead.Status = 'Sent to Distributor';
                objLead.Is_Email_Sent_to_Distributor__c=true;
                objLead.Account__c=ActId;
                objLead.OwnerId=acr.AccountRange.OwnerId;
                update objLead;
                
                //Update Account
                Account accountUpdate=new Account(id=ActId);
                    accountUpdate.Total_Number_of_Lead_Sent__c = acr.AccountRange.Total_Number_of_Lead_Sent__c + 1; 
                    accountUpdate.Total_Lead_Sent_This_Year__c = acr.AccountRange.Total_Lead_Sent_This_Year__c + 1;
                update accountUpdate;
        
                break;
            }
        
        }
        return Back(); 
    }
    
    public Pagereference Back()
    {
        PageReference MainPage;
        MainPage= new PageReference('/'+LeadId);
        MainPage.setRedirect(true);
        return MainPage;    
    }
    
    class AccountRange{
        public Account AccountRange {get;set;}
        public AccountRange(Account AccountRange){
            this.AccountRange = AccountRange;
        } 
    }
}