trigger CalculateTimeTookForFirstAction on Lead (after update) {
        Lead lead; 
        Lead lead2;        
        List<lead> list_lead_update =new List<Lead>(); 
        List<lead> list_lead_update2 =new List<Lead>();       
        Map<String, BusinessHours> mapRegBusiness = new Map<String, BusinessHours>();   
        String currentUserName = userinfo.getName();     
        //Map<String, Profile_Check_for_Rating__c> profile_chk = Profile_Check_for_Rating__c.getAll();       
        //Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()limit 1];
        for(BusinessHours bhs : [select name from businesshours where IsActive=true])
        {              
            mapRegBusiness.put(bhs.Name, bhs);            
        }
        for (Lead l : trigger.new)
        {                                               
            //if ( (trigger.oldMap.get(l.id).Most_Recent_Action__c == null || trigger.oldMap.get(l.id).Most_Recent_Action__c == '' || trigger.oldMap.get(l.id).Most_Recent_Action__c == 'New') && l.Most_Recent_Action__c != 'New' && l.Most_Recent_Action__c != null && l.Time_to_First_Action__c == null)
            if (trigger.oldMap.get(l.id).Most_Recent_Action__c == 'New' && l.Most_Recent_Action__c != 'New' && l.Most_Recent_Action__c != null)    
            {
                BusinessHours bh = mapRegBusiness.get(l.Business_Unit__c);
                Datetime endTime = l.LastModifiedDate;
                //Datetime startTime = l.CreatedDate;  
                Datetime startTime = l.Lead_Disposition_Start_Time__c;
                Long diff = BusinessHours.diff(bh.id, startTime, endTime);                                    
                Double duration = diff/(1000.0*60.0); 
                lead = new Lead(id= l.id); 
                lead.Time_to_First_Action__c = duration;                
                //lead.Action_Date__c = l.LastModifiedDate;    
                lead.Action_Date__c = system.now(); 
                lead.First_Action_Taken__c = l.Most_Recent_Action__c; 
                lead.First_action_taken_by__c = currentUserName;                                              
                list_lead_update.add(lead);  
            }
            if ( (trigger.oldMap.get(l.id).First_Action_After_Qualification__c == null || trigger.oldMap.get(l.id).First_Action_After_Qualification__c == '' || trigger.oldMap.get(l.id).First_Action_After_Qualification__c == 'New') && l.First_Action_After_Qualification__c != 'New' && l.First_Action_After_Qualification__c != null && l.Time_to_First_Action_after_Qualification__c == null)
            {
                BusinessHours bh2 = mapRegBusiness.get(l.Business_Unit__c);
                Datetime endTime2 = l.LastModifiedDate;
                Datetime startTime2 = l.CreatedDate;                       
                Long diff2 = BusinessHours.diff(bh2.id, startTime2, endTime2);                                    
                Double duration2 = diff2/(1000.0*60.0); 
                lead2 = new Lead(id= l.id); 
                lead2.Time_to_First_Action_after_Qualification__c = duration2;                
                //lead.Action_Date__c = l.LastModifiedDate;    
                lead2.Action_Date_After_Qualification__c = system.now(); 
                lead2.Action_Taken_After_Qualification__c = l.First_Action_After_Qualification__c; 
                lead2.Action_Taken_By__c = currentUserName;                                              
                list_lead_update2.add(lead2); 
            }
        }
        try
        {                
            if(list_lead_update.size()>0)               
            update list_lead_update; } catch(exception e){ system.debug('exception*****>'+e); }  
// Set when and what action was taken first time after lead was qualified
       try
        {                
            if(list_lead_update2.size()>0)               
            update list_lead_update2; } catch(exception e){ system.debug('exception*****>'+e); }  

     
}