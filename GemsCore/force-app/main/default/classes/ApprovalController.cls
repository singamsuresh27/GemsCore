/*public with sharing class ApprovalController {
    public List<opportunity>opplist {get;set;}
    public List<Additional_ship_To__c>shiplist {get;set;}   
    Public List<opportunityLineitem>oppline {get;set;}
    public set<id>oppset {get;set;}
    Public List<LineItem__c>linelist{get;set;} 
    public List<opportunity>listo{get;set;}
    Public List<String>lsst = new List<String>();
    public String ids;
    public list<Modelclass>mdlist{get;set;}
    
    public ApprovalController(){        
        mdlist = new list<modelclass>();
        oppset = new set<id>();        
        linelist = new list<Lineitem__c>();
        opplist = new List<opportunity>();
        shiplist = new List<Additional_ship_To__c>();
        oppline= new List <opportunityLineitem>();
        user usr= new user();
        
        // obtain record by quary for each object
        usr=[select name,companyid__c from user where id=: Userinfo.getUserId()];
        ids=usr.companyid__c;
      
        opplist=[select id,OPP_Approval_Status__c, PM_Com_rate__c, TM_Com_Rate__c, Name, Opportunity_Number__c, Total_New_Business__c, Estimated_Amount__c, OPP_Owners_Name__c,Clock_Start_Date__c,Clock_End_date__c, Project_Managers_Name__c, account.name, opportunity_approval_note__c, Account.BU_ID__c from opportunity where OPP_Approval_Status__c = 'Pending Approval' AND StageName = 'Closed Won' AND Account.BU_ID__c =: ids Order BY OPP_Owners_Name__c ];   
              
        for(opportunity oppObj:opplist){
            oppset.add(oppObj.id);
            if(oppObj.PM_Com_rate__c==null){
                oppObj.PM_Com_rate__c=0.0000;
            } 
            if(oppObj.TM_Com_Rate__c==null){
                oppObj.TM_Com_Rate__c=0.0000;
            } 
            
            mdlist.add(new modelclass(oppobj));
        }
        
        shiplist=[select commission_Approval_Status__c,account__r.name, account__r.AccountNumber, ship_To_Account_Number__c,Opportunityid__r.name,Opportunityid__r.Opportunity_Number__c from Additional_ship_To__c where Opportunityid__r.stagename='Closed Won' And commission_Approval_Status__c='pending Approval' ];
        oppline=[select Commission_Approval_Status__c,product2.name,Productcode,Opportunity.name,opportunity.opportunity_number__c from opportunityLineItem where opportunity.stagename = 'Closed Won' AND commission_Approval_Status__c='pending Approval'];       
        
     }  
    
    //method for save button
    public void save(){
        listo = new List<opportunity>();
        //temporary list for opportunity 
        List<opportunity> templist = new List<opportunity>();
        for(modelclass md : mdlist){
            templist.add(md.oppObj);
        }
        if(templist.size()>0){
              update templist;
        }
        oppList.addAll(templist);
        templist.clear();
        
        // Functionality for set today date for opportunity 
        for(opportunity opp:oppList){
            if(opp.OPP_Approval_Status__c=='Approved for All' ||opp.OPP_Approval_Status__c=='Approved for TM Only'|| opp.OPP_Approval_Status__c=='Approved for PM only'){    
             
                listo=[select Final_Com_Approval_Date__c from opportunity where id IN:oppset]; 
                
                // List to update Final_Com_Approval_Date field in opportunity
                for(opportunity ops :listo){
                    ops.Final_Com_Approval_Date__c=date.today();
                }
                update(listo);
            }  
        }
        oppList.clear();
        
        //linelist=[select Commission_Pay_Date__c from LineItem__c where Opportunityid__c IN: oppset];
        date d;
        for(modelclass md:mdlist){
            d=md.dateobj;
            system.debug('===d==='+d);
            for(lineitem__c line : [select Commission_Pay_Date__c from LineItem__c where Opportunityid__c =: md.oppobj.id]){   
                line.Commission_Pay_Date__c=d;    
                system.debug('===line.Commission_Pay_Date__c==='+line.Commission_Pay_Date__c);
                linelist.add(line);
            }
        }
        
            update linelist;
        
        
        //temporary list for Additional_ship_To__c 
        List<Additional_ship_To__c> tempship=new List <Additional_ship_To__c> ();       
        tempship.addAll(shiplist); 
        update tempship;
        shiplist.clear();
        shiplist.addAll(tempship); 
        tempship.clear();
        
        //temporary list for opportunityLineItem
        List<opportunityLineitem> tempItem =new List <opportunityLineitem>();
        tempitem.addAll(oppline);
        update tempitem;
        oppline.clear();
        oppline.addAll(tempitem);
        tempitem.clear();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your Record(s) Saved successfully!'));
 
        
    }  
   
    public class Modelclass{
        public opportunity oppObj{get;set;}
        public date dateobj {get;set;}
        
        public Modelclass(opportunity oppObj){
            this.oppObj=oppObj;
            for(opportunity lines : [select id, ( select id, Commission_Pay_Date__c from Orders_Shipments__r ) from opportunity]){
                if(lines.Orders_Shipments__r.size() > 0){
                    dateobj= lines.Orders_Shipments__r[0].Commission_Pay_Date__c;
                }
            }
            this.dateobj=date.today();
        }
    }  
}
*/






public with sharing class ApprovalController {
    public List<opportunity>opplist {get;set;}
    public List<Additional_ship_To__c>shiplist {get;set;}   
    Public List<opportunityLineitem>oppline {get;set;}
    public set<id>oppset {get;set;}
    Public List<LineItem__c>linelist{get;set;} 
    public List<opportunity>listo{get;set;}
    Public List<String>lsst = new List<String>();
    public String ids;
    
    public list<Modelclass>mdlist{get;set;}
    
    public ApprovalController(){        
         mdlist = new list<modelclass>();
         oppset = new set<id>();
        
        linelist = new list<Lineitem__c>();
        opplist = new List<opportunity>();
        shiplist = new List<Additional_ship_To__c>();
        oppline= new List <opportunityLineitem>();
        user usr= new user();
        
        // obtain record by quary for each object
        usr=[select name,companyid__c from user where id=: Userinfo.getUserId()];
        ids=usr.companyid__c;
      
        opplist=[select id,OPP_Approval_Status__c, PM_Com_rate__c, TM_Com_Rate__c, Name, Opportunity_Number__c, Total_New_Business__c, Estimated_Amount__c, OPP_Owners_Name__c,Clock_Start_Date__c,Clock_End_date__c, Project_Managers_Name__c, account.name, opportunity_approval_note__c, Account.BU_ID__c, Final_Com_Approval_Date__c from opportunity where OPP_Approval_Status__c = 'Pending Approval' AND StageName = 'Closed Won' AND Account.BU_ID__c =: ids Order BY OPP_Owners_Name__c ];   
        system.debug('===oppList1==='+oppList);      
        for(opportunity oppObj:opplist){
            oppset.add(oppObj.id);
            if(oppObj.PM_Com_rate__c==null){
                oppObj.PM_Com_rate__c=0.0000;
            } 
            if(oppObj.TM_Com_Rate__c==null){
                oppObj.TM_Com_Rate__c=0.0000;
            } 
            mdlist.add(new modelclass(oppobj));
        }
        
        shiplist=[select commission_Approval_Status__c,account__r.name, account__r.AccountNumber, ship_To_Account_Number__c,Opportunityid__r.name,Opportunityid__r.Opportunity_Number__c from Additional_ship_To__c where Opportunityid__r.stagename='Closed Won' And commission_Approval_Status__c='pending Approval' ];
        oppline=[select Commission_Approval_Status__c,product2.name,Productcode,Opportunity.name,opportunity.opportunity_number__c from opportunityLineItem where opportunity.stagename = 'Closed Won' AND commission_Approval_Status__c='pending Approval'];       
        
     }  
    
    //method for save button
    public void save(){
        listo = new List<opportunity>();
        //temporary list for opportunity 
        List<opportunity> templist = new List<opportunity>();
        for(modelclass md : mdlist){
            templist.add(md.oppObj);
        }
        if(templist.size()>0){
              update templist;
        }
        oppList.addAll(templist);
        system.debug('===oppList2==='+oppList);
        templist.clear();
        
        // Functionality for set today date for opportunity 
        for(opportunity opp:oppList){
            if(opp.OPP_Approval_Status__c=='Approved for All' ||opp.OPP_Approval_Status__c=='Approved for TM Only'|| opp.OPP_Approval_Status__c=='Approved for PM only'){    
                opp.Final_Com_Approval_Date__c = date.today();
                update opp; 
                /*listo=[select Final_Com_Approval_Date__c from opportunity where id IN:oppset]; 
                system.debug('===listo==='+listo);
                // List to update Final_Com_Approval_Date field in opportunity
                for(opportunity ops :listo){
                system.debug('===opportunity-ops==='+ops);
                    ops.Final_Com_Approval_Date__c = date.today();
                    system.debug('===ops.Final_Com_Approval_Date__c==='+ops.Final_Com_Approval_Date__c);
                    update ops;
                    system.debug('===ops-list==='+ops);
                }*/
                
            }  
        }
        oppList.clear();
        
        //linelist=[select Commission_Pay_Date__c from LineItem__c where Opportunityid__c IN: oppset];
        date d;
        for(modelclass md:mdlist){
            if(md.oppobj.OPP_Approval_Status__c=='Approved for All'|| md.oppobj.OPP_Approval_Status__c=='Approved for TM Only'|| md.oppobj.OPP_Approval_Status__c=='Approved for PM only'){
                d=md.dateobj;
                system.debug('===d==='+d);
                for(lineitem__c line : [select Commission_Pay_Date__c from LineItem__c where Opportunityid__c =: md.oppobj.id]){   
                    line.Commission_Pay_Date__c=d;    
                    system.debug('===line.Commission_Pay_Date__c==='+line.Commission_Pay_Date__c);
                    update line;
                }
            }
        }
        /*if(linelist.size()>0){
            update linelist;
        }*/
        
        //temporary list for Additional_ship_To__c 
        List<Additional_ship_To__c> tempship=new List <Additional_ship_To__c> ();       
        tempship.addAll(shiplist); 
        update tempship;
        shiplist.clear();
        shiplist.addAll(tempship); 
        tempship.clear();
        
        //temporary list for opportunityLineItem
        List<opportunityLineitem> tempItem =new List <opportunityLineitem>();
        tempitem.addAll(oppline);
        update tempitem;
        oppline.clear();
        oppline.addAll(tempitem);
        tempitem.clear();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your Record(s) Saved successfully!'));
 
        
    }  
   
    public class Modelclass{
        public opportunity oppObj{get;set;}
        public date dateobj {get;set;}
        
        public Modelclass(opportunity oppObj){
            this.oppObj=oppObj;
            this.dateobj= date.today();
      }
 
    }  
}