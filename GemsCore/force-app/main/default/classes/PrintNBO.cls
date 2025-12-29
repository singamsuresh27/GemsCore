public with sharing class PrintNBO {
    public NBO_Forms__c nbo{get;set;}
    public string nboId{get;set;}
    public string NBOLabel{get;set;}
    
    public PrintNBO(ApexPages.StandardController stdController){
        
        nboId=stdController.getId();
        if(nboId==null || nboId==''){
            nboId=ApexPages.currentPage().getParameters().get('Id');
        }
        if(nboId!=null && nboId!=''){
            nbo=[Select Opportunity__r.Account.Name,Opportunity__r.Account.Phone,NBO_Complete_Date__c, Mounting_R__c,
            Opportunity__r.Account.ShippingStreet,Opportunity__r.Account.ShippingCity, Estimated_Quantity__c,
            Opportunity__r.Account.ShippingState,Opportunity__r.Account.ShippingCountry,
            Opportunity__r.name,Opportunity__r.Market__c,Opportunity__r.LeadSource, EMI__c ,
            Opportunity__r.Product_Model__c,Opportunity__r.Product_Model__r.Product_Type__c,
            Opportunity__r.TotalOpportunityQuantity,Opportunity__r.Unit_Price__c , Boiling_Water__c,
            Opportunity__r.Amount,Opportunity__r.Application_Detail__c,RecordType.Name, L3__c,
            RecordType.DeveloperName,Wire_Guage__c, Wire_Config3__c, Wire_Config2__c, L4__c,
            Wetted_Material__c, Voltage__c, Voltage_Unit__c, Voltage_High__c, Viscosity__c, 
            Vibration__c, Vibration_At__c, Vapor__c, Valve_Body_Material__c, Unit_of_Measure__c, 
            Tolerance_Accuracy__c, Time_Delay_Increasing__c, Time_Delay_Increasing_By__c, Wire_Configuration__c,
            Time_Delay_Decreasing__c, Time_Delay_Decreasing_By__c, Termination__c, Terminal_Pin__c, L1__c ,
            Tank_Material__c, Tank_Depth__c, SystemModstamp, Switch_Load_Voltage__c, Tstat_Logic__c ,
            Switch_Load_Current__c, Subject_to_Vibration__c, Sub_Sensor_Type__c, Strip_Length__c, L6__c, L5__c,
            Stop_Port_Configuration__c, Stock_Prototype__c, Stock_Prototype_QTY__c, Final_end_use_location__c,
            Stock_Prototype_PN__c, Specific_Load__c, Specific_Gravity__c, Special_Options__c, Flow_Rate_Typical__c,
            Source__c, Solenoid__c, Sink__c, Shock__c, Sheath_Length__c, Sheath_Length_Unit__c, 
            Sheat_Material__c, Set_Point__c, Set_Point_Tolerance__c, Set_Point_Direction__c, Cycle_Frequency__c,
            Sensor_Type__c, Sensor_Cable__c, Revision_Number__c, Resistance_C__c, Resistance_At_25__c, 
            Relay__c, RecordTypeId, Ramp_Unit_Measure__c, Ramp_Rate__c, Quotation_Due_Date__c, 
            Quotation_Costs__c, Prototype_Promise_date__c, Prototype_Due_Date__c, Min_Off_Time__c,
            Prototype_Delivery_date__c, Project_Manager__c, Project_Engineer__c, Problem__c, Special_power_features__c,
            Pressure_Range__c, Pressure_Port__c, Pressure_Out__c, Pressure_In__c, Pressure_Drop__c, 
            Pressure_Drop_At__c, Pressure_Datum__c, Port_Size__c, Plunger_Seal_Material__c, Closed_or_Open_Loop__c,
            AF_Score__c,SDR_Color__c, SDR_Card_Color__c, PLC__c, PIM_Score__c, Output__c, Output_Voltage_Unit__c, Flow_Rate_Min__c,
            Output_Voltage_To__c, Output_Voltage_From__c, Output_Type__c, Output_Cable__c, Seal_Material__c,
            Out_Port_Size__c, Other__c, Other_Thermocouple__c, Other_Sheath_Material__c, Sheath_Diameter__c ,
            Other_Sheath_Diameter__c, Other_Sensor_Type__c, Other_Resistance__c, Other_Requirements__c, 
            Other_Plunger_Seal_Material__c, Other_Output_Cable__c, Other_O_Ring_Material__c, Allowable_Pressure_Drop__c,
            Other_Mounting__c, Other_Housing_Style__c, Other_Housing_Material__c, Other_DC_Volt__c, Saety_Critical_Device__c,
            Other_Circuit__c, Other_Bottle_Thickness__c, Other_Bottle_Material__c, Other_Body_Material__c,
             Other_Approvals__c, Other_AC_Volt__c, Orifice_Diameter_Stop__c, Orifice_Diameter_Body__c, Tank_Thickness__c,
             Opportunity__c, Opportunity_Number__c, Operating_Voltage_DC__c, Operating_Voltage_AC__c, 
             Ope_Temp_Range_To__c, Ope_Temp_Range_From__c, O_Ring_Material__c, OPR_Temperature__c, Bubbles_or_Foam__c ,
             OPR_Pressure__c, OPR_Flow_Rate__c, Normal_Voltage__c, Normal_Output_Voltage__c, Monitoring_Type__c,
             Normal_Oper_Pressure__c, Name, NBO_Status__c, NBO_Promise_Date__c, NBO_Number_Formula__c, Suggested_Material__c,
             NBO_Due_Date__c, Mounting__c, Moisture_Exposed__c, Min_Voltage__c, Min_Output_Voltage__c, Reflective_Surfaces__c,
             Min_Output_Current__c, Min_Media_Temperature__c, Min_Input_Current__c, Min_Holding_Volt__c, 
             Min_Ambient_Temperature__c, Media__c, Media_Type__c, Media_Resistivity__c, Burst_Pressure__c,
             Media_Highly_Reflective__c, Media_Conductivity__c, Measurement_Range__c, Max_Wattage__c, Ambient_Light__c,
             Max_Voltage__c, Max_Temperature__c, Max_Pull_In_Volt__c, Max_Pressure__c, Level_of_Filtration__c,
             Max_Output_Voltage__c, Max_Output_Current__c, Max_Input_Current__c, Max_Flow_Rate__c, MOPD__c,
             Max_Coil_Temp_Rating__c, Max_Ambient_Temperature__c, Male_Bottom_Porting__c, Typical_Media_Temp__c,
             MSCRM_Rev_No__c, MSCRM_NBO_No__c, MIN_Pressure__c, MAX_Media_Temperature__c, SF_Legacy_ID__c,
             MAX_Back_Pressure__c, Logic__c, Level_Points_Per_Bottle__c, Legacy_ID__c, Leadwire_Type__c, Current_Limited__c,
             Leadwire_Length__c, Leadwair_Length_Unit__c, Lead_Wire_Length__c, LastModifiedDate, Pressure_Spikes__c,
             LastModifiedById, LastActivityDate, Junction_Type__c, IsDeleted, Input_Voltage_Unit__c, Proof_Pressure__c,
             In_Port_Size__c, Id, Housing_Style__c, Housing_PN__c, Housing_Material__c, Function_State__c,
              Foam_Agitation__c, Flying_Leads__c, Fluid__c, Fluid_Temperature__c, Fluid_Temp_Unit__c, Port_Thread_Fittings__c,
               Flow_At_Stop_Orifice__c, Flow_At_Body_Orifice__c, Flat_Side_for_Sensor__c, Regulated__c, Estimated_Unit_Price__c,
               Female_Bottom_Port__c, Feasibility_Info__c, Feasibility_Due_Date__c, External_Exposed__c, Estimated_Amount__c,
               Evaluation_Test__c, Evaluation_Due_date__c, Engineered_Prototype__c, Switching_Voltage__c, L2__c,
               Engineered_Prototype_QTY__c, Engineered_Prototype_PN__c, Electrical_Termination__c, Ramp_Rate_Falling__c,
               Electrical_Requirements__c, Electrical_Connection__c, Electrical_Configuration__c, Specs__c, Proximity_to_Heat_Source__c,
               Duration__c, Drawing_Required__c, Drawing_Due_Date1__c, Drawing_Attached__c, Maintenance_Procedure__c, Max_On_Time__c,
               Digital_Req__c, Diameter__c, Dead_Band__c, Cv_Stop__c, Cv_Body__c, Current__c, Alternate_Technologies_Considered__c,
               Current_In_Rush__c, CurrencyIsoCode, CreatedDate, CreatedById, Connector_Type_Or_PN__c, Criticality_in_system__c,
                Conn_Manufacturer__c, Condensation_prism__c, Competitor__c, Competitor_PN__c, Competitor_Drawing__c, Coil_Insulation_Type__c, 
               Close_to_Heat__c, Clone_Record__c, Circuit__c, Chief_Engineer__c, Bottle_Thickness__c, Life_expectancy__c,
               Bottle_Material__c, Bottle_Geometry__c, Body_Port_Orientation__c, Switching_Current_steadystate__c, Validation_testing_to_be_done__c,
               Body_Port_Configuration__c, Body_Configuration__c, Approvals_Needed_By__c, Approval__c, Problem_to_Solve__c,
               Amb_Temp__c, Amb_Temp_Unit__c, Additional_Project_Manager__c, Actuation__c, Accuracy__c,Revenue_Stream__c,Customer_Driver__c,
               Sub_Market__c,Services_Required__c,Customer_Supplied__c,Proposal_Requirements__c, Switching_Current_inrush__c
               From NBO_Forms__c where id=:nboId];
        }
    }   
    
    public Pagereference RedirecttoNBOPage(){
        string NewPath;
        Map<String,NBO_Form_Record_Type_Name__c> mapRecordType = NBO_Form_Record_Type_Name__c.getAll();
                
        if(mapRecordType.get('Level_Float').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_FTL?id='+nboId;
        }
        if(mapRecordType.get('NBO_Flow').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_FLO?id='+nboId;
        }
        if(mapRecordType.get('Pressure').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_PRE?id='+nboId;
        }
        if(mapRecordType.get('Temp_Cont_Switch').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_TSW?id='+nboId;
        }
        if(mapRecordType.get('Valve').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_VAL?id='+nboId;
        }
        if(mapRecordType.get('Level_Continuous').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_LEC?id='+nboId;
        }
        if(mapRecordType.get('Level_Elect_Switch').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_LES?id='+nboId;
        }
        if(mapRecordType.get('Fluidic_Systems').Record_Type_Dev_Name__c==nbo.RecordType.DeveloperName){
            NewPath='/apex/PrintNBO_FLD?id='+nboId;
        }
         PageReference MainPage;
         MainPage= new PageReference(NewPath);
         MainPage.getParameters().put('nooverride', '1');
         MainPage.setRedirect(true);
         return MainPage;   
    }
}