public with sharing class Cont_NBO {
	
	public string NBOId{get;set;}
	public string OppId{get;set;}
	public string OppName{get;set;}
	public string RecordTypeDevName{get;set;}
	public string RecordTypeId{get;set;}
	public string ProjectNumber{get;set;}
	public string NBOType{get;set;}
	public List<RecordType> RecordTypeList;
	public string OtherForm{get;set;}
	public Map<string,string> NBORecordTypeMap;
	public boolean isDisable{get;set;}
	public boolean isRedirect{get;set;}
	public string NBOStatus{get;set;}
	public Map<String,NBO_Form_Record_Type_Name__c> mapRecordType;	
	
	public Cont_NBO(ApexPages.StandardController stdController){
	
		//get All Record Type developer Name from Custom Settings
		 mapRecordType = NBO_Form_Record_Type_Name__c.getAll();
		 
		Map<String,CloneVariable__c> mapClonevariable=CloneVariable__c.getAll();
		
		NBOStatus=mapClonevariable.get('NBOStatus').ContId__c;
		 
		OtherForm=ApexPages.currentPage().getParameters().get('Other');
		//For Sandbox
		//OppId=ApexPages.currentPage().getParameters().get('CF00NP0000000GMC3_lkid');
		//For Production
		OppId=ApexPages.currentPage().getParameters().get('CF00N60000002MZXC_lkid');
		if(OtherForm!=null){
			OppId=ApexPages.currentPage().getParameters().get('OppId');
		}
		isRedirect=true;
		
		if(OppId!=null){
			Opportunity Opp=GetOppDetail(OppId);
			OppName=Opp.Name;
			ProjectNumber=Opp.Opportunity_Number__c;
			if(Opp.Product_Model__c!=null){
				//get NBO Type
				isDisable=Opp.Product_Model__r.Product_Type__r.Is_Disable__c;
				if(isDisable==true){
					isRedirect=false;
				}
				else{
					string NBType=Opp.Product_Model__r.Product_Type__r.NBO_Type__c;
					if(NBType==null || NBType=='' || NBType=='All'){
						isRedirect=false;
					}
					else{
						isRedirect=true;
						NBOType=getNBOTypeFromOpp(NBType);
					}
				}
			}
		}
		//get All record Type
		NBORecordTypeMap=NBORecordTypeMapping();
		if(NBORecordTypeMap!=null && NBORecordTypeMap.size()>0 && NBOType!=null && NBOType!=''){
			RecordTypeId=getRecordTypeId(NBOType);
		}
	}	
	
	public string getRecordTypeId(string NBOType){
		string RecordTypeId;
	//	if(NBOType=='FLT'){
	//		RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('Level_Float').Record_Type_Dev_Name__c);
	//	}
		if(NBOType=='FLO'){
			RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('NBO_Flow').Record_Type_Dev_Name__c);
		}
		if(NBOType=='PRE'){
			RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('Pressure').Record_Type_Dev_Name__c);
		}
		if(NBOType=='TSW'){
			RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('Temp_Cont_Switch').Record_Type_Dev_Name__c);
		}
		if(NBOType=='VAL'){
			RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('Valve').Record_Type_Dev_Name__c);
		}
		if(NBOType=='LEC'){
			RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('Level_Continuous').Record_Type_Dev_Name__c);
		}
		//Changes as on 25th May 2012 as per Gazi by Anand
		if(NBOType=='LES' || NBOType=='FLT' || NBOType=='PTL'){
			RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('Level_Elect_Switch').Record_Type_Dev_Name__c);
		}
		if(NBOType=='FCM'){
			RecordTypeId=NBORecordTypeMap.get(mapRecordType.get('Fluid_Quality').Record_Type_Dev_Name__c);
		}
        
		return RecordTypeId;
	}
	
	
	
	public Opportunity GetOppDetail(string OppId)
	{
		Opportunity opp=[select Name,Opportunity_Number__c,Product_Model__r.Product_Type__r.NBO_Type__c, Product_Model__r.Product_Type__r.Is_Disable__c, Product_Model__c from Opportunity where id=:OppId limit 1];
		return opp;
		
	}

	public List<SelectOption> getRecordTypeSelectList()
	{
		List<SelectOption> volOptions = new List<SelectOption>();
		for(RecordType retc:RecordTypeList){
			if(retc.DeveloperName!='Level_Float'){
				volOptions.add(new SelectOption(retc.DeveloperName,retc.Name));
			}
		}
		return volOptions;
	}
	
	public string getNBOTypeFromOpp(string ProductType)
	{
		string NBOType='';
		if(ProductType=='Flow'){
			NBOType='FLO';
		}
		if(ProductType=='Level Continuous'){
			NBOType='LEC';
		}
		//Changes as on 25th May 2012 as per Gazi by Anand
		if(ProductType=='Level Electronic Switch' || ProductType=='Point Level' ||  ProductType=='Level Float'){
			NBOType='PTL';
		}
		/*if(ProductType=='Level Float'){
			NBOType='FLT';
		}*/
		if(ProductType=='Pressure'){
			NBOType='PRE';
		}
		if(ProductType=='Temp Switch & Continuous Temp'){
			NBOType='TSW';
		}
		if(ProductType=='Valve'){
			NBOType='VAL';
		}
		if(ProductType=='Fluidic Systems'){
			NBOType='FLD';
		}
        if(ProductType=='Fluid Quality'){
			NBOType='FCM';
		}
		return NBOType;
	}
	public Pagereference RedirectToNewNBO(){
		
		if(OtherForm==null && RecordTypeId!=null){
			return NBOURL();
		}
		return null;
	}
	
	public Pagereference NBOURL(){
		 string NewPath='';
		 string NBOName=NBOType+'0000';
		 if(OppId!=null && OppId!=''){
             OppName=OppName.replace('&','%26');
             NBOName=NBOType+ProjectNumber;
             //For Sandbox
			 //NewPath='/a0N/e?'+NBOStatus+'=Not Started&Name='+NBOName+'&CF00NP0000000GMC3='+OppName+'&CF00NP0000000GMC3_lkid='+OppId+'&retURL=/'+OppId+'&RecordType='+RecordTypeId;
			 //For Production
			 NewPath='/a0L/e?'+NBOStatus+'=Not Started&Name='+NBOName+'&CF00N60000002MZXC='+OppName+'&CF00N60000002MZXC_lkid='+OppId+'&retURL=/'+OppId+'&RecordType='+RecordTypeId;
			
		 }else{
		 	//for Sandbox
		 	 //NewPath='/a0N/e?'+NBOStatus+'=Not Started&Name='+NBOName+'&retURL=/a0N/o&RecordType='+RecordTypeId;
		 	 //for Production
		 	 NewPath='/a0L/e?'+NBOStatus+'=Not Started&Name='+NBOName+'&retURL=/a0L/o&RecordType='+RecordTypeId;
		 }
	   	 PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
		 MainPage.setRedirect(true);
		 return MainPage;	
	}
	
	
	public Pagereference cancel(){
		PageReference MainPage;
		//Sandbox
		//MainPage= new PageReference('/a0N/o');
		//Production
		MainPage= new PageReference('/a0L/o');
		if(OppId!=null && OppId!=''){
        	MainPage= new PageReference('/'+OppId);
		}
		MainPage.setRedirect(true);
		return MainPage;
	}
	public Pagereference GoToNBOForm(){
		if(RecordTypeDevName!=null){
			//Get Record Type id
			RecordTypeId=NBORecordTypeMap.get(RecordTypeDevName);
			//Get NBO Type
			NBOType=Utility.getNBOType(RecordTypeDevName,mapRecordType);
			return NBOURL();
		}
		return null;
	}	
	
	public Map<string,string> NBORecordTypeMapping(){
		Map<string,string> NBORecordTypeMap=new Map<string,string>();	
		RecordTypeList=Utility.NBORecordTypeList();
		if(RecordTypeList.size()>0){
			for(RecordType retc:RecordTypeList){
				NBORecordTypeMap.put(retc.DeveloperName, retc.id);
			}
		}
		return NBORecordTypeMap;
	}

}