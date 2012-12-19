/*  Detailed Comparison Report - Controller class which handles the requests related to the Comparison Log report 
*   for object level metadata comparison.	
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				  Amol Chaudhari	  06/12/2012			Intial Draft 
*/
public with sharing class ObjectComparisonComponentController {
	map<Id,Id> mapMatchComparisonLog = new map<Id,Id>();
	//list of all comparison log where comparison type is Object Comparison
    list<Comparison_Log__c> comparisonLogList = new list<Comparison_Log__c>();
    //set which contains the target objects which are being compared with source
    set<string> targetObjectSet = new set<string>();
    list<Object_Information__c> objectInformationList = new list<Object_Information__c>();
    //map which contains list of Comaparison log with respect to each target object
    map<Id,list<Comparison_Log__c>>objectComparisonMap =  new map<Id,list<Comparison_Log__c>>();
    //map which contains list of object information with respect to each target object
    map<Id,list<Object_Information__c>> targetObjectInformationMap = new map<Id,list<Object_Information__c>>();
    //list of object information of source object
    list<Object_Information__c> sourceObjectInformationList = new list<Object_Information__c>();
    //source object to which other objects are being compared
    public string sourceObject;
    list<ObjectComparisonLog> objectComparisonLogList = new list<ObjectComparisonLog>();
    private Integer countSrNo{get;set;}
    //final variables
    private final string LABEL= 'Label__c';
	private final string API_NAME= 'API_Name__c';
	private final string CHATTER_FEED_ENABLED= 'Chatter_Feed_Enabled__c';
	private final string ACCESSIBLE='Is_Accessible__c';
	private final string CREATABLE='Is_Createable__c';
	private final string CUSTOM_OBJECT='Is_Custom_Object__c';
	private final string CUSTOM_SETTING='Is_Custom_Setting__c';
	private final string DELETABLE='Is_Deletable__c';
	private final string DEPRECATED='Is_Deprecated__c';
	private final string MERGEABLE='Is_Mergeable__c';
	private final string QUERYABLE='Is_Queryable__c';
	private final string SEARCHABLE='Is_Searchable__c';
	private final string UNDELETABLE='Is_Undeletable__c';
	private final string UPDATABLE='Is_Updateable__c';
	private final string KEY_PREFIX='Key_Prefix__c';
	private final string ORG_ID='Org_Id__c';
	private final string PLURAL_LABEL='Plural_Label__c';
	private final string OBJECT_COMPARISON = 'Object Comparison';
	//set the contentype for excel export
    private final string CONTENT_TYPE='application/vnd.ms-excel#MetadataExportRpt.xls';
    private final string TARGET_BLANK = 'targetBlank'; 
	private final string SOURCE_BLANK= 'sourceBlank';
	//to check whether to show the message if batch is running or not
    public boolean isBatchRunning{get;set;}
    public boolean isFormVisible{get;set;}
    
    //returning the list of (Inner classes) object level comparison
    public list<ObjectComparisonLog> getcomparisonLogList(){
    	return objectComparisonLogList;
    }
    
    public ObjectComparisonComponentController(){
    	objectMetadataComparison();
    }
    
    //poplulating the inner class to bind on the respective visual force page
    public Pagereference objectMetadataComparison(){
    	list<Object_Information__c> lstTargetMatchObjectInfo = [select SystemModstamp, 
					                                             Plural_Label__c, 
					                                             OwnerId, 
					                                             Org_Id__c,  
					                                             Name, 
					                                             LastModifiedDate, 
					                                             LastModifiedById, 
					                                             LastActivityDate, 
					                                             Label__c, 
					                                             Key_Prefix__c,
					                                             Field_Count__c, 
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
		    	                                                from Object_Information__c
		    	                                                where Comparison_Source__c!=null];
    	 
    	set<Id> setMatchSourceId = new set<Id>();                                                
    	if(!lstTargetMatchObjectInfo.isEmpty()){
    		for(Object_Information__c objInfoMatch : lstTargetMatchObjectInfo){
	    		mapMatchComparisonLog.put(objInfoMatch.Id,objInfoMatch.Comparison_Source__c);
	    		setMatchSourceId.add(objInfoMatch.Comparison_Source__c);
    	    }
    	}
    	 
    	list<Object_Information__c> lstSourceMatchObjectInfo = new list<Object_Information__c>(); 
    	if(setMatchSourceId!=null){
    		lstSourceMatchObjectInfo = [select SystemModstamp, 
					                           Plural_Label__c,
					                           OwnerId,
					                           Field_Count__c, 
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
		    	                               from Object_Information__c
		    	                               where Id IN:setMatchSourceId];
		    	                               
    	}
    	
    	map<Id,Object_Information__c> mapSourceObjectInfo = new map<Id,Object_Information__c>();
    	if(!lstSourceMatchObjectInfo.isEmpty()){
    		for(Object_Information__c objSrc : lstSourceMatchObjectInfo){
    			mapSourceObjectInfo.put(objSrc.Id,objSrc);
    		}
    	}
    	
    	//map which contains list of Comaparison log with respect to each target object
        map<Id,list<Comparison_Log__c>>objectComparisonMap =  new map<Id,list<Comparison_Log__c>>();
        
    	for(Comparison_Log__c objComparisonLog :[select Object__c,
														Attribute__c,
														Match__c,
														TargetObject__c,
														SourceObject__c
														From Comparison_Log__c
														where Object__c IN: mapMatchComparisonLog.keySet() 
														and ComparisonType__c=:OBJECT_COMPARISON
														and SourceObject__c!=null]){
		    if(!(objectComparisonMap.containsKey(objComparisonLog.Object__c)))
	          	{
	          		List<Comparison_Log__c> lstFI = new List<Comparison_Log__c>();
	          		lstFI.add(objComparisonLog);
	          		objectComparisonMap.put(objComparisonLog.Object__c, lstFI);
	          	}
	          	else
	          	{
	          		objectComparisonMap.get(objComparisonLog.Object__c).add(objComparisonLog);
	          	}	  													
		}												
    	
    	ObjectComparisonLog objectComparisonLog;
    	Integer srNo = 0;
    	
    	for(Object_Information__c targetObjInfo : lstTargetMatchObjectInfo){
    		objectComparisonLog= new ObjectComparisonLog();
    		srNo = srNo+1; 
    		ObjectComparisonLog.srNo = srNo; 
    		objectComparisonLog.targetLabel=targetObjInfo.Label__c;
			objectComparisonLog.targetAPIName=targetObjInfo.API_Name__c;
			objectComparisonLog.targetchatterFeedEnabled = targetObjInfo.Chatter_Feed_Enabled__c;
			objectComparisonLog.targetAccessible = targetObjInfo.Is_Accessible__c;
			objectComparisonLog.targetCreateable = targetObjInfo.Is_Createable__c;
			objectComparisonLog.targetCustomObject = targetObjInfo.Is_Custom_Object__c;
			objectComparisonLog.targetCustomSetting = targetObjInfo.Is_Custom_Setting__c;
			objectComparisonLog.targetDeletable = targetObjInfo.Is_Deletable__c;
			objectComparisonLog.targetDeprecated = targetObjInfo.Is_Deprecated__c;
			objectComparisonLog.targetMergeable = targetObjInfo.Is_Mergeable__c;
			objectComparisonLog.targetQueryable = targetObjInfo.Is_Queryable__c;
			objectComparisonLog.targetSearchable = targetObjInfo.Is_Searchable__c;
			objectComparisonLog.targetUndeletable = targetObjInfo.Is_Undeletable__c;
			objectComparisonLog.targetUpdateable = targetObjInfo.Is_Updateable__c;
			objectComparisonLog.targetKeyPrefix = targetObjInfo.Key_Prefix__c;
			objectComparisonLog.targetOrgId = targetObjInfo.Org_Id__c;
			objectComparisonLog.targetPluralLabel = targetObjInfo.Plural_Label__c;
			objectComparisonLog.targetFieldCount = Integer.valueOf(targetObjInfo.field_count__c);
			
			Id tempSrcId = mapMatchComparisonLog.get(targetObjInfo.Id);
			Object_Information__c sourceObjInfo = mapSourceObjectInfo.get(tempSrcId);
			
			objectComparisonLog.sourceLabel=sourceObjInfo.Label__c;
			objectComparisonLog.sourceAPIName=sourceObjInfo.API_Name__c;
			objectComparisonLog.sourcechatterFeedEnabled = sourceObjInfo.Chatter_Feed_Enabled__c;
			objectComparisonLog.sourceAccessible = sourceObjInfo.Is_Accessible__c;
			objectComparisonLog.sourceCreateable = sourceObjInfo.Is_Createable__c;
			objectComparisonLog.sourceCustomObject = sourceObjInfo.Is_Custom_Object__c;
			objectComparisonLog.sourceCustomSetting = sourceObjInfo.Is_Custom_Setting__c;
			objectComparisonLog.sourceDeletable = sourceObjInfo.Is_Deletable__c;
			objectComparisonLog.sourceDeprecated = sourceObjInfo.Is_Deprecated__c;
			objectComparisonLog.sourceMergeable = sourceObjInfo.Is_Mergeable__c;
			objectComparisonLog.sourceQueryable = sourceObjInfo.Is_Queryable__c;
			objectComparisonLog.sourceSearchable = sourceObjInfo.Is_Searchable__c;
			objectComparisonLog.sourceUndeletable = sourceObjInfo.Is_Undeletable__c;
			objectComparisonLog.sourceUpdateable = sourceObjInfo.Is_Updateable__c;
			objectComparisonLog.sourceKeyPrefix = sourceObjInfo.Key_Prefix__c;
			objectComparisonLog.sourceOrgId = sourceObjInfo.Org_Id__c;
			objectComparisonLog.sourcePluralLabel = sourceObjInfo.Plural_Label__c;
			objectComparisonLog.sourceFieldCount = Integer.valueOf(sourceObjInfo.field_count__c);
			
			list<Comparison_Log__c> tempComparisonLogList = new list<Comparison_Log__c>();
            tempComparisonLogList=objectComparisonMap.get(targetObjInfo.Id);
            map<string,string> comparisonLogMapMatch= new map<string,string>();
            for(Comparison_Log__c tempobjComparisonLog:tempComparisonLogList){
            	comparisonLogMapMatch.put(tempobjComparisonLog.attribute__c,tempobjComparisonLog.Match__c);
            }
           
            objectComparisonLog.matchLabel=comparisonLogMapMatch.get(LABEL);
			objectComparisonLog.matchAPIName=comparisonLogMapMatch.get(API_NAME);
			objectComparisonLog.matchchatterFeedEnabled = 
			                                      comparisonLogMapMatch.get(CHATTER_FEED_ENABLED);
			objectComparisonLog.matchAccessible = comparisonLogMapMatch.get(ACCESSIBLE);
			objectComparisonLog.matchCreateable = comparisonLogMapMatch.get(CREATABLE);
			objectComparisonLog.matchCustomObject = comparisonLogMapMatch.get(CUSTOM_OBJECT);
			objectComparisonLog.matchCustomSetting = comparisonLogMapMatch.get(CUSTOM_SETTING);
			objectComparisonLog.matchDeletable = comparisonLogMapMatch.get(DELETABLE);
			objectComparisonLog.matchDeprecated = comparisonLogMapMatch.get(DEPRECATED);
			objectComparisonLog.matchMergeable = comparisonLogMapMatch.get(MERGEABLE);
			objectComparisonLog.matchQueryable = comparisonLogMapMatch.get(QUERYABLE);
			objectComparisonLog.matchSearchable = comparisonLogMapMatch.get(SEARCHABLE);
			objectComparisonLog.matchUndeletable = comparisonLogMapMatch.get(UNDELETABLE);
			objectComparisonLog.matchUpdateable = comparisonLogMapMatch.get(UPDATABLE);
			objectComparisonLog.matchKeyPrefix = comparisonLogMapMatch.get(KEY_PREFIX);
			objectComparisonLog.matchOrgId = comparisonLogMapMatch.get(ORG_ID);
			objectComparisonLog.matchPluralLabel = comparisonLogMapMatch.get(PLURAL_LABEL);
			
			objectComparisonLogList.add(objectComparisonLog);
    	   }
    	    
			set<Id> setSourceNotMatch  = new set<Id>();
			
			for(Comparison_Log__c objSourceNotMatch : [select Object__c
			                                               from Comparison_Log__c
			                                               where SourceObject__c=null
			                                               and TargetObject__c=:MetadataComparerHelper.MATCH_NO]){
			                              	
			    setSourceNotMatch.add(objSourceNotMatch.Object__c);
			}
			
			for(Object_Information__c sourceObjInfo:[select SystemModstamp, 
						                           Plural_Label__c,
						                           OwnerId,
						                           Field_Count__c, 
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
			    	                               from Object_Information__c
			    	                               where Id IN:setSourceNotMatch] ){
			    	                               	
				ObjectComparisonLog objUnmatchedSourceComparisonLog = new ObjectComparisonLog(TARGET_BLANK);
				
				srNo = srNo+1;
				objUnmatchedSourceComparisonLog.srNo = srNo; 
				
				objUnmatchedSourceComparisonLog.sourceLabel=sourceObjInfo.Label__c;
				objUnmatchedSourceComparisonLog.sourceAPIName=sourceObjInfo.API_Name__c;
				objUnmatchedSourceComparisonLog.sourcechatterFeedEnabled = sourceObjInfo.Chatter_Feed_Enabled__c;
				objUnmatchedSourceComparisonLog.sourceAccessible = sourceObjInfo.Is_Accessible__c;
				objUnmatchedSourceComparisonLog.sourceCreateable = sourceObjInfo.Is_Createable__c;
				objUnmatchedSourceComparisonLog.sourceCustomObject = sourceObjInfo.Is_Custom_Object__c;
				objUnmatchedSourceComparisonLog.sourceCustomSetting = sourceObjInfo.Is_Custom_Setting__c;
				objUnmatchedSourceComparisonLog.sourceDeletable = sourceObjInfo.Is_Deletable__c;
				objUnmatchedSourceComparisonLog.sourceDeprecated = sourceObjInfo.Is_Deprecated__c;
				objUnmatchedSourceComparisonLog.sourceMergeable = sourceObjInfo.Is_Mergeable__c;
				objUnmatchedSourceComparisonLog.sourceQueryable = sourceObjInfo.Is_Queryable__c;
				objUnmatchedSourceComparisonLog.sourceSearchable = sourceObjInfo.Is_Searchable__c;
				objUnmatchedSourceComparisonLog.sourceUndeletable = sourceObjInfo.Is_Undeletable__c;
				objUnmatchedSourceComparisonLog.sourceUpdateable = sourceObjInfo.Is_Updateable__c;
				objUnmatchedSourceComparisonLog.sourceKeyPrefix = sourceObjInfo.Key_Prefix__c;
				objUnmatchedSourceComparisonLog.sourceOrgId = sourceObjInfo.Org_Id__c;
				objUnmatchedSourceComparisonLog.sourcePluralLabel = sourceObjInfo.Plural_Label__c;
				objUnmatchedSourceComparisonLog.sourceFieldCount = Integer.valueOf(sourceObjInfo.field_count__c);
				
				objectComparisonLogList.add(objUnmatchedSourceComparisonLog);
				
			}
			
			set<Id> setTargetNotMatch  = new set<Id>();
			
			for(Comparison_Log__c objTargetNotMatch : [select Object__c
			                                               from Comparison_Log__c
			                                               where TargetObject__c=null
			                                               and SourceObject__c=:MetadataComparerHelper.MATCH_NO]){
			                              	
			    setTargetNotMatch.add(objTargetNotMatch.Object__c);
			}
			
			for(Object_Information__c targetObjInfo:[select SystemModstamp, 
						                           Plural_Label__c,
						                           OwnerId,
						                           Field_Count__c, 
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
			    	                               from Object_Information__c
			    	                               where Id IN:setTargetNotMatch] ){
			    	                               	
				ObjectComparisonLog objUnmatchedTargetComparisonLog = new ObjectComparisonLog(SOURCE_BLANK);
				
				srNo = srNo+1;
				objUnmatchedTargetComparisonLog.srNo = srNo; 
				
				objUnmatchedTargetComparisonLog.targetLabel=targetObjInfo.Label__c;
				objUnmatchedTargetComparisonLog.targetAPIName=targetObjInfo.API_Name__c;
				objUnmatchedTargetComparisonLog.targetchatterFeedEnabled = targetObjInfo.Chatter_Feed_Enabled__c;
				objUnmatchedTargetComparisonLog.targetAccessible = targetObjInfo.Is_Accessible__c;
				objUnmatchedTargetComparisonLog.targetCreateable = targetObjInfo.Is_Createable__c;
				objUnmatchedTargetComparisonLog.targetCustomObject = targetObjInfo.Is_Custom_Object__c;
				objUnmatchedTargetComparisonLog.targetCustomSetting = targetObjInfo.Is_Custom_Setting__c;
				objUnmatchedTargetComparisonLog.targetDeletable = targetObjInfo.Is_Deletable__c;
				objUnmatchedTargetComparisonLog.targetDeprecated = targetObjInfo.Is_Deprecated__c;
				objUnmatchedTargetComparisonLog.targetMergeable = targetObjInfo.Is_Mergeable__c;
				objUnmatchedTargetComparisonLog.targetQueryable = targetObjInfo.Is_Queryable__c;
				objUnmatchedTargetComparisonLog.targetSearchable = targetObjInfo.Is_Searchable__c;
				objUnmatchedTargetComparisonLog.targetUndeletable = targetObjInfo.Is_Undeletable__c;
				objUnmatchedTargetComparisonLog.targetUpdateable = targetObjInfo.Is_Updateable__c;
				objUnmatchedTargetComparisonLog.targetKeyPrefix = targetObjInfo.Key_Prefix__c;
				objUnmatchedTargetComparisonLog.targetOrgId = targetObjInfo.Org_Id__c;
				objUnmatchedTargetComparisonLog.targetPluralLabel = targetObjInfo.Plural_Label__c;
				
				objectComparisonLogList.add(objUnmatchedTargetComparisonLog);
				
			}                                
    	system.debug('lstMatchCompLog......'+lstTargetMatchObjectInfo.size());
    	system.debug('mapMatchComparisonLog......'+mapMatchComparisonLog.size());
    	system.debug('setMatchSourceId......'+setMatchSourceId.size());
    	system.debug('lstSourceMatchObjectInfo......'+lstSourceMatchObjectInfo.size());
    	system.debug('mapSourceObjectInfo......'+mapSourceObjectInfo.size()); 
    	system.debug('objectComparisonMap......'+objectComparisonMap.size());
    	system.debug('objectComparisonLogList......'+objectComparisonLogList.size());                                                      
    	return null;
    }
}