@isTest
private class Cont_NBO_TestClass {  
    static testMethod void testMethod_NBO ()
    {
        Profile pro = [SELECT Id FROM Profile Where Name = 'System Administrator' LIMIT 1];
        User appdataOwner = new User(
                        lastname ='App', 
                        alias ='Data', 
                        email ='app.data@testdev.com', 
                        username ='app.data@testdev.com', 
                        ProfileId = pro.Id, 
                        EmailEncodingKey = 'ISO-8859-1', 
                        LanguageLocaleKey = 'en_US', 
                        LocaleSidKey = 'en_GB', 
                        TimeZoneSidKey = 'GMT', 
                        IsActive = true);
        insert appdataOwner;
        
        Account a = new Account(Name='Test');
        a.Is_Distributor__c = true;
        insert a;
        
        //Create Product Type
        Product_Type__c prType1=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Flow');
        insert prType1;
        //Insert Product Model
        Product_Model__c prm1=new Product_Model__c(Product_Type__c=prType1.id,name='Test product Model',Product_Model__c='Test Model');
        insert prm1;
        Opportunity opp1 = new Opportunity(AccountId = a.Id, OwnerId=appdataOwner.Id, Product_Model__c=prm1.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp1;
        
         //Create Product Type
        Product_Type__c prType2=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Level Continuous');
        insert prType2;
        //Insert Product Model
        Product_Model__c prm2=new Product_Model__c(Product_Type__c=prType2.id,name='Test product Model',Product_Model__c='Test Model');
        insert prm2;
        Opportunity opp2 = new Opportunity(AccountId = a.Id, OwnerId=appdataOwner.Id, Product_Model__c=prm2.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp2;
        
         //Create Product Type
        Product_Type__c prType3=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Level Electronic Switch');
        insert prType3;
        //Insert Product Model
        Product_Model__c prm3=new Product_Model__c(Product_Type__c=prType3.id,name='Test product Model',Product_Model__c='Test Model');
        insert prm3;
        Opportunity opp3 = new Opportunity(AccountId = a.Id, OwnerId=appdataOwner.Id, Product_Model__c=prm3.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp3;
        
         //Create Product Type
        Product_Type__c prType4=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Level Float');
        insert prType4;
        //Insert Product Model
        Product_Model__c prm4=new Product_Model__c(Product_Type__c=prType4.id,name='Test product Model',Product_Model__c='Test Model');
        insert prm4;
        Opportunity opp4 = new Opportunity(AccountId = a.Id,Product_Model__c=prm4.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp4;
        
         //Create Product Type
        Product_Type__c prType5=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Pressure');
        insert prType5;
        //Insert Product Model
        Product_Model__c prm5=new Product_Model__c(Product_Type__c=prType5.id,name='Test product Model',Product_Model__c='Test Model');
        insert prm5;
        Opportunity opp5 = new Opportunity(AccountId = a.Id,Product_Model__c=prm5.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp5;
        
         //Create Product Type
        Product_Type__c prType6=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Temp Switch & Continuous Temp');
        insert prType6;
        //Insert Product Model
        Product_Model__c prm6=new Product_Model__c(Product_Type__c=prType6.id,name='Test product Model',Product_Model__c='Test Model');
        insert prm6;
        Opportunity opp6 = new Opportunity(AccountId = a.Id,Product_Model__c=prm6.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp6;
        
         //Create Product Type
        Product_Type__c prType7=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Valve');
        insert prType7;
        //Insert Product Model
        Product_Model__c prm7=new Product_Model__c(Product_Type__c=prType7.id,name='Test product Model',Product_Model__c='Test Model');
        insert prm7;
        Opportunity opp7 = new Opportunity(AccountId = a.Id,Product_Model__c=prm7.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp7;

         //Create Product Type
        Product_Type__c prType8=new Product_Type__c(Name='Test type',Is_Disable__c=false,NBO_Type__c='Fluidic Systems');
        insert prType8;
        //Insert Product Model
        Product_Model__c prm8=new Product_Model__c(Product_Type__c=prType8.id,name='Test product Model',Product_Model__c='Test Model' );
        insert prm8;
        Opportunity opp8 = new Opportunity(AccountId = a.Id,Product_Model__c=prm8.id,Name = 'Test Opp',StageName = 'Stage 0 - Pre Project',CloseDate = Date.today());
        insert opp8;        
        
              
        
       List<RecordType> RecordTypeList=Utility.NBORecordTypeList();
       Map<string,string> MapRecordType=new Map<string,string>();
       if(RecordTypeList.size()>0){
         for(RecordType retc:RecordTypeList){
            MapRecordType.put(retc.DeveloperName,retc.id);
         }
       }
        NBO_Forms__c nboFTL=new NBO_Forms__c();
        nboFTL.Name='NBO FTL';
        nboFTL.Opportunity__c=opp4.id;
        nboFTL.RecordTypeId=MapRecordType.get('Level_Float');
        nboFTL.OwnerId=appdataOwner.Id;
        // this is to test PIM_AI_score trigger
        nboFTL.PIM_Q1__c = 'Prototypes Only';
        nboFTL.PIM_Q2__c = '0 – 40 ($4000 NRE)';
        nboFTL.PIM_Q3__c = 'Component only & core competency';
        nboFTL.PIM_Q4__c = 'Existing cell';
        nboFTL.PIM_Q5__c = '$0 - $1000 Fixtures & Gauges Off the shelf or existing';
        nboFTL.PIM_Q6__c = 'Current part, consistent usage';
        nboFTL.PIM_Q7__c = 'Current suppliers, standard lead-times';
        nboFTL.PIM_Q8__c = 'Existing Quality System';
        nboFTL.PIM_Q9__c = 'Current processes and people';
        nboFTL.PIM_Q10__c = 'All';
        nboFTL.AF_Q1__c = '0-50%';
        nboFTL.AF_Q2__c = '0 – 8 weeks';
        nboFTL.AF_Q3__c = 'Partial';
        nboFTL.AF_Q4__c = 'Weak Competitor';
        nboFTL.AF_Q5__c = 'PPV';
        nboFTL.AF_Q6__c = 'Existing';     
        nboFTL.Product_Type__c = 'Fluidic Systems';    
        insert nboFTL;
        
        NBO_Forms__c NBO_Flow=new NBO_Forms__c();
        NBO_Flow.Name='NBO NBO_Flow';
        NBO_Flow.Opportunity__c=opp1.id;
        NBO_Flow.RecordTypeId=MapRecordType.get('NBO_Flow');
        NBO_Flow.OwnerId=appdataOwner.Id;
        // this is to test PIM_AI_score trigger
        NBO_Flow.PIM_Q1__c = 'Prototypes Only';
        NBO_Flow.PIM_Q2__c = '0 – 40 ($4000 NRE)';
        NBO_Flow.PIM_Q3__c = 'Component only & core competency';
        NBO_Flow.PIM_Q4__c = 'Existing cell';
        NBO_Flow.PIM_Q5__c = '$0 - $1000 Fixtures & Gauges Off the shelf or existing';
        NBO_Flow.PIM_Q6__c = 'Current part, consistent usage';
        NBO_Flow.PIM_Q7__c = 'Current suppliers, standard lead-times';
        NBO_Flow.PIM_Q8__c = 'Existing Quality System';
        NBO_Flow.PIM_Q9__c = 'Current processes and people';
        NBO_Flow.PIM_Q10__c = 'All';
        NBO_Flow.AF_Q1__c = '0-50%';
        NBO_Flow.AF_Q2__c = '0 – 8 weeks';
        NBO_Flow.AF_Q3__c = 'Partial';
        NBO_Flow.AF_Q4__c = 'Weak Competitor';
        NBO_Flow.AF_Q5__c = 'PPV';
        NBO_Flow.AF_Q6__c = 'Existing';
        NBO_Flow.Product_Type__c = 'Flow';
        insert NBO_Flow;
        
        NBO_Forms__c Pressure=new NBO_Forms__c();
        Pressure.Name='NBO Pressure';
        Pressure.Opportunity__c=opp5.id;
        Pressure.RecordTypeId=MapRecordType.get('Pressure');
        Pressure.OwnerId=appdataOwner.Id;
        // this is to test PIM_AI_score trigger
        Pressure.PIM_Q1__c = 'Prototypes Only';
        Pressure.PIM_Q2__c = '0 – 40 ($4000 NRE)';
        Pressure.PIM_Q3__c = 'Component only & core competency';
        Pressure.PIM_Q4__c = 'Existing cell';
        Pressure.PIM_Q5__c = '$0 - $1000 Fixtures & Gauges Off the shelf or existing';
        Pressure.PIM_Q6__c = 'Current part, consistent usage';
        Pressure.PIM_Q7__c = 'Current suppliers, standard lead-times';
        Pressure.PIM_Q8__c = 'Existing Quality System';
        Pressure.PIM_Q9__c = 'Current processes and people';
        Pressure.PIM_Q10__c = 'All';
        Pressure.AF_Q1__c = '0-50%';
        Pressure.AF_Q2__c = '0 – 8 weeks';
        Pressure.AF_Q3__c = 'Partial';
        Pressure.AF_Q4__c = 'Weak Competitor';
        Pressure.AF_Q5__c = 'PPV';
        Pressure.AF_Q6__c = 'Existing';       
        Pressure.Product_Type__c = 'Pressure';
        insert Pressure;
        
        NBO_Forms__c Temp_Cont_Switch=new NBO_Forms__c();
        Temp_Cont_Switch.Name='NBO Temp_Cont_Switch';
        Temp_Cont_Switch.Opportunity__c=opp6.id;
        Temp_Cont_Switch.RecordTypeId=MapRecordType.get('Temp_Cont_Switch');
        Temp_Cont_Switch.OwnerId=appdataOwner.Id;
        Temp_Cont_Switch.Product_Type__c = 'Temperature Sensor';
        insert Temp_Cont_Switch;
        
        NBO_Forms__c Valve=new NBO_Forms__c();
        Valve.Name='NBO Valve';
        Valve.Opportunity__c=opp7.id;
        Valve.RecordTypeId=MapRecordType.get('Valve');
        // this is to test PIM_AI_score trigger
        Valve.PIM_Q1__c = 'Prototypes Only';
        Valve.PIM_Q2__c = '0 – 40 ($4000 NRE)';
        Valve.PIM_Q3__c = 'Component only & core competency';
        Valve.PIM_Q4__c = 'Existing cell';
        Valve.PIM_Q5__c = '$0 - $1000 Fixtures & Gauges Off the shelf or existing';
        Valve.PIM_Q6__c = 'Current part, consistent usage';
        Valve.PIM_Q7__c = 'Current suppliers, standard lead-times';
        Valve.PIM_Q8__c = 'Existing Quality System';
        Valve.PIM_Q9__c = 'Current processes and people';
        Valve.PIM_Q10__c = 'All';
        Valve.AF_Q1__c = '0-50%';
        Valve.AF_Q2__c = '0 – 8 weeks';
        Valve.AF_Q3__c = 'Partial';
        Valve.AF_Q4__c = 'Weak Competitor';
        Valve.AF_Q5__c = 'PPV';
        Valve.AF_Q6__c = 'Existing';
        Valve.Product_Type__c = 'Valve';
        insert Valve;
        
        NBO_Forms__c Level_Continuous=new NBO_Forms__c();
        Level_Continuous.Name='NBO Level_Continuous';
        Level_Continuous.Opportunity__c=opp2.id;
        Level_Continuous.RecordTypeId=MapRecordType.get('Level_Continuous');
        Level_Continuous.Product_Type__c = 'Valve';
        insert Level_Continuous;
        
        NBO_Forms__c Level_Elect_Switch=new NBO_Forms__c();
        Level_Elect_Switch.Name='NBO Level_Elect_Switch';
        Level_Elect_Switch.Opportunity__c=opp3.id;
        Level_Elect_Switch.RecordTypeId=MapRecordType.get('Level_Elect_Switch');
        Level_Elect_Switch.Product_Type__c = 'Valve';
        insert Level_Elect_Switch;

        NBO_Forms__c Fluidic_Systems = new NBO_Forms__c();
        Fluidic_Systems.Name='NBO Fluidic_Systems';
        Fluidic_Systems.Opportunity__c=opp8.id;
        Fluidic_Systems.RecordTypeId=MapRecordType.get('Fluidic_Systems');
        Fluidic_Systems.Product_Type__c = 'Fluidic Systems';
        insert Fluidic_Systems;        
        
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp4.id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(nboFTL);
        Cont_NBO  cnbo1=new Cont_NBO(sc1);
        cnbo1.cancel();
        cnbo1.RedirectToNewNBO();
        cnbo1.getRecordTypeSelectList();
        cnbo1.NBOURL();
        cnbo1.RecordTypeDevName = 'Flow';
        cnbo1.GoToNBOForm();
        
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp1.id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(NBO_Flow);
        Cont_NBO  cnbo2=new Cont_NBO(sc2);
        
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp5.id);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(Pressure);
        Cont_NBO  cnbo3=new Cont_NBO(sc3);
       
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp6.id);
        ApexPages.StandardController sc4 = new ApexPages.StandardController(Temp_Cont_Switch);
        Cont_NBO  cnbo4=new Cont_NBO(sc4);
        
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp7.id);
        ApexPages.StandardController sc5 = new ApexPages.StandardController(Valve);
        Cont_NBO  cnbo5=new Cont_NBO(sc5);
        
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp2.id);
        ApexPages.StandardController sc6 = new ApexPages.StandardController(Level_Continuous);
        Cont_NBO  cnbo6=new Cont_NBO(sc6);
        
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp3.id);
        ApexPages.StandardController sc7 = new ApexPages.StandardController(Level_Elect_Switch);
        Cont_NBO  cnbo7=new Cont_NBO(sc7);
        
        ApexPages.currentPage().getParameters().put('Other','true');
        ApexPages.currentPage().getParameters().put('OppId',opp8.id);
        ApexPages.StandardController sc8 = new ApexPages.StandardController(Fluidic_Systems);
        Cont_NBO  cnbo8=new Cont_NBO(sc8);
        
        ApexPages.currentPage().getParameters().put('Other',null);
        ApexPages.StandardController scOther = new ApexPages.StandardController(Fluidic_Systems);
        Cont_NBO  cnboOther=new Cont_NBO(scOther);
        String RecordTypeId = cnboOther.getRecordTypeId('FLT');
        cnboOther.RedirectToNewNBO();
        cnboOther.NBOURL();
                
        //test Covergae for Cont_CloneNBO
        ApexPages.currentPage().getParameters().put('Id',Level_Elect_Switch.id);
        ApexPages.StandardController scClone = new ApexPages.StandardController(Level_Elect_Switch);
        Cont_CloneNBO  CloneCnt=new Cont_CloneNBO(scClone);
        CloneCnt.RedirectToNBOClone();
        
        //Test coverage for PrintNBO
        ApexPages.StandardController sc11 = new ApexPages.StandardController(nboFTL);
        PrintNBO  PrintNBO1=new PrintNBO(sc11);
        PrintNBO1.RedirecttoNBOPage();      
        
        ApexPages.StandardController sc21 = new ApexPages.StandardController(NBO_Flow);
        PrintNBO  PrintNBO2=new PrintNBO(sc21);
        PrintNBO2.RedirecttoNBOPage();
        
        ApexPages.StandardController sc31 = new ApexPages.StandardController(Pressure);
        PrintNBO  PrintNBO3=new PrintNBO(sc31);
        PrintNBO3.RedirecttoNBOPage();
        
        ApexPages.StandardController sc41 = new ApexPages.StandardController(Temp_Cont_Switch);
        PrintNBO  PrintNBO4=new PrintNBO(sc41);
        PrintNBO4.RedirecttoNBOPage();
        
        ApexPages.StandardController sc51 = new ApexPages.StandardController(Valve);
        PrintNBO  PrintNBO5=new PrintNBO(sc51);
        PrintNBO5.RedirecttoNBOPage();
        
        ApexPages.StandardController sc61 = new ApexPages.StandardController(Level_Continuous);
        PrintNBO  PrintNBO6=new PrintNBO(sc61);
        PrintNBO6.RedirecttoNBOPage();
        
        ApexPages.StandardController sc71 = new ApexPages.StandardController(Level_Elect_Switch);
        PrintNBO  PrintNBO7=new PrintNBO(sc71);
        PrintNBO7.RedirecttoNBOPage();

        ApexPages.StandardController sc81 = new ApexPages.StandardController(Fluidic_Systems);
        PrintNBO  PrintNBO8=new PrintNBO(sc81);
        PrintNBO8.RedirecttoNBOPage();  
        
        ApexPages.currentPage().getParameters().put('Id',NBO_Flow.Id);
        ApexPages.StandardController sc91 = new ApexPages.StandardController(Fluidic_Systems);
        PrintNBO printNBO9 = new printNBO(sc91);
        printNBO9.nboId = null;
        printNBO9.RedirecttoNBOPage();  
        
        //For test Coverage of Generate Name Revision NBO trigger
        NBO_Forms__c cloneRecord;
        cloneRecord = NBO_Flow.Clone(false);
        //cloneRecord.Clone_Record__c = 'a0L60000001jQui';
        //cloneRecord.Clone_Record__c =NBO_Flow.id;
        cloneRecord.Revision_Number__c = 'A';
        cloneRecord.Name= 'FLO0016506-1';
        cloneRecord.Opportunity__c = opp1.Id;
        cloneRecord.OwnerId=appdataOwner.Id;
        cloneRecord.PIM_Q1__c = 'Prototypes Only';
        cloneRecord.PIM_Q2__c = '0 – 40 ($4000 NRE)';
        cloneRecord.PIM_Q3__c = 'Component only & core competency';
        cloneRecord.PIM_Q4__c = 'Existing cell';
        cloneRecord.PIM_Q5__c = '$0 - $1000 Fixtures & Gauges Off the shelf or existing';
        cloneRecord.PIM_Q6__c = 'Current part, consistent usage';
        cloneRecord.PIM_Q7__c = 'Current suppliers, standard lead-times';
        cloneRecord.PIM_Q8__c = 'Existing Quality System';
        cloneRecord.PIM_Q9__c = 'Current processes and people';
        cloneRecord.PIM_Q10__c = 'All';
        cloneRecord.AF_Q1__c = '0-50%';
        cloneRecord.AF_Q2__c = '0 – 8 weeks';
        cloneRecord.AF_Q3__c = 'Partial';
        cloneRecord.AF_Q4__c = 'Weak Competitor';
        cloneRecord.AF_Q5__c = 'PPV';
        cloneRecord.AF_Q6__c = 'Existing';
        insert cloneRecord; 
        
        //Integer cnt = [Select count() from NBO_Forms__c Where Opportunity__c = :opp1.Id];
        //system.assertEquals(2, cnt);
        
        cloneRecord.RecordTypeId = null;
        cloneRecord.Clone_Record__c = null;
        cloneRecord.Battery__c = false;
        cloneRecord.Name = null;
        cloneRecord.OwnerId=appdataOwner.Id;        
        cloneRecord.PIM_Q1__c = 'Prototypes with internal OR external testing, OR Agency Approval';
        cloneRecord.PIM_Q2__c = '240+ ($50,000 NRE)';
        cloneRecord.PIM_Q3__c = 'Full system; limited or no expertise or technology in house';
        cloneRecord.PIM_Q4__c = 'New Value stream to New building';
        cloneRecord.PIM_Q5__c = '$5K - $20K i.e. Simple tooling (plastic mold) New Fixtures/Gages';
        cloneRecord.PIM_Q6__c = 'New part, must have consistent usage, medium volume';
        cloneRecord.PIM_Q7__c = 'Find and qualify new suppliers, new to Gems parts';
        cloneRecord.PIM_Q8__c = 'Existing Quality System';
        cloneRecord.PIM_Q9__c = 'New processes and current people';
        cloneRecord.PIM_Q10__c = 'All';
        cloneRecord.AF_Q1__c = '60 -80%';
        cloneRecord.AF_Q2__c = '8 – 24 weeks';
        cloneRecord.AF_Q3__c = 'All';
        cloneRecord.AF_Q4__c = 'Competitor at Parity';
        cloneRecord.AF_Q5__c = 'New platform';
        cloneRecord.AF_Q6__c = 'Top tier';
        
        update cloneRecord;
        
        NBO_Forms__c cloneRecord2;
        cloneRecord2 = Valve.clone(false);
        cloneRecord2.Clone_Record__c = null;
        cloneRecord2.Name = 'VAL0016506-1';
        insert cloneRecord2;
        
        
        //For test Coverage of Utility class
        Utility.GetCharacterFromASCII(65);
        Utility.GetCharacterFromASCII(66);
        Utility.GetCharacterFromASCII(67);
        Utility.GetCharacterFromASCII(68);
        Utility.GetCharacterFromASCII(69);
        Utility.GetCharacterFromASCII(70);
        Utility.GetCharacterFromASCII(71);
        Utility.GetCharacterFromASCII(72);
        Utility.GetCharacterFromASCII(73);
        Utility.GetCharacterFromASCII(74);
        Utility.GetCharacterFromASCII(75);
        Utility.GetCharacterFromASCII(76);
        Utility.GetCharacterFromASCII(77);          
        Utility.GetCharacterFromASCII(78);
        Utility.GetCharacterFromASCII(79);
        Utility.GetCharacterFromASCII(80);
        Utility.GetCharacterFromASCII(81);
        Utility.GetCharacterFromASCII(82);
        Utility.GetCharacterFromASCII(83);  
        Utility.GetCharacterFromASCII(84);
        Utility.GetCharacterFromASCII(85);
        Utility.GetCharacterFromASCII(86);
        Utility.GetCharacterFromASCII(87);
        Utility.GetCharacterFromASCII(88);
        Utility.GetCharacterFromASCII(89);      
        Utility.GetCharacterFromASCII(90);              
        Utility.getRevisionNumber('A');
        Utility.getRevisionNumber('B');
        Utility.getRevisionNumber('C');
        Utility.getRevisionNumber('D');
    }

}