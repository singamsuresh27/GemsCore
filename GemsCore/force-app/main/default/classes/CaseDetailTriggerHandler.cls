public with sharing class CaseDetailTriggerHandler{
    public static Boolean isUpdate = true;
    public static Boolean fromSearch = false;    
    public static void updateQuantityReturned(Map<String,LineItem__c> mapOrders, LIST<Case_Detail__c> lstCaseDetails, Map<Id,Case_Detail__c> oldMap){
        for(Case_Detail__c line : lstCaseDetails){
            mapOrders.get(line.Order_Shipment__c).Quantity_Returned__c += (line.Quantity__c - oldMap.get(line.id).Quantity__c);
        }  
        isUpdate = false;     
        
        update mapOrders.values();
    }
    
    
    public static void updateCaseDetailTotal(Map<String,Case> mapCase){
        if(mapCase.size() > 0){    
            for(Case cs : mapCase.values()){
                cs.total__c = 0.0;
            }
            
            //update mapCase.values();
            for(AggregateResult agRes : [select case__c , sum(Amount__c) total from Case_Detail__c where case__c in : mapCase.keyset() group by case__c ]){
                if(mapCase.get((String)agRes.get('case__c')) != null){
                    mapCase.get((String)agRes.get('case__c')).total__c =  (Double)agRes.get('total');
                }
            }            
            update mapCase.values();
        
        }    
    }
}