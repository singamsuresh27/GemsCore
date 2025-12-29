public class opprtunity_trigger_handler {
    public static boolean Checktest;
    public static boolean runTrigger; 
    public static void trigger_handler_method(List<Sobject> triggerdlist,boolean isinsert,boolean isdelete,boolean isupdate,Map<id,Sobject> newmap,Map<id,Sobject> oldmap){
        
        String sobj_p_oppid;//Sobject Opportunity id
        STring sobj_p_parentid;//Sobject Parent id
        String changing_field;// Sobject related chechbox field of invoice (lineitem) object
        
        //List for storing invoices
        List<lineitem__c> lineitemlist= new  List<lineitem__c>();
        
        //list for storing opportunities
        list<opportunity> opplist=new list<opportunity>();
        
        //Map for storing <Sobjectid,Opportunityid>
        Map<id,opportunity> oppmap=new Map<id,opportunity>(); 
        opportunity opps1;
        
        
        //Map for storing <Sobjectid,parentid>
        Map<id,id> parentid=new Map<id,id>();
        
        
        //Map for storing <parentids,no. of childs of that parent>
        Map<id,integer> parent_child_cnt=new Map<id,integer>();
        
        
        //Setting sobj_p_oppid,sobj_p_parentid and changing_field accoring to Sobject
        if(triggerdlist.getSObjectType() == OpportunityLineItem.Sobjecttype){
            sobj_p_oppid='Opportunityid';
            sobj_p_parentid='Product2id';
            changing_field='Is_Part_Number_Deleted__c';
        }
        else{
            sobj_p_oppid='Opportunityid__c';
            sobj_p_parentid='account__c';
            changing_field='Is_Additional_Ship_To_Deleted__c';
        }
        
        //Setting data for all maps
        for(Sobject sobj : triggerdlist){
            Id s1=(id)sobj.get(sobj_p_oppid);
            ID s2=(id)sobj.get('id');
            ID s3=(id)sobj.get(sobj_p_parentid);
            if(isinsert || isdelete)
            { 	
                parent_child_cnt.put(s3,0);
                oppmap.put(s1, null);
            }
            if(isupdate){
                if(newmap.get(s2).get(sobj_p_parentid) != oldmap.get(s2).get(sobj_p_parentid)){
                    parent_child_cnt.put(s3,0);
                    oppmap.put(s1, null);
                    
                }
            }
            if(isinsert){
                parentid.put(s2,s3);
            }
        }
        
        //Set of opportunities ids
        set<id> oppids=new set<id>();
        oppids.addAll(oppmap.keySet());
        
        Set<id> parents=new set<id>();
        parents.addAll(parent_child_cnt.keySet());
        
        
        
        
        if(oppmap.size() >0 && oppids.size()>0){
            String q8='select id,OPP_Approval_Status__c from opportunity where id in : oppids';
            //Getting opportunities in opplist
            opplist=[select id,OPP_Approval_Status__c,accountid from opportunity where id in : oppmap.keySet()];
            if(isdelete){
                string q;
                if(changing_field.equals('Is_Additional_Ship_To_Deleted__c') ){
                    q='select id, '+changing_field+' from lineitem__c where opportunityid__c in : oppids and Accountid__c in: parents';
                }      
                else{
                	 q='select id, '+changing_field+' from lineitem__c where opportunityid__c in : oppids and Productid__c in: parents';
                }
                //Getting invoices in lineitemlist
                lineitemlist=database.query(q);
                
            }  
            if(isupdate){
                string q='select id, '+changing_field+' from lineitem__c where opportunityid__c in : oppids and Accountid__c in: parents';
                
                //Getting invoices in lineitemlist
                lineitemlist=database.query(q);
                
            }
        }
        
        //Setting data in oppmap <opportunityid, opporunity obj>
        if(opplist.size()>0){
            for(opportunity oppobj : opplist){
                oppmap.put(oppobj.id,oppobj);
            }
        }
        //Fullfiling Condition no.2  LineItem__c. Is_Additional_Ship_To_Deleted__c = true
        if(isdelete  || isupdate){
            if( lineitemlist.size()>0){
                for(lineitem__c lineobj : lineitemlist){
                    lineobj.put(changing_field,true);
                }
            }
            update lineitemlist;
        }
        
        //Getting Sobjects parent child count and put in map parent_child_cnt
        if(isinsert){
            if(parentid != null && parentid.size()>0){
                List<Sobject> allsobjlist=new List<Sobject>();
                set<id> pids=new set<id>();
                pids.addAll(parent_child_cnt.keyset());
                String q1= 'select id,'+sobj_p_parentid+' from '+triggerdlist.getSObjectType()+ ' where '+sobj_p_parentid+' in : pids and  '+sobj_p_oppid+ ' in : oppids';
                allsobjlist= database.query(q1);
                for(Sobject sobj: allsobjlist){
                    id s4=(id)sobj.get(sobj_p_parentid);
                    parent_child_cnt.put(s4,parent_child_cnt.get(s4)+1);
                }
            }
            
            //Fulfilling condition no. 1 & 3:   Commission_Approval_Status__c=”Approved” &  does not add the same parent twice.
            for(Sobject sobj : triggerdlist){
                
                Id s1=(id)sobj.get(sobj_p_oppid);
                ID s2=(id)sobj.get('id');
                ID s3=(id)sobj.get(sobj_p_parentid);
                if( parent_child_cnt.get(parentid.get(s2)) > 0){
                    sobj.addError('!! WARNING: CANNOT ADD ONE PARENT RECORD TWICE ||');
                }
                
                Else {                opps1 = oppmap.get(s1);
                      if(changing_field.equals('Is_Additional_Ship_To_Deleted__c') )
                      {	if(oppmap.size() > 0 && opps1!=null){
                          if( opps1.accountid == sobj.get('account__c')){
                              sobj.addError('!! WARNING: OPPORTUNITY ALREADY HAVE THIS ACCOUNT AS PRIMARY ||');       
                          }
                          else{
                              if((opps1.OPP_Approval_Status__c != 'Approved for All') && (opps1.OPP_Approval_Status__c != 'Approved for TM Only') && (opps1.OPP_Approval_Status__c != 'Approved for PM Only') ){
                                  sobj.put('Commission_Approval_Status__c','Approved');
                              }
                              else{
                                  sobj.put('Commission_Approval_Status__c','Pending Approval');
                              }
                          }
                      }
                      }
                      else{
                          if(oppmap.size() > 0 && opps1!=null){
                              if((opps1.OPP_Approval_Status__c != 'Approved for All') && (opps1.OPP_Approval_Status__c != 'Approved for TM Only') && (opps1.OPP_Approval_Status__c != 'Approved for PM Only') ){
                                  sobj.put('Commission_Approval_Status__c','Approved');
                              }
                              else{
                                  sobj.put('Commission_Approval_Status__c','Pending Approval');
                              }
                          }
                      }
                     }
            }
        }
    }
    
}