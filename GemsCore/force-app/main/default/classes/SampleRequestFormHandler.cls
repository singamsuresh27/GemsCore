/**------------------------------------------------------------------------------------
* @File Name        :  SampleRequestFormHandler
* @Author           :  Thirumoorthy Mani
* @Modification Log :  
* @Test class		: SampleRequestFormHelperTest
* 1.0                  2024-10-01                    
* -------------------------------------------------------------------------------------
**/
public class SampleRequestFormHandler {
    public static void beforeUpdate(List<Sample_Request_Form__c> srfList,Map<Id,Sample_Request_Form__c> mapOldSRF){
        system.debug('afterUpdate');
        Map<Sample_Request_Form__c, String> srfToProcessMap = new Map<Sample_Request_Form__c, String>();
        for(Sample_Request_Form__c srfRecord: srfList){
            if(srfRecord.Status__c != mapOldSRF.get(srfRecord.Id).Status__c)
            {
                srfToProcessMap.put(srfRecord,mapOldSRF.get(srfRecord.Id).Status__c);
            }
        }
        if (!srfToProcessMap.isEmpty()) {
        	SampleRequestFormHelper.calculateBusinessHours(srfToProcessMap);
    	}
    }
}