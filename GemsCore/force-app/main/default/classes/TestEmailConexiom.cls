@isTest
public class TestEmailConexiom{
	static testMethod void emailTextConexiom() {
        List<string> fileIds = new list<string>();
        List < Id > selectedAttId = new List < Id >(); 
        List < Id > selectedFileId = new List < Id >();
        List<AttachmentWrapper> attWrapList = new List<AttachmentWrapper>();
        EmailMessage email = new EmailMessage();
        Attachment attachment = new Attachment();
        List<string> AttIds = new list<string>();
        ContentVersion cv=new Contentversion();
    
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account acc = new Account(Name = 'Acc',Conexiom_User__c=true,Type='Global Account');
        test.startTest();
        insert acc;
        
        Account accChild = new Account(Name = 'AccChild',Conexiom_User__c=true,parentId=acc.Id);
        insert accChild;
        
        ID acctID = accChild.ID;
        Contact con = new Contact(LastName = 'test', Email = 'test@gmail.com',AccountId=acctID);
        insert con;
        Case c = new Case(ContactId = con.id, AccountId = accChild.id, Type = 'RA',status='New');
        insert c;
        
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.FromAddress = 'test@abc.org';
        email.Incoming = true;
        email.ToAddress= 'conexiom.net@xyz.org';
        email.Subject = 'Test email';
        email.TextBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
          
        Blob bodyBlob  = Blob.valueOf('Unit Test Attachment Body');
        attachment.body       = bodyBlob;
        attachment.Name       = 'attach';
        attachment.ParentId = email.Id;
        Insert attachment;
                  
        AttIds.add(attachment.Id);
            
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.PathOnClient = 'ABC.PDF';
        insert cv;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=c.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;      
        
       	fileIds.add(cv.Id);    
        for (Attachment a : [SELECT Id, Name,createddate, ParentId FROM Attachment WHERE ParentId IN :AttIds]) {            	
                   attWrapList.add(new AttachmentWrapper(a));
        	}
        // Add files to the attachment wrapper list
        for (ContentVersion version : [SELECT Id, Title, VersionData, FileType,ContentSize,CreatedDate FROM ContentVersion WHERE ContentDocumentId = :fileIds]) {
                attWrapList.add(new AttachmentWrapper(version));
            }
        PageReference pageRef = Page.EmailConexiom;
        // Create the controller
        EmailConexiomController controller = new EmailConexiomController(new ApexPages.StandardController(c));
        controller.btnMode='Prod';
        pageRef = controller.sendAttachment();
        controller.sendEmail(AttIds,fileIds,'Prod');
          
        Test.stopTest();
   }
    public class AttachmentWrapper {
        public Attachment att {get; set;}
        public id Id {get;set;}
        public String Name { get; set; }
    	public String ContentType { get; set; }
        public Integer ContentSize { get; set; }
        public Boolean isSelected {get; set;}
        public string createdDate{get;set;}  
        public string type {get; set;}
        public ContentVersion cv { get; set; }
       
        public AttachmentWrapper(Attachment at)
         {                
           att = new Attachment();
           att= at;
           Id = at.Id;
           createdDate= string.valueOf(at.CreatedDate.date());
           isSelected = true;  
           type = 'att';
         } 
        public AttachmentWrapper(ContentVersion cv) {
            cv = new ContentVersion();
            cv = cv;
        	Id = cv.Id;
            Name = cv.Title;
            ContentType = cv.FileType;
            ContentSize = cv.ContentSize;
            isSelected = true;
            type = 'file';
    	}
    }
}