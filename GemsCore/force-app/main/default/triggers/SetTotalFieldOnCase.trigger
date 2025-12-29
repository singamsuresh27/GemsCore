trigger SetTotalFieldOnCase on Case_Detail__c (after insert, before update,after update,after delete,after undelete) {
    Set<String> setCaseIds = new Set<String>();
    Set<String> setOrderIds = new Set<String>();
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
        for(Case_Detail__c line : Trigger.NEW){
            if(line.case__c != null){
                setCaseIds.add(line.Case__c);   
            }
            
            if(Trigger.isUpdate && line.case__c != null && Trigger.newMap.get(line.id).case__c != Trigger.oldMap.get(line.id).case__c){
                setCaseIds.add(line.Case__c);
            }
            
            if(Trigger.isUpdate && line.Order_Shipment__c != null &&  (Trigger.newMap.get(line.id).Quantity__c != Trigger.oldMap.get(line.id).Quantity__c || Trigger.newMap.get(line.id).Credit_per_unit__c != Trigger.oldMap.get(line.id).Credit_per_unit__c)){
                if(Trigger.isBefore)            
                    line.Amount__c = line.Quantity__c * line.Credit_per_unit__c;
                setOrderIds.add(line.Order_Shipment__c);    
            }
        }
    }    
    if(Trigger.isDelete){
        for(Case_Detail__c line : Trigger.OLD){
            if(line.case__c != null){
                setCaseIds.add(line.Case__c);   
            }
        }
    }
    
    
    
    
    //Fetching Case Objects to be updated
    if(Trigger.isUpdate && Trigger.isAfter){
        Map<String,Case> mapCase = new Map<String,Case>([select id,total__c, (Select id,Case__c, Total__c from Case_Details__r) from case where id in : setCaseIds]);
        if(mapCase.size() > 0 ){    
            CaseDetailTriggerHandler.updateCaseDetailTotal(mapCase);
        }
    }
    
    LIST<Case_Detail__c> lstCaseDetail = new LIST<Case_Detail__c>();
    Map<String,Case> mapForCaseDetail = new Map<String,Case>([select id,type from Case where id in : setCaseIds and type not in ('Credit Memo','Credit Memo Request')]);
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
        for(Case_Detail__c cd :Trigger.NEW){   
            if(cd.Case__c != null && mapForCaseDetail.get(cd.case__c) != null){
                lstCaseDetail.add(cd);                    
            }
        }
    }else if(Trigger.isDelete){
        for(Case_Detail__c cd :Trigger.OLD){   
            if(cd.Case__c != null && mapForCaseDetail.get(cd.case__c) != null){
                lstCaseDetail.add(cd);                    
            }
        }    
    }
    
    //Fetching Order & Shipments to be updated
    if(lstCaseDetail != null && lstCaseDetail.size() > 0){
        Map<String,LineItem__c> mapOrders;
        if(!CaseDetailTriggerHandler.FromSearch){
            mapOrders = new Map<String,LineItem__c>([select id, Quantity_Returned__c from LineItem__c where id in : setOrderIds]);    
        }else{
            mapOrders = new Map<String,LineItem__c>();
        }
        if(mapOrders.size() > 0 && CaseDetailTriggerHandler.isUpdate){
            CaseDetailTriggerHandler.updateQuantityReturned(mapOrders,lstCaseDetail, Trigger.oldMap);
        }
    }

}