/*  class for comparing  objects Metadata values on object level as well as field level 
*   and store the reult into "Comparison_Log__c" object.
*	
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				  Amol Chaudhari	27/11/2012			Intial Draft 
*/
global with sharing class MetadataComparer {
    private static final string COMMA = ',';
	private static final string PICKLIST_ENTRIES = 'picklistentries__c';
	private static final string TYPE = 'type__c';
    //Static method make comparison between two object metadata values.
     public static void compareObjectMetadata(Id pSourceId,Id pTargetId,String pReportType) 
    {   
        List<Comparison_Log__c> lstComparisonLog = new List<Comparison_Log__c>();
        List<String> lstFieldName = new List<String>(); 
        Set<Id> setTargetObjectInfoId = new Set<Id>();
        //String of comparable field(Attribute) Name.
        String strFields = MetadataComparerHelper.getCommaSeparatedFields(MetadataComparerHelper.IS_OBJECT_INFORMATION_FIELD);
       
        //split above string and add all the values into list.
        lstFieldName.addAll(strFields.split(COMMA));
        
        //Retrieve the record from "Object_Information__c"  for Source object. 
        Object_Information__c objSourceObject = [Select Field_Count__c, 
			                                             Plural_Label__c, 
			                                             OwnerId, 
			                                             Org_Id__c,  
			                                             Name, 
			                                             LastModifiedDate, 
			                                             LastModifiedById, 
			                                             LastActivityDate, 
			                                             Label__c, 
			                                             Key_Prefix__c, 
			                                             Is_Updateable__c,
			                                             Is_Searchable__c, 
			                                             Is_Queryable__c, 
			                                             Is_Mergeable__c, 
			                                             Is_Deprecated__c, 
			                                             Is_Deletable__c, 
			                                             Is_Custom_Setting__c, 
			                                             Is_Custom_Object__c, 
			                                             Is_Createable__c, 
			                                             Is_Accessible__c, 
			                                             IsDeleted, Id,
			                                             CreatedDate, 
			                                             CreatedById, 
			                                             Comparison_Source__c, 
			                                             Chatter_Feed_Enabled__c, 
			                                             API_Name__c,
			                                             Is_Undeletable__c
			                                       From Object_Information__c
			                                       where Id =: pSourceId];
                                          
        //Retrieve the record from "Object_Information__c"  for Target object.                                   
        List<Object_Information__c> lstTargetObject = [Select Field_Count__c, 
			                                             Plural_Label__c, 
			                                             OwnerId, 
			                                             Org_Id__c,  
			                                             Name, 
			                                             LastModifiedDate, 
			                                             LastModifiedById, 
			                                             LastActivityDate, 
			                                             Label__c, 
			                                             Key_Prefix__c, 
			                                             Is_Updateable__c,
			                                             Is_Searchable__c, 
			                                             Is_Queryable__c, 
			                                             Is_Mergeable__c, 
			                                             Is_Deprecated__c, 
			                                             Is_Deletable__c, 
			                                             Is_Custom_Setting__c,
			                                             Is_Custom_Object__c, 
			                                             Is_Createable__c, 
			                                             Is_Accessible__c, 
			                                             IsDeleted, Id,
			                                             CreatedDate, 
			                                             CreatedById, 
			                                             Comparison_Source__c, 
			                                             Chatter_Feed_Enabled__c, 
			                                             API_Name__c,
			                                             Is_Undeletable__c
				                                   From Object_Information__c
				                                   where Id =: pTargetId];
                                          
        //invoke a method to delete all existing record having relationship with Target object.                                                  
        //Make comparison based on each field(Metadata field) and create the record of "Comparison_Log__c" according to comparison result.
        for(Object_Information__c objTargetObjectInfo : lstTargetObject)
        {
	        for(String field : lstFieldName)
	        {
	            lstComparisonLog.add(new Comparison_Log__c(
	                                    Object__c = objTargetObjectInfo.Id, 
	                                    TargetObject__c = objTargetObjectInfo.API_Name__c,
	                                    SourceObject__c = objSourceObject.API_Name__c,
	                                    Attribute__c = field,
	                                    Match__c = String.valueOf(objSourceObject.get(field)) == (String.valueOf(objTargetObjectInfo.get(field))) ? MetadataComparerHelper.MATCH_YES : MetadataComparerHelper.MATCH_NO));                                                    
	        }   
	        
	        setTargetObjectInfoId.add(objTargetObjectInfo.Id);
        }
         
        try{
	        //insert list of comparison log
	        if(!lstComparisonLog.isEmpty())
	            insert lstComparisonLog;
        }
        catch(DmlException genException){
        	ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
        } 
        
       if(pReportType.equalsIgnoreCase('Detailed'))
            compareFieldMetadata(objSourceObject.id, setTargetObjectInfoId);
    }
    
     //Method Comparing field level metadata information between two objects.
    public static void compareFieldMetadata(Id pSourceObjectID, Set<Id> pSetTargetObjectInfoId)
    {
        List<Comparison_Log__c> lstComparisonLog = new List<Comparison_Log__c>();
        List<String> lstFieldName = new List<String>();
        
        //Create a map of Id to Field Informaiton and store all child field records of Source Object. 
        Map<Id, Field_Information__c> mapIdToSourceFieldDescription = new Map<Id, Field_Information__c>([Select Use_in_Where_Clause__c, 
                                                                                                           Use_in_Order_By_Clause__c,       
                                                                                                           Use_in_Group_By_Clause__c, 
                                                                                                           Type__c, SystemModstamp,
                                                                                                           Soap_Type__c, Scale__c, 
                                                                                                           Relationship_Name__c, 
                                                                                                           Precision__c,
                                                                                                           Picklist_Values__c, 
                                                                                                           Parent_Object__c, 
                                                                                                           Name,
                                                                                                           Default_Value__c, 
                                                                                                           Length__c, 
                                                                                                           LastModifiedDate, 
                                                                                                           LastModifiedById, 
                                                                                                           LastActivityDate, 
                                                                                                           Label__c, 
                                                                                                           Is_Unique__c, 
                                                                                                           Is_Required__c, 
                                                                                                           Is_Field_Visible__c, 
                                                                                                           Is_External_ID__c, 
                                                                                                           Is_Deprecated__c, 
                                                                                                           Is_Dependent_Picklist__c, 
                                                                                                           Is_Case_Sensitive__c,
                                                                                                           Is_Auto_Number__c, 
                                                                                                           IsDeleted, 
                                                                                                           Id, 
                                                                                                           Help_Text__c, 
                                                                                                           Has_Multiple_SObject_Parents__c, 
                                                                                                           Formula_Used__c, 
                                                                                                           Field_Category__c, 
                                                                                                           Digits__c, CreatedDate, 
                                                                                                           CreatedById, 
                                                                                                           Contains_HTML_Data__c,
                                                                                                           Comparison_Source__c, 
                                                                                                           Can_Upsert__c, 
                                                                                                           Can_Update__c, 
                                                                                                           Can_Create__c, 
                                                                                                           Byte_Length__c, 
                                                                                                           API_Name__c,
                                                                                                           Parent_Object__r.Api_Name__c 
                                                                                                    From Field_Information__c 
                                                                                                    Where Parent_Object__c =: pSourceObjectID ]);
        //Create a map of Id to Field Informaiton and store all child field records of Target Object. 
                                                                                                    
       List<Field_Information__c> lstTargetFieldInformation = [Select  Use_in_Where_Clause__c, 
                                                                       Use_in_Order_By_Clause__c,       
                                                                       Use_in_Group_By_Clause__c, 
                                                                       Type__c, SystemModstamp,
                                                                       Soap_Type__c, Scale__c, 
                                                                       Relationship_Name__c, 
                                                                       Precision__c,
                                                                       Picklist_Values__c, 
                                                                       Parent_Object__c, 
                                                                       Name, 
                                                                       Length__c, 
                                                                       LastModifiedDate, 
                                                                       LastModifiedById, 
                                                                       LastActivityDate, 
                                                                       Label__c, 
                                                                       Is_Unique__c, 
                                                                       Is_Required__c, 
                                                                       Is_Field_Visible__c, 
                                                                       Is_External_ID__c, 
                                                                       Is_Deprecated__c, 
                                                                       Is_Dependent_Picklist__c, 
                                                                       Is_Case_Sensitive__c,
                                                                       Is_Auto_Number__c, 
                                                                       IsDeleted, 
                                                                       Id, 
                                                                       Help_Text__c, 
                                                                       Has_Multiple_SObject_Parents__c, 
                                                                       Formula_Used__c, 
                                                                       Field_Category__c, 
                                                                       Digits__c, CreatedDate, 
                                                                       CreatedById,
                                                                       Default_Value__c, 
                                                                       Contains_HTML_Data__c,
                                                                       Comparison_Source__c, 
                                                                       Can_Upsert__c, 
                                                                       Can_Update__c, 
                                                                       Can_Create__c, 
                                                                       Byte_Length__c, 
                                                                       API_Name__c,
                                                                       Parent_Object__r.Api_Name__c   
                                                                From Field_Information__c 
                                                                Where Parent_Object__c IN : pSetTargetObjectInfoId];   
         Map<Id, List<Field_Information__c>> mapObjectIdToFieldInformation = new  Map<Id, List<Field_Information__c>>();
         
		 //String of all comparable fields(Attributes)
         String strFields = MetadataComparerHelper.getCommaSeparatedFields(!MetadataComparerHelper.IS_OBJECT_INFORMATION_FIELD);
                            
         //Create a list of attributes 
         lstFieldName.addAll(strFields.split(COMMA));

         for(Field_Information__c objFieldInfo : lstTargetFieldInformation)
          {	
          	if(mapObjectIdToFieldInformation.get(objFieldInfo.Parent_Object__c) == null)
          	{
          		List<Field_Information__c> lstFI = new List<Field_Information__c>();
          		lstFI.add(objFieldInfo);
          		mapObjectIdToFieldInformation.put(objFieldInfo.Parent_Object__c, lstFI);
          	}
          	else
          	{
          		mapObjectIdToFieldInformation.get(objFieldInfo.Parent_Object__c).add(objFieldInfo);
          	}
          }	
          		
     	for(Id keyId : mapObjectIdToFieldInformation.keySet()) 
     	{
     		set<Id> setComparisonSourceId = new set<Id>();
     		for(Field_Information__c objFD : mapObjectIdToFieldInformation.get(keyId) )
       		{
	           //Create a new object of Comparison Log.
	            Comparison_Log__c objComparisonLog = new Comparison_Log__c();
	            
	            //Check comparison source field and further process.
	            //Comparison_Source__c value is null.
	            if(objFD.Comparison_Source__c == null)
	            {
	                objComparisonLog.Field__c = objFD.Id;
	                objComparisonLog.Attribute__c = MetadataComparerHelper.NO_FIELDS_MATCH_FOUND;
	                objComparisonLog.Match__c = MetadataComparerHelper.MATCH_NO;
	                objComparisonLog.TargetFieldObject__c = objFD.Parent_Object__r.Api_Name__c;
	                objComparisonLog.SourceFieldObject__c = mapIdToSourceFieldDescription.values()[0].Parent_Object__r.Api_Name__c;
	                
	                //add object in list.
	                lstComparisonLog.add(objComparisonLog);        
	            }
	            else // Comparison_Source__c value is not null
	            {
	            	setComparisonSourceId.add(objFD.Comparison_Source__c);
	                //Fetch the record from Target map
	                Field_Information__c objFieldDescription = mapIdToSourceFieldDescription.get(objFD.Comparison_Source__c);
	                
	                //Start comparison for each attribute value
	                for(String field : lstFieldName)
	                {	
	                	objComparisonLog = new Comparison_Log__c();
	                	objComparisonLog.Field__c = objFD.Id;
	                	objComparisonLog.TargetFieldObject__c = objFD.Parent_Object__r.Api_Name__c;
	                    objComparisonLog.SourceFieldObject__c = objFieldDescription.Parent_Object__r.Api_Name__c;
	                	objComparisonLog.ComparisonSourceField__c = objFD.Comparison_Source__c;
	                	
	                    //If field is picklist field then compare picklist values.
	                    if(field.equalsIgnoreCase(PICKLIST_ENTRIES) && (objFD.get(TYPE) == objFieldDescription.get(TYPE)))
	                    {
	                        //create a set to store picklist value
	                        Set<String> setPicklistValue = new Set<String>();
	                        setPicklistValue.addAll(String.valueOf(objFD.get(field)).split(COMMA));
	                        
	                        // Boolean variable indicate comparison is made or not.
	                        Boolean isCheck = true;
	                        
	                        List<String> lstTargetRecordPicklistValue = new list<String>(); 
	                        lstTargetRecordPicklistValue.addAll(String.valueOf(objFieldDescription.get(field)).split(COMMA));
	                        
	                        //Check size of both picklists
	                        if(setPicklistValue.size() == lstTargetRecordPicklistValue.size())
	                        {
	                            //Check each value is available in Source picklist value
	                            //If yes then check continue otherwise break the looi with changing the status to false.
	                            for(String picklistValue : lstTargetRecordPicklistValue)
	                            {
	                                if(setPicklistValue.contains(picklistValue))
	                                    continue;
	                                isCheck = false;
	                                break;
	                            }
	                        }
	                        else // picklist size is diffrent
	                            isCheck = false;
	                         
	                        objComparisonLog.Attribute__c = field;   
	                        //picklist values are matched.
	                        if(isCheck)
	                            objComparisonLog.Match__c = MetadataComparerHelper.MATCH_YES;
	                        else
	                            objComparisonLog.Match__c = MetadataComparerHelper.MATCH_NO;
	                        
	                    }
	                   	else // if Attibute is other than picklist type
	                    {
	                        objComparisonLog.Attribute__c = field;
	                        objComparisonLog.Match__c = String.valueOf(objFD.get(field)) == (string.valueOf(objFieldDescription.get(field))) ? MetadataComparerHelper.MATCH_YES : MetadataComparerHelper.MATCH_NO;
	                    }
	                        
	                     //add object in list.
	                     lstComparisonLog.add(objComparisonLog);
	                }
	            }
       		 }
     		
     		for(Id sourceFieldRecordId : mapIdToSourceFieldDescription.keySet() )
	        {
				if(!setComparisonSourceId.contains(sourceFieldRecordId))
					lstComparisonLog.add( new Comparison_Log__c(
											  ComparisonSourceField__c = sourceFieldRecordId,
											  attribute__c = MetadataComparerHelper.NO_FIELDS_MATCH_FOUND,
								              Match__c = MetadataComparerHelper.MATCH_NO,
								              TargetFieldObject__c = mapObjectIdToFieldInformation.get(keyId)[0].Parent_Object__r.Api_Name__c,
								              SourceFieldObject__c = mapIdToSourceFieldDescription.values()[0].Parent_Object__r.Api_Name__c));
	 
	        }
     	}
     	
     	try{	
	        //Perform Insert DML operation.
	        if(!lstComparisonLog.isEmpty())
	            insert lstComparisonLog;
     	}
     	catch(DmlException genException){
     		ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
     	}
       //Compare child relationship
       compareChildRelationShipMetadata(pSourceObjectID, pSetTargetObjectInfoId);
    }
    
     //Method for comparing child relationship
    public static void compareChildRelationShipMetadata(Id pSourceObjectID, Set<Id> pSetTargetObjectInfoId)
    {
    	//Map for Child object Name to thier child relationship record.
    	Map<String, Child_Relationship__c> mapSourceChildObjectNameToRelationshipRecord = new Map<String, Child_Relationship__c>();
    	
    	//Map target object Id to Object Information record
    	Map<Id, Object_Information__c> mapTargetObjectIdToInformationRecord = new Map<Id, Object_Information__c>([select Id,
    																												 Api_Name__c 
    																										  from Object_Information__c 
    																										  Where Id IN : pSetTargetObjectInfoId]);
    	//List of Comparison Log object records.
    	List<Comparison_Log__c> lstComparisonLog = new List<Comparison_Log__c>();
    	
    	//Get the source object Name
    	String soruceObjectName = [select Id, 
    									  Api_Name__c 
    							   from Object_Information__c 
    							   where Id =: pSourceObjectID].Api_Name__c;
    	
    	//Create map Child object Name to  child relationship record for source .
    	for(Child_Relationship__c objCR : [Select Type__c,
    											  SystemModstamp, 
    											  Relationship_Name__c, 
    											  Parent_Object__r.Api_Name__c, 
    											  Id,
    											  Relationship_FieldName__c,
    				 							  isDeprecatedAndHidden__c,
    											  isRestrictedDelete__c, 
    											  Child_Object__c 
    										From Child_Relationship__c
    										where Parent_Object__c =: pSourceObjectID])
    	{
    		mapSourceChildObjectNameToRelationshipRecord.put(objCR.Child_Object__c, objCR);
    	} 
    	
    	//Map Target object Id to related child records in "Child_Relationship" object.
    	Map<Id, List<Child_Relationship__c>> mapParentObjectIdToListOfRelationshipObject = new Map<Id, List<Child_Relationship__c>>(); 
    	for(Child_Relationship__c objChildRelationInfo : [Select Type__c,
    											  SystemModstamp, 
    											  Relationship_Name__c, 
    											  Parent_Object__r.Api_Name__c,
    											  Parent_Object__c, 
    											  Id,
    											  Relationship_FieldName__c,
    											  isDeprecatedAndHidden__c,
    											  isRestrictedDelete__c, 
    											  Child_Object__c 
    										From Child_Relationship__c
    										where Parent_Object__c IN: pSetTargetObjectInfoId])
        {	
          	if(!mapParentObjectIdToListOfRelationshipObject.containsKey(objChildRelationInfo.Parent_Object__c))
          	{
          		List<Child_Relationship__c> lstCR = new List<Child_Relationship__c>();
          		lstCR.add(objChildRelationInfo);
          		mapParentObjectIdToListOfRelationshipObject.put(objChildRelationInfo.Parent_Object__c, lstCR);
          	}
          	else
          	{
          		mapParentObjectIdToListOfRelationshipObject.get(objChildRelationInfo.Parent_Object__c).add(objChildRelationInfo);
          	}
        }
        
		//Compare child records of each target object with Source child relationship record.        
        for(Id parentId : mapParentObjectIdToListOfRelationshipObject.keySet())
        {
        	//Set store those child object Name they are available in Source child relationship.
        	Set<String> setChildObjectName = new Set<String>();
        	
        	//Access list of target child relationship record.
        	for(Child_Relationship__c objChildRelation : mapParentObjectIdToListOfRelationshipObject.get(parentId))
        	{
        		//Check target child object is match with source child records.
        		if(mapSourceChildObjectNameToRelationshipRecord.containsKey(objChildRelation.Child_Object__c))
        		{
        			//add this child object Name into set
        			setChildObjectName.add(objChildRelation.Child_Object__c);
        			
        			//retrieve the source child object record 
        			Child_Relationship__c objSourceChildRelationship = mapSourceChildObjectNameToRelationshipRecord.get(objChildRelation.Child_Object__c);
        			
        			//Compare each target child record field value with source object child record.
        			for(String fieldName : MetadataComparerHelper.RELATIONSHIP_FIELD_ATTRIBUTE.split(COMMA))
        			{
        				lstComparisonLog.add(new Comparison_Log__c(ComparisonRelationshipSource__c = objSourceChildRelationship.Id,
        														   Attribute__c = fieldName,
        														   Relationship__c = objChildRelation.Id,
        														   Match__c = String.valueOf(objChildRelation.get(fieldName)) == string.valueOf(objSourceChildRelationship.get(fieldName)) ? MetadataComparerHelper.MATCH_YES : MetadataComparerHelper.MATCH_NO,
        														   TargetObject__c = objChildRelation.Parent_Object__r.Api_Name__c,
        														   SourceObject__c = objSourceChildRelationship.Parent_Object__r.Api_Name__c));
        									
        			}
        		}
        		//relationship object match is not found.
        		else
        		{
        			lstComparisonLog.add(new Comparison_Log__c( Attribute__c = MetadataComparerHelper.NO_FIELDS_MATCH_FOUND,
    														   Relationship__c = objChildRelation.Id,
    														   Match__c = MetadataComparerHelper.MATCH_NO,
    														   TargetObject__c = objChildRelation.Parent_Object__r.Api_Name__c,
    														   SourceObject__c = soruceObjectName));
    										 	
        		}
        		
        	}
        	
        	//Create a comparison log record with those child object of source field they do not have any match.
        	for(String strChildObjectName : mapSourceChildObjectNameToRelationshipRecord.keySet())
        	{
        		if(!setChildObjectName.contains(strChildObjectName))
        		{
        			lstComparisonLog.add(new Comparison_Log__c( Attribute__c = MetadataComparerHelper.NO_FIELDS_MATCH_FOUND,
    														   ComparisonRelationShipSource__c = mapSourceChildObjectNameToRelationshipRecord.get(strChildObjectName).Id,
    														   Match__c = MetadataComparerHelper.MATCH_NO,
    														   TargetObject__c = mapParentObjectIdToListOfRelationshipObject.get(parentId)[0].Parent_Object__r.Api_Name__c,
    														   SourceObject__c = soruceObjectName));
        		}
        		
        	}
        }
        
        //If target object dont have any child relationship record with parent.
        for(Id targetObjecId : mapTargetObjectIdToInformationRecord.keySet())
        {
        	if(!mapParentObjectIdToListOfRelationshipObject.containsKey(targetObjecId))
        	{
        		for(Child_Relationship__c objCR : mapSourceChildObjectNameToRelationshipRecord.values())
        		{
        			lstComparisonLog.add(new Comparison_Log__c( Attribute__c = MetadataComparerHelper.NO_FIELDS_MATCH_FOUND,
    														   ComparisonRelationShipSource__c = objCR.Id,
    														   Match__c = MetadataComparerHelper.MATCH_NO,
    														   TargetObject__c = mapTargetObjectIdToInformationRecord.get(targetObjecId).Api_Name__c,
    														   SourceObject__c = soruceObjectName));
        		}
        	}
        }
        
        try{
	        //Perform Insert DML operation.
	        if(!lstComparisonLog.isEmpty())
	            insert lstComparisonLog;
        }
        catch(DmlException genException){
        	ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
        }
    } 
}