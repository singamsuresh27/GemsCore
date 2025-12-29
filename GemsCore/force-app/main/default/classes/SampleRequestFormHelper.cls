/**------------------------------------------------------------------------------------
* @File Name        :  SampleRequestFormHelper
* @Author           :  Thirumoorthy Mani
* @Modification Log :  
* @Test class		: SampleRequestFormHelperTest
* 1.0                  2024-10-01                    
* -------------------------------------------------------------------------------------
**/
public class SampleRequestFormHelper {
    public static void calculateBusinessHours(Map<Sample_Request_Form__c, String> sprToOldStatusMap)
        {
            BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault =true LIMIT 1];
            String oldStatus,fieldName;
            DateTime lastStatusDate,updatedDate;
          	system.debug('calculateBusinessHours');
            For(Sample_Request_Form__c srfRecord : sprToOldStatusMap.keySet())
            {
                oldStatus = sprToOldStatusMap.get(srfRecord);
                system.debug('oldStatus : '+oldStatus);
                oldStatus = oldStatus.replaceAll(' - ', ' ');
                oldStatus = oldStatus.replaceAll(' ', '_');
                
                system.debug('Transformed Status : '+oldStatus);
                fieldName = oldStatus +'__c';
                if(oldStatus == 'Purchasing_Awaiting_Part_Creation/Awaiting_Account_Set_up')
                {
                    fieldName = 'Awaiting_Creation_Setup__c';
                }
                system.debug('fieldName : '+fieldName);
                lastStatusDate = srfRecord.CreatedDate;
                updatedDate = DateTime.now();
                
                if (srfRecord.Status_Change_Timestamp__c != null) {
                    lastStatusDate = srfRecord.Status_Change_Timestamp__c;
                }
                system.debug('lastStatusDate : '+lastStatusDate);
                Decimal businessHoursMilliseconds = BusinessHours.diff(defaultBH.Id, lastStatusDate, updatedDate);
                Decimal businessHours = businessHoursMilliseconds / (1000 * 60 * 60);
                businessHours = businessHours.setScale(2);
                try
                {
                    srfRecord.put(fieldName,businessHours);                   
                    srfRecord.Status_Change_Timestamp__c = Datetime.now();
                }
                catch(Exception ex)
                {
                    system.debug(' Exception during Sample Request Form status business hour calculation : '+ ex.getMessage());
                }
           }
        }
}