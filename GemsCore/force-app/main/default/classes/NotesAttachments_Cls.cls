public with sharing class NotesAttachments_Cls {
		
	public string RecordId{get;set;}
	public string ForNotes{get;set;}	
	public list<AttachmentWrapper> AttachmentWrapperList{get;set;}
	public AttachmentWrapper AttachmentWrapperObj;
	
	
	public NotesAttachments_Cls(ApexPages.StandardController stdController){
		ForNotes=ApexPages.currentPage().getParameters().get('Notes');
		RecordId=ApexPages.currentPage().getParameters().get('RecordId');
		
		AttachmentWrapperList=new List<AttachmentWrapper>();
		AttachmentWrapperObj=new AttachmentWrapper();
		AttachmentWrapperObj.Count=1;
		AttachmentWrapperList.add(AttachmentWrapperObj);
		
	}
    
	public Pagereference RedirectToNotes(){
		
		if(ForNotes!=null){
			PageReference MainPage;
	        MainPage= new PageReference('/002/e?parent_id='+RecordId+'&retURL=/'+RecordId);
	        MainPage.getParameters().put('nooverride', '1');
			MainPage.setRedirect(true);
			return MainPage;
		}
		return null;
	}
	
	public Pagereference AttachFile(){
		
		for(AttachmentWrapper ath:AttachmentWrapperList){
				system.debug('ath------>' + ath);
				
			if((ath.fileName!=null && ath.fileBody!=null && RecordId!=null)){
				//Insert Attachment
		          Attachment myAttachment  = new Attachment();  
		          myAttachment.Body = ath.fileBody;  
		          myAttachment.Name = ath.fileName;
		          string Description=ath.Description;
		          if(Description.length()>500){
		          	Description=Description.substring(0,499);
		          }
		          myAttachment.Description=Description;
		          myAttachment.ParentId = RecordId;  
		          insert myAttachment;  
			}
		}
		return cancel();
	}
	
	public Pagereference AddOneMoreRow(){
		AttachmentWrapperObj=new AttachmentWrapper();
		AttachmentWrapperObj.Count=AttachmentWrapperList.size()+1;
		AttachmentWrapperList.add(AttachmentWrapperObj);
		return null;	
	}
	
	public Pagereference cancel(){
		PageReference MainPage;
        MainPage= new PageReference('/'+RecordId);
		MainPage.setRedirect(true);
		return MainPage;
	}
	
	public class AttachmentWrapper{
		
		public string fileName  {    get;set;    }  
    	public Blob fileBody{    get;set;    }  
    	public string Description{get;set;}
    	public integer Count{get;set;}
		public 	AttachmentWrapper(){
		}
	}
	
}