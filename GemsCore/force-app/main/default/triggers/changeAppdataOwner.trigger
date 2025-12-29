trigger changeAppdataOwner on NBO_Forms__c (after insert) {
	NBO_Forms__c nbo; 
    List<ID> appdataIds = New List<ID> ();
    List<ID> opptyIds = New List<ID> ();
    list<ID> opptyOwner = New List<ID>();
    for (NBO_Forms__c app : Trigger.New){
        appdataIds.add(app.Id);
        opptyIds.add (app.Opportunity__c);
    }
    //List<Opportunity> opptyOwnerIds=[Select Id, OwnerId  From Opportunity Where Id IN:opptyIds]; 
    List<NBO_Forms__c> appDataOwnerNeedToUpdate = [Select Id, Opportunity__c, Opportunity__r.OwnerId  From NBO_Forms__c Where Id IN:appdataIds]; 
    // update app data ids with the opptyOwnerIds
    List<NBO_Forms__c> appDataOwnerUpdate=new List<NBO_Forms__c>();  
    for (NBO_Forms__c apps : appDataOwnerNeedToUpdate){
        //for (Opportunity opptys  : opptyOwnerIds) {
            //if (apps.Opportunity__c == opptys.Id){
            	nbo = new NBO_Forms__c(id= apps.id);            	                  
                //nbo.OwnerId = opptys.OwnerId;
                nbo.OwnerId = apps.Opportunity__r.OwnerId;
                appDataOwnerUpdate.add(nbo);                  
            //}           
        //}
    }       
  try{
      update appDataOwnerUpdate;
     }catch (DMLException e){
            system.debug('Oppty Swarm subscriptions were not all inserted successfully.  Error: '+e);
     }//catch  
}