trigger ReCalcReportedTo on Contact (Before update,before delete) {
    Map<String,String> MapOFIdAndRepId = new Map<String,String>();
    
    if( trigger.isDelete ){
        for( contact con : trigger.old){
            MapOFIdAndRepId.put(con.id,con.ReportsToid) ;   
        }
    }
    else if( trigger.isUpdate ){
        for( contact con : trigger.new){
            if( con.Contact_Status__c == 'Disable' ){
                MapOFIdAndRepId.put(con.id,con.ReportsToid) ;   
            }
        }
    }
    
    if( MapOFIdAndRepId.size() > 0 ){
        list<Contact> lstToUpdt = [ select id , ReportsToid from contact where ReportsToid in : MapOFIdAndRepId.keySet()];
        for( contact con : lstToUpdt ){
            con.ReportsToid = MapOFIdAndRepId.get(con.ReportsToid);
        }
        update lstToUpdt;
    }
}