/* AddMetadata - inserting all Sobject level information into the custom object 
*  Revision History:
*
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          04/10/2012          Initial Draft 
*/
public with sharing class AddMetadata {
 list<Object_Information__c> objectInformationList = new list<Object_Information__c>();	
 private final string COMMA = ',';
 map<String,String> mapMatchedObjects = new map<String,String>();
 
 // insert the object level info to the custom object
 public void insertObjectInfo(ObjectMetadata objectMetadata,Id objectInformationId, string pOrgId){
     Object_Information__c objectInformation;
     if(objectInformationId != null)
			objectInformation = new Object_Information__c(Id = objectInformationId);
	  else
			objectInformation = new Object_Information__c();
 	
 	objectInformation.Label__c = objectMetadata.label;
    objectInformation.Plural_Label__c = objectMetadata.labelPlural; 
    objectInformation.Key_Prefix__c = objectMetadata.keyPrefix; 
    objectInformation.Is_Createable__c = objectMetadata.createable;
    objectInformation.Is_Custom_Object__c = objectMetadata.custom;
    objectInformation.Is_Custom_Setting__c = objectMetadata.customSetting;
    objectInformation.Is_Deletable__c = objectMetadata.deletable;
    objectInformation.Is_Deprecated__c = objectMetadata.deprecatedAndHidden;
    objectInformation.Chatter_Feed_Enabled__c = objectMetadata.feedEnabled;
    objectInformation.Is_Mergeable__c = objectMetadata.mergeable;
    objectInformation.Is_Queryable__c = objectMetadata.queryable;
    objectInformation.Is_Searchable__c = objectMetadata.searchable;
    objectInformation.Is_Undeletable__c = objectMetadata.undeletable;
    objectInformation.Is_Updateable__c = objectMetadata.updateable;
    objectInformation.Org_Id__c = pOrgId;
    
 	update objectInformation;
    insertFieldInfo(objectMetadata,objectInformationId);
 } 
 //insert the field level info to the custom object
 public void insertFieldInfo(ObjectMetadata objectMetadata,Id objectInformationId){
    
    list<Field_Information__c> lstFieldInformation = new list<Field_Information__c>();
    list<Child_Relationship__c> lstChildRelationship = new list<Child_Relationship__c>();
 	list<FieldMetadata> fieldMetadataList = objectMetadata.fields;
 	list<ChildRelationshipMetadata> childMetadataList = objectMetadata.childRelationships;
 	system.debug('childMetadataList.............'+childMetadataList);
 	string picklistValues;
 	
 	for(FieldMetadata fieldMetadata:fieldMetadataList){
 		Field_Information__c fieldInformation = new Field_Information__c();
 		list<Picklist> picklistList = fieldMetadata.picklistValues;
 		picklistValues='';
 		for(Picklist objPicklist:picklistList){
 			if(picklistValues==''){
 				picklistValues = objPicklist.value;
 			}else{
 				picklistValues = picklistValues+COMMA+objPicklist.value;
 			}
 		} 		
 	 	system.debug('picklistList'+picklistList);
 		fieldInformation.API_Name__c = fieldMetadata.name;
        fieldInformation.Label__c = fieldMetadata.label;
        fieldInformation.Byte_Length__c = fieldMetadata.byteLength;
        fieldInformation.Help_Text__c = fieldMetadata.inlineHelpText;
        fieldInformation.Field_Category__c = fieldMetadata.custom;
        fieldInformation.Is_Auto_Number__c = fieldMetadata.autoNumber;
        fieldInformation.Is_Unique__c = fieldMetadata.unique;
        fieldInformation.Is_Required__c = fieldMetadata.nillable;
        fieldInformation.Is_Case_Sensitive__c = fieldMetadata.caseSensitive;
        fieldInformation.Is_Dependent_Picklist__c = fieldMetadata.dependentPicklist;
        fieldInformation.Is_External_ID__c = fieldMetadata.externalId;
        fieldInformation.Formula_Used__c = fieldMetadata.calculatedFormula;
        fieldInformation.Relationship_Name__c = fieldMetadata.relationshipName;
        fieldInformation.Can_Create__c = fieldMetadata.createable;
        fieldInformation.Can_Update__c = fieldMetadata.updateable;
        fieldInformation.Can_Upsert__c = fieldMetadata.idLookup;
        fieldInformation.Has_Multiple_SObject_Parents__c = fieldMetadata.namePointing;
        fieldInformation.Contains_HTML_Data__c = fieldMetadata.htmlFormatted;
        fieldInformation.Is_Deprecated__c = fieldMetadata.deprecatedAndHidden;
        fieldInformation.Use_in_Where_Clause__c = fieldMetadata.filterable;
        fieldInformation.Use_in_Group_By_Clause__c = fieldMetadata.groupable;
        fieldInformation.Use_in_Order_By_Clause__c = fieldMetadata.sortable;
        fieldInformation.Type__c = fieldMetadata.type;
        fieldInformation.Picklist_Values__c = picklistValues;
        fieldInformation.Length__c = fieldMetadata.length;
        fieldInformation.Digits__c = fieldMetadata.digits;
        fieldInformation.Precision__c = fieldMetadata.precision;
        fieldInformation.Scale__c = fieldMetadata.scale;
        fieldInformation.Soap_Type__c = fieldMetadata.soapType;  
        fieldInformation.Parent_Object__c = objectInformationId; 
        
        lstFieldInformation.add(fieldInformation);
 	}
 	
 	for(ChildRelationshipMetadata childMetadata:childMetadataList){
 		Child_Relationship__c childRelationship = new Child_Relationship__c();
 		childRelationship.Parent_Object__c = objectInformationId;
 		childRelationship.Child_Object__c = childMetadata.childSObject;
 		childRelationship.Relationship_Name__c = childMetadata.relationshipName;
 	    childRelationship.Type__c = childMetadata.cascadeDelete ? system.Label.Master_Detail : system.Label.Lookup;
 	    childRelationship.Relationship_FieldName__c = childMetadata.field;
 	    childRelationship.isDeprecatedAndHidden__c = childMetadata.deprecatedAndHidden;
 	    childRelationship.isRestrictedDelete__c = childMetadata.restrictedDelete;
 	    
 	    lstChildRelationship.add(childRelationship);
 	} 
 	
    system.debug('FIELD_LEVEL...!!!'+fieldMetadataList);
    system.debug('fieldInformationList...!!!'+lstFieldInformation);
    system.debug('lstChildRelationship...!!!'+lstChildRelationship);
    
    if(!lstFieldInformation.isEmpty()){
    	insert lstFieldInformation;
    }
    if(!lstChildRelationship.isEmpty()){
    	insert lstChildRelationship;
    }
 }
 
  // insert the object level info to the custom object
 public void insertObjectQuickInfo(list<ObjectMetadata> objectMetadataList, string pOrgId){
    list<Object_Information__c> objectInformationList = new list<Object_Information__c>();
    system.debug('objectMetadataList...$$$'+objectMetadataList);
    for(ObjectMetadata objectMetadata:objectMetadataList){
    	Object_Information__c objectInformation = new Object_Information__c();
    	objectInformation.API_Name__c = objectMetadata.name;
    	objectInformation.Label__c = objectMetadata.label;
        objectInformation.Plural_Label__c = objectMetadata.labelPlural; 
        objectInformation.Key_Prefix__c = objectMetadata.keyPrefix; 
        objectInformation.Is_Createable__c = objectMetadata.createable;
        objectInformation.Is_Custom_Object__c = objectMetadata.custom;
        objectInformation.Is_Custom_Setting__c = objectMetadata.customSetting;
        objectInformation.Is_Deletable__c = objectMetadata.deletable;
        objectInformation.Is_Deprecated__c = objectMetadata.deprecatedAndHidden;
        objectInformation.Chatter_Feed_Enabled__c = objectMetadata.feedEnabled;
        objectInformation.Is_Mergeable__c = objectMetadata.mergeable;
        objectInformation.Is_Queryable__c = objectMetadata.queryable;
        objectInformation.Is_Searchable__c = objectMetadata.searchable;
        objectInformation.Is_Undeletable__c = objectMetadata.undeletable;
        objectInformation.Is_Updateable__c = objectMetadata.updateable;
        objectInformation.Org_Id__c = pOrgId;
        system.debug('objectInformation...$$$before adding object'+objectInformation);
        objectInformationList.add(objectInformation);
        system.debug('objectInformationList...$$$ after addding list'+objectInformationList);
    }
    
    system.debug('objectInformationList...$$$'+objectInformationList); 
    
    //insert the Object info list and if success call for a method which maps the matching objects
    if(!objectInformationList.isEmpty()){
        try{
           List<Database.Saveresult> saveResult = Database.insert(objectInformationList);
           	boolean isSuccess = true;
           	for(Database.SaveResult sr:saveResult){
           		if(!sr.isSuccess())
                    isSuccess = false;
           		} 
           		if(isSuccess)  
           			//Database.executeBatch(new ExtractMetadataBatch(pSessionId, pServerUrl, pRemoteOrgId),1);
           			MatchObjects.matchingObjects();
           		}
        catch(DmlException genException){ 
           	  ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
           	}
    }        	
 }
 
}