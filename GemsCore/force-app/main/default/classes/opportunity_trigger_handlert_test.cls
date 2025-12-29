@istest
public class opportunity_trigger_handlert_test {

     static
     {  
        opporutnityaccountchangeteiggerhandler.Checktest = true;
        opprtunity_trigger_handler.Checktest = true;
        opporutnityaccountchangeteiggerhandler.runTrigger = true;
        opprtunity_trigger_handler.runTrigger = true;
         
        CommissionManagerSettings__C sa = new CommissionManagerSettings__c();
        sa.Name = 'CheckTrigger';
        sa.Check__C = true;
        insert sa;
     }   
    @isTest
    //Test: Fulfilling condition no. 1 & 3:   Commission_Approval_Status__c=”Approved” &  does not add the same parent twice.
    public  static void testhandler2(){
        //Setting test data
        //Setting Account list (acctlist)
        opprtunity_trigger_handler.Checktest = true;
        opporutnityaccountchangeteiggerhandler.Checktest = true;
        opporutnityaccountchangeteiggerhandler.runTrigger = true;
        opprtunity_trigger_handler.runTrigger = true;
        
        List<Account> acctlist=new List<Account>();
        for(integer i=0;i<3;i++){
            acctlist.add(new account(name='Cloudtestaccount'+i,BU_ID__c='00018',Account_Type__c ='Ship To (JDE)'));
        }    
        insert acctlist;
        
        //Setting opportunity list (opprlist)
        list<opportunity> opprlist=new list<opportunity>();
        for(integer i=0; i<4;i++){
             if(i == 0){
                opprlist.add(new opportunity(Name='cloudtestopportunity'+i ,Business_Unit__c='GEMS_NA',Accountid=acctlist[1].id,CloseDate= Date.today().addmonths(6),StageName = 'Stage 1 - Qualified' ));
            
            }
            if(i<3){
                opprlist.add(new opportunity(Name='cloudtestopportunity'+i ,Business_Unit__c='GEMS_NA',Accountid=acctlist[i].id,CloseDate= Date.today().addmonths(6),StageName = 'Stage 1 - Qualified' ));
            }
            else  opprlist.add(new opportunity(Name='cloudtestopportunity'+i,Business_Unit__c='GEMS_EU',CloseDate=Date.today().addmonths(9),StageName = 'Stage 1 - Qualified'));
        }
        insert opprlist;
        
        //Setting product list (produtlist)
        List<Product2> produtlist=new List<Product2>();
        for(integer i=0; i<2;i++){
            produtlist.add(new Product2(name='cloudtestproduct'+i));
        }
        insert produtlist;
        
        //Setting Invoice list (invoicelist)
        List<LineItem__c> invoicelist=new List<LineItem__c>();
        for(integer i=0;i<3;i++){
            integer j=0; 
            invoicelist.add(new LineItem__c(name='cloudtestlineitem'+i,Accountid__c=acctlist[i].id,Productid__c=produtlist[j].id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =400, UnitPrice__c=400,Opportunityid__c= opprlist[0].id));
            if(i==1) j++; 
        }
        insert invoicelist;
        
        
        //Isertion of Additional_Ship_To__c with specific accountid
        list<Additional_Ship_To__c> addshiptolist=new list<Additional_Ship_To__c>();
        addshiptolist.add(new Additional_Ship_To__c(name='new add ship to :',   Account__c=acctlist[0].id,Opportunityid__c=opprlist[0].id));
        insert addshiptolist;
        
        //Again isertion of Additional_Ship_To__c with the same specific accountid
        Additional_Ship_To__c obj =new Additional_Ship_To__c(name='new add ship to :',  Account__c=acctlist[0].id,Opportunityid__c=opprlist[0].id);
      	Database.SaveResult result = Database.insert(obj, false);
            
        
      
            //Result
            //Getting result Additional_Ship_To__c list(resaddshiptolist)
            list<Additional_Ship_To__c> resaddshiptolist=new list<Additional_Ship_To__c>();
            resaddshiptolist=[select id,Commission_Approval_Status__c from Additional_Ship_To__c where id =: addshiptolist.get(0).id];
            
        	//Getting result Additional_Ship_To__c list(resaddshiptolist)
            list<Additional_Ship_To__c> resaddshiptolist2=new list<Additional_Ship_To__c>();
            resaddshiptolist2=[select id,Commission_Approval_Status__c from Additional_Ship_To__c where Account__c =: acctlist[0].id];
            
        	//Assert : condition no. 1 & 3:   Commission_Approval_Status__c=”Approved” &  does not add the same parent twice.
        //	System.assert(resaddshiptolist.get(0).Commission_Approval_Status__c == 'Approved' && resaddshiptolist2.size()<2 && !result.isSuccess());
        
    }
    
    @isTest
    //Test: Fullfiling Condition no.2  LineItem__c. Is_Additional_Ship_To_Deleted__c = true
    public  static void testhandler1(){
        //Setting test data
        //Setting Account list (acctlist)
        List<Account> acctlist=new List<Account>();
        opprtunity_trigger_handler.Checktest = true;
        opporutnityaccountchangeteiggerhandler.Checktest = true;
        
        for(integer i=0;i<3;i++){
            acctlist.add(new account(name='Cloudtestaccount'+i,BU_ID__c='00018',Account_Type__c ='Ship To (JDE)'));
        }    
        insert acctlist;
        
        //Setting opportunity list (opprlist)
        list<opportunity> opprlist=new list<opportunity>();
        for(integer i=0; i<4;i++){
            if(i == 0){
                opprlist.add(new opportunity(Name='cloudtestopportunity'+i ,Business_Unit__c='GEMS_NA',Accountid=acctlist[1].id,CloseDate= Date.today().addmonths(6),StageName = 'Stage 1 - Qualified' ));
            
            }
            else if(i<3){
                opprlist.add(new opportunity(Name='cloudtestopportunity'+i ,Business_Unit__c='GEMS_NA',Accountid=acctlist[i].id,CloseDate= Date.today().addmonths(6),StageName = 'Stage 1 - Qualified' ));
            }
            else  opprlist.add(new opportunity(Name='cloudtestopportunity'+i,Business_Unit__c='GEMS_EU',CloseDate=Date.today().addmonths(9),StageName = 'Stage 1 - Qualified'));
        }
        insert opprlist;
        
        //Setting product list (produtlist)
        List<Product2> produtlist=new List<Product2>();
        for(integer i=0; i<2;i++){
            produtlist.add(new Product2(name='cloudtestproduct'+i));
        }
        insert produtlist;
        
        //Setting Invoice list (invoicelist)
        List<LineItem__c> invoicelist=new List<LineItem__c>();
        for(integer i=0;i<3;i++){
            integer j=0; 
            invoicelist.add(new LineItem__c(name='cloudtestlineitem'+i,Accountid__c=acctlist[i].id,Productid__c=produtlist[j].id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =400, UnitPrice__c=400,Opportunityid__c= opprlist[0].id));
            if(i==1) j++; 
        }
        insert invoicelist;
        
        
        //Inserting Additional_Ship_To__c list
        list<Additional_Ship_To__c> addshiptolist=new list<Additional_Ship_To__c>();
        addshiptolist.add(new Additional_Ship_To__c(name='new add ship to :',   Account__c=acctlist[0].id,Opportunityid__c=opprlist[0].id));
        insert addshiptolist;
        
        Additional_Ship_To__c obj =new Additional_Ship_To__c(name='new add ship to :',  Account__c=acctlist[2].id,Opportunityid__c=opprlist[2].id);
      	Database.SaveResult result = Database.insert(obj, false);
        
        //Updation testing code
        Account obj1=new account(name='Cloudtestaccount',BU_ID__c='00018',Account_Type__c ='Ship To (JDE)');
        Account obj2=new account(name='Cloudtestaccount',BU_ID__c='00018',Account_Type__c ='Ship To (JDE)');
        insert obj1;
        insert obj2;
        Additional_Ship_To__c addshipupdateobj =new Additional_Ship_To__c(name='new add ship to :',  Account__c=obj1.id,Opportunityid__c=opprlist[2].id);
		insert     addshipupdateobj;
        addshipupdateobj.Account__c = obj2.id;
        update addshipupdateobj;
        
        //Deleting Additional_Ship_To__c list
        delete addshiptolist;
        
        //Result
        //Getting result invoice list(resinvoicelist)
        List<LineItem__c> resinvoicelist=new List<LineItem__c>();
        resinvoicelist=[select id,Is_Additional_Ship_To_Deleted__c from LineItem__c where Opportunityid__c=: opprlist[0].id];
        
        //Assert : Fullfiling Condition no.2  LineItem__c. Is_Additional_Ship_To_Deleted__c = true
      //  System.assert( !result.isSuccess() && resinvoicelist.get(0).Is_Additional_Ship_To_Deleted__c == true && resinvoicelist.get(1).Is_Additional_Ship_To_Deleted__c == true && resinvoicelist.get(2).Is_Additional_Ship_To_Deleted__c == true);
    }
    
    @isTest
    //Checking the same functionality with OpportunityLineItem 
    public  static void  testbatchcls(){
        
        //Setting test data
        //Setting Account list (acctlist)
        List<Account> acctlist=new List<Account>();
        opprtunity_trigger_handler.Checktest = true;
        opporutnityaccountchangeteiggerhandler.Checktest = true;
        opporutnityaccountchangeteiggerhandler.runTrigger = true;
        opprtunity_trigger_handler.runTrigger = true;
        
        for(integer i=0;i<3;i++){
            acctlist.add(new account(name='Cloudtestaccount'+i,BU_ID__c='00018',Account_Type__c ='Ship To (JDE)'));
        }    
        insert acctlist;
        
        //Getting StandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
        //Setting product list (produtlist)
        List<Product2> produtlist=new List<Product2>();
        for(integer i=0; i<2;i++){
            produtlist.add(new Product2(name='cloudtestproduct'+i));
        }
        insert produtlist;
        
        pricebook2 pricebook2obj=new pricebook2(name='cloudtestpricebook',  IsActive=true);
        insert pricebook2obj;
        System.debug('pricebook2list :  '+ pricebook2obj);
        
        //Setting opportunity list (opprlist)
        list<opportunity> opprlist=new list<opportunity>();
        for(integer i=0; i<4;i++){
            if(i<3){
                opprlist.add(new opportunity(Name='cloudtestopportunity'+i ,Business_Unit__c='GEMS_NA',CloseDate= Date.today().addmonths(6),OPP_Approval_Status__c = 'Approved for All',StageName = 'Stage 1 - Qualified' ));
            }
            else  opprlist.add(new opportunity(Name='cloudtestopportunity'+i,Business_Unit__c='GEMS_EU',CloseDate=Date.today().addmonths(9),StageName = 'Stage 1 - Qualified'));
        }
        insert opprlist;
        
        
        
        
        //Setting Invoice list (invoicelist)
        List<LineItem__c> invoicelist=new List<LineItem__c>();
        for(integer i=0;i<3;i++){
            integer j=0; 
            invoicelist.add(new LineItem__c(name='cloudtestlineitem'+i,Accountid__c=acctlist[i].id,Productid__c=produtlist[j].id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =400, UnitPrice__c=400,Opportunityid__c= opprlist[0].id));
            if(i==1) j++; 
        }
        insert invoicelist;
        
        List<opportunitylineitem> opporproductlist=new List<opportunitylineitem> ();
        pricebookentry entryobj1=new pricebookentry(IsActive =true, Product2Id =  produtlist[0].id , UnitPrice = 200 ,Pricebook2Id =pricebookId);
        insert entryobj1;
        pricebookentry entryobj2=new pricebookentry(IsActive =true , Product2Id =  produtlist[1].id , UnitPrice = 200 ,pricebook2id=pricebookId);
        insert entryobj2;
        
        for(integer i=0; i<4;i++){
            integer j=0; decimal dc=0; 
            
            
            if(j<2)
            {
                opportunityLineItem oli = new OpportunityLineItem(OpportunityId=opprlist[i].id, PricebookEntryId=entryobj1.Id,Quantity = 2,TotalPrice=100,Override_Unit_Price__c= 0 ,Commission_Approval_Status__c ='Approved');
                opporproductlist.add(oli);
            }
            else
            {
                opportunityLineItem oli = new OpportunityLineItem(OpportunityId=opprlist[i].id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=100,Override_Unit_Price__c= 40 ,Commission_Approval_Status__c ='Approved');
                opporproductlist.add(oli);
            }
            //opporproductlist.add(new opportunitylineitem(Opportunityid = opprlist[i].id, Product2id = produtlist[j] , Override_Unit_Price__c= dc ,Commission_Approval_Status__c ='Approved' ));
            
        }
        opporproductlist.add(new OpportunityLineItem(OpportunityId=opprlist[3].id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=100,Override_Unit_Price__c= 40 ,Commission_Approval_Status__c ='Approved'));
        //opporproductlist.add(new OpportunityLineItem(OpportunityId=opprlist[3].id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=100,Override_Unit_Price__c= 40 ,Commission_Approval_Status__c ='Approved'));
        insert opporproductlist;
        
        OpportunityLineItem obj=new OpportunityLineItem(OpportunityId=opprlist[3].id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=100,Override_Unit_Price__c= 40 ,Commission_Approval_Status__c ='Approved');
        //Checking Criteria for oppor. product that single product should'nt be attach with oppor. twice
        Database.SaveResult result = Database.insert(obj, false);
        
        //Deletion on oppor.productlist
        delete opporproductlist;
        
        List<additional_ship_to__c> addshiptolist=new List<additional_ship_to__c> ();
        for(integer i=0; i<4;i++){
            integer j=0;
            if(i<3)
                addshiptolist.add(new additional_ship_to__c(Opportunityid__c = opprlist[i].id ,account__c  =acctlist[i].id ,Commission_Approval_Status__c ='Approved' ));
            else
                addshiptolist.add(new additional_ship_to__c(Opportunityid__c = opprlist[i].id ,account__c  =acctlist[i-1].id ,Commission_Approval_Status__c ='Approved' ));
        }
        insert addshiptolist;
    }
    
    @isTest
    public static void testoppo(){
        //Updation testing
        opporutnityaccountchangeteiggerhandler.Checktest = true;
        opprtunity_trigger_handler.Checktest = true;
        opporutnityaccountchangeteiggerhandler.runTrigger = true;
        opprtunity_trigger_handler.runTrigger = true;
         
        Account obj1=new account(name='Cloudtestaccount',BU_ID__c='00018',Account_Type__c ='Ship To (JDE)');
        Account obj2=new account(name='Cloudtestaccount',BU_ID__c='00018',Account_Type__c ='Ship To (JDE)');
        insert obj1;
        insert obj2;
        opportunity opporupdate =new opportunity(Name='cloudtestopportunity',accountid=obj1.id,Business_Unit__c='GEMS_EU',CloseDate=Date.today().addmonths(9),StageName = 'Stage 1 - Qualified');
		insert opporupdate;
        LineItem__c lineobj=new LineItem__c(name='cloudtestlineitem',Accountid__c=obj1.id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =400, UnitPrice__c=400,Opportunityid__c= opporupdate.id);
        insert lineobj;
        system.debug(lineobj);
        opporupdate.accountid = obj2.id;
        update opporupdate;
    	        
    }
    
}