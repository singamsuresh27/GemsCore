global class OpportunityDetailController{
    public boolean isEdit{get;set;}
    public Opportunity oppRecord{get;set;}
    Opportunity tempOp ; 
    String myqry ='';
    //public OpportunityDetailController(){
    public OpportunityDetailController(ApexPages.StandardController controller) {
        isEdit = false;
        oppRecord = new Opportunity();
        String oppId = ApexPages.currentPage().getParameters().get('id');
        if(oppId != null && oppId.trim().length() > 0 ){
            //oppRecord = [Select o.Type, o.StageName, o.OwnerId, o.Name, o.LeadSource, o.IsPrivate, o.Id, o.CloseDate, o.CampaignId, o.Amount, 
                         //o.AccountId From Opportunity o WHERE Id=:oppId];
                         
            SObject sobj = SObjectHelper.createObject('Opportunity');
            myqry = 'Select ';
            for(String st : SObjectHelper.getObjectFieldsList(sobj)){
                myqry += st + ',';
            }
            myqry = myqry.substring(0,myqry.lastIndexof(','));
            myqry += ' from Opportunity where id =\''+ oppId +'\'';
            oppRecord = (Opportunity)Database.query(myqry);
        }
        
        tempOp = oppRecord;
        
        
        
    }
    
    // Toogle between Edit And read-only view.
    public void toggleEdit(){
        if(isEdit)
            isEdit = false;
        else
            isEdit = true;
    }
    
    // Save changes in Task.
    public void saveOpportunity(){
        try{      
            update oppRecord;
            
            isEdit = false;
            Apexpages.addMessage(new Apexpages.Message(ApexPages.SEVERITY.Confirm , 'Opportunity Updated.'));
            oppRecord = (Opportunity)Database.query(myqry);
        }
        catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.SEVERITY.Confirm , e.getMessage()));
        }        
    }
    
    // Cancel Edit mode.
    public void cancelSave(){
      isEdit = false;
      //update tempOp;
    }
    
    
       
}