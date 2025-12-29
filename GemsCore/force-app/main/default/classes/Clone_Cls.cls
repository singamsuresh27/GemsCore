public with sharing class Clone_Cls
{
	public string RecordId{get;set;}
	public string OppId{get;set;}
	public string CloneFieldId{get;set;}
	
	public Clone_Cls(ApexPages.StandardController stdController){
			RecordId=ApexPages.currentPage().getParameters().get('id');
			
	}
	
	
	
		//For Clone Redirect
	public Pagereference RedirectToLESClonePage()
	{
		//For Full Sandbox
			CloneFieldId='00NP0000000FrwY';
		//For Production
			//CloneFieldId='00N600000024oJB';
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&00N600000022nWI=&CF00N600000022nVy_lkid=&CF00N600000022nVy=&CF00N600000022nVy_lkold=&00N600000022nVt=&CF00N600000022nW3_lkold=&CF00N600000022nW3_lkid=&CF00N600000022nW3=&00N600000022nVG=&00N600000022nWr=&00N600000022nX1=&00N600000022nXV=&00N600000022nVH=&00N600000022iC0=&00N600000022i6k=&'+CloneFieldId+'='+RecordId+'&retURL=%2F'+RecordId);
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	public Pagereference RedirectToLECClonePage()
	{
		//For Full Sandbox
			CloneFieldId='00NP0000000FrwJ';
		//For Production
			//CloneFieldId='00N600000024oIr';
			
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&00N600000022oZZ=&CF00N600000022oTf_lkid=&CF00N600000022oTf=&CF00N600000022oTf_lkold=&00N600000022oTa=&CF00N600000022oYH_lkold=&CF00N600000022oYH_lkid=&CF00N600000022oYH=&00N600000022odW=&00N600000022odl=&00N600000022odv=&00N600000022oee=&00N600000022oef=&00N600000022oTV=&00N600000022oT6=&'+CloneFieldId+'='+RecordId+'&retURL=%2F'+RecordId);
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	
	/*Need to implement a code for TSW*/
	
	public Pagereference RedirectToTSWClonePage()
	{
		//For Full Sandbox
			CloneFieldId='00NP0000000Frwi';
		//For Production
			//CloneFieldId='00N600000024oJf';
			
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&00N600000022oKi=&CF00N600000022oJu_lkid=&CF00N600000022oJu=&CF00N600000022oJu_lkold=&00N600000022oAH=&CF00N600000022oJz_lkold=&CF00N600000022oJz_lkid=&CF00N600000022oJz=&00N600000022oKs=&00N600000022oL2=&00N600000022oLH=&00N600000022oLg=&00N600000022oLq=&00N600000022oAC=&00N600000022oA7=&'+CloneFieldId+'='+RecordId+'&retURL=%2F'+RecordId);   
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage; 
	}
	
	public Pagereference RedirectToVALClonePage()
	{
		//For Full Sandbox
			CloneFieldId='00NP0000000Frwn';
		//For Production
			//CloneFieldId='00N600000024oJz';
			
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&00N600000022pa7=&CF00N600000022pZ4_lkid=&CF00N600000022pZ4=&CF00N600000022pZ4_lkold=&00N600000022pYp=&CF00N600000022pZE_lkold=&CF00N600000022pZE_lkid=&CF00N600000022pZE=&00N600000022paR=&00N600000022pab=&00N600000022pav=&00N600000022pbe=&00N600000022pby=&00N600000022pYV=&00N600000022pYL=&'+CloneFieldId+'='+RecordId+'&retURL=%2F'+RecordId); 
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
	
		
	public Pagereference RedirectToFLOClonePage()
	{
		//For Full Sandbox
			CloneFieldId='00NP0000000Frw9';
		//For Production
			//CloneFieldId='00N600000024oI8';
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&00N600000022p1e=&CF00N600000022ozi_lkid=&CF00N600000022ozi=&CF00N600000022ozi_lkold=&00N600000022ozd=&CF00N600000022p02_lkold=&CF00N600000022p02_lkid=&CF00N600000022p02=&00N600000022pFw=&00N600000022pGG=&00N600000022pIC=&00N600000022pJ0=&00N600000022pK3=&00N600000022ozY=&00N600000022ozO=&'+CloneFieldId+'='+RecordId+'&retURL=%2F'+RecordId);
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
	
		
	public Pagereference RedirectToPREClonePage()
	{
		//For Full Sandbox
			CloneFieldId='00NP0000000Frwd';
		//For Production
			//CloneFieldId='00N600000024oJL';
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&00N600000022qqR=&CF00N600000022qpO_lkid=&CF00N600000022qpO=&CF00N600000022qpO_lkold=&00N600000022qpJ=&CF00N600000022qpT_lkold=&CF00N600000022qpT_lkid=&CF00N600000022qpT=&00N600000022qql=&00N600000022qqv=&00N600000022qr5=&00N600000022qre=&00N600000022qro=&00N600000022qpE=&00N600000022qp9=&'+CloneFieldId+'='+RecordId+'&retURL=%2F'+RecordId);
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
	
		
	public Pagereference RedirectToFTLClonePage()
	{
		//For Full Sandbox
			CloneFieldId='00NP0000000FrwD';
		//For Production
			//CloneFieldId='00N600000024oIX';
			
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId+'/e?clone=1&00N600000022rqn=&CF00N600000022rp1_lkid=&CF00N600000022rp1=&CF00N600000022rp1_lkold=&00N600000022row=&CF00N600000022rp6_lkold=&CF00N600000022rp6_lkid=&CF00N600000022rp6=&00N600000022rrR=&00N600000022rrb=&00N600000022rwh=&00N600000022rxG=&00N600000022rxV=&00N600000022ror=&00N600000022rom=&'+CloneFieldId+'='+RecordId+'&retURL=%2F'+RecordId);
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	
	//For New redirect for LES 
	public Pagereference RedirectToLESNewPage()
	{
		//Get OppId by URL
		string OppName='';
		string AutoNumber='000000';
		string OppId=ApexPages.currentPage().getParameters().get('CF00N600000022llz_lkid');
		string NewPath='/a09/e?Name=LES0&retURL=%2Fa09%2Fo';
		if(OppId!=null && OppId!='')
		{
			Opportunity opp=GetOppDetail(OppId);
			if(opp!=null)
			{
			AutoNumber=opp.Opportunity_Number__c;
			OppName=opp.Name;
			OppName=OppName.replace('&','%26');
			OppName=OppName.replace(' ','+');
			string LESNBOName='LES'+AutoNumber; 
			NewPath='/a09/e?Name='+LESNBOName+'&CF00N600000022llz='+OppName+'&CF00N600000022llz_lkid='+OppId+'&retURL=%2F'+OppId;
			}
		}		
		PageReference MainPage;
        MainPage= new PageReference(NewPath);
        MainPage.getParameters().put('nooverride', '1');
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	//For New redirect for TSW 
	public Pagereference RedirectToTSWNewPage()
	{
		//Get OppId by URL
		string OppName='';
		string AutoNumber='000000';
		string OppId=ApexPages.currentPage().getParameters().get('CF00N600000022oA2_lkid');
		string NewPath='/a0B/e?Name=LES0&retURL=/a09';
		if(OppId!=null && OppId!='')
		{
			Opportunity opp=GetOppDetail(OppId);
			if(opp!=null)
			{
			AutoNumber=opp.Opportunity_Number__c;
			OppName=opp.Name;
			OppName=OppName.replace('&','%26');
			string LESNBOName='TSW'+AutoNumber; 
			NewPath='/a0B/e?Name='+LESNBOName+'&CF00N600000022oA2='+OppName+'&CF00N600000022oA2_lkid='+OppId+'&retURL=/'+OppId;	
			}
		} 	
		 PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
		 MainPage.setRedirect(true);
		 return MainPage;
	}
	
	public Pagereference RedirectToLECNewPage()
	{
		//Get OppId by URL
		string OppName='';
		string AutoNumber='000000';
		string OppId=ApexPages.currentPage().getParameters().get('CF00N600000022oSr_lkid');
		string NewPath='/a0C/e?Name=LES0&retURL=/a09/o';
		if(OppId!=null && OppId!='')
		{
			Opportunity opp=GetOppDetail(OppId);
			if(opp!=null)
			{
			AutoNumber=opp.Opportunity_Number__c;
			OppName=opp.Name;
            OppName=OppName.replace('&','%26');
			//OppName=OppName.replace(' ','+');
			string LESNBOName='LEC'+AutoNumber; 
			NewPath='/a0C/e?Name='+LESNBOName+'&CF00N600000022oSr='+OppName+'&CF00N600000022oSr_lkid='+OppId+'&retURL=/'+OppId;	
			}
		} 	
		 PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
		 MainPage.setRedirect(true);
		 return MainPage;
	}
	
	
	public Pagereference RedirectToFLONewPage()
	{
		//Get OppId by URL
		string OppName='';
		string AutoNumber='000000';
		string OppId=ApexPages.currentPage().getParameters().get('CF00N600000022p07_lkid');
		string NewPath='/a0D/e?Name=LES0&retURL=/a09/o';
		if(OppId!=null && OppId!='')
		{
			Opportunity opp=GetOppDetail(OppId);
			if(opp!=null)
			{
			AutoNumber=opp.Opportunity_Number__c;
			OppName=opp.Name;
            OppName=OppName.replace('&','%26');
		//	OppName=OppName.replace(' ','+');
			string LESNBOName='FLO'+AutoNumber; 
			NewPath='/a0D/e?Name='+LESNBOName+'&CF00N600000022p07='+OppName+'&CF00N600000022p07_lkid='+OppId+'&retURL=/'+OppId;	
			}
		} 	
		 PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
		 MainPage.setRedirect(true);
		 return MainPage;
	}

	
	public Pagereference RedirectToVALNewPage()
	{
		//Get OppId by URL
		string OppName='';
		string AutoNumber='000000';
		string OppId=ApexPages.currentPage().getParameters().get('CF00N600000022pZO_lkid');
		string NewPath='/a0E/e?Name=LES0&retURL=/a09/o';
		if(OppId!=null && OppId!='')
		{
			Opportunity opp=GetOppDetail(OppId);
			if(opp!=null)
			{
			AutoNumber=opp.Opportunity_Number__c;
			OppName=opp.Name;
            OppName=OppName.replace('&','%26');
		//	OppName=OppName.replace(' ','+');
			string LESNBOName='VAL'+AutoNumber; 
			NewPath='/a0E/e?Name='+LESNBOName+'&CF00N600000022pZO='+OppName+'&CF00N600000022pZO_lkid='+OppId+'&retURL=/'+OppId;	
			}
		} 	
		 PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
		 MainPage.setRedirect(true);
		 return MainPage;
	}
	
	
	
	
	public Pagereference RedirectToPRENewPage()
	{
		//Get OppId by URL
		string OppName='';
		string AutoNumber='000000';
		string OppId=ApexPages.currentPage().getParameters().get('CF00N600000022qpY_lkid');
		string NewPath='/a0F/e?Name=LES0&retURL=/a09/o';
		if(OppId!=null && OppId!='')
		{
			Opportunity opp=GetOppDetail(OppId);
			if(opp!=null)
			{
			AutoNumber=opp.Opportunity_Number__c;
			OppName=opp.Name;
            OppName=OppName.replace('&','%26');
			//OppName=OppName.replace(' ','+');
			string LESNBOName='PRE'+AutoNumber; 
			NewPath='/a0F/e?Name='+LESNBOName+'&CF00N600000022qpY='+OppName+'&CF00N600000022qpY_lkid='+OppId+'&retURL=/'+OppId;	
			}
		} 	
		 PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
		 MainPage.setRedirect(true);
		 return MainPage;
	}

	
	public Pagereference RedirectToFTLNewPage()
	{
		//Get OppId by URL
		string OppName='';
		string AutoNumber='000000';
		string OppId=ApexPages.currentPage().getParameters().get('CF00N600000022rpB_lkid');
		string NewPath='/a0G/e?Name=LES0&retURL=/a09/o';
		if(OppId!=null && OppId!='')
		{
			Opportunity opp=GetOppDetail(OppId);
			if(opp!=null)
			{
			AutoNumber=opp.Opportunity_Number__c;
			OppName=opp.Name;
            OppName=OppName.replace('&','%26');
			//OppName=OppName.replace(' ','+');
			string LESNBOName='FTL'+AutoNumber; 
			NewPath='/a0G/e?Name='+LESNBOName+'&CF00N600000022rpB='+OppName+'&CF00N600000022rpB_lkid='+OppId+'&retURL=/'+OppId;	
			}
		} 	
		 PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
		 MainPage.setRedirect(true);
		 return MainPage;
	}

	public Opportunity GetOppDetail(string OppId)
	{
		Opportunity opp=[select Name,Opportunity_Number__c from Opportunity where id=:OppId limit 1];
		return opp;
	}
}