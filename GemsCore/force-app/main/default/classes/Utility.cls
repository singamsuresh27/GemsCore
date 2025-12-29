public with sharing class Utility 
{
  public static String GetCharacterFromASCII(integer Num)
    {   
      String Character='';
      if(Num==65)
        Character='A';
      if(Num==66)
        Character='B';
    if(Num==67)
        Character='C';
      if(Num==68)
        Character='D';
      if(Num==69)
        Character='E';
      if(Num==70)
        Character='F';  
      if(Num==71)
        Character='G';
      if(Num==72)
        Character='H';
      if(Num==73)
        Character='I';
      if(Num==74)
        Character='J';
      if(Num==75)
        Character='K';
      if(Num==76)
        Character='L';
      if(Num==77)
        Character='M';
      if(Num==78)
        Character='N';
      if(Num==79)
        Character='O';
      if(Num==80)
        Character='P';
      if(Num==81)
        Character='Q';
      if(Num==82)
        Character='R';
      if(Num==83)
        Character='S';
      if(Num==84)
        Character='T';
      if(Num==85)
        Character='U';
      if(Num==86)
        Character='V';
      if(Num==87)
        Character='W';
      if(Num==88)
        Character='X';
      if(Num==89)
        Character='Y';
      if(Num==90)
        Character='Z';
                                                      
      return   Character;
    }
  
  public static List<RecordType> NBORecordTypeList(){
    List<RecordType> RecordTypeList=[Select SobjectType, Name,DeveloperName, IsActive, Id From RecordType where SObjectType='NBO_Forms__c' and isActive=true];
    return RecordTypeList;
  }
  
  public static string getNBOType(string RecordTypeDevname,Map<String,NBO_Form_Record_Type_Name__c> mapRecordType){
    string NBOType;
    //if(mapRecordType.get('Level_Float').Record_Type_Dev_Name__c==RecordTypeDevName){
    //  NBOType='FLT';
    //}
    if(mapRecordType.get('NBO_Flow').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='FLO';
    }
    if(mapRecordType.get('Pressure').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='PRE';
    }
    if(mapRecordType.get('Temp_Cont_Switch').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='TSW';
    }
    if(mapRecordType.get('Valve').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='VAL';
    }
    if(mapRecordType.get('Level_Continuous').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='LEC';
    }
    //Changes as on 25th May 2012 as per Gazi by Anand
    if((mapRecordType.get('Level_Elect_Switch').Record_Type_Dev_Name__c==RecordTypeDevName) || 
    (mapRecordType.get('Level_Float').Record_Type_Dev_Name__c==RecordTypeDevName)){
      NBOType='PTL';
    }
    if(mapRecordType.get('Fluidic_Systems').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='FLD';
    }
        if(mapRecordType.get('Fluid_Quality').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='FCM';
    }  
        if(mapRecordType.get('CSP').Record_Type_Dev_Name__c==RecordTypeDevName){
      NBOType='CSP';
    }
    return NBOType;
  }  
  
  public static string getRevisionNumber(string key){
    Map<string,string> MapRevision=new Map<string,string>{'A'=>'B','B'=>'C','C'=>'D','D'=>'E','E'=>'F'
      ,'F'=>'G','G'=>'H','H'=>'I','I'=>'J','J'=>'K','K'=>'L','L'=>'M','M'=>'N','N'=>'O','O'=>'P',
      'P'=>'Q','Q'=>'R','R'=>'S','S'=>'T','T'=>'U','U'=>'V','V'=>'W','W'=>'X','X'=>'Y','Y'=>'Z','Z'=>'A'};
    
    string val=MapRevision.get(key);
    return val;
  }
  
}