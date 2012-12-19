/*  Controller class which is to extract the Field Comparison Metadata report into Excel format
*	
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				  Amol Chaudhari		10/12/2012			Intial Draft 
*/
public with sharing class FieldMetadataComparisonExtractor {
    //Properties 
    public String sourceObjectName;
    public List<SelectOption> targetObjectList{get; set;}
    public List<SelectOption> sourceObjectList{get;set;}
    public String targetObjectName;
    list<FieldComparisonLog> fieldComparisonLogList; 
   
    //sr No variable
    public Integer srNo{get;set;} 
        
    private final string LABEL = 'Label__c';
    private final string API_NAME = 'API_Name__c';
    private final string BYTE_LENGTH = 'Byte_Length__c';
    private final string CAN_CREATE = 'Can_Create__c';
    private final string CAN_UPDATE = 'Can_Update__c';
    private final string CAN_UPSERT = 'Can_Upsert__c';
    private final string CONTAINS_HTML_DATA = 'Contains_HTML_Data__c';
    private final string DIGITS = 'Digits__c';
    private final string FIELD_CATEGORY = 'Field_Category__c';
    private final string FORMULAE_USED = 'Formula_Used__c';
    private final string HAS_MULTIPLE_SOBJECT_PARENTS = 'Has_Multiple_SObject_Parents__c';
    private final string HELP_TEXT = 'Help_Text__c';
    private final string AUTO_NUMBER = 'Is_Auto_Number__c';
    private final string CASE_SENSITIVE = 'Is_Case_Sensitive__c';
    private final string DEPENDENT_PICKLIST = 'Is_Dependent_Picklist__c';
    private final string DEPRECATED = 'Is_Deprecated__c';
    private final string EXTERNAL_ID = 'Is_External_ID__c';
    private final string FIELD_VISIBLE = 'Is_Field_Visible__c';
    private final string REQUIRED = 'Is_Required__c';
    private final string UNIQUE = 'Is_Unique__c';
    private final string LENGTH = 'Length__c';
    private final string PARENT_OBJECT = 'Parent_Object__c';
    private final string PICKLIST_VALUES = 'Picklist_Values__c';
    private final string PRECISION = 'Precision__c';
    private final string RELATIONSHIP_NAME = 'Relationship_Name__c';
    private final string SCALE = 'Scale__c';
    private final string SOAP_TYPE = 'Soap_Type__c';
    private final string TYPE = 'Type__c';
    private final string USE_IN_GROUP_BY_CLAUSE = 'Use_in_Group_By_Clause__c';
    private final string USE_IN_ORDER_BY_CLAUSE = 'Use_in_Order_By_Clause__c';
    private final string USE_IN_WHERE_CLAUSE = 'Use_in_Where_Clause__c';
    private final string DEFAULT_VALUE = 'Default_Value__c';
    
    private final string NO_FIELD_MATCH_FOUND = 'No Field Match Found';
    private final string COOKIE_FIELD_TARGET = 'targetField';
    private final string COOKIE_FIELD_SOURCE = 'sourceField';
    private final string TAB_NAME = 'tabName';
    private final string FIELD_COMPARISON = 'Field Comparison';
    private final string TARGET_BLANK = 'targetBlank'; 
    private final string SOURCE_BLANK= 'sourceBlank';
    private final string NA = 'NA';
    private final string HTTPS = 'https://';
    private final string APEX_METADATAREPORT = '/apex/MetadataComparisionReport';
    private String REDIRECT_BATCH_PROCESSED;
    map<String,set<string>> mapObject{get;set;}
    
    //getting the list of Field Comparison Log list of inner which is to be binded for VF report 
    public list<FieldComparisonLog> getFieldComparisonLogList(String pSrc,String pTarget){
    	fieldMetadataComparison(pSrc,pTarget);
        return fieldComparisonLogList;
    }

    // extract the metadata to xls format
    public Pagereference fieldMetadataComparison(String pSrcObject,String pTargetObj) {
        
     map<Double,String> mapSourceId = new map<Double,String>();
     map<Double,String> mapTargetId = new map<Double,String>();
      map<String,Double> mapMatchedObjectPairsToUpdateCompSource = new map<String,Double>();
     
     for(Object_Information__c objObjectInfo : [select Id,
                                                Comparison_Pair__c,API_Name__c
                                                from Object_Information__c
                                                where Org_Id__c=:Userinfo.getOrganizationId()]){
        mapSourceId.put(objObjectInfo.Comparison_Pair__c,objObjectInfo.API_Name__c);
     }
     
     for(Object_Information__c objObjectInfo : [select Id,
                                                Comparison_Pair__c,API_Name__c
                                                from Object_Information__c
                                                where Org_Id__c!=:Userinfo.getOrganizationId()]){
        mapTargetId.put(objObjectInfo.Comparison_Pair__c,objObjectInfo.API_Name__c);
     }
     
     for(Double objmapTargetId : mapTargetId.keySet()){
      
       String s =mapTargetId.get(objmapTargetId)+'-'+mapSourceId.get(objmapTargetId);
        mapMatchedObjectPairsToUpdateCompSource.put(s,objmapTargetId);
     }
        
    //list of all matching fields from comparison log 
    list<Comparison_Log__c> matchingSourceFieldsList = new list<Comparison_Log__c>();
    //list of all fields whicha are not matching in comparison log
    list<Comparison_Log__c> notMatchingSourceFieldsList = new list<Comparison_Log__c>();
    //map of source field vs list of all comparison log list
    map<Id,list<Comparison_Log__c>> matchingsourceFieldsMap = new map<Id,list<Comparison_Log__c>>();
    //map of source field vs related Field_Information__c
    map<Id,Field_Information__c> sourceFieldInfoMap = new map<Id,Field_Information__c>();
    //map of target field vs related Field_Information__c
    map<Id,Field_Information__c> targetFieldInfoMap = new map<Id,Field_Information__c>();
    //map of source field vs target field
    map<Id,Id> matchesSourceTarget = new map<Id,Id>();
    //list of inner class which is to be bind with UI
    fieldComparisonLogList = new list<FieldComparisonLog>();
    //set of not matching source fields from comparison log
    set<Id> notMatchingSourceFieldsSet = new set<Id>();
    //set of not matching target fields
    set<Id> notMatchingTargetFieldSet = new set<Id>();
    //list of not matching source fields information from Field Information
    list<Field_Information__c> UnMatchedFieldsInfoList = new list<Field_Information__c>();
    //set of target objects from Object Information
    set<Id> targetObjectSet = new set<Id>();
    //lsit of not matching target fields information from Field Information
    list<Field_Information__c> UnMatchedTargetFieldsInfoList = new list<Field_Information__c>();
     
      String stringPair = pTargetObj+'-'+pSrcObject;
        
        //list of all matching fields
        matchingSourceFieldsList=[select Id,
                                  Attribute__c,
                                  ComparisonSourceField__c,
                                  Match__c,
                                  SourceFieldObject__c,
                                  TargetFieldObject__c,
                                  ComparisonType__c
                                  from Comparison_Log__c
                                  where ComparisonType__c=:FIELD_COMPARISON
                                  and Attribute__c!=:NO_FIELD_MATCH_FOUND
                                  and TargetFieldObject__c =:pTargetObj
                                  and SourceFieldObject__c=:pSrcObject];                   
        system.debug('matchingSourceFieldsList...........'+matchingSourceFieldsList.size());
                                  
        //checking for unmatched fields from Comparison Log
        notMatchingSourceFieldsList=[select Id,
                                     Attribute__c,
                                     ComparisonSourceField__c,
                                     Match__c,
                                     SourceFieldObject__c,
                                     TargetFieldObject__c,
                                     ComparisonType__c
                                     from Comparison_Log__c
                                     where ComparisonType__c=:FIELD_COMPARISON
                                     and Attribute__c=:NO_FIELD_MATCH_FOUND
                                     and ComparisonSourceField__c!=null
                                     and TargetFieldObject__c =:pTargetObj
                                     and SourceFieldObject__c=:pSrcObject];
         system.debug('notMatchingSourceFieldsList...........'+notMatchingSourceFieldsList.size());
                                     
        //getting the set of target objects from Object Information
          Double pair = mapMatchedObjectPairsToUpdateCompSource.get(stringPair);
          list<Object_Information__c> targetObjectInformationList = new list<Object_Information__c>();                   
          targetObjectInformationList=[select Id
                           from Object_Information__c
                           where Comparison_Source__c!=null and Api_Name__c =:pTargetObj
                           and Comparison_Pair__c =:pair
                           and Org_Id__c!=:Userinfo.getOrganizationId()];
          
           system.debug('targetObjectInformationList...........'+targetObjectInformationList.size());
                            
        //making set of target objects
          if(!targetObjectInformationList.isEmpty()){
            for(Object_Information__c objectInfo:targetObjectInformationList){
                targetObjectSet.add(objectInfo.Id); 
            }
          }                       
        system.debug('targetObjectSet...........'+targetObjectSet.size());
        
        //getting the list of all unmatched target fields
          if(targetObjectSet!=null){
            UnMatchedTargetFieldsInfoList=[ select API_Name__c,
                                             Label__c,
                                             Byte_Length__c,
                                             Can_Create__c,
                                             Can_Update__c,
                                             Can_Upsert__c,
                                             Comparison_Source__c,
                                             Contains_HTML_Data__c,
                                             Digits__c,
                                             Field_Category__c,
                                             Formula_Used__c,
                                             Has_Multiple_SObject_Parents__c,
                                             Help_Text__c,
                                             Is_Auto_Number__c,
                                             Is_Case_Sensitive__c,
                                             Is_Dependent_Picklist__c,
                                             Is_Deprecated__c,
                                             Is_External_ID__c,
                                             Is_Field_Visible__c,
                                             Is_Required__c,
                                             Is_Unique__c,
                                             Length__c,
                                             Parent_Object__c,
                                             Picklist_Values__c,
                                             Precision__c,
                                             Relationship_Name__c,
                                             Scale__c,
                                             Soap_Type__c,
                                             Type__c,
                                             Default_Value__c,
                                             Use_in_Group_By_Clause__c,
                                             Use_in_Order_By_Clause__c,
                                             Use_in_Where_Clause__c
                                             from Field_Information__c
                                         where Comparison_Source__c=null
                                         and Parent_Object__c IN:targetObjectSet];
          }
                              
        //making a set of all unmatched source fields                              
        if(!notMatchingSourceFieldsList.isEmpty()){
            for(Comparison_Log__c objCompLog:notMatchingSourceFieldsList){
                notMatchingSourceFieldsSet.add(objCompLog.ComparisonSourceField__c);
            }
        }
        //getting the unmatched source field information
        UnMatchedFieldsInfoList = [select API_Name__c,
                                 Label__c,
                                 Byte_Length__c,
                                 Can_Create__c,
                                 Can_Update__c,
                                 Can_Upsert__c,
                                 Comparison_Source__c,
                                 Contains_HTML_Data__c,
                                 Digits__c,
                                 Field_Category__c,
                                 Formula_Used__c,
                                 Has_Multiple_SObject_Parents__c,
                                 Help_Text__c,
                                 Is_Auto_Number__c,
                                 Is_Case_Sensitive__c,
                                 Is_Dependent_Picklist__c,
                                 Is_Deprecated__c,
                                 Is_External_ID__c,
                                 Is_Field_Visible__c,
                                 Is_Required__c,
                                 Is_Unique__c,
                                 Length__c,
                                 Parent_Object__c,
                                 Picklist_Values__c,
                                 Precision__c,
                                 Default_Value__c,
                                 Relationship_Name__c,
                                 Scale__c,
                                 Soap_Type__c,
                                 Type__c,
                                 Use_in_Group_By_Clause__c,
                                 Use_in_Order_By_Clause__c,
                                 Use_in_Where_Clause__c
                                 from Field_Information__c
                                 where Id IN:notMatchingSourceFieldsSet];                       
        
        for(Comparison_Log__c objComparisonLog:matchingSourceFieldsList){
            if(!(matchingsourceFieldsMap.containsKey(objComparisonLog.ComparisonSourceField__c))){
                    List<Comparison_Log__c> tempComparisonLog = new List<Comparison_Log__c>();
                    tempComparisonLog.add(objComparisonLog);
                    matchingsourceFieldsMap.put(objComparisonLog.ComparisonSourceField__c, tempComparisonLog);
            }else{
                    matchingsourceFieldsMap.get(objComparisonLog.ComparisonSourceField__c).add(objComparisonLog);
            }
        }

        //getting the related source fields information to populate in inner class
        list<Field_Information__c> tempSourceFieldInfoList = new list<Field_Information__c>();
        tempSourceFieldInfoList=[select API_Name__c,
                                 Label__c,
                                 Byte_Length__c,
                                 Can_Create__c,
                                 Can_Update__c,
                                 Can_Upsert__c,
                                 Comparison_Source__c,
                                 Contains_HTML_Data__c,
                                 Digits__c,
                                 Field_Category__c,
                                 Formula_Used__c,
                                 Has_Multiple_SObject_Parents__c,
                                 Help_Text__c,
                                 Is_Auto_Number__c,
                                 Is_Case_Sensitive__c,
                                 Is_Dependent_Picklist__c,
                                 Is_Deprecated__c,
                                 Is_External_ID__c,
                                 Is_Field_Visible__c,
                                 Is_Required__c,
                                 Is_Unique__c,
                                 Length__c,
                                 Parent_Object__c,
                                 Picklist_Values__c,
                                 Precision__c,
                                 Default_Value__c,
                                 Relationship_Name__c,
                                 Scale__c,
                                 Soap_Type__c,
                                 Type__c,
                                 Use_in_Group_By_Clause__c,
                                 Use_in_Order_By_Clause__c,
                                 Use_in_Where_Clause__c
                                 from Field_Information__c
                                 where Id IN: matchingsourceFieldsMap.keyset()];
                                 
        //getting the related target fields information to populate in inner class                       
        list<Field_Information__c> tempTargetFieldInfoList = new list<Field_Information__c>();
        tempTargetFieldInfoList=[select API_Name__c,
                                 Label__c,
                                 Byte_Length__c,
                                 Can_Create__c,
                                 Can_Update__c,
                                 Can_Upsert__c,
                                 Comparison_Source__c,
                                 Contains_HTML_Data__c,
                                 Digits__c,
                                 Field_Category__c,
                                 Formula_Used__c,
                                 Has_Multiple_SObject_Parents__c,
                                 Help_Text__c,
                                 Is_Auto_Number__c,
                                 Is_Case_Sensitive__c,
                                 Is_Dependent_Picklist__c,
                                 Is_Deprecated__c,
                                 Is_External_ID__c,
                                 Is_Field_Visible__c,
                                 Is_Required__c,
                                 Is_Unique__c,
                                 Length__c,
                                 Default_Value__c,
                                 Parent_Object__c,
                                 Picklist_Values__c,
                                 Precision__c,
                                 Relationship_Name__c,
                                 Scale__c,
                                 Soap_Type__c,
                                 Type__c,
                                 Use_in_Group_By_Clause__c,
                                 Use_in_Order_By_Clause__c,
                                 Use_in_Where_Clause__c
                                 from Field_Information__c
                                 where Comparison_Source__c IN: matchingsourceFieldsMap.keyset()];
                                 
        for(Field_Information__c objFieldInfo:tempSourceFieldInfoList){
            sourceFieldInfoMap.put(objFieldInfo.Id,objFieldInfo);
        }
        
        for(Field_Information__c objFieldInfo:tempTargetFieldInfoList){
            matchesSourceTarget.put(objFieldInfo.Comparison_Source__c,objFieldInfo.Id);
            targetFieldInfoMap.put(objFieldInfo.Id,objFieldInfo);
        }
                         
        srNo = 0;
        for(Field_Information__c objSrcFieldInfo:tempSourceFieldInfoList){
            FieldComparisonLog objFieldComparisonLog = new FieldComparisonLog();
            Field_Information__c objTargetFieldInfo=targetFieldInfoMap.get(matchesSourceTarget.get(objSrcFieldInfo.Id));
            //populating source fields to inner class 
            if(objSrcFieldInfo!=null){
                objFieldComparisonLog.sourceFieldLabel = objSrcFieldInfo.Label__c;
                objFieldComparisonLog.sourceFieldAPIName = objSrcFieldInfo.API_Name__c;
                if(objSrcFieldInfo.Byte_Length__c!=null){
                    objFieldComparisonLog.sourceFieldByteLength = String.valueOf(Math.floor(objSrcFieldInfo.Byte_Length__c));
                }
                objFieldComparisonLog.sourceFieldCreatable = objSrcFieldInfo.Can_Create__c;
                objFieldComparisonLog.sourceFieldUpdateable = objSrcFieldInfo.Can_Update__c;
                objFieldComparisonLog.sourceFieldUpsertable = objSrcFieldInfo.Can_Upsert__c;
                objFieldComparisonLog.sourceFieldContainsHtmlData = 
                                                  objSrcFieldInfo.Contains_HTML_Data__c;
                objFieldComparisonLog.sourceDefaultValue = objSrcFieldInfo.Default_Value__c;                                  
                objFieldComparisonLog.sourceFieldDigits = objSrcFieldInfo.Digits__c;
                objFieldComparisonLog.sourceFieldCategory = objSrcFieldInfo.Field_Category__c;
                objFieldComparisonLog.sourceFieldFormulaeUsed = objSrcFieldInfo.Formula_Used__c;                
                objFieldComparisonLog.sourceFieldHasMultipleSObjectParents = 
                                                   objSrcFieldInfo.Has_Multiple_SObject_Parents__c;
                objFieldComparisonLog.sourceFieldHelpText = objSrcFieldInfo.Help_Text__c;               
                objFieldComparisonLog.sourceFieldAutoNumber = objSrcFieldInfo.Is_Auto_Number__c;
                objFieldComparisonLog.sourceFieldCaseSensitive = 
                                                   objSrcFieldInfo.Is_Case_Sensitive__c;                
                objFieldComparisonLog.sourceFieldDependentPicklist = 
                                                    objSrcFieldInfo.Is_Dependent_Picklist__c;
                objFieldComparisonLog.sourceFieldDeprecated = objSrcFieldInfo.Is_Deprecated__c;             
                objFieldComparisonLog.sourceFieldExternalID = objSrcFieldInfo.Is_External_ID__c;
                objFieldComparisonLog.sourceFieldVisible = objSrcFieldInfo.Is_Field_Visible__c;             
                objFieldComparisonLog.sourceFieldRequired = objSrcFieldInfo.Is_Required__c;
                objFieldComparisonLog.sourceFieldUnique = objSrcFieldInfo.Is_Unique__c;             
                if(objSrcFieldInfo.Length__c==null){
                    objFieldComparisonLog.sourceFieldLength = NA;
                }else{
                    objFieldComparisonLog.sourceFieldLength = String.valueOf(Math.floor(objSrcFieldInfo.Length__c));
                }   
                objFieldComparisonLog.sourceFieldParentObject = sourceObjectName;               
                objFieldComparisonLog.sourceFieldPicklistValues = objSrcFieldInfo.Picklist_Values__c;
                if(objSrcFieldInfo.Precision__c==null){
                    objFieldComparisonLog.sourceFieldPrecision = NA;
                }else{
                    objFieldComparisonLog.sourceFieldPrecision= String.valueOf(Math.floor(objSrcFieldInfo.Precision__c));
                }                   
                objFieldComparisonLog.sourceFieldRelationshipName = 
                                                    objSrcFieldInfo.Relationship_Name__c;
                if(objSrcFieldInfo.Scale__c==null){
                    objFieldComparisonLog.sourceFieldScale  = NA;
                }else{
                    objFieldComparisonLog.sourceFieldScale = String.valueOf(Math.floor(objSrcFieldInfo.Scale__c));
                }               
                objFieldComparisonLog.sourceFieldSoapType = objSrcFieldInfo.Soap_Type__c;
                objFieldComparisonLog.sourceFieldType = objSrcFieldInfo.Type__c;                
                objFieldComparisonLog.sourceFieldUseinGroupByClause = 
                                                    objSrcFieldInfo.Use_in_Group_By_Clause__c;
                objFieldComparisonLog.sourceFieldUseinOrderByClause = 
                                                    objSrcFieldInfo.Use_in_Order_By_Clause__c;              
                objFieldComparisonLog.sourceFieldUseinWhereClause = objSrcFieldInfo.Use_in_Where_Clause__c;
            }
         
            //populating target fields to inner class
            if(objTargetFieldInfo!=null){
                objFieldComparisonLog.targetDefaultValue = objTargetFieldInfo.Default_Value__c; 
                objFieldComparisonLog.targetFieldLabel = objTargetFieldInfo.Label__c;
                objFieldComparisonLog.targetFieldAPIName = objTargetFieldInfo.API_Name__c;
                 if(objTargetFieldInfo.Byte_Length__c!=null){
                    objFieldComparisonLog.targetFieldByteLength = String.valueOf(Math.floor(objTargetFieldInfo.Byte_Length__c));
                }
                objFieldComparisonLog.targetFieldCreatable = objTargetFieldInfo.Can_Create__c;
                objFieldComparisonLog.targetFieldUpdateable = objTargetFieldInfo.Can_Update__c;
                objFieldComparisonLog.targetFieldUpsertable = objTargetFieldInfo.Can_Upsert__c;
                objFieldComparisonLog.targetFieldContainsHtmlData = 
                                                    objTargetFieldInfo.Contains_HTML_Data__c;
                objFieldComparisonLog.targetFieldDigits = objTargetFieldInfo.Digits__c;
                objFieldComparisonLog.targetFieldCategory = objTargetFieldInfo.Field_Category__c;
                objFieldComparisonLog.targetFieldFormulaeUsed = objTargetFieldInfo.Formula_Used__c;             
                objFieldComparisonLog.targetFieldHasMultipleSObjectParents = 
                                                    objTargetFieldInfo.Has_Multiple_SObject_Parents__c;
                objFieldComparisonLog.targetFieldHelpText = objTargetFieldInfo.Help_Text__c;                
                objFieldComparisonLog.targetFieldAutoNumber = objTargetFieldInfo.Is_Auto_Number__c;
                objFieldComparisonLog.targetFieldCaseSensitive = 
                                                    objTargetFieldInfo.Is_Case_Sensitive__c;                
                objFieldComparisonLog.targetFieldDependentPicklist = 
                                                    objTargetFieldInfo.Is_Dependent_Picklist__c;
                objFieldComparisonLog.targetFieldDeprecated = objTargetFieldInfo.Is_Deprecated__c;              
                objFieldComparisonLog.targetFieldExternalID = objTargetFieldInfo.Is_External_ID__c;
                objFieldComparisonLog.targetFieldVisible = objTargetFieldInfo.Is_Field_Visible__c;              
                objFieldComparisonLog.targetFieldRequired = objTargetFieldInfo.Is_Required__c;
                objFieldComparisonLog.targetFieldUnique = objTargetFieldInfo.Is_Unique__c;              
                if(objTargetFieldInfo.Length__c==null){
                    objFieldComparisonLog.targetFieldLength = NA;
                }else{
                    objFieldComparisonLog.targetFieldLength = String.valueOf(Math.floor(objTargetFieldInfo.Length__c));
                }
                objFieldComparisonLog.targetFieldParentObject = targetObjectName;               
                objFieldComparisonLog.targetFieldPicklistValues = 
                                                    objTargetFieldInfo.Picklist_Values__c;
                if(objTargetFieldInfo.Precision__c==null){
                    objFieldComparisonLog.targetFieldPrecision = NA;
                }else{
                    objFieldComparisonLog.targetFieldPrecision = String.valueOf(Math.floor(objTargetFieldInfo.Precision__c));
                }               
                objFieldComparisonLog.targetFieldRelationshipName = 
                                                     objTargetFieldInfo.Relationship_Name__c;
                if(objTargetFieldInfo.Scale__c==null){
                    objFieldComparisonLog.targetFieldScale = NA;
                }else{
                    objFieldComparisonLog.targetFieldScale = String.valueOf(Math.floor(objTargetFieldInfo.Scale__c));
                }               
                objFieldComparisonLog.targetFieldSoapType = objTargetFieldInfo.Soap_Type__c;
                objFieldComparisonLog.targetFieldType = objTargetFieldInfo.Type__c;             
                objFieldComparisonLog.targetFieldUseinGroupByClause =
                                                     objTargetFieldInfo.Use_in_Group_By_Clause__c;
                objFieldComparisonLog.targetFieldUseinOrderByClause = 
                                                     objTargetFieldInfo.Use_in_Order_By_Clause__c;              
                objFieldComparisonLog.targetFieldUseinWhereClause = 
                                                     objTargetFieldInfo.Use_in_Where_Clause__c;
            }
            
            //populating match fields to inner class
            list<Comparison_Log__c> tempComparisonLogList = matchingsourceFieldsMap.get(objSrcFieldInfo.Id);
            map<string,string> tempAttributeMatchesMap = new map<string,string>();
            for(Comparison_Log__c objComparisonAttribute:tempComparisonLogList){
                tempAttributeMatchesMap.put(objComparisonAttribute.Attribute__c,objComparisonAttribute.Match__c);
            }
            if(tempAttributeMatchesMap!=null){
                objFieldComparisonLog.matchDefaultValue = tempAttributeMatchesMap.get(DEFAULT_VALUE);
                objFieldComparisonLog.matchFieldLabel = tempAttributeMatchesMap.get(LABEL);
                objFieldComparisonLog.matchFieldFieldAPIName = tempAttributeMatchesMap.get(API_NAME);
                objFieldComparisonLog.matchFieldByteLength = tempAttributeMatchesMap.get(BYTE_LENGTH);              
                objFieldComparisonLog.matchFieldCreatable = tempAttributeMatchesMap.get(CAN_CREATE);
                objFieldComparisonLog.matchFieldUpdateable = tempAttributeMatchesMap.get(CAN_UPDATE);
                objFieldComparisonLog.matchFieldUpsertable = tempAttributeMatchesMap.get(CAN_UPSERT);               
                objFieldComparisonLog.matchFieldContainsHtmlData = 
                                                      tempAttributeMatchesMap.get(CONTAINS_HTML_DATA);
                objFieldComparisonLog.matchFieldDigits = tempAttributeMatchesMap.get(DIGITS);
                objFieldComparisonLog.matchFieldCategory = tempAttributeMatchesMap.get(FIELD_CATEGORY);             
                objFieldComparisonLog.matchFieldFormulaeUsed = tempAttributeMatchesMap.get(FORMULAE_USED);
                objFieldComparisonLog.matchFieldHasMultipleSObjectParents = 
                                                      tempAttributeMatchesMap.get(HAS_MULTIPLE_SOBJECT_PARENTS);
                objFieldComparisonLog.matchFieldHelpText = tempAttributeMatchesMap.get(HELP_TEXT);              
                objFieldComparisonLog.matchFieldAutoNumber = tempAttributeMatchesMap.get(AUTO_NUMBER);
                objFieldComparisonLog.matchFieldCaseSensitive = tempAttributeMatchesMap.get(CASE_SENSITIVE);
                objFieldComparisonLog.matchFieldDependentPicklist = 
                                                      tempAttributeMatchesMap.get(DEPENDENT_PICKLIST);              
                objFieldComparisonLog.matchFieldDeprecated = tempAttributeMatchesMap.get(DEPRECATED);
                objFieldComparisonLog.matchFieldExternalID = tempAttributeMatchesMap.get(EXTERNAL_ID);
                objFieldComparisonLog.matchFieldVisible = tempAttributeMatchesMap.get(FIELD_VISIBLE);               
                objFieldComparisonLog.matchFieldRequired = tempAttributeMatchesMap.get(REQUIRED);
                objFieldComparisonLog.matchFieldUnique = tempAttributeMatchesMap.get(UNIQUE);
                objFieldComparisonLog.matchFieldLength = tempAttributeMatchesMap.get(LENGTH);               
                objFieldComparisonLog.matchFieldParentObject = tempAttributeMatchesMap.get(PARENT_OBJECT);
                objFieldComparisonLog.matchFieldPicklistValues = 
                                                       tempAttributeMatchesMap.get(PICKLIST_VALUES);
                objFieldComparisonLog.matchFieldPrecision = tempAttributeMatchesMap.get(PRECISION);             
                objFieldComparisonLog.matchFieldRelationshipName = 
                                                       tempAttributeMatchesMap.get(RELATIONSHIP_NAME);
                objFieldComparisonLog.matchFieldScale=tempAttributeMatchesMap.get(SCALE);
                objFieldComparisonLog.matchFieldSoapType=tempAttributeMatchesMap.get(SOAP_TYPE);                
                objFieldComparisonLog.matchFieldType=tempAttributeMatchesMap.get(TYPE);
                objFieldComparisonLog.matchFieldUseinGroupByClause = 
                                                       tempAttributeMatchesMap.get(USE_IN_GROUP_BY_CLAUSE);
                objFieldComparisonLog.matchFieldUseinOrderByClause = 
                                                       tempAttributeMatchesMap.get(USE_IN_ORDER_BY_CLAUSE);             
                objFieldComparisonLog.matchFieldUseinWhereClause=
                                                       tempAttributeMatchesMap.get(USE_IN_WHERE_CLAUSE);

            }
            objFieldComparisonLog.srNo = ++srNo;
            fieldComparisonLogList.add(objFieldComparisonLog);
        }
        
       //populating unmatched source fields to inner class
        if(!UnMatchedFieldsInfoList.isEmpty()){
            for(Field_Information__c objUnamtchedSourceFieldInfo:UnMatchedFieldsInfoList){
                FieldComparisonLog objUnmatchedSourceFieldComparisonLog = new FieldComparisonLog(TARGET_BLANK);
                objUnmatchedSourceFieldComparisonLog.sourceDefaultValue = objUnamtchedSourceFieldInfo.Default_Value__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldLabel = objUnamtchedSourceFieldInfo.Label__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldAPIName = objUnamtchedSourceFieldInfo.API_Name__c;
                if(objUnamtchedSourceFieldInfo.Byte_Length__c!=null){
                    objUnmatchedSourceFieldComparisonLog.sourceFieldByteLength = String.valueOf(Math.floor(objUnamtchedSourceFieldInfo.Byte_Length__c));
                }
                objUnmatchedSourceFieldComparisonLog.sourceFieldCreatable = objUnamtchedSourceFieldInfo.Can_Create__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldUpdateable = objUnamtchedSourceFieldInfo.Can_Update__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldUpsertable = objUnamtchedSourceFieldInfo.Can_Upsert__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldContainsHtmlData = 
                                                  objUnamtchedSourceFieldInfo.Contains_HTML_Data__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldDigits = objUnamtchedSourceFieldInfo.Digits__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldCategory = objUnamtchedSourceFieldInfo.Field_Category__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldFormulaeUsed = objUnamtchedSourceFieldInfo.Formula_Used__c;             
                objUnmatchedSourceFieldComparisonLog.sourceFieldHasMultipleSObjectParents = 
                                                   objUnamtchedSourceFieldInfo.Has_Multiple_SObject_Parents__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldHelpText = objUnamtchedSourceFieldInfo.Help_Text__c;                
                objUnmatchedSourceFieldComparisonLog.sourceFieldAutoNumber = objUnamtchedSourceFieldInfo.Is_Auto_Number__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldCaseSensitive = 
                                                   objUnamtchedSourceFieldInfo.Is_Case_Sensitive__c;                
                objUnmatchedSourceFieldComparisonLog.sourceFieldDependentPicklist = 
                                                    objUnamtchedSourceFieldInfo.Is_Dependent_Picklist__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldDeprecated = objUnamtchedSourceFieldInfo.Is_Deprecated__c;              
                objUnmatchedSourceFieldComparisonLog.sourceFieldExternalID = objUnamtchedSourceFieldInfo.Is_External_ID__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldVisible = objUnamtchedSourceFieldInfo.Is_Field_Visible__c;              
                objUnmatchedSourceFieldComparisonLog.sourceFieldRequired = objUnamtchedSourceFieldInfo.Is_Required__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldUnique = objUnamtchedSourceFieldInfo.Is_Unique__c;              
                 if(objUnamtchedSourceFieldInfo.Length__c==null){
                    objUnmatchedSourceFieldComparisonLog.sourceFieldLength = NA;
                }else{
                    objUnmatchedSourceFieldComparisonLog.sourceFieldLength = String.valueOf(Math.floor(objUnamtchedSourceFieldInfo.Length__c));
                }
                objUnmatchedSourceFieldComparisonLog.sourceFieldParentObject = sourceObjectName;                
                objUnmatchedSourceFieldComparisonLog.sourceFieldPicklistValues = objUnamtchedSourceFieldInfo.Picklist_Values__c;
                 if(objUnamtchedSourceFieldInfo.Precision__c==null){
                    objUnmatchedSourceFieldComparisonLog.sourceFieldPrecision = NA;
                }else{
                    objUnmatchedSourceFieldComparisonLog.sourceFieldPrecision= String.valueOf(Math.floor(objUnamtchedSourceFieldInfo.Precision__c));
                }
                objUnmatchedSourceFieldComparisonLog.sourceFieldRelationshipName = 
                                                    objUnamtchedSourceFieldInfo.Relationship_Name__c;
                 if(objUnamtchedSourceFieldInfo.Scale__c==null){
                    objUnmatchedSourceFieldComparisonLog.sourceFieldScale = NA;
                }else{
                    objUnmatchedSourceFieldComparisonLog.sourceFieldScale= String.valueOf(Math.floor(objUnamtchedSourceFieldInfo.Scale__c));
                }
                objUnmatchedSourceFieldComparisonLog.sourceFieldSoapType = objUnamtchedSourceFieldInfo.Soap_Type__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldType = objUnamtchedSourceFieldInfo.Type__c;             
                objUnmatchedSourceFieldComparisonLog.sourceFieldUseinGroupByClause = 
                                                    objUnamtchedSourceFieldInfo.Use_in_Group_By_Clause__c;
                objUnmatchedSourceFieldComparisonLog.sourceFieldUseinOrderByClause = 
                                                    objUnamtchedSourceFieldInfo.Use_in_Order_By_Clause__c;              
                objUnmatchedSourceFieldComparisonLog.sourceFieldUseinWhereClause = objUnamtchedSourceFieldInfo.Use_in_Where_Clause__c;
                objUnmatchedSourceFieldComparisonLog.srNo = ++srNo;
                fieldComparisonLogList.add(objUnmatchedSourceFieldComparisonLog);
            }
        }
          
        //populating unmatched target fields to inner class
        if(!UnMatchedTargetFieldsInfoList.isEmpty()){
            for(Field_Information__c objUnamtchedTargetFieldInfo:UnMatchedTargetFieldsInfoList){
                FieldComparisonLog objUnmatchedTargetFieldComparisonLog = new FieldComparisonLog(SOURCE_BLANK);
                
                objUnmatchedTargetFieldComparisonLog.targetDefaultValue = objUnamtchedTargetFieldInfo.Default_Value__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldLabel = objUnamtchedTargetFieldInfo.Label__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldAPIName = objUnamtchedTargetFieldInfo.API_Name__c;
                if(objUnamtchedTargetFieldInfo.Byte_Length__c!=null){
                    objUnmatchedTargetFieldComparisonLog.targetFieldByteLength = String.valueOf(Math.floor(objUnamtchedTargetFieldInfo.Byte_Length__c));
                }
                objUnmatchedTargetFieldComparisonLog.targetFieldCreatable = objUnamtchedTargetFieldInfo.Can_Create__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldUpdateable = objUnamtchedTargetFieldInfo.Can_Update__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldUpsertable = objUnamtchedTargetFieldInfo.Can_Upsert__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldContainsHtmlData = 
                                                    objUnamtchedTargetFieldInfo.Contains_HTML_Data__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldDigits = objUnamtchedTargetFieldInfo.Digits__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldCategory = objUnamtchedTargetFieldInfo.Field_Category__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldFormulaeUsed = objUnamtchedTargetFieldInfo.Formula_Used__c;             
                objUnmatchedTargetFieldComparisonLog.targetFieldHasMultipleSObjectParents = 
                                                    objUnamtchedTargetFieldInfo.Has_Multiple_SObject_Parents__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldHelpText = objUnamtchedTargetFieldInfo.Help_Text__c;                
                objUnmatchedTargetFieldComparisonLog.targetFieldAutoNumber = objUnamtchedTargetFieldInfo.Is_Auto_Number__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldCaseSensitive = 
                                                    objUnamtchedTargetFieldInfo.Is_Case_Sensitive__c;               
                objUnmatchedTargetFieldComparisonLog.targetFieldDependentPicklist = 
                                                    objUnamtchedTargetFieldInfo.Is_Dependent_Picklist__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldDeprecated = objUnamtchedTargetFieldInfo.Is_Deprecated__c;              
                objUnmatchedTargetFieldComparisonLog.targetFieldExternalID = objUnamtchedTargetFieldInfo.Is_External_ID__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldVisible = objUnamtchedTargetFieldInfo.Is_Field_Visible__c;              
                objUnmatchedTargetFieldComparisonLog.targetFieldRequired = objUnamtchedTargetFieldInfo.Is_Required__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldUnique = objUnamtchedTargetFieldInfo.Is_Unique__c;              
                if(objUnamtchedTargetFieldInfo.Length__c==null){
                    objUnmatchedTargetFieldComparisonLog.targetFieldLength = NA;
                }else{
                    objUnmatchedTargetFieldComparisonLog.targetFieldLength = String.valueOf(Math.floor(objUnamtchedTargetFieldInfo.Length__c));
                }
                objUnmatchedTargetFieldComparisonLog.targetFieldParentObject = targetObjectName;                
                objUnmatchedTargetFieldComparisonLog.targetFieldPicklistValues = 
                                                    objUnamtchedTargetFieldInfo.Picklist_Values__c;
                if(objUnamtchedTargetFieldInfo.Precision__c==null){
                    objUnmatchedTargetFieldComparisonLog.targetFieldPrecision = NA;
                }else{
                    objUnmatchedTargetFieldComparisonLog.targetFieldPrecision = String.valueOf(Math.floor(objUnamtchedTargetFieldInfo.Precision__c));
                }
                objUnmatchedTargetFieldComparisonLog.targetFieldRelationshipName = 
                                                     objUnamtchedTargetFieldInfo.Relationship_Name__c;
                if(objUnamtchedTargetFieldInfo.Scale__c==null){
                    objUnmatchedTargetFieldComparisonLog.targetFieldScale = NA;
                }else{
                    objUnmatchedTargetFieldComparisonLog.targetFieldScale = String.valueOf(Math.floor(objUnamtchedTargetFieldInfo.Scale__c));
                }
                objUnmatchedTargetFieldComparisonLog.targetFieldSoapType = objUnamtchedTargetFieldInfo.Soap_Type__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldType = objUnamtchedTargetFieldInfo.Type__c;             
                objUnmatchedTargetFieldComparisonLog.targetFieldUseinGroupByClause =
                                                     objUnamtchedTargetFieldInfo.Use_in_Group_By_Clause__c;
                objUnmatchedTargetFieldComparisonLog.targetFieldUseinOrderByClause = 
                                                     objUnamtchedTargetFieldInfo.Use_in_Order_By_Clause__c;             
                objUnmatchedTargetFieldComparisonLog.targetFieldUseinWhereClause = 
                                                     objUnamtchedTargetFieldInfo.Use_in_Where_Clause__c;
                objUnmatchedTargetFieldComparisonLog.srNo = ++srNo;
                fieldComparisonLogList.add(objUnmatchedTargetFieldComparisonLog);
            }
        }
        
        system.debug('fieldComparisonLogList...........'+fieldComparisonLogList.size());    
        return null;
    } 
}