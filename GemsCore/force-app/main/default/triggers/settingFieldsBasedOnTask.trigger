trigger settingFieldsBasedOnTask on Opportunity (before insert,before update) {

    Set<String> oppIdSet = new Set<String>();
    Set<String> opStages = new Set<String>();
    for(Opportunity op : Trigger.NEW){
        oppIdSet.add(op.Id);
        opStages.add(op.StageName);
    }
    
    RecordType recType = [select id from RecordType Where SObjectType='Task' and Name = 'Sales Deliverable' limit 1];
        
    Map<String,Map<String,Date>> oppMap1 = new Map<String,Map<String,Date>>();
    for(AggregateResult ag : [select WhatId wid, Opportunity_Stage__c stg , ActivityDate adat  from Task where recordTypeId =: recType.Id and Opportunity_Stage__c != null and Opportunity_Stage__c in : opStages and whatId in : oppIdSet group by WhatId, Opportunity_Stage__c, ActivityDate order by WhatId, Opportunity_Stage__c, ActivityDate desc]){
        if(oppMap1.containsKey(ag.get('wid')+'')){
            if(!oppMap1.get(ag.get('wid')+'').containskey(ag.get('stg')+'')){
                oppMap1.get(ag.get('wid')+'').put(ag.get('stg')+'', Date.valueOf(ag.get('adat')));        
            }
        }else{
            Map<String,Date> tempMap = new Map<String,Date>();
            tempMap.put(ag.get('stg')+'', Date.valueOf(ag.get('adat')));
            
            oppMap1.put(ag.get('wid')+'', tempMap);
        }        
    }

    for(Opportunity op : Trigger.NEW){
        if(oppMap1.containsKey(op.Id)){
            op.NextStageDate__c = oppMap1.get(op.Id).get(op.StageName);
        }
    }
    
}