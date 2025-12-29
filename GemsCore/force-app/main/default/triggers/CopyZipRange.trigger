/*
Description: When We insert record in Zip Range object it copies the 
value "From" and "To" field in Number field.
*/
trigger CopyZipRange on Zip_Range__c (before insert, before update) 
{
	for(Zip_Range__c zrc:Trigger.new){
		double ZipFrom=0,ZipTo=0;
		if(zrc.Name!=null){
			ZipFrom=double.valueof(zrc.Name);
		}
		if(zrc.Zip_To__c!=null){
			ZipTo=double.valueof(zrc.Zip_To__c);
		}
		zrc.Zip_From__c=ZipFrom;
		zrc.Zip_To_Num__c=ZipTo;
	}
}