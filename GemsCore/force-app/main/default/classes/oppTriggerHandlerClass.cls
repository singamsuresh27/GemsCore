/* 
########################################################################### 
# Project Name..........: <<Gems Sensors >> 
# File..................: <<oppTriggerHandlerClass>> 
# Version...............: <<27.0>> 
# Created by............: <<Gazi Ahmed>> 
# Created Date..........: <<May 14 2013>> 
# Last Modified by......: <<Gazi Ahmed>> 
# Last Modified Date....: <<May 4 2013>>
# Description...........: <<This is Trigger Handler Class for trigger OpportunityStageTrigger. This trigger is for moving the big OPP through every stage/funnel based on the Milestones. Sach stage has Milestones.>> 
########################################################################### 
*/
public class oppTriggerHandlerClass{
    
    public static Boolean runTrigger = true;
    
    /*public static void OnBeforeUpdate(List<Opportunity> newOpportunities,Map<Id,Opportunity> newOpportunityMap,List<Opportunity> oldOpportunities,Map<Id,Opportunity> oldOpportunityMap){

        System.debug('-----newOpportunities--------' +newOpportunities);
        System.debug('-----oldOpportunityMap.get(opp.Id).StageName--------' +oldOpportunityMap);
        Map<String, String> recTypeNameMap = new Map<String, String>();
        for( RecordType rt: [Select SobjectType, Name, IsActive, Id, DeveloperName From RecordType where SobjectType ='Opportunity'] ){
            recTypeNameMap.put(rt.id, rt.name );
        }    
        
        //system.debug('==25===>'+recTypeNameMap);
        for(Opportunity opp : newOpportunities){
            //system.debug('==27===>'+opp.RecordTypeId+'---'+recTypeNameMap.containskey(opp.RecordTypeId)+'----'+recTypeNameMap.get(opp.RecordTypeId));
            //Checking the RecordType of an Opportunity is 'Active'
            if( opp.RecordTypeId!=null && recTypeNameMap!=null && recTypeNameMap.containskey(opp.RecordTypeId) && recTypeNameMap.get(opp.RecordTypeId) == 'Active'){
                //system.Debug('===30===>');
                //Moving other stages forward and backward
                if(opp.StageName == 'Stage 1 - Qualified' && opp.StageName == oldOpportunityMap.get(opp.Id).StageName){
                    //System.debug('opp.StageName -- '+opp.StageName +'-----oldOpportunityMap.get(opp.Id).StageName--------' +oldOpportunityMap.get(opp.Id).StageName);
                    if((opp.S2SD1__c == true && opp.S2SD1__c != oldOpportunityMap.get(opp.Id).S2SD1__c) ||
                        (opp.S2SD2__c == true && opp.S2SD2__c != oldOpportunityMap.get(opp.Id).S2SD2__c) ||
                        (opp.S2SD3__c == true && opp.S2SD3__c != oldOpportunityMap.get(opp.Id).S2SD3__c) ||
                        (opp.S2SD4__c == true && opp.S2SD4__c != oldOpportunityMap.get(opp.Id).S2SD4__c) ||
                        (opp.S3SD1__c == true && opp.S3SD1__c != oldOpportunityMap.get(opp.Id).S3SD1__c) ||
                        (opp.S3SD2__c == true && opp.S3SD2__c != oldOpportunityMap.get(opp.Id).S3SD2__c) ||
                        (opp.S3SD3__c == true && opp.S3SD3__c != oldOpportunityMap.get(opp.Id).S3SD3__c) ||
                        (opp.S4SD1__c == true && opp.S4SD1__c != oldOpportunityMap.get(opp.Id).S4SD1__c) ||
                        (opp.S4SD2__c == true && opp.S4SD2__c != oldOpportunityMap.get(opp.Id).S4SD2__c) ||
                        (opp.S4SD3__c == true && opp.S4SD3__c != oldOpportunityMap.get(opp.Id).S4SD3__c) ||
                        (opp.S4SD4__c == true && opp.S4SD4__c != oldOpportunityMap.get(opp.Id).S4SD4__c) ||
                        (opp.S5SD1__c == true && opp.S5SD1__c != oldOpportunityMap.get(opp.Id).S5SD1__c) ||
                        (opp.S5SD2__c == true && opp.S5SD2__c != oldOpportunityMap.get(opp.Id).S5SD2__c) ||
                        (opp.S5SD3__c == true && opp.S5SD3__c != oldOpportunityMap.get(opp.Id).S5SD3__c) ){
                        
                            opp.addError('You can not check other SalesDeliverables when you are on Stage 1');
                            
                        }
                }
                
                if(opp.StageName != 'Closed Lost'){
                    System.debug('---class--'+opp.StageName + ' ---'+oldOpportunityMap.get(opp.Id).StageName);
                    if(opp.StageName != oldOpportunityMap.get(opp.Id).StageName){
                    
                        String newStage = '';
                        String oldStage = '';
                        
                        if(opp.StageName.contains('Closed Won')){
                            newStage = '6';
                        }else{
                            newStage = opp.StageName.subStringAfter('Stage ');
                            newStage = newStage.subString(0,1);
                        }
                        
                        if(oldOpportunityMap.get(opp.Id).StageName.contains('Closed Won')){
                            oldStage= '6';
                        }else if(oldOpportunityMap.get(opp.Id).StageName.contains('Closed Lost')){
                            oldStage = '7';
                        }else{
                            oldStage = oldOpportunityMap.get(opp.Id).StageName.subStringAfter('Stage ');
                            oldStage = oldStage.subString(0,1);
                        }    
                        
                        //Checking condition to move stage backward
                        if(Integer.valueOf(newStage) < Integer.valueOf(oldStage)){
                            moveStageBackward(opp,oldOpportunityMap.get(opp.Id),newStage, oldStage);     
                        }
                        
                        if(Integer.valueOf(newStage) > Integer.valueOf(oldStage)){
                            moveStageForward(opp,oldOpportunityMap.get(opp.Id),newStage, oldStage);
                        }
                    }
                    if(opp.StageName == oldOpportunityMap.get(opp.Id).StageName && (opp.S1SD1__c != oldOpportunityMap.get(opp.Id).S1SD1__c ||
                        opp.S1SD2__c != oldOpportunityMap.get(opp.Id).S1SD2__c ||
                        opp.S1SD3__c != oldOpportunityMap.get(opp.Id).S1SD3__c ||
                        opp.S2SD1__c != oldOpportunityMap.get(opp.Id).S2SD1__c ||
                        opp.S2SD2__c != oldOpportunityMap.get(opp.Id).S2SD2__c ||
                        opp.S2SD3__c != oldOpportunityMap.get(opp.Id).S2SD3__c ||
                        opp.S2SD4__c != oldOpportunityMap.get(opp.Id).S2SD4__c ||
                        opp.S3SD1__c != oldOpportunityMap.get(opp.Id).S3SD1__c ||
                        opp.S3SD2__c != oldOpportunityMap.get(opp.Id).S3SD2__c ||
                        opp.S3SD3__c != oldOpportunityMap.get(opp.Id).S3SD3__c ||
                        opp.S4SD1__c != oldOpportunityMap.get(opp.Id).S4SD1__c ||
                        opp.S4SD1__c != oldOpportunityMap.get(opp.Id).S4SD2__c ||
                        opp.S4SD1__c != oldOpportunityMap.get(opp.Id).S4SD3__c ||
                        opp.S4SD1__c != oldOpportunityMap.get(opp.Id).S4SD4__c ||
                        opp.S5SD1__c != oldOpportunityMap.get(opp.Id).S5SD1__c ||
                        opp.S5SD1__c != oldOpportunityMap.get(opp.Id).S5SD2__c ||
                        opp.S5SD1__c != oldOpportunityMap.get(opp.Id).S5SD3__c)){
                        
                        for(String field : salesField()){
                            if(opp.get(field) == false){
                                 System.debug('---enter---'+ opp);  
                                string s = field.subStringAfter('S');
                                System.debug('subStringAfter(S)--'+ s);
                                s = s.subString(0,1);
                                System.debug('subString(0,1)--'+ s);
                                opp.StageName = stageMapWithIndex().get(Integer.valueOf(s));
                                System.debug('--opp.StageName-- '+opp.StageName);
                                if(opp.StageName.contains('Stage 1'))
                                    opp.ApproveStatus__c = ' ';   
                                    
                                break;
                            }
                            if(opp.StageName.contains('Stage 1') && opp.get(field) != false){
                                opp.ApproveStatus__c = 'Ready for Approval';
                                opp.StageName = 'Stage 1 - Qualified';
                                break;
                                
                            }
                        }      
                    }
                }
            }
        }            
    }*/
    
    public static void moveStageBackward(Opportunity opp, Opportunity oldOpp, String newStage, String oldStage){
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        
        for(Integer i=Integer.valueOf(newStage); i <= 5; i++ ){
            for(String obj : objectFieldMap.keyset()){
                String stageName = 's'+i;
                if(obj.contains(stageName) && objectFieldMap.get(obj).getDescribe().getType() == Schema.DisplayType.BOOLEAN){
                    opp.put(obj,false);
                }
                if(opp.StageName.contains('Stage 1'))
                    opp.ApproveStatus__c = '';
            }
        }
        
    }
    
    public static void moveStageForward(Opportunity opp, Opportunity oldOpp,String newStage, String oldStage){
        Boolean flag = false;
        List<String> fieldNames = getFieldsName().get(Integer.valueOf(oldStage));
        for(String fieldN : fieldNames){
            if(opp.get(fieldN) == false){
                opp.addError('Can not move stage forward before completing all SalesDeliverables');
            }
        }
        
    }
    
    public static Map<Integer, List<String>> getFieldsName(){
        Map<Integer, List<String>> fMap = new Map<Integer, List<String>>();
        fMap.put(1,new List<String>{'S1SD1__c','S1SD2__c','S1SD3__c'});
        
        fMap.put(2,new List<String>{'S2SD1__c','S2SD2__c','S2SD3__c','S2SD4__c'});
        
        fMap.put(3,new List<String>{'S3SD1__c','S3SD2__c','S3SD3__c'});
        
        fMap.put(4,new List<String>{'S4SD1__c','S4SD2__c','S4SD3__c','S4SD4__c'});
          
        fMap.put(5,new List<String>{'S5SD1__c','S5SD2__c','S5SD3__c'});
        
        return fMap;
    }
    
    public static List<String> salesField(){
        return new List<String>{'S1SD1__c','S1SD2__c','S1SD3__c','S2SD1__c','S2SD2__c','S2SD3__c','S2SD4__c','S3SD1__c','S3SD2__c','S3SD3__c','S4SD1__c','S4SD2__c','S4SD3__c','S4SD4__c','S5SD1__c','S5SD2__c','S5SD3__c'};
    }
    
    //Map of stages
    public static Map<Integer,String> stageMapWithIndex(){
        Map<Integer,String> stageMap = new Map<Integer,String>{
            1=>'Stage 1 - Qualified',
            2=>'Stage 2 - Needs Identified & Accepted',
            3=>'Stage 3 - Solution Presented & Accepted',
            4=>'Stage 4 - Specific Price / Budget',
            5=>'Stage 5 - Order Placement',
            6=>'Closed Won'
        };
        
        return stageMap;
    }
    
    public static void validateOpportunityRevenueForecastCreated(List<Opportunity> newOpportunities,Map<Id,Opportunity> oldOpportunityMap)
    { 
       
        Id opptyOEMRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('OEM (Industrial Solutions)').getRecordTypeId();
      //  Id opptyProjectRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project (Critical Environments)').getRecordTypeId();
		List<Opportunity_Values__c> expectedRevenueMap = getExpectedRevenue(oldOpportunityMap);
        Map<Id, Opportunity_Values__c> opptyIdWithExpRevenueMap = new Map<Id, Opportunity_Values__c>();
        for(Opportunity_Values__c expRevenue : expectedRevenueMap)
        {
			opptyIdWithExpRevenueMap.put(expRevenue.Opportunity__r.Id,expRevenue);           
        }
        for(Opportunity opp : newOpportunities){
            if(	opp.RecordTypeId!=null && opp.RecordTypeId == opptyOEMRtId
      //         	&& oldOpportunityMap.get(opp.Id).StageName.Contains('Stage 1') 
     //           && !opp.StageName.Contains('Stage 1')
                && oldOpportunityMap.get(opp.Id).StageName != opp.StageName
                && opptyIdWithExpRevenueMap.get(opp.Id) == null && !test.isRunningTest()){
                    opp.addError('Opportunity cannot be moved unless the Revenue Forecast section is populated.');
        	}
        }
    }
    public static List<Opportunity_Values__c> getExpectedRevenue(Map<Id,Opportunity> mapOldopty){

      Return new List<Opportunity_Values__c> ([SELECT Id,Opportunity__r.Id
                                                 FROM Opportunity_Values__c 
                                                 WHERE Opportunity__r.Id IN: mapOldopty.keyset()]);
  	}
    
    public static void addToFunnel(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
        Set<String> funnelStages = new Set<String>{
        'Stage 1 - Qualified',
        'Stage 2 - Needs Identified & Accepted',
        'Stage 3 - Solution Presented & Accepted',
        'Stage 4 - Specific Price / Budget',
        'Stage 5 - Order Placement'
        };
            
        for(Opportunity opp : oppList){
            if (oldMap == null && funnelStages.contains(opp.StageName)) {
              opp.Added_to_the_Funnel_Date__c = System.today();
              opp.Added_to_the_Funnel__c = true;
            }
            
            if(oldMap != null && oldMap.get(opp.Id).StageName == 'Stage 0 - Unqualified Lead / Prospect' && funnelStages.contains(opp.StageName)  && oldMap.get(opp.Id).Added_to_the_Funnel_Date__c == null){
               opp.Added_to_the_Funnel_Date__c = System.today();     
               opp.Added_to_the_Funnel__c = true;
            }
        }
    }
    
}