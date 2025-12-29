public class LineItemHelper {
    public static void LineItemUpdate(Set<Id> setCaseId){
         list<Case> CaseList = new List<Case>();
         list<Case> CaseListSelected = new List<Case>();
         list<Case> CaseListUpdated = new List<Case>();         
       //  map<Case, list<Case_Detail__c>> MapCaseItemList;
         CaseList = [SELECT Id, Status,(SELECT ID,Stage__c from Case_Details__r) from Case WHERE Id in :setCaseId];
         for(Case caseL : CaseList){
             list<Case_Detail__c> lineItemList = new list<Case_Detail__c>();
             list<Case_Detail__c> lineItemListSelected = new list<Case_Detail__c>();
             lineItemList = caseL.Case_Details__r;
             for(Case_Detail__c li : lineItemList ){
                 if(li.Stage__c == 'Closed as Complete' || li.Stage__c == 'Closed as Cancel')
                     lineItemListSelected.add(li);
             }
             if(lineItemListSelected.size() == lineItemList.size())
             	CaseListSelected.add(caseL);
           //  MapCaseItemList.put(caseL,caseL.Case_Details__r);
         }
         for(Case caseL : CaseListSelected){
             caseL.Status = 'Closed as Complete';
             CaseListUpdated.add(caseL);
         }
         update CaseListUpdated;
    }
}