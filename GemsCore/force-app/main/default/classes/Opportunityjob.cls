/**

DESCRIPTION:
*Batch Job for Updating the invoices,Opportunity Records, In this we use objects:-Opportunity, Account, Order & Shipment (LineItem__c), Opportunity Product, Additional Ship To  (Additional_Ship_To__c). *
*In this Batch Class we are fecthing record of invoices which have not been attached with any opportunity previously and fullfill criteria no. 5,6 and 9. *
*Then Fetching of those Opportunity records done which fullfill criteria no. 1,2,7 and 8, then attach them with related invoices by using AccountID and Product ID. *
*We Update opportunity fields   Total_New_Business__c ,oppobj.OPP_Approval_Status__c,oppobj.Clock_Start_Date__c and  oppobj.Clock_End_date_c as per requirement of Bacth Class point no: 1,2 and 3. *
*We also Update invoice(LineItem__c) fields   Opportunityid__c, (Commissionable_Unit_Price__c, Commission_Pay_Date__c as per enhanced requirements). *

*@Author: BALKISHAN KACHAWA
*
*/
//Gazi added comment on 10/10/2017: Can we add a condition on line 24 to make sure we just look at the invoices shipped in last 12 months. No need to look at all invoices in the system, just look at last 12 months invoices.
//Remove OrderType__c != 'CR' from line 24, 34. In line 94 when you comparing Clock Start and End date to ship date, I think some invoices are not getting accepted becaues Clock start and end date is date time, and ship date is just date.

global class Opportunityjob implements Database.Batchable<sobject>{  
        
    List<LineItem__c> mylistitems;
    Map<id,set<id>> invidsbyprod;
    Map<id,set<id>> invidsbyaddship;
    Map<id,decimal> oppo_prod_overrideprice;
    Decimal opp_prod_overprice;
    //Start Method
    global Database.Querylocator start (Database.BatchableContext BC) {
        
        //Getting all invoices which fullfill this criteria no. 5,6 and 9 (Opportunityid__c = null AND IsShiped__c = True AND OrderType__c != 'CR' AND OrderType__c != 'SB')
        //recent changes : string query = 'SELECT ID, ShipDate__c From LineItem__c WHERE ShipDate__c >=: eDate ORDER BY ShipDate__c';
        Date eDate = System.today().addMonths(-12);
        system.debug('===edate==='+edate);
        
        string query = 'SELECT ID, ShipDate__c From LineItem__c WHERE ShipDate__c >=: eDate ORDER BY ShipDate__c';
        
        system.debug('===q=324=='+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute (Database.BatchableContext BC, List<sobject> q) {
        system.debug('===q==='+q);
        set<id> getIds = new set<Id>();
        for(sObject str : q){
            getIds.add(str.Id);  
            system.debug('===getIds==='+getIds);  
        }
        List<CommissionManagerSettings__C> customList = new List<CommissionManagerSettings__C>([select Name,Check__C From CommissionManagerSettings__C Where Name = 'CheckBatch' AND Check__C = true Limit 1]);
        system.debug('===customList==='+customList);
        if(customList.size() > 0)
        {
            //mylistitems = [Select id,Date_Accepted__c,Accountid__c,QuantityShipped__c,UnitPrice__c,Productid__c,Commission_Pay_Date__c,Name,BUID__c,ShipDate__c,Extended__c,Opportunityid__c,Commissionable_Unit_Price__c,Total_Commission__c  From LineItem__c  WHERE Id IN : getIds AND Opportunityid__c = null AND IsShiped__c = True AND OrderType__c != 'SB' ORDER BY ShipDate__c];//getting all related invoices
            //Commented by Paritosh : edited the soql to sort the list correctly.
            mylistitems = [Select id,Date_Accepted__c,Accountid__c,QuantityShipped__c,UnitPrice__c,Productid__c,Commission_Pay_Date__c,Name,BUID__c,ShipDate__c,Extended__c,Opportunityid__c,Commissionable_Unit_Price__c,Total_Commission__c  From LineItem__c  WHERE Id IN : getIds AND Opportunityid__c = null AND IsShiped__c = True AND OrderType__c != 'SB' ORDER BY OpportunityId__r.CreatedDate, ShipDate__c ASC];
            
            system.debug('===mylistitems==='+mylistitems);
            invidsbyprod=new  Map<id,set<id>>(); //Storing prod id's with opportunity id
            invidsbyaddship=new  Map<id,set<id>>(); //Storing addshipto id's with oppotunity id
            oppo_prod_overrideprice=new Map<id,decimal>(); //Storing override price of oppotunity product with opp. id
            Set<id> accids=new Set<id>(); //Getting additional_ship_to ids from invoices 
            Set<id> prodids=new Set<id>(); //Getting opportunity_line_item ids  from invoices
            boolean nullpoint1=false; boolean nullpoint2=false;
            //Checking size of q
            if(mylistitems.size() >0 &&  mylistitems!= null){
                for(LineItem__c qitem: mylistitems){        
                    accids.add(qitem.Accountid__c); //Making set of addship's id with related invoice id's
                    system.debug('===accids==='+accids);        
                    prodids.add(qitem.Productid__c); //Making set of addship's id with related invoice id's
                    system.debug('===prodids==='+prodids);
                }
            }
            list<OpportunityLineItem> invprod=[select Opportunityid,Product2id,Override_Unit_Price__c  from OpportunityLineItem  where  Commission_Approval_Status__c = 'Approved' and     PricebookEntry.Product2id in : prodids ];    //getting list of invoice products
            system.debug('===invprod==='+invprod);
            //Checking size of invprod list
            if(invprod.size()>0 && invprod!= null){ 
                for(OpportunityLineItem invprodobj: invprod){
                    if(invidsbyprod.get(invprodobj.Opportunityid)==null){ //If any oppor. product is not stored in map with related oppr. id
                        invidsbyprod.put(invprodobj.Opportunityid,new set<id>());
                        system.debug('===invidsbyprod==='+invidsbyprod);    
                        invidsbyprod.get(invprodobj.Opportunityid).add(invprodobj.Product2id); //Then add new oppr. prod. to set with the corresponding opportunity id
                        system.debug('===invidsbyprod==='+invidsbyprod);
                    }
                    else{
                        invidsbyprod.get(invprodobj.Opportunityid).add(invprodobj.Product2id); //If already any oppr. product exist in map then also add this one with the set
                        system.debug('===invidsbyprod==='+invidsbyprod);
                    }
                    oppo_prod_overrideprice.put(invprodobj.Product2id,invprodobj.Override_Unit_Price__c); //Making map of oppr. product's override prices with related product id
                    system.debug('===oppo_prod_overrideprice==='+oppo_prod_overrideprice);
                }
            }
            list<Additional_Ship_To__c> addship=[select Opportunityid__c,account__c  from Additional_Ship_To__c where Commission_Approval_Status__c ='Approved' and account__c in:accids ];    //getting related additional ship obj list
            system.debug('===addship==='+addship);
            //Checking size of add ship to list
            if(addship.size()>0 && addship!= null){
                for(Additional_Ship_To__c invaddship: addship){
                    if(invidsbyaddship.get(invaddship.Opportunityid__c)==null){ //If any additional ship to is not stored in map with related oppr. id
                        invidsbyaddship.put(invaddship.Opportunityid__c,new set<id>());
                        system.debug('===invidsbyaddship==='+invidsbyaddship);
                        invidsbyaddship.get(invaddship.Opportunityid__c).add(invaddship.account__c); //Then add new additional ship to, to set with the corresponding opportunity id
                        system.debug('===invidsbyaddship==='+invidsbyaddship);
                    }
                    else{
                        invidsbyaddship.get(invaddship.Opportunityid__c).add(invaddship.account__c); //If already any  additional ship to,  exist in map then also add this one with the set
                        system.debug('===invidsbyaddship==='+invidsbyaddship);
                    }
                }
            }

            list<opportunity> opplist=new list<opportunity>();// List of opportunities
            
            //Getting related opportunities fullfill criteria 1,2,7 and 8
            opplist=[Select id,Name,Account.BU_ID__c,CloseDate,Total_New_Business__c,Clock_Start_Date__c,Clock_End_date__c,OPP_Approval_Status__c,Business_Unit__c,accountid From Opportunity WHERE   Opportunity.OPP_Approval_Status__c != 'Denied' AND  id in : invidsbyprod.keyset()  AND  (id in: invidsbyaddship.keyset() or accountid in: accids ) And StageName=: 'Closed Won'];//getting all related oppotunities    And StageName=: 'Closed Won'
            system.debug('===opplist==='+opplist);
            if(mylistitems.size()>0 && mylistitems != null){
                
                //Loop for connecting invoices to related opportunities
                for(LineItem__c lineobj: mylistitems){ 
                    
                    if(opplist.size()>0 &&  opplist != null){                        
                        //Loop of all opprtunities
                        for (Opportunity oppobj : opplist) { 
                           
                            system.debug('==============================================');
                            //Checking the criteria no. 4 and updated condition i.e. oppobj.Clock_End_date__c.addmonths(-6)<lineobj.ShipDate__c
        //recent changes : (oppobj.Clock_Start_Date__c <= lineobj.ShipDate__c && lineobj.ShipDate__c< oppobj.Clock_End_date__c && oppobj.Clock_End_date__c > datetime.now())
                            if(lineobj != null && oppobj !=null && ((oppobj.Clock_Start_Date__c == null && oppobj.Clock_End_date__c == null)|| (oppobj.Clock_Start_Date__c <= lineobj.ShipDate__c && lineobj.ShipDate__c< oppobj.Clock_End_date__c && oppobj.Clock_End_date__c > datetime.now()))){
                             system.debug('+++++++++++++++++++++++++++++++++++++++++++++');    
                                //Checking criteria no. 3 & Opportunity Product has to be same as invoice Product And Opportunity Account (or Additional ship to account) has to be same as invoice account
                                try{
                                    
                                    if(invidsbyaddship.get(oppobj.id)!=null ){
                                        nullpoint1 =(invidsbyaddship.get(oppobj.id).contains(lineobj.Accountid__c) || lineobj.Accountid__c == oppobj.Accountid);
                                        system.debug('===nullpoint1=108=='+nullpoint1);
                                    } else {
                                        nullpoint1 = (lineobj.Accountid__c == oppobj.Accountid);
                                        system.debug('===nullpoint1=111=='+nullpoint1);
                                    }
                                }
                                finally{
                                    
                                    // if(lineobj.BUID__c == oppobj.Account.BU_ID__c && invidsbyprod.get(oppobj.id).contains(lineobj.Productid__c) && nullpoint1 && oppobj.CloseDate.addmonths(-6) < lineobj.ShipDate__c)
                                    if(lineobj.BUID__c == oppobj.Account.BU_ID__c && invidsbyprod.get(oppobj.id).contains(lineobj.Productid__c) && nullpoint1 && Datetime.now().addmonths(-12) < lineobj.ShipDate__c)
                                        
                                    {
                                        lineobj.Opportunityid__c = oppobj.id; //Assigning oppor. id to relate invoice
                                        lineobj.Date_Accepted__c = Datetime.now(); //Accepting order and assgning date to date accepted
                                        
                                        //Updated requirement of commisionable unit price field of invoice 
                                        opp_prod_overprice = oppo_prod_overrideprice.get(lineobj.Productid__c); 
                                        if(opp_prod_overprice > 0){
                                            lineobj.Commissionable_Unit_Price__c = opp_prod_overprice ;
                                            system.debug('===lineobj.Commissionable_Unit_Price__c=127=='+lineobj.Commissionable_Unit_Price__c);
                                        }
                                        else{
                                            lineobj.Commissionable_Unit_Price__c = lineobj.UnitPrice__c;
                                            system.debug('===lineobj.Commissionable_Unit_Price__c=131=='+lineobj.Commissionable_Unit_Price__c);
                                        }
                                        
                                        //Batch class req. 1:Set Opportunity.Total_New_Business__c = Sum of all invoices (Sum of (lineobj.QuantityShipped__c * lineobj.Commissionable_Unit_Price__c)).
                                        if(oppobj.Total_New_Business__c != null){
                                            oppobj.Total_New_Business__c = oppobj.Total_New_Business__c + (decimal)(lineobj.QuantityShipped__c * lineobj.Commissionable_Unit_Price__c); //If map of Total_New_Business__c does have any value related to oppr. id then add this invoice amount 
                                            system.debug('===oppobj.Total_New_Business__c=137=='+oppobj.Total_New_Business__c);
                                        }
                                        else{
                                            oppobj.Total_New_Business__c =(decimal)(lineobj.QuantityShipped__c * lineobj.Commissionable_Unit_Price__c); //Else direct put the extended value with oppr. id
                                            system.debug('===oppobj.Total_New_Business__c=141=='+oppobj.Total_New_Business__c);
                                        }                           
                                        
                                        // Batch requirement 2:Set Opportunity. OPP_Approval_Status__c = Under Threshold, 
                                        If ((((oppobj.Business_Unit__c == 'GEMS_NA' || oppobj.Business_Unit__c == 'GEMS_CANADA') && oppobj.Total_New_Business__c < 10000.00) || (oppobj.Business_Unit__c =='GEMS_EU' && oppobj.Total_New_Business__c < 7000.00)) && oppobj.OPP_Approval_Status__c != 'Approved for All' && oppobj.OPP_Approval_Status__c != 'Approved for TM Only' && oppobj.OPP_Approval_Status__c != 'Approved for PM Only'){
                                            oppobj.OPP_Approval_Status__c = 'Under Threshold';
                                            system.debug('===oppobj.OPP_Approval_Status__c==='+oppobj.OPP_Approval_Status__c);
                                        }
                                        
                                        // Batch requirement 2:Set Opportunity. OPP_Approval_Status__c = Pending Approval, & batch requirement 3:Set Clock_Start_Date__c, and Clock_End_date__c.
                                        else If ((((oppobj.Business_Unit__c == 'GEMS_NA' || oppobj.Business_Unit__c == 'GEMS_CANADA') && oppobj.Total_New_Business__c > 10000.00) || (oppobj.Business_Unit__c =='GEMS_EU' && oppobj.Total_New_Business__c > 7000.00)) && (oppobj.OPP_Approval_Status__c != 'Approved for All' && oppobj.OPP_Approval_Status__c != 'Approved for TM Only' && oppobj.OPP_Approval_Status__c != 'Approved for PM Only' && oppobj.OPP_Approval_Status__c != 'Pending Approval')){
                                            //date d= lineobj.ShipDate__c;
                                            oppobj.OPP_Approval_Status__c = 'Pending Approval';
                                            system.debug('===oppobj.OPP_Approval_Status__c==='+oppobj.OPP_Approval_Status__c);
                                            oppobj.Clock_Start_Date__c = Date.newinstance(lineobj.ShipDate__c.year(), lineobj.ShipDate__c.month(), lineobj.ShipDate__c.day());
                                            system.debug('===oppobj.Clock_Start_Date__c==='+oppobj.Clock_Start_Date__c);
                                            oppobj.Clock_End_date__c = Date.newinstance(lineobj.ShipDate__c.year(), lineobj.ShipDate__c.month(), lineobj.ShipDate__c.day()).addmonths(16);
                                            system.debug('===oppobj.Clock_End_date__c==='+oppobj.Clock_End_date__c);
                                        }
                                        
                                        //Updated requirement of updating Commission_Pay_Date__c field of invoice
                                        if(oppobj.OPP_Approval_Status__c == 'Approved for All' || oppobj.OPP_Approval_Status__c == 'Approved for TM Only' || oppobj.OPP_Approval_Status__c == 'Approved for PM Only'){
                                            DateTime dT = datetime.now();
                                            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                                            lineobj.Commission_Pay_Date__c = myDate;
                                        }  
                                    } 
                                }
                            }
                        }                        
                    }
                }               
            }  
            //Check if List is empty or not
            if (opplist != null && opplist.size()>0) { //Check if List is empty or not
                    Database.update(opplist); //Update the Records
                    system.debug('===opplist==='+opplist);
            }
            //Check if List is empty or not
            if (mylistitems!= null && mylistitems.size()>0) {
                    Database.update(mylistitems); //Update the Records
                    system.debug('===mylistitems==='+mylistitems);
            }
            
        }
    }
    //Finish Method
    global void finish(Database.BatchableContext BC){ //Updation of opportunity and invoice lists
    }
}