trigger CaseSubStatusBusinessHours on CaseSubStatusHistory__c (before update) {

    //Selecting default business hours (BH) record
    BusinessHours defaultBH = [SELECT Id,Name FROM BusinessHours WHERE Name ='GEMS_NA' Limit 1];
	//Making sure BH record exists
    if(defaultBH != NULL){
        for(CaseSubStatusHistory__c caseStatusObj : trigger.new ){
            if(caseStatusObj.Exit_Time__c != NULL){
				//For BH method we assign (BH record id, start time field, end time field)
				decimal result = BusinessHours.diff(defaultBH.Id, caseStatusObj.Entry_Time__c, caseStatusObj.Exit_Time__c );
				//Result from the method is divided by 60*60*100 (milliseconds to be then converted into hours)
				Decimal resultingHours = result/(60*60*1000);
                Decimal resultingMinutes = result/(60*1000);
				//Populating result into our custom field & setting number of decimals
				caseStatusObj.Elapsed_Hours__c = resultingHours.setScale(2);
                caseStatusObj.Elapsed_Time__c = resultingMinutes.setScale(2);
            }  
        }    
    } 
}