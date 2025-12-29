public with sharing class SObjectHelper {
  
  // Create SObject of given type.
  public static sObject createObject(String typeName) {
          Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
          if (targetType == null) {
              // throw an exception
          }
          
          // Instantiate an sObject with the type passed in as an argument
          //  at run time.
          return targetType.newSObject(); 
    }
    
    // Get Field Select Option list of given sObject.
    public static List<SelectOption> createFieldOptionsList(SObject sobj){
      List<SelectOption> optionsList = new List<SelectOption>();
          Map<String, Schema.SobjectField> fields = sobj.getSObjectType().getDescribe().fields.getMap();
          for (String s : fields.keySet()) {
            if(fields.get(s).getDescribe().isAccessible()){
                System.debug('Name: '+fields.get(s).getDescribe().getName()+'\tLabel: '+fields.get(s).getDescribe().getLabel()+'\n');
                  optionsList.add(new SelectOption(fields.get(s).getDescribe().getName(), fields.get(s).getDescribe().getLabel()));
            }
          }
          // Sort and return list items.
          sortSelectOptionList(optionsList);
          return optionsList;
  }
  
  // Get Fields API name list of given sObject.
  public static List<String> getObjectFieldsList(SObject sobj){
      List<String> fieldsList = new List<String>();
          Map<String, Schema.SobjectField> fields = sobj.getSObjectType().getDescribe().fields.getMap();
          for (String s : fields.keySet()) {
            if(fields.get(s).getDescribe().isAccessible()){
                fieldsList.add(fields.get(s).getDescribe().getName());
                
                // Field is of reference type? Get Its name also in query.
                if(fields.get(s).getDescribe().getType() == Schema.DisplayType.Reference){
                    System.debug('Relationship Name: '+fields.get(s).getDescribe().getRelationshipName());
                    if(fields.get(s).getDescribe().getRelationshipName() != null)
                    fieldsList.add(fields.get(s).getDescribe().getRelationshipName() + '.Name');
                }
            }
          }
          return fieldsList;
  }  
  
  // Get Type of given field of a sobject.
  public static Schema.DescribeFieldResult getFieldType(SObject sobj, String field_api_name){
      Map<String, Schema.SobjectField> fields = sobj.getSObjectType().getDescribe().fields.getMap();
      Schema.DescribeFieldResult fieldTypeResult = fields.get(field_api_name).getDescribe();
      return fieldTypeResult;
  }
  
  
  // Convert given type of field value of a sobject to String format.
  public static String convertFieldToString(Schema.DescribeFieldResult field_result, SObject sobj, String field){
      if(field_result.getType() == Schema.DisplayType.Date){
          return sobj.get(field) != null ? ((Date)sobj.get(field)).format() : '';
      }
      else if(field_result.getType() == Schema.DisplayType.DateTime){
          return sobj.get(field) != null ? ((DateTime)sobj.get(field)).format() : '';
      }
      return String.valueOf(sobj.get(field));
  }
  
  // Sort SelectOption List.
  public static void sortSelectOptionList(List<SelectOption> lstItems){
        List<String> lstItemByName = new List<String>();
        Map<String, String> mapValueByItemName = new Map<String, String>();
        for(SelectOption sc : lstItems){
          lstItemByName.add(sc.getLabel());
          mapValueByItemName.put(sc.getLabel(), sc.getValue());
        } 
        //lstItemByName.sort();
        
        // Sort List items.
        for(integer i=0 ; i<lstItemByName.size()-1;i++){
              for(integer j=i+1 ; j<lstItemByName.size();j++){                            
                  if(lstItemByName[i].toLowerCase().compareTo(lstItemByName[j].toLowerCase())> 0){
                        string str = lstItemByName[i];
                        lstItemByName[i] = lstItemByName[j];
                        lstItemByName[j] = str;
                  }
              } 
          }
        // Clear all existing items.
        lstItems.clear();
        // Add all items in sorted order.
        for(String itemName : lstItemByName)
          lstItems.add(new SelectOption(mapValueByItemName.get(itemName), itemName));
        
    }
    
    public static  void sortStringItems(List<String> lstItems){
        // Sort List items.
        for(integer i=0 ; i<lstItems.size()-1;i++){
              for(integer j=i+1 ; j<lstItems.size();j++){                            
                  if(lstItems[i].toLowerCase().compareTo(lstItems[j].toLowerCase())> 0){
                        string str = lstItems[i];
                        lstItems[i] = lstItems[j];
                        lstItems[j] = str;
                  }
              } 
        }
    }
    
}