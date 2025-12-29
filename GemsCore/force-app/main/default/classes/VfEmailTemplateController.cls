public class VfEmailTemplateController{
    public String oppId{get;set;}
    public String dueDate{get;set;}
    List<Opportunity> oppList;
    
    public Opportunity opp{
        get{
            oppList = new List<Opportunity>();
            if(oppId != null && oppId.trim().length() > 0){
                
                oppList = [Select Id,Name,Estimated_Amount__c,Commercial_Triggers__c,CloseDate,Project_Manager__r.FirstName,Project_Manager__r.LastName,(Select Subject__c, body__c from TaskComments__r Where Opportunity_Stage__c='Stage 1 - Qualified' Order By Subject__c) from Opportunity where id =: oppId];
                if(oppList.size() > 0){
                    opp = oppList.get(0);
                    dueDate = opp.CloseDate.format();
                    
                    return opp;        
                }    
            }
            return opp = new Opportunity();
        }
        set;
        
    }
}