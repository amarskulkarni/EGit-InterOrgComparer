/*  Controller class which is to extract the Child Relationships Comparison Metadata report into Excel format
*	
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				  Amol Chaudhari		10/12/2012			Intial Draft 
*/
public with sharing class ChildMetadataComparisonExtractor {

    //final variable for Child Comparison tab
    private final string tabChild = 'Child Comparison';
    //sr no variable
    public Integer srNo{get;set;}
    //final variables
    private final string CHILD_OBJECT= 'Child_Object__c';
	private final string IS_DEPRECATED_AND_HIDDEN = 'isDeprecatedAndHidden__c';
	private final string IS_RESTRICTIVE_DELETE = 'isRestrictedDelete__c';
	private final string PARENT_OBJECT = 'Parent_Object__c';
	private final string RELATIONSHIP_FIELD_NAME = 'Relationship_FieldName__c';
	private final string RELATIONSHIP_NAME = 'Relationship_Name__c';
	private final string TYPE = 'Type__c';
	
	private final string NO_FIELD_MATCH_FOUND = 'No Field Match Found';
	private final string COOKIE_CHILD_TARGET = 'targetChild';
	private final string COOKIE_CHILD_SOURCE = 'sourceChild';
	private final string TAB_NAME = 'tabName';
	private final string CHILD_COMPARISON = 'Child Comparison';
	private final string TARGET_BLANK = 'targetBlank'; 
	private final string SOURCE_BLANK= 'sourceBlank';
     private final string HTTPS = 'https://';
     private final string APEX_METADATAREPORT = '/apex/MetadataComparisionReport';
     private String REDIRECT_BATCH_PROCESSED;
	
	list<ChildComparisonLog> childComparisonLogList;
	//Properties
	public String sourceObjectName;
	public List<SelectOption> targetObjectList{get; set;}
	public List<SelectOption> sourceObjectList{get; set;}
	public String targetObjectName;
	public Boolean isChildComparisonLogEmpty{get;set;}
	public Boolean isChildComparisonLogNotEmpty{get;set;}
	map<String,set<string>> mapObject{get;set;}
	
	//getting the list of ChildComparisonLog to bind with VF page
	public list<ChildComparisonLog> getChildComparisonLogList(String pSrc,String pTarget){
		sourceObjectName = pSrc;
		targetObjectName = pTarget;
		childMetadataComparison();
    	return childComparisonLogList;
	}

    //getting the list of inner class for Child Level comparison to bind with UI
    public Pagereference childMetadataComparison(){
    	//list of comparison log where comparison type is Child level and which matches
    list<Comparison_Log__c> matchingchildComparisonLogList = new list<Comparison_Log__c>(); 
    //map of matches of target object childs vs source object childs
    map<Id,Id> childMatchesTargetSourceMap = new map<Id,Id>();
    //set of all source objects
    set<Id> sourceChildSet = new set<Id>();
    //list of target object's childs info
    list<Child_Relationship__c> targetObjectChildInfoList = new list<Child_Relationship__c>();
    //list of source object's childs info
    list<Child_Relationship__c> sourceObjectChildInfoList = new list<Child_Relationship__c>();
    //map of target object's childs info
    map<Id,Child_Relationship__c> targetObjectChildInfoMap = new map<Id,Child_Relationship__c>();
    //map of source object's childs info
    map<Id,Child_Relationship__c> sourceObjectChildInfoMap= new map<Id,Child_Relationship__c>();
    //map of match child field vs actual matches info
    map<Id,list<Comparison_Log__c>> childMatchesDetailsMap = new map<Id,list<Comparison_Log__c>>();
    //list of all unmacthed target childs 
    list<Comparison_Log__c> unmatchedTargetChildList = new list<Comparison_Log__c>();
    //list of all unmacthed source childs 
    list<Comparison_Log__c> unmatchedSourceChildList = new list<Comparison_Log__c>();
    //set of all unmathed target childs 
    set<Id> unmatchedTargetChildSet = new set<Id>();
    //set of all unmathed source childs 
    set<Id> unmatchedSourceChildSet = new set<Id>();
    //map of target object's childs info
    map<Id,Child_Relationship__c> unmatchedTargetObjectChildInfoMap = new map<Id,Child_Relationship__c>();
    //map of source object's childs info
    map<Id,Child_Relationship__c> unmatchedSourceObjectChildInfoMap= new map<Id,Child_Relationship__c>();
    //list of inner classes which is to be populate
    childComparisonLogList = new list<ChildComparisonLog>();    
    		matchingchildComparisonLogList=[select Id,
    	                                Attribute__c,
    	                                Match__c,
    	                                ComparisonRelationshipSource__c,
    	                                Relationship__c
    	                                from Comparison_Log__c
    	                                where ComparisonRelationshipSource__c!=null
    	                                and Relationship__c!=null
    	                                and Attribute__c!=:NO_FIELD_MATCH_FOUND
    	                                and TargetObject__c =:targetObjectName
                                       and SourceObject__c=:sourceObjectName];
        system.debug('matchingchildComparisonLogList.................'+matchingchildComparisonLogList.size());
		
    	if(!matchingchildComparisonLogList.isEmpty()){ 
    		for(Comparison_Log__c objComparisonLog:matchingchildComparisonLogList){
	        	if(!(childMatchesDetailsMap.containsKey(objComparisonLog.Relationship__c))){
		          		List<Comparison_Log__c> tempComparisonLog = new List<Comparison_Log__c>();
		          		tempComparisonLog.add(objComparisonLog);
		          		childMatchesDetailsMap.put(objComparisonLog.Relationship__c, tempComparisonLog);
		        }else{
		          		childMatchesDetailsMap.get(objComparisonLog.Relationship__c).add(objComparisonLog);
		        }
            }
    	system.debug('childMatchesDetailsMap.................'+childMatchesDetailsMap.size());
		
    		for(Comparison_Log__c objChildMatchingComparisonLog:matchingchildComparisonLogList){
    		    childMatchesTargetSourceMap.put(objChildMatchingComparisonLog.Relationship__c,
    		                      objChildMatchingComparisonLog.ComparisonRelationshipSource__c);
    		    sourceChildSet.add(objChildMatchingComparisonLog.ComparisonRelationshipSource__c);                                        
    	    }
    	}
    	system.debug('sourceChildSet.................'+sourceChildSet.size());
		
    	//getting the map which contains info of target and source childs which matches to each other
    	if(childMatchesTargetSourceMap!=null){
 
    		targetObjectChildInfoList=[select Id,
    	                           Parent_Object__c,
    	                           Name,
    	                           Relationship_Name__c,
    	                           Relationship_FieldName__c,
    	                           Child_Object__c,
    	                           Type__c,
    	                           isDeprecatedAndHidden__c,
    	                           isRestrictedDelete__c
    	                           from Child_Relationship__c
    	                           where Id IN: childMatchesTargetSourceMap.keyset()];
    	   system.debug('targetObjectChildInfoList.................'+targetObjectChildInfoList.size());

		   
    	    if(!targetObjectChildInfoList.isEmpty()){
    	        for(Child_Relationship__c objectTargetChildInfo:targetObjectChildInfoList){
    	        	targetObjectChildInfoMap.put(objectTargetChildInfo.Id,objectTargetChildInfo);
    	        }   
    	    }
			
    	     system.debug('targetObjectChildInfoMap.................'+targetObjectChildInfoMap.size());
			 
    	    sourceObjectChildInfoList=[select Id,
    	                           Parent_Object__c,
    	                           Name,
    	                           Relationship_Name__c,
    	                           Relationship_FieldName__c,
    	                           Child_Object__c,
    	                           Type__c,
    	                           isDeprecatedAndHidden__c,
    	                           isRestrictedDelete__c
    	                           from Child_Relationship__c
    	                           where Id IN: sourceChildSet];
    	     system.debug('sourceObjectChildInfoList.................'+sourceObjectChildInfoList.size());

			 
    	    if(!sourceObjectChildInfoList.isEmpty()){
    	        for(Child_Relationship__c objectSourceChildInfo:sourceObjectChildInfoList){
    	        	sourceObjectChildInfoMap.put(objectSourceChildInfo.Id,objectSourceChildInfo);
    	        }   
    	    }                                           
    	}
    	system.debug('sourceObjectChildInfoMap.................'+sourceObjectChildInfoMap.size());
		
    	//getting the unmatched target childs
    	unmatchedTargetChildList=[select Id,
    	                                Attribute__c,
    	                                Match__c,
    	                                ComparisonRelationshipSource__c,
    	                                Relationship__c
    	                                from Comparison_Log__c
    	                                where Relationship__c!=null
    	                                and ComparisonRelationshipSource__c=null
    	                                and Attribute__c=:NO_FIELD_MATCH_FOUND
    	                                and TargetObject__c =:targetObjectName
										and SourceObject__c=:sourceObjectName];
										
		system.debug('unmatchedTargetChildList.................'+unmatchedTargetChildList.size());	
		
    	//getting the set of target child Id's which are does not matches with source childs                                 
    	if(!unmatchedTargetChildList.isEmpty()){
    		for(Comparison_Log__c objComparisonLog:unmatchedTargetChildList){
    			unmatchedTargetChildSet.add(objComparisonLog.Relationship__c);
    		}
    	}
    	system.debug('unmatchedTargetChildSet.................'+unmatchedTargetChildSet.size());	
		
		
    	list<Child_Relationship__c> tempTargetChildInfoList = new List<Child_Relationship__c>();
    	//getting the map which contains info of target childs which does not matches with source
    	if(unmatchedTargetChildSet!=null){
    		tempTargetChildInfoList=[select Id,
    	                           Parent_Object__c,
    	                           Name,
    	                           Relationship_Name__c,
    	                           Child_Object__c,
    	                           Type__c,
    	                           isDeprecatedAndHidden__c,
    	                           isRestrictedDelete__c,
    	                           Relationship_FieldName__c
    	                           from Child_Relationship__c
    	                           where Id IN: unmatchedTargetChildSet];
								   
		system.debug('tempTargetChildInfoList.................'+tempTargetChildInfoList.size());
		
    	    if(!tempTargetChildInfoList.isEmpty()){
    	    	for(Child_Relationship__c objTargetChildInfo:tempTargetChildInfoList){
    	    	    unmatchedTargetObjectChildInfoMap.put(objTargetChildInfo.Id,objTargetChildInfo);   
    	        }     
    	    }
    	}
    	system.debug('unmatchedTargetObjectChildInfoMap.................'+unmatchedTargetObjectChildInfoMap.size());
		
		
    	unmatchedSourceChildList=[select Id,
    	                                Attribute__c,
    	                                Match__c,
    	                                ComparisonRelationshipSource__c,
    	                                Relationship__c
    	                                from Comparison_Log__c
    	                                where Relationship__c=null
    	                                and ComparisonRelationshipSource__c!=null
    	                                and Attribute__c=:NO_FIELD_MATCH_FOUND
    	                                and TargetObject__c =:targetObjectName
                                           and SourceObject__c=:sourceObjectName]; 
    	system.debug('unmatchedSourceChildList.................'+unmatchedSourceChildList.size());
		
		
		
    	//getting the set of source child Id's which are does not matches with target childs                                 
    	if(!unmatchedSourceChildList.isEmpty()){
    		for(Comparison_Log__c objComparisonLog:unmatchedSourceChildList){
    			unmatchedSourceChildSet.add(objComparisonLog.ComparisonRelationshipSource__c);
    		}
    	}
    	system.debug('unmatchedSourceChildSet.................'+unmatchedSourceChildSet.size());
				
				
    	list<Child_Relationship__c> tempSourceChildInfoList = new List<Child_Relationship__c>();
    	//getting the map which contains info of source childs which does not matches with source
    	if(unmatchedSourceChildSet!=null){
    		tempSourceChildInfoList=[select Id,
    	                           Parent_Object__c,
    	                           Name,
    	                           Relationship_Name__c,
    	                           Child_Object__c,
    	                           Type__c,
    	                           isDeprecatedAndHidden__c,
    	                           isRestrictedDelete__c,
    	                           Relationship_FieldName__c
    	                           from Child_Relationship__c
    	                           where Id IN: unmatchedSourceChildSet];
								   
			system.debug('tempSourceChildInfoList.................'+tempSourceChildInfoList.size());				
			
    	    if(!tempSourceChildInfoList.isEmpty()){
    	    	for(Child_Relationship__c objSourceChildInfo:tempSourceChildInfoList){
    	    	    unmatchedSourceObjectChildInfoMap.put(objSourceChildInfo.Id,objSourceChildInfo);   
    	        }     
    	    }
			
			system.debug('unmatchedSourceObjectChildInfoMap.................'+unmatchedSourceObjectChildInfoMap.size());			
    	}
    	srNo = 0;
    	//popuating the inner class for matching childs      
    	if(!targetObjectChildInfoList.isEmpty()){
	    		for(Child_Relationship__c objectTargetChildInfo:targetObjectChildInfoList){
	    		//inner class instance
	    		ChildComparisonLog objChildComparisonLog = new ChildComparisonLog();
	    		
	    		objChildComparisonLog.targetChildRelationshipName = 
	    		                              objectTargetChildInfo.Relationship_Name__c;
	    		objChildComparisonLog.targetChildRelationshipFieldName = 
	    		                              objectTargetChildInfo.Relationship_FieldName__c;                               
	    		objChildComparisonLog.targetChildParentObject = 
	    		                              targetObjectName;
	    		objChildComparisonLog.targetChildChildObject = 
	    		                              objectTargetChildInfo.Child_Object__c;
	    		objChildComparisonLog.targetChildRelationshipType = 
	    		                              objectTargetChildInfo.Type__c;
	    		objChildComparisonLog.targetChildIsDeprecatedAndHidden = 
	    		                             objectTargetChildInfo.isDeprecatedAndHidden__c;
	    		objChildComparisonLog.targetChildIsRestrictedDelete = 
	    		                             objectTargetChildInfo.isRestrictedDelete__c;                                                           
	    		
	    		Child_Relationship__c objSourceChildInfo =
	    		                          sourceObjectChildInfoMap.get(childMatchesTargetSourceMap.get(objectTargetChildInfo.Id)); 
	    		
	    		objChildComparisonLog.sourceChildRelationshipName = 
	    		                              objSourceChildInfo.Relationship_Name__c;
	    		//list<String> lstTemp = sourceObjectName.split('(');
	    		objChildComparisonLog.sourceChildParentObject = 
	    		                              sourceObjectName;
	    		objChildComparisonLog.sourceChildChildObject = 
	    		                              objSourceChildInfo.Child_Object__c;
	    		objChildComparisonLog.sourceChildRelationshipFieldName = 
	    		                              objSourceChildInfo.Relationship_FieldName__c;                               
	    		objChildComparisonLog.sourceChildRelationshipType = 
	    		                              objSourceChildInfo.Type__c;
	    		objChildComparisonLog.sourceChildIsDeprecatedAndHidden = 
	    		                             objSourceChildInfo.isDeprecatedAndHidden__c;
	    		objChildComparisonLog.sourceChildIsRestrictedDelete = 
	    		                             objSourceChildInfo.isRestrictedDelete__c;
	    		
	    		list<Comparison_Log__c> tempMatchesComparisonLogList =
	    		                             childMatchesDetailsMap.get(objectTargetChildInfo.Id);
	    		map<string,string> tempAttributeMatchesMap = new map<string,string>();
	    		if(!tempMatchesComparisonLogList.isEmpty()){
	    			for(Comparison_Log__c objCompLog:tempMatchesComparisonLogList){
	    				tempAttributeMatchesMap.put(objCompLog.Attribute__c,objCompLog.Match__c);
	    			}
	    		}
	    		
	    		objChildComparisonLog.matchChildRelationshipName = 
	    		                              tempAttributeMatchesMap.get(RELATIONSHIP_NAME);
	    		objChildComparisonLog.matchChildParentObject = 
	    		                              tempAttributeMatchesMap.get(PARENT_OBJECT);
	    		objChildComparisonLog.matchChildChildObject = 
	    		                              tempAttributeMatchesMap.get(CHILD_OBJECT);
	    		objChildComparisonLog.matchChildRelationshipType = 
	    		                              tempAttributeMatchesMap.get(TYPE);                              
	    		objChildComparisonLog.matchChildRelationshipFieldName = 
	    		                              tempAttributeMatchesMap.get(RELATIONSHIP_FIELD_NAME);
	    		objChildComparisonLog.matchChildIsDeprecatedAndHidden = 
	    		                             tempAttributeMatchesMap.get(IS_DEPRECATED_AND_HIDDEN);
	    		objChildComparisonLog.matchChildIsRestrictedDelete = 
	    		                             tempAttributeMatchesMap.get(IS_RESTRICTIVE_DELETE);
	    		 
	    		objChildComparisonLog.srNo = ++srNo;                                                          
	    		//adding the inner class object in a list
	    		childComparisonLogList.add(objChildComparisonLog);
	    	}
    	}
//populating the unmatched target childs
    	if(!tempTargetChildInfoList.isEmpty()){
    		for(Child_Relationship__c objTargetChildInfo:tempTargetChildInfoList){
    		    ChildComparisonLog objChildComparisonLog1 = new ChildComparisonLog(SOURCE_BLANK);
    		    
    		    objChildComparisonLog1.targetChildRelationshipName = 
    		                              objTargetChildInfo.Relationship_Name__c;
    		    objChildComparisonLog1.targetChildRelationshipFieldName = 
    		                              objTargetChildInfo.Relationship_FieldName__c;                          
	    		objChildComparisonLog1.targetChildParentObject = 
	    		                              targetObjectName;
	    		objChildComparisonLog1.targetChildChildObject = 
	    		                              objTargetChildInfo.Child_Object__c;
	    		objChildComparisonLog1.targetChildRelationshipType = 
	    		                              objTargetChildInfo.Type__c;
	    		objChildComparisonLog1.targetChildIsDeprecatedAndHidden = 
	    		                             objTargetChildInfo.isDeprecatedAndHidden__c;
	    		objChildComparisonLog1.targetChildIsRestrictedDelete = 
	    		                             objTargetChildInfo.isRestrictedDelete__c;
	    		 
	    		objChildComparisonLog1.srNo = ++srNo;                            
	    		//adding the inner class object to list
    	        childComparisonLogList.add(objChildComparisonLog1);                             
    	    }
    	}
    	
    	//populating the unmatched source childs
    	if(!tempSourceChildInfoList.isEmpty()){
    		for(Child_Relationship__c objSourceChildInfo:tempSourceChildInfoList){
    		    ChildComparisonLog objChildComparisonLog1 = new ChildComparisonLog(TARGET_BLANK);
    		    
    		    objChildComparisonLog1.sourceChildRelationshipName = 
    		                              objSourceChildInfo.Relationship_Name__c;
	    		objChildComparisonLog1.sourceChildParentObject = 
	    		                              sourceObjectName;
	    		objChildComparisonLog1.sourceChildRelationshipFieldName = 
    		                              objSourceChildInfo.Relationship_FieldName__c;                                 
	    		objChildComparisonLog1.sourceChildChildObject = 
	    		                              objSourceChildInfo.Child_Object__c;
	    		objChildComparisonLog1.sourceChildRelationshipType = 
	    		                              objSourceChildInfo.Type__c;
	    		objChildComparisonLog1.sourceChildIsDeprecatedAndHidden = 
	    		                             objSourceChildInfo.isDeprecatedAndHidden__c;
	    		objChildComparisonLog1.sourceChildIsRestrictedDelete =  
	    		                             objSourceChildInfo.isRestrictedDelete__c;
    	        
    	        objChildComparisonLog1.srNo = ++srNo;
    	        //adding the inner class object to list
    	        childComparisonLogList.add(objChildComparisonLog1);
    	}
    	}      
    	return null;
    }
}