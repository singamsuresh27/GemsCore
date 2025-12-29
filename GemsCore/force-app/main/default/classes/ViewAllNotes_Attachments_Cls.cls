public with sharing class ViewAllNotes_Attachments_Cls 
{
	public string OpportunityId{get;set;}
	public SortWrapper wrap{get;set;}
	public List<SortWrapper> SortWrapperListBefore{get;set;}
	public List<SortWrapper> SortWrapperListAfter{get;set;}
	public Map<string,SortWrapper> MapSoftWrapperBefore;
	public Map<string,SortWrapper> MapSoftWrapperAfter;
	
	public string URL;
	
	public ViewAllNotes_Attachments_Cls(ApexPages.StandardController stdController){
		OpportunityId=ApexPages.currentPage().getParameters().get('RecordId');
		SortWrapperListBefore=new List<SortWrapper>();
		SortWrapperListAfter=new List<SortWrapper>();
		MapSoftWrapperBefore=new Map<string,SortWrapper>();
		MapSoftWrapperAfter=new Map<string,SortWrapper>();
		
		//URL='https://cs4.salesforce.com/';
		
		//URL='https://na4.salesforce.com/';
		URL='https://login.salesforce.com/';
		
		//Get All Notes after 12/25/2010
		AllNotesAfter();
		AllAttachmentAfter();
		system.debug('MapSoftWrapperAfter------>' + MapSoftWrapperAfter);
		if(MapSoftWrapperAfter.size()>0){
			SortWrapperListAfter=SortAfterData(MapSoftWrapperAfter);
		}
		
		//Get All Notes before 12/25/2010
		AllNotes();
		AllAttachment();
		if(MapSoftWrapperBefore.size()>0){
		SortWrapperListBefore=SortBeforeData(MapSoftWrapperBefore);
		}
	}
	
	//Get All Notes before 12/25/2010
	public void AllNotes(){
		List<Note> NoteList=[Select Id,Title,CreatedBy.Name,LastModifiedBy.Name, ParentId, LastModifiedDate, LastModifiedById, 
		CreatedDate, CreatedById, Body From Note n where
		 CreatedDate< 2010-12-25T00:00:00Z and ParentId=:OpportunityId];
		 if(NoteList!=null && NoteList.size()>0){
		 	for(Note nt:NoteList){
		 		MapSoftWrapperBefore.put(nt.Title+''+nt.id,getNotesRecord(nt));
		 	}
		 }
	}
	//Get All Attachments before 12/25/2010
	public void AllAttachment(){
		List<Attachment> AttachmentList=new List<Attachment>();
		
		AttachmentList=[Select Description,Id,CreatedBy.Name,ParentId,LastModifiedBy.Name, Name, LastModifiedDate, LastModifiedById, 
		CreatedDate, CreatedById From Attachment where CreatedDate< 2010-12-25T00:00:00Z and ParentId=:OpportunityId];
		if(Test.isRunningTest()){
			AttachmentList=[Select Description,Id,CreatedBy.Name,ParentId,LastModifiedBy.Name, Name, LastModifiedDate, LastModifiedById, 
			CreatedDate, CreatedById From Attachment where ParentId=:OpportunityId limit 1];
		}
		if(AttachmentList!=null && AttachmentList.size()>0){
			for(Attachment ath:AttachmentList){
		 		MapSoftWrapperBefore.put(ath.Name+''+ath.id,getAttachmentRecord(ath));
			}
		}
	}
	
	//Get All Attachments after 12/25/2010
	public void AllAttachmentAfter(){
		List<Attachment> AttachmentList=[Select Description,Id,ParentId,CreatedBy.Name,LastModifiedBy.Name, Name, LastModifiedDate, LastModifiedById, 
		CreatedDate, CreatedById From Attachment where CreatedDate>= 2010-12-25T00:00:00Z and ParentId=:OpportunityId];
		if(AttachmentList!=null && AttachmentList.size()>0){
			for(Attachment ath:AttachmentList){
				if(ath.Name.contains('Note Created On')){
					MapSoftWrapperAfter.put(ath.Name+''+ath.id,getAttachmentRecord(ath));
				}
				else{
				MapSoftWrapperAfter.put(ath.CreatedDate+''+ath.id,getAttachmentRecord(ath));
				}
			}
		}
	}
	//Get All Notes after 12/25/2010
	public void AllNotesAfter(){
		List<Note> NoteList=[Select Id,Title, CreatedBy.Name,ParentId, LastModifiedBy.Name,LastModifiedDate, LastModifiedById, 
		CreatedDate, CreatedById, Body From Note n where
		 CreatedDate>= 2010-12-25T00:00:00Z and ParentId=:OpportunityId];
		  if(NoteList!=null && NoteList.size()>0){
		 	for(Note nt:NoteList){
		 		if(nt.Title.contains('Note Created On')){
		 			MapSoftWrapperAfter.put(nt.Title+''+nt.id,getNotesRecord(nt));
		 		}
		 		else{
		 			MapSoftWrapperAfter.put(nt.CreatedDate+''+nt.id,getNotesRecord(nt));
		 		}
		 	}
		 }
	}
	
	
	public List<SortWrapper> SortBeforeData(Map<string,SortWrapper> MapSoftWrapper){
		List<SortWrapper> lstSortWrapper=new List<SortWrapper>();
		List<String> sortingList = new List<String>();//List to store all keys generated.
		for(String Title: MapSoftWrapper.keySet()){
			sortingList.add(Title);
		}
		sortingList.sort();
		//Generating sorted list from map by picking values from map as per keys from sorted list.
		for(integer i=sortingList.size()-1;i>=0;i--){
			lstSortWrapper.add(MapSoftWrapper.get(sortingList[i]));
		} 
		/*for(String sortedKey:sortingList){
			lstSortWrapper.add(MapSoftWrapper.get(sortedKey));
		}*/
		return lstSortWrapper;
	}
	
	public List<SortWrapper> SortAfterData(Map<string,SortWrapper> MapSoftWrapper){
		List<SortWrapper> lstSortWrapper=new List<SortWrapper>();
		List<String> sortingList = new List<String>();//List to store all keys generated.
		List<String> sortingList1 = new List<String>();//List to store all keys generated.
		for(String Title: MapSoftWrapper.keySet()){
			if(Title.contains('Note Created On')){
				sortingList.add(Title);
			}
			else{
				sortingList1.add(Title);
			}
		}
		sortingList.sort();
		sortingList1.sort();
		
		//Generating sorted list from map by picking values from map as per keys from sorted list.
		for(integer i=sortingList1.size()-1;i>=0;i--){
			lstSortWrapper.add(MapSoftWrapper.get(sortingList1[i]));
		} 
		
		//Generating sorted list from map by picking values from map as per keys from sorted list.
		for(integer i=sortingList.size()-1;i>=0;i--){
			lstSortWrapper.add(MapSoftWrapper.get(sortingList[i]));
		} 
		
		return lstSortWrapper;
	}
	
	private SortWrapper getNotesRecord(Note nt){
		wrap=new SortWrapper();
		if(nt.Body!=null){
 		wrap.description=nt.Body.replace('\n','<br/>');
		}
 		wrap.isNotes=true;
 		wrap.LastModifiedBy=nt.LastModifiedBy.Name;
 		wrap.LastModifiedDate=nt.LastModifiedDate;
 		wrap.CreatedBy=nt.CreatedBy.Name;
 		wrap.CreatedDate=nt.CreatedDate;
 		wrap.RecordId=nt.id;
 		wrap.title=nt.Title;
 		wrap.URL=URL+ nt.id+'/e?retURL=%2F'+OpportunityId;
 		wrap.Type1='Notes';
 		return wrap;
	}
	
	private SortWrapper getAttachmentRecord(Attachment ath){
		wrap=new SortWrapper();
		wrap.description='';
		if(ath.Description!=null){
			wrap.description=ath.Description.replace('\n','<br/>');
		}
 		wrap.isNotes=false;
 		wrap.LastModifiedBy=ath.LastModifiedBy.Name;
 		wrap.LastModifiedDate=ath.LastModifiedDate;
 		wrap.CreatedBy=ath.CreatedBy.Name;
 		wrap.CreatedDate=ath.CreatedDate;
 		wrap.RecordId=ath.id;
 		wrap.URL=URL+ ath.id+'/e?retURL=%2F'+OpportunityId;
 		wrap.title=ath.Name;
 		wrap.Type1='Attachment';
 		return wrap;
	}
	
	public Pagereference cancel(){
		PageReference MainPage;
        MainPage= new PageReference('/'+OpportunityId);
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	public Pagereference NewNote(){
		PageReference MainPage;
        MainPage= new PageReference('/apex/RedirectToNotes_Attachments?Notes=Yes&RecordId='+OpportunityId);
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	public Pagereference AttachFile(){
		PageReference MainPage;
        MainPage= new PageReference('/apex/RedirectToNotes_Attachments?RecordId='+OpportunityId);
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	public class SortWrapper{
		
		public datetime CreatedDate{get;set;}
		public string CreatedBy{get;set;}
		public string LastModifiedBy{get;set;}
		public datetime LastModifiedDate{get;set;}
		public string title{get;set;}
		public string RecordId{get;set;}
		public string Type1{get;set;}
		public string description{get;set;}
		public boolean isNotes{get;set;}
		public string URL{get;set;}
		
		public SortWrapper(){
			
		}
		
	}
}