/**------------------------------------------------------------------------------------
* @File Name        :  SampleRequestFormTrigger
* @Author           :  Thirumoorthy Mani
* @Modification Log :  
* @Test class		: 
* 1.0                  2024-10-01                    
* -------------------------------------------------------------------------------------
**/
trigger SampleRequestFormTrigger on Sample_Request_Form__c (before insert,before update,after insert) {
  
    if (Trigger.isBefore && Trigger.isUpdate)
    {        
        SampleRequestFormHandler.beforeUpdate(trigger.new,Trigger.oldMap);
    }

}