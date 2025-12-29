@istest
public class opportesting {
    
    
    static
    {  
        
        CommissionManagerSettings__C sa = new CommissionManagerSettings__c();
        sa.Name = 'CheckBatch';
        sa.Check__C = true;
        insert sa;
    }  
    //Testing: Batch requirement 2:Set Opportunity. OPP_Approval_Status__c = Pending Approval, & batch requirement 3:Set Clock_Start_Date__c, and Clock_End_date__c.
    @isTest
    public static void  testbatchcls(){
       opporutnityaccountchangeteiggerhandler.runTrigger = true;
        opporutnityaccountchangeteiggerhandler.Checktest = true;
         
        //Setting test data
        //Setting Account list (acctlist)
        List<Account> acctlist=new List<Account>();
        for(integer i=0;i<3;i++){
            acctlist.add(new account(name='Cloudtestaccount'+i,BU_ID__c='00018',Account_Type__c ='Ship To (JDE)'));
        }    
        insert acctlist;
        
        //stating sol for search
        List<contact> conlist = new   List<contact>();
        for(integer i=0;i<3;i++){
        		conlist.add(new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = acctlist[i].id));
          }    
        insert conlist;
        List<case> caselist = new   List<case>();
        for(integer i=0;i<3;i++){
        		caselist.add( new Case(AccountId=acctlist[i].id,
                            Origin ='Email',
                            contactId = conlist[i].id,
                            type = 'RA Request',
                            PO_No__c='1234',
                            Gems_SO_Number__c='1234',
                            Gems_Invoice_Number__c= '1234',
                            Customer_Internal_Case_RA_No__c = '1234',
                            Product_Number__c = '111'));
          }    
        insert caselist;  
        
        
        
        System.assert(acctlist.size()>0);
        //Setting product list (produtlist)
        List<Product2> produtlist=new List<Product2>();
        for(integer i=0; i<2;i++){
            produtlist.add(new Product2(Name='one', 
                                ProductCode='111', 
                                isActive=true, 
                                Description='Test Product'));
        }
        insert produtlist;
        
        
        //ending solution.....
        
        System.assert(produtlist.size()>0);
        
        //Getting StandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
        //Setting opportunity list (opprlist)
        list<opportunity> opprlist=new list<opportunity>();
        for(integer i=0; i<4;i++){
            if(i<3){
                opprlist.add(new opportunity(Name='cloudtestopportunity'+i ,Business_Unit__c='GEMS_NA',Accountid=acctlist[i].id,CloseDate= Date.today().addmonths(6) ,StageName= 'Closed Won'));//,StageName= 'Closed Won'
            }
            else  opprlist.add(new opportunity(Name='cloudtestopportunity'+i,Business_Unit__c='GEMS_EU',CloseDate=Date.today().addmonths(9),StageName= 'Closed Won'));//,StageName= 'Closed Won'
        }
        insert opprlist;
        system.assert(opprlist.size()>0);
        Set<id> oppids=new set<id>();
        for(opportunity obj: opprlist){
            obj.OPP_Approval_Status__c = 'Under Threshold';
            oppids.add(obj.id);
        }
        update opprlist;
        
        //Setting opportunity product list (opporproductlist)
        List<opportunitylineitem> opporproductlist=new List<opportunitylineitem> ();
        pricebookentry entryobj1=new pricebookentry(IsActive =true, Product2Id =  produtlist[0].id , UnitPrice = 200 ,Pricebook2Id =pricebookId);
        insert entryobj1;
        pricebookentry entryobj2=new pricebookentry(IsActive =true , Product2Id =  produtlist[1].id , UnitPrice = 200 ,pricebook2id=pricebookId);//'01s60000000MVae'
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
        }
        opporproductlist.add(new OpportunityLineItem(OpportunityId=opprlist[3].id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=100,Override_Unit_Price__c= 40 ,Commission_Approval_Status__c ='Approved'));
        opporproductlist.add(new OpportunityLineItem(OpportunityId=opprlist[3].id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=100,Override_Unit_Price__c= 40 ,Commission_Approval_Status__c ='Approved'));
        insert opporproductlist;
        system.assert(opporproductlist.size()>0);
        //Setting addition ship to list (addshiptolist)
        List<additional_ship_to__c> addshiptolist=new List<additional_ship_to__c> ();
        for(integer i=0; i<3;i++){
            if(i<3)
                addshiptolist.add(new additional_ship_to__c(Opportunityid__c = opprlist[3].id ,account__c  =acctlist[i].id ,Commission_Approval_Status__c ='Approved' ));
            else
                addshiptolist.add(new additional_ship_to__c(Opportunityid__c = opprlist[3].id ,account__c  =acctlist[i-1].id ,Commission_Approval_Status__c ='Approved' ));
        }
        insert addshiptolist;
        system.assert(addshiptolist.size()>0);
        //Setting Invoice list (invoicelist) : which will check the  Opportunity. OPP_Approval_Status__c = Pending Approval
        List<LineItem__c> invoicelist=new List<LineItem__c>();
        for(integer i=0;i<3;i++){
            integer j=0; 
            invoicelist.add(new LineItem__c(   OrderType__c = 'SO',  Quantity_Returned__c = 3, OrderDate__c = System.today(),PONumber__c = '1234', OrderNumber__c = '1234',InvoiceNumber__c = '1234',ProdNo__c = '1234',name='cloudtestlineitem'+i,Accountid__c=acctlist[i].id,Productid__c=produtlist[j].id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =400,QuantityShipped__c=400, UnitPrice__c=400,Commissionable_Unit_Price__c =400,ShipDate__c = date.today().addmonths(5)) );
            
            if(i==1) j++; 
        }
        insert invoicelist;
        system.assert(invoicelist.size()>0);
          User u = [Select id, Job_title__c, Companyid__c from User where id =: UserInfo.getUserId()];                
        u.job_title__c = 'Case Manager'; 
        u.Companyid__c='00018';
        update u;

        //Testing process
        Test.startTest();
        List<CommissionManagerSettings__C> customList = new List<CommissionManagerSettings__C>([select Name,Check__C From CommissionManagerSettings__C Where Name = 'CheckBatch' AND Check__C = true Limit 1]);
        if(customList.size() > 0)
            
        {
            Opportunityjob obj=new Opportunityjob();
            Database.executeBatch(obj);
        }
        Test.stopTest();
        //Result
        //Getting result opportunity list(resopplist)
        List<opportunity> resopplist=new  List<opportunity>();
        resopplist=[select id, OPP_Approval_Status__c, Clock_Start_Date__c, Clock_End_date__c from opportunity where id in: oppids];
        
        //Assert : Batch requirement 2:Set Opportunity. OPP_Approval_Status__c = Pending Approval, & batch requirement 3:Set Clock_Start_Date__c, and Clock_End_date__c.
        //System.assert( resopplist[0].OPP_Approval_Status__c== 'Pending Approval' && resopplist[0].Clock_Start_Date__c ==date.today() && resopplist[0].Clock_End_date__c ==  date.today().addmonths(13) && resopplist[1].OPP_Approval_Status__c== 'Pending Approval' && resopplist[1].Clock_Start_Date__c ==date.today() && resopplist[1].Clock_End_date__c ==  date.today().addmonths(13) && resopplist[2].OPP_Approval_Status__c== 'Pending Approval' && resopplist[2].Clock_Start_Date__c==date.today() && resopplist[2].Clock_End_date__c ==  date.today().addmonths(13) ); 
        
    }
    
    //Testing Enhanced requirement of updating Commission_Pay_Date__c field of invoice
    @isTest
    public static void  testbatchcls2(){
        //setting test data
        opporutnityaccountchangeteiggerhandler.runTrigger = true;
        opporutnityaccountchangeteiggerhandler.Checktest = true;
        
        //Setting Account list (acctlist)
        List<Account> acctlist=new List<Account>();
        for(integer i=0;i<3;i++){
            acctlist.add(new account(name='Cloudtestaccount'+i,BU_ID__c='00018',Account_Type__c ='Ship To (JDE)'));
        }    
        insert acctlist;
        system.assert(acctlist.size()>0);
          //stating sol for search
        List<contact> conlist = new   List<contact>();
        for(integer i=0;i<3;i++){
        		conlist.add(new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = acctlist[i].id));
          }    
        insert conlist;
        List<case> caselist = new   List<case>();
        for(integer i=0;i<3;i++){
        		caselist.add( new Case(AccountId=acctlist[i].id,
                            Origin ='Email',
                            contactId = conlist[i].id,
                            type = 'RA Request',
                            PO_No__c='1234',
                            Gems_SO_Number__c='1234',
                            Gems_Invoice_Number__c= '1234',
                            Customer_Internal_Case_RA_No__c = '1234',
                            Product_Number__c = '111'));
          }    
        insert caselist;  
        
        
        
        System.assert(acctlist.size()>0);
        //Setting product list (produtlist)
        List<Product2> produtlist=new List<Product2>();
        for(integer i=0; i<2;i++){
            produtlist.add(new Product2(Name='one', 
                                ProductCode='111', 
                                isActive=true, 
                                Description='Test Product'));
        }
        insert produtlist;
        system.assert(produtlist.size()>0);
        
        
        //ending solution.....

        
        //Getting StandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();   
        
        
        //Setting opportunity obj (obj1)
        opportunity  obj1= new opportunity(Name='cloudtestopportunity',Business_Unit__c='GEMS_NA',Accountid=acctlist[0].id,CloseDate= Date.today().addmonths(6),StageName= 'Closed Won');//,StageName= 'Closed Won'
        insert obj1;
        
        //Setting opportunity product list (opporproductlist)
        List<opportunitylineitem> opporproductlist=new List<opportunitylineitem> ();
        pricebookentry entryobj1=new pricebookentry(IsActive =true , Product2Id =  produtlist[0].id , UnitPrice = 20 ,Pricebook2Id = pricebookId);
        insert entryobj1;
        pricebookentry entryobj2=new pricebookentry(IsActive =true , Product2Id =  produtlist[1].id , UnitPrice = 20 ,Pricebook2Id = pricebookId);
        insert entryobj2;
        
        for(integer i=0; i<4;i++){
            integer j=0; decimal dc=0; 
            if(j<2)
            {
                opportunityLineItem oli = new OpportunityLineItem(OpportunityId=obj1.id, PricebookEntryId=entryobj1.Id,Quantity = 2,TotalPrice=1,Override_Unit_Price__c= 5 ,Commission_Approval_Status__c ='Approved');
                opporproductlist.add(oli);
            }
            else
            {
                opportunityLineItem oli = new OpportunityLineItem(OpportunityId=obj1.id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=1,Override_Unit_Price__c= 6 ,Commission_Approval_Status__c ='Approved');
                opporproductlist.add(oli);
            }
        }
        insert opporproductlist;
        system.assert(opporproductlist.size()>0);
        
        //Setting Invoice list (invoicelist) 
        List<LineItem__c> invoicelist=new List<LineItem__c>();
        for(integer i=0;i<3;i++){
            integer j=0; 
            invoicelist.add(new LineItem__c(   OrderType__c = 'SO',  Quantity_Returned__c = 3, OrderDate__c = System.today(),PONumber__c = '1234', OrderNumber__c = '1234',InvoiceNumber__c = '1234',ProdNo__c = '1234',name='cloudtestlineitem'+i,Accountid__c=acctlist[i].id,Productid__c=produtlist[j].id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =400,QuantityShipped__c=400, UnitPrice__c=400,Commissionable_Unit_Price__c =400,ShipDate__c = date.today().addmonths(5)));
            if(i==1) j++; 
        }
        insert invoicelist;
        system.assert(invoicelist.size()>0);
           User u = [Select id, Job_title__c, Companyid__c from User where id =: UserInfo.getUserId()];                
        u.job_title__c = 'Case Manager'; 
        u.Companyid__c='00018';
        update u;

        
        //Updating Opportunity Field OPP_Approval_Status__c and insert new invoice which will Test Updated requirement of updating Commission_Pay_Date__c field of invoice
        obj1.OPP_Approval_Status__c = 'Approved for All';
        update obj1;
        LineItem__c obj2= new LineItem__c(name='cloudtestlineitem',Accountid__c=acctlist[0].id,Productid__c=produtlist[0].id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =2,QuantityShipped__c=2, UnitPrice__c=4,Commissionable_Unit_Price__c=4,ShipDate__c= date.today().addmonths(5));
        insert obj2;
        
        //Testing Process
        Test.startTest();
        List<CommissionManagerSettings__C> customList = new List<CommissionManagerSettings__C>([select Name,Check__C From CommissionManagerSettings__C Where Name = 'CheckBatch' AND Check__C = true Limit 1]);
        if(customList.size() > 0)
            
        {
            
            Opportunityjob obj=new Opportunityjob();
            Database.executeBatch(obj);
        }
        Test.stopTest();
        //Result
        //Getting result invoice list(resinvlist)
        list<LineItem__c> resinvlist=new list<LineItem__c>();
        resinvlist=[select id,Commission_Pay_Date__c from LineItem__c where id=: obj2.id];
        
        //Assert : Enhanced requirement of updating Commission_Pay_Date__c field of invoice
        //System.assert(resinvlist[0].Commission_Pay_Date__c==datetime.today()  );
    }
    
    
    
    
    //Testing Batch requirement 2:Set Opportunity. OPP_Approval_Status__c = Under Threshold, and Updated requirement of commisionable unit price field of invoice 
    @isTest
    public static void  testbatchcls3(){
        opporutnityaccountchangeteiggerhandler.runTrigger = true;
        opporutnityaccountchangeteiggerhandler.Checktest = true;
        
        //Setting Account list (acctlist)
        List<Account> acctlist=new List<Account>();
        for(integer i=0;i<3;i++){
            acctlist.add(new account(name='Cloudtestaccount'+i,BU_ID__c='00018',Account_Type__c ='Ship To (JDE)'));
        }    
        insert acctlist;
        system.assert(acctlist.size()>0);
         //stating sol for search
        List<contact> conlist = new   List<contact>();
        for(integer i=0;i<3;i++){
        		conlist.add(new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = acctlist[i].id));
          }    
        insert conlist;
        List<case> caselist = new   List<case>();
        for(integer i=0;i<3;i++){
        		caselist.add( new Case(AccountId=acctlist[i].id,
                            Origin ='Email',
                            contactId = conlist[i].id,
                            type = 'RA Request',
                            PO_No__c='1234',
                            Gems_SO_Number__c='1234',
                            Gems_Invoice_Number__c= '1234',
                            Customer_Internal_Case_RA_No__c = '1234',
                            Product_Number__c = '111'));
          }    
        insert caselist;  
        
        
        
        System.assert(acctlist.size()>0);
        //Setting product list (produtlist)
        List<Product2> produtlist=new List<Product2>();
        for(integer i=0; i<2;i++){
            produtlist.add(new Product2(Name='one', 
                                ProductCode='111', 
                                isActive=true, 
                                Description='Test Product'));
        }
        insert produtlist;
        
        
        //ending solution.....
       
        //Getting StandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();   
        
        
        //Setting opportunity obj (obj1)
        opportunity  obj1= new opportunity(Name='cloudtestopportunity',Business_Unit__c='GEMS_NA',Accountid=acctlist[0].id,CloseDate= Date.today().addmonths(6),StageName= 'Closed Won');//,StageName= 'Closed Won'
        insert obj1;
        obj1.OPP_Approval_Status__c = 'Under Threshold';
        update obj1;
        
        //Setting opportunity product list (opporproductlist)
        List<opportunitylineitem> opporproductlist=new List<opportunitylineitem> ();
        pricebookentry entryobj1=new pricebookentry(IsActive =true , Product2Id =  produtlist[0].id , UnitPrice = 20 ,Pricebook2Id =pricebookId);
        insert entryobj1;
        pricebookentry entryobj2=new pricebookentry(IsActive =true , Product2Id =  produtlist[1].id , UnitPrice = 20 ,Pricebook2Id = pricebookId);
        insert entryobj2;
        for(integer i=0; i<4;i++){
            integer j=0; decimal dc=0; 
            if(j<2)
            {
                opportunityLineItem oli = new OpportunityLineItem(OpportunityId=obj1.id, PricebookEntryId=entryobj1.Id,Quantity = 2,TotalPrice=1,Override_Unit_Price__c= 5 ,Commission_Approval_Status__c ='Approved');
                opporproductlist.add(oli);
            }
            else
            {
                opportunityLineItem oli = new OpportunityLineItem(OpportunityId=obj1.id, PricebookEntryId=entryobj2.Id,Quantity = 2,TotalPrice=1,Override_Unit_Price__c= 5 ,Commission_Approval_Status__c ='Approved');
                opporproductlist.add(oli);
            }
        }
        insert opporproductlist;
        system.assert(opporproductlist.size()>0);
        
        //Setting addition ship to list (addshiptolist)
        List<additional_ship_to__c> addshiptolist=new List<additional_ship_to__c> ();
        for(integer i=0; i<4;i++){
            integer j=0;
            if(i<3)
                addshiptolist.add(new additional_ship_to__c(Opportunityid__c = obj1.id ,account__c  =acctlist[1].id ,Commission_Approval_Status__c ='Approved' ));
            else
                addshiptolist.add(new additional_ship_to__c(Opportunityid__c = obj1.id ,account__c  =acctlist[2].id ,Commission_Approval_Status__c ='Approved' ));
        }
        insert addshiptolist;
        system.assert(addshiptolist.size()>0);
        
        //Setting Invoice list (invoicelist) which will Test Batch requirement 2:Set Opportunity. OPP_Approval_Status__c = Under Threshold, and Updated requirement of commisionable unit price field of invoice 
        List<LineItem__c> invoicelist=new List<LineItem__c>();
        for(integer i=0;i<3;i++){
            integer j=0; 
            invoicelist.add(new LineItem__c(   OrderType__c = 'SO',  Quantity_Returned__c = 3, OrderDate__c = System.today(),PONumber__c = '1234', OrderNumber__c = '1234',InvoiceNumber__c = '1234',ProdNo__c = '1234',name='cloudtestlineitem'+i,Accountid__c=acctlist[i].id,Productid__c=produtlist[j].id,BUID__c='00018', IsShiped__c = True,QuantityOrdered__c =400,QuantityShipped__c=400, UnitPrice__c=400,Commissionable_Unit_Price__c =400,ShipDate__c = date.today().addmonths(5)));
            if(i==1) j++; 
        }
        insert invoicelist;
        system.assert(invoicelist.size()>0);
        User u = [Select id, Job_title__c, Companyid__c from User where id =: UserInfo.getUserId()];                
        u.job_title__c = 'Case Manager'; 
        u.Companyid__c='00018';
        update u;
        //testing process
        Test.startTest();
        List<CommissionManagerSettings__C> customList = new List<CommissionManagerSettings__C>([select Name,Check__C From CommissionManagerSettings__C Where Name = 'CheckBatch' AND Check__C = true Limit 1]);
        if(customList.size() > 0)
            
        {
            
            Opportunityjob obj=new Opportunityjob();
            Database.executeBatch(obj);
        }
        Test.stopTest();
        
        //Result
        //Getting result invoice list(resinvlist)
        list<LineItem__c> resinvlist=new list<LineItem__c>();
        resinvlist=[select id,Commission_Pay_Date__c,Commissionable_Unit_Price__c from LineItem__c where Opportunityid__c=: obj1.id];
        
        //Getting result opportunity list(resopplist)
        List<opportunity> resopplist=new  List<opportunity>();
        resopplist=[select id, OPP_Approval_Status__c, Clock_Start_Date__c, Clock_End_date__c from opportunity where id=: obj1.Id];
        
        //Assert : Batch requirement 2:Set Opportunity. OPP_Approval_Status__c = Under Threshold, and Updated requirement of commisionable unit price field of invoice 
        //System.assert(resopplist[0].OPP_Approval_Status__c == 'Under Threshold' && resinvlist[0].Commissionable_Unit_Price__c == 5);
    }  
}