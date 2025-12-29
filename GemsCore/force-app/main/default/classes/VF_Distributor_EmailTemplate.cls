public class VF_Distributor_EmailTemplate   
{
	public String leadId;
	public String Account{get;set;}
	public String Company{get;set;}
	public String Name{get;set;}
	public String Title{get;set;}
	public String Email{get;set;}
	public String Website{get;set;}
	public String Address{get;set;}
	public String Phone{get;set;}
	public String Fax{get;set;}
	public String MobilePhone{get;set;}
	public String Lead_Topic {get;set;}
	public String Application_Detail {get;set;}
	public String LeadSource{get;set;}
	public String Category_Sources {get;set;}
	public String Product_Of_Interest {get;set;}
	public String Market {get;set;}
	public String Customer_Type {get;set;}
	public list<Note> NotesAttachmnt{get;set;}
	
	public VF_Distributor_EmailTemplate()
	{
		//leadId=ApexPages.currentPage().getParameters().get('id');
		//leadDetails();
		//relatedNotes();
	}
	
	public string getleadId()
	{
		return leadId;
	}
	public void setleadId(String s) {
		leadId = s;
		leadDetails();
		relatedNotes();
	}
	
	public void leadDetails()
	{
	   if(leadId!=null && leadId!='')
	   {
	   	 	List<Lead> ledlist=[Select State,Street,City,PostalCode,Country,Account__c,Account__r.Name,Website,Title,Product_Of_Interest__c,Phone,Name,MobilePhone,Market__c,Lead_Topic__c,LeadSource,Fax, Email,Customer_Type__c,Company,Category_Sources__c,Application_Detail__c From Lead where id=:leadId limit 1];
	   	 	
	   		if(ledlist!=null && ledlist.size()>0)
	   		{	
	   			 Lead led=ledlist[0];
		   		 Account =led.Account__r.Name;
		   		 Company =led.Company;
				 Name =led.Name;
				 Title =led.Title;
				 Email =led.Email;
				 Website =led.Website;
				 Address =led.Street+'\n'+led.City+'\n'+led.State+'\n'+led.PostalCode+'\n'+led.Country;
				 system.debug('Address==================>>'+Address);
				 Phone =led.Phone;
				 Fax =led.Fax;
				 MobilePhone =led.MobilePhone;
				 Lead_Topic  =led.Lead_Topic__c;
				 Application_Detail  =led.Application_Detail__c;
				 LeadSource =led.LeadSource;
				 Category_Sources  =led.Category_Sources__c;
				 Product_Of_Interest  =led.Product_Of_Interest__c;
				 Market  =led.Market__c;
				 Customer_Type  =led.Customer_Type__c;
		   	}
	   }
	}
	
	public list<Note> relatedNotes()
	{
			/*
			if(NotesAttachmnt!=null && NotesAttachmnt.size()>0)
			{
				String ConcatTilteBody='';  
				for(NoteAndAttachment Notes:NotesAttachmnt)
				{
					if(Notes.Title!=null)
					ConcatTilteBody=ConcatTilteBody + '\n' + Notes.Title;
					if(Notes.Body!=null)
					ConcatTilteBody=ConcatTilteBody + '\n' + Notes.Body;
				}
			}
			*/
		if(leadId!=null && leadId!='')
		{
			NotesAttachmnt=[Select Title,Body,Parent.Id,ParentId,Id From Note 
			                where Parent.Id =:leadId];			                		
		}
		return NotesAttachmnt; 
	} 
}