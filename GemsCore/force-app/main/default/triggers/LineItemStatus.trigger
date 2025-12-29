trigger LineItemStatus on Case_Detail__c (after update) {
	Set<Id> setCaseId = new set<Id>();
    for(Case_Detail__c LineItem : Trigger.new){
        if(LineItem.Case__c != null && (LineItem.Stage__c == 'Closed as Complete' || LineItem.Stage__c == 'Closed as Cancel'))
        	setCaseId.add(LineItem.Case__c);
    }
    LineItemHelper.LineItemUpdate(setCaseId);
}