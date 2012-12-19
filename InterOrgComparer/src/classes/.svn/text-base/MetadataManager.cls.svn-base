/*  Class which serves the purpose of extracting the object, field and child relationship
 *  level metadata
 *  
 *  Revision History: 
 *  
 *	Version			Author				Date				Description 
 *	1.0				Amol Chaudhari		23/11/2012			Intial Draft 
 */
public with sharing class MetadataManager{ 
    
    //Map which holds Object name and it's token for all objects in the org 
    //private static  Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();   

    //Method to get metadata of all the objects in an org
    public static List<Selectoption> getAllSFDCObjects(){
        Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();  
        List<Selectoption> sfdcObjectList = new List<Selectoption>();
        Schema.Sobjecttype objSFDCObject;
       
        if(globalDescribeMap.size() > sfdcObjectList.size()){
           List<String> keyList = new List<String>();
           keyList.addAll(GlobalDescribeMap.keySet());
           keyList.sort();  
           
           if(!sfdcObjectList.isEmpty()) 
                sfdcObjectList.clear();
           
           sfdcObjectList.add(new Selectoption(system.Label.Select_String, system.Label.Select_Option));
           for(String strKey : KeyList){
                if(GlobalDescribeMap.containsKey(strKey))
                    objSFDCObject = GlobalDescribeMap.get(strKey);
                
                /* Add the Label and API Name values to be displayed in the picklist in the 
                   following format: API Name(Label) */
                 sfdcObjectList.add(new Selectoption(
                    objSFDCObject.getDescribe().getName(), 
                    objSFDCObject.getDescribe().getName() + system.Label.Round_Bracket_Open + 
                    objSFDCObject.getDescribe().getLabel()  + system.Label.Round_Bracket_Close));
           }
        }
        return sfdcObjectList;
     }
    
    //Method which fetches metadata of a particular object
    public static Object_Information__c getObjectMetadata(String pObjectName, Id pObjectId){
        Object_Information__c objectInfo;       
        objectInfo = pObjectId != null ? new Object_Information__c(Id = pObjectId) : new Object_Information__c();

        if(pObjectName != null){
            if(getObjectToken(pObjectName) != null){            
            Schema.SobjectType objSFDCObject = getObjectToken(pObjectName);
            Schema.DescribeSobjectResult objectResult = objSFDCObject.getDescribe();
             
            objectInfo.API_Name__c = objectResult.getName();
            objectInfo.Label__c = objectResult.getLabel(); 
            objectInfo.Plural_Label__c = objectResult.getLabelPlural(); 
            objectInfo.Key_Prefix__c = objectResult.getKeyPrefix(); 
            objectInfo.Is_Accessible__c = objectResult.isAccessible(); 
            objectInfo.Is_Createable__c = objectResult.isCreateable();
            objectInfo.Is_Custom_Object__c = objectResult.isCustom();
            objectInfo.Is_Custom_Setting__c = objectResult.isCustomSetting();
            objectInfo.Is_Deletable__c = objectResult.isDeletable();
            objectInfo.Is_Deprecated__c = objectResult.isDeprecatedAndHidden();
            objectInfo.Chatter_Feed_Enabled__c = objectResult.isFeedEnabled();
            objectInfo.Is_Mergeable__c = objectResult.isMergeable();
            objectInfo.Is_Queryable__c = objectResult.isQueryable();
            objectInfo.Is_Searchable__c = objectResult.isSearchable();
            objectInfo.Is_Undeletable__c = objectResult.isUndeletable();
            objectInfo.Is_Updateable__c = objectResult.isUpdateable();
            }
            
        }       
        return objectInfo;  
    }
    
    //Method which fetches metadata of a field for a particular object and returns a list of
    //metadata for all fields of an object
    public static List<Field_Information__c> getFieldMetadata(String pObjectName, Id pObjectId){ 

        Integer picklistLimit = 32000;
        List<Field_Information__c> fieldInfoList = new List<Field_Information__c>();
        
        if(pObjectName != NULL){
            Schema.Sobjecttype objSFDCObject = getObjectToken(pObjectName);
            Schema.Describesobjectresult result = objSFDCObject.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = result.fields.getMap();
                
            for(String strField : fieldMap.keySet()){ 
                Field_Information__c objFieldInfo = new Field_Information__c();  
                           
                Schema.Describefieldresult fieldResult = fieldMap.get(strField).getDescribe();
                 object obj = pObjectName;
                 object fld = strField;   
                
                fieldInfoList.add( new Field_Information__c( 
                API_Name__c = fieldResult.getName(),
                Label__c = fieldResult.getLabel(),
                Byte_Length__c = fieldResult.getByteLength(),
                Help_Text__c = fieldResult.getInlineHelpText(),
                Field_Category__c = fieldResult.isCustom() ? system.Label.Field_Category_Custom : system.Label.Field_Category_Standard,
                Is_Auto_Number__c = fieldResult.isAutoNumber(),
                Is_Unique__c = fieldResult.isUnique(),
                Is_Required__c = fieldResult.isNillable(),
                Is_Case_Sensitive__c = fieldResult.isCaseSensitive(),
                Is_Dependent_Picklist__c = fieldResult.isDependentPicklist(),
                Is_External_ID__c = fieldResult.isExternalId(),
                Formula_Used__c = fieldResult.getCalculatedFormula(),
                Relationship_Name__c = fieldResult.getRelationshipName(),
                Can_Create__c = fieldResult.isCreateable(),
                Can_Update__c = fieldResult.isUpdateable(),
                Can_Upsert__c = fieldResult.isIdLookup(),
                Is_Field_Visible__c = fieldResult.isAccessible(),
                Has_Multiple_SObject_Parents__c = fieldResult.isNamePointing(),
                Contains_HTML_Data__c = fieldResult.isHtmlFormatted(),
                Is_Deprecated__c = fieldResult.isDeprecatedAndHidden(),
                Use_in_Where_Clause__c = fieldResult.isFilterable(),
                Use_in_Group_By_Clause__c = fieldResult.isGroupable(),
                Use_in_Order_By_Clause__c = fieldResult.isSortable(),
                Type__c = FieldTypeHelper.getFieldTypeDetails(fieldResult),
                Picklist_Values__c = PicklistHelper.getFieldPicklistValues(fieldResult).length()>picklistLimit? PicklistHelper.getFieldPicklistValues(fieldResult).substring(0, (picklistLimit-3))+'...':PicklistHelper.getFieldPicklistValues(fieldResult),
                Length__c = StringHelper.getFieldLength(fieldResult),
                Digits__c = IntegerHelper.getFieldDigits(fieldResult),
                Precision__c = DoubleHelper.getFieldPrecision(fieldResult),
                Scale__c = DoubleHelper.getFieldScale(fieldResult),
                Soap_Type__c = SoapTypeHelper.getSOAPTypeEnumValues(fieldResult),
                Parent_Object__c = pObjectId) );
             }             
        }
        return fieldInfoList;       
    }
    
    //Method which fetches child relationship metadata for a particular object and returns a list
    //of metadata for all child relationships for an object
    public static List<Child_Relationship__c> getChildRelationshipMetadata(String pObjectName, Id pObjectId){
        List<Child_Relationship__c> childRelationshipInfoList= new List<Child_Relationship__c>();
        
        if(pObjectName != NULL){
            Schema.Sobjecttype objSFDCObject = getObjectToken(pObjectName);
            Schema.Describesobjectresult result = objSFDCObject.getDescribe();
            
            List<Schema.Childrelationship> childRelationshipList = result.getChildRelationships();
            
            for(Schema.Childrelationship objChildRelationship: childRelationshipList){
                
                childRelationshipInfoList.add( new Child_Relationship__c( 
                        Child_Object__c = objChildRelationship.getChildSObject().getDescribe().getName(),
                        Relationship_Name__c = objChildRelationship.getRelationshipName(),
                        Type__c = objChildRelationship.isCascadeDelete() ? system.Label.Master_Detail : system.Label.Lookup,
                        Relationship_FieldName__c = objChildRelationship.getField().getDescribe().getName(),
                        Parent_Object__c = pObjectId,
                        isDeprecatedAndHidden__c = objChildRelationship.isDeprecatedAndHidden(),
                        isRestrictedDelete__c = objChildRelationship.isRestrictedDelete()) );
            } 
        }
        return childRelationshipInfoList;   
    } 
     
    //Method which returns object token of an object
    private static Schema.Sobjecttype getObjectToken(String pOjbectName){
        Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe(); 
        if(globalDescribeMap.size() > 0 && globalDescribeMap.containsKey(pOjbectName))
            return globalDescribeMap.get(pOjbectName);                        
        return null;
    } 
}