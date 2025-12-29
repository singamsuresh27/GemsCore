public  class opporutnityaccountchangeteiggerhandler {
    public static boolean Checktest;
    public static boolean runTrigger;    
    
    public static void handle(List<opportunity> opplist,Map<id,opportunity> newmap,Map<id,opportunity> oldmap){
        Map<id,opportunity> updatedopp=new      Map<id,opportunity>();
        set<id> acclist=new set<id>();
         List<lineitem__c> lineitemlist= new  List<lineitem__c>();
        for(opportunity obj:opplist){
            if(newmap.get(obj.id).accountid != oldmap.get(obj.id).accountid){
                updatedopp.put(obj.id, null);
                acclist.add(oldmap.get(obj.id).accountid);
                
            }
        }
          
                //Getting invoices in lineitemlist
                lineitemlist=[select id,Is_Additional_Ship_To_Deleted__c,Is_Account_Deleted__c from lineitem__c where Opportunityid__c in:updatedopp.keySet() and Accountid__c in : acclist];
            if( lineitemlist.size()>0){
                for(lineitem__c lineobj : lineitemlist){
                    lineobj.Is_Account_Deleted__c=true;
                }
            }
            update lineitemlist;
        
    }
}