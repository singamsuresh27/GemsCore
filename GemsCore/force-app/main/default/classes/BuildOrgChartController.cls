public class BuildOrgChartController{
    public String orgChartDataInJson {get;set;}
    public Account acc{get;set;}
    public Contact newConObj {get;set;}    
    public LIST<ContactAndReportsToModel> lstreportToModel {get;set;}
    public LIST<SelectOption> lstReportsToContact {get;set;}
    public LIST<Contact> lstAllContacts {get;set;} 
    public LIST<ContactModel> lstConModel {get;set;}
    
    private Map<String,Precall_Contact__c> mapPreCallContact ;
    private String actId;
    Map<String,Contact> mapReportToContact = new Map<String,Contact>();
    
    public BuildOrgChartController(){
        newConObj = new Contact();
        newConObj.LastName = 'LastName';
        mapPreCallContact = new Map<String,Precall_Contact__c>();
        
        if(ApexPages.currentPage().getParameters().get('id') != null ){
            actId = ApexPages.currentPage().getParameters().get('id');
            acc = [ select id,name from Account where id =: actId limit 1];
            fillConModel();
            creatingOrgChartData();
        }
    }
    
    
    private void creatingOrgChartData(){
        orgChartDataInJson = '[';
        LIST<OrgChartDataModel> lstOrgChartDataModel = new LIST<OrgChartDataModel>();
        LIST<Contact> tempConList =  [select id,Name, Phone,email,ReportsToId,title,DMU__c from Contact where accountId =: actId];
        
        Map<String,OrgChartDataModel> mapContactForOrgChart = new Map<String,OrgChartDataModel>();
        Integer i=2;        
        for(Contact con : tempConList ){
            OrgChartDataModel md = new OrgChartDataModel();
            md.id = i++ +'';
            md.conObj = con;
            lstOrgChartDataModel.add(md); 
            mapContactForOrgChart.put(con.id, md);          
        }
        
        LIST<OrgCharDataModelWithParent> tempList = new LIST<OrgCharDataModelWithParent>();
        OrgCharDataModelWithParent rootNode = new OrgCharDataModelWithParent();
        rootNode.id = '1';
        string Conname = acc.Name;
        if( acc.Name.length() > 28 ){
            Conname = Conname.subString(0,28)+'..';
        }
        rootNode.name = '<div style="width:100%;height:100%;"><a title="'+acc.Name+'" href="/'+acc.id+'" target="_blank">'+ Conname + '</a></div>';
        rootNode.parent = '0';        
        tempList.add(rootNode);
        
        for(OrgChartDataModel conMd : lstOrgChartDataModel){
            String conColor = 'white';
            String fontColor = 'black';
            if( conMd.conObj.DMU__c == 'Gems Friend' ){
                conColor= 'green';
                fontColor = 'white';
            }else if( conMd.conObj.DMU__c == 'Gems Foe' ){
                conColor= 'red';
                fontColor = 'white';
            }else if( conMd.conObj.DMU__c == 'Mixed' ){
                conColor= 'yellow';
                fontColor = 'black';
            }
            
            OrgCharDataModelWithParent temp = new OrgCharDataModelWithParent();
            temp.id = conMd.id;
            Conname = conMd.conObj.name;
            if( conMd.conObj.name.length() > 14 ){
                Conname = Conname.subString(0,14)+'..';
            }
            
            String title = '';
            if( conMd.conObj.title != null ){
                title = conMd.conObj.title;
                if( conMd.conObj.title .length() > 14 ){
                    title = conMd.conObj.title.subString(0,14)+'..';
                }
                temp.name ='<div style="padding-top: 1px;border-radius: 3px;width:100%;height:100%;background:'+conColor+';"><a title="'+conMd.conObj.name+' ('+conMd.conObj.title+ ')" style="color:'+fontColor+'" href="/'+conMd.conObj.id+'" target="_blank">'+ Conname + '\n\r(' + title + ')</a></div>';
            }else{
                temp.name ='<div style="padding-top: 1px;border-radius: 3px;width:100%;height:100%;background:'+conColor+';"><a title="' +conMd.conObj.name+ ')" style="color:'+fontColor+'" href="/'+conMd.conObj.id+'" target="_blank">'+ Conname + '</a></div>';
            }
            
            if(conMd.conObj.reportsToId  == null){
                temp.parent = '1';    
            }else{
                temp.parent =  mapContactForOrgChart.get(conMd.conObj.reportsToId).id ;
            }
            tempList.add(temp);
        }
        orgChartDataInJson = JSON.serialize(tempList);
    }
    
    public void saveNewContact(){
        if(newConObj != null){
            newConObj.accountId = actId;
            insert newConObj;
            fillConModel();
            creatingOrgChartData();
            newConObj = new Contact();
            newConObj.LastName = 'LastName';
        }
    }
    
     //Method to ChangeReportsToSetting 
    public void saveReportsToSetting(){
        if(lstreportToModel != null && lstreportToModel.size() > 0 ){
            LIST<Contact> tempConList = new LIST<Contact>();
            for(ContactAndReportsToModel crm : lstreportToModel){
                crm.conObj.ReportsToId = crm.reportsToId;
                tempConList.add(crm.conObj);
            }
            
            if(tempConList != null && tempConList.size() > 0){
                update tempConList;
            }
            lstreportToModel.clear();
            for(Contact con : tempConList){
                ContactAndReportsToModel  crmd = new ContactAndReportsToModel ();
                crmd.conObj = con;
                crmd.reportsToId = con.reportsToId;
                lstreportToModel.add(crmd);
            }
            creatingOrgChartData();
        }
    }
    
     //Filling Contact Model List with Contacts available for AccountId
    public List<SelectOption> lstDMUSelOpt{get;set;}
    private void fillConModel(){
        lstDMUSelOpt = new List<SelectOption>();
        lstDMUSelOpt.add(new selectOption('',''));
        lstDMUSelOpt.add(new selectOption('Gems Friend','Gems Friend'));
        lstDMUSelOpt.add(new selectOption('Mixed','Mixed'));
        lstDMUSelOpt.add(new selectOption('Gems Foe','Gems Foe'));
        lstDMUSelOpt.add(new selectOption('Unknown','Unknown'));
        
        lstReportsToContact = new LIST<SelectOption>();
        lstreportToModel = new LIST<ContactAndReportsToModel>();
        lstAllContacts = [select id,Title,Name,Email,phone,ReportsTo.Name,ReportsToId,DMU__c from Contact where AccountId =: actId  order by Name];        
        
        lstConModel = new LIST<ContactModel>();
        integer i= 0; 
        lstReportsToContact.add(new SelectOption('','--None--'));
        for(Contact con : lstAllContacts){
            ContactModel model = new ContactModel();
            model.idx = i++;
            if(mapPreCallContact != null && mapPreCallContact.containskey(con.id)){
                model.flg = true;    
            }else{
                model.flg = false;
            }           
            
            model.conObj = con;
            lstConModel.add(model);
            lstReportsToContact.add(new SelectOption(con.id, con.Name));
            mapReportToContact.put(con.id,con);
            ContactAndReportsToModel tempReportsTo = new ContactAndReportsToModel();
            tempReportsTo.conObj = con;
            tempReportsTo.reportsToId = con.ReportsToId;
            lstreportToModel.add(tempReportsTo);
            
        }
        
    }
       
    public class OrgChartDataModel{
        public String id {get;set;}
        public Contact conObj {get;set;}
    }
    public class OrgCharDataModelWithParent{
        public String id {get;set;}
        public String name {get;set;}
        public String parent {get;set;}
    }
    public class ContactAndReportsToModel{
        public Contact conObj {get;set;}
        public String reportsToId {get;set;}
    }
    public class ContactModel{
        public boolean flg {get;set;}
        public integer idx {get;set;}
        public Contact conObj {get;set;}
        public String notesValues {get;set;}
        
    }
}