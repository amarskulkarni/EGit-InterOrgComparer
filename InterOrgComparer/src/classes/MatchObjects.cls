/*  Class contains a mehtods which maps the matching Sobjects from both the orgs
*	Revision History: 
*	Version				 Author				  Date				Description 
*	1.0				  Amol Chaudhari		27/11/2012			Intial Draft 
*/

public with sharing class MatchObjects {
	//org Id of the self org
	private static final String selfOrgId = Userinfo.getOrganizationId();
	//Name of scheduler which is going to be scheduled
	private static final string METADATA_COMPARER_SCHEDULER = 'MetadataComparerScheduler';
    
    // method compares Sobjects from both the orgs and maps the objects with matching API Name
    public static void matchingObjects(){
    	//list of objects from self org
   	    list<Object_Information__c> lstSelfOrgObjects = [select API_Name__c,Id
   	                                                     from Object_Information__c
   	                                                     where Org_Id__c=: selfOrgId];
   	    //list of objects from remote org                                                 
   	    list<Object_Information__c> lstRemoteOrgObjects = [select API_Name__c,Id
   	                                                     from Object_Information__c
   	                                                     where Org_Id__c!=: selfOrgId];
   	                                                                                                      
   	    map<String,Id> mapSelfOrgObjects = new map<String,Id>();     //object map of self org
   	    map<String,Id> mapTargetOrgObjects = new map<String,Id>();   //object map of remote org
   	    map<Id,Id> mapMatchingObjects = new map<Id,Id>();            //matching object map from both the orgs
   	    
   	    set<Id> setSelfUnmatchedObjects = new set<Id>();             //set of unmatched objects self org 
   	    set<Id> setTargetUnmatchedObjects = new set<Id>();           //set of unmatched objects remote org
   	    
   	    //map the list from sef org
   	    for(Object_Information__c objSelfOrgInfo : lstSelfOrgObjects){
   	    	mapSelfOrgObjects.put(objSelfOrgInfo.API_Name__c,objSelfOrgInfo.Id);
   	    }
   	    
   	    // map the list from remote org
   	     for(Object_Information__c objTargetOrgInfo : lstRemoteOrgObjects){
   	    	mapTargetOrgObjects.put(objTargetOrgInfo.API_Name__c,objTargetOrgInfo.Id);
   	    }
         
        // map of matching Sobjects wrt to API Name and set of unmatched objects from target org                                                 
   	    for(Object_Information__c objTargetOrgInfo : lstRemoteOrgObjects){
   	    	if(mapSelfOrgObjects.keyset().contains(objTargetOrgInfo.API_Name__c)){
   	    		mapMatchingObjects.put(objTargetOrgInfo.Id,
   	    		                    mapSelfOrgObjects.get(objTargetOrgInfo.API_Name__c));
   	    	}
   	    	if(!mapSelfOrgObjects.keyset().contains(objTargetOrgInfo.API_Name__c)){
   	    		setTargetUnmatchedObjects.add(objTargetOrgInfo.Id);
   	    	}
   	    }
   	    //set of unmatched objects from self org
   	     for(Object_Information__c objSelfOrgInfo : lstSelfOrgObjects){
   	     	if(!mapTargetOrgObjects.keyset().contains(objSelfOrgInfo.API_Name__c)){
   	    		setSelfUnmatchedObjects.add(objSelfOrgInfo.Id);
   	    	}
   	     }
   	    
   	   
   	    system.debug('lstSelfOrgObjects....'+lstSelfOrgObjects.size());
   	    system.debug('lstRemoteOrgObjects....'+lstRemoteOrgObjects.size());
   	    system.debug('mapSelfOrgObjects....'+mapSelfOrgObjects.size()); 
   	    system.debug('mapMatchingObjects....'+mapMatchingObjects.size());   
   	    system.debug('setTargetUnmatchedObjects....'+setTargetUnmatchedObjects.size());   
   	    system.debug('setSelfUnmatchedObjects....'+setSelfUnmatchedObjects.size());  
   	    
   	    //call to method which update the comparison source field of all matching target objects
   	    if(mapMatchingObjects != null)
   	    	updateObjectComparisonSource(mapMatchingObjects,setSelfUnmatchedObjects,setTargetUnmatchedObjects);

   }
   
   //method will update the comparison source field of all matching target objects
   public static void updateObjectComparisonSource(map<Id,Id> pmapMatchingObject,
                                                    set<Id> psetSelfUnMatch,
                                                    set<Id> psetTargetUnMatch){
   	   //list for updateing records.													 
	   List<Object_Information__c> lstUpdateTargetObjectInfo = new List<Object_Information__c>();	
	   
   	   // list of target org matching objects 
   	   list<Object_Information__c> lstTargetObjectInfo = [select Id
   	                                                      from Object_Information__c
   	                                                       where Id IN: pmapMatchingObject.keySet()];
   	                                                       
   	   //creating list to update the comparison source field
   	   for(Object_Information__c objTargetInfo : lstTargetObjectInfo){
   	   	  objTargetInfo.Comparison_Source__c = pmapMatchingObject.get(objTargetInfo.Id);
		  lstUpdateTargetObjectInfo.add(objTargetInfo);
   	   }
		  
	   try{
		  if(!lstUpdateTargetObjectInfo.isEmpty()){
		  	//update the list to update the comparison source field 
		  	List<Database.Saveresult> saveResult = Database.update(lstUpdateTargetObjectInfo);
           	boolean isSuccess = true;                  //check for success if DML operation
           	for(Database.SaveResult sr:saveResult){
           		if(!sr.isSuccess())                    
                    isSuccess = false;
           		} 
           		// if Update is successfull, schedule the MetadataComparisonBatch using the resp scheduler.
           		if(isSuccess){
           			    Datetime systemDateTime = System.now();
    	                systemDateTime = systemDateTime.addSeconds(20);
    	                String cronExpression = constructCronExpression();
    	                System.schedule(METADATA_COMPARER_SCHEDULER + systemDateTime.getTime(), 
    	                         cronExpression, new MetadataComparerScheduler(pmapMatchingObject, psetSelfUnMatch, psetTargetUnMatch));
           		}   
           	 }
		  }
        catch(DmlException genException){
        	  //inserting the exception into custom object, Error Log 
           	  ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
          }                                                       
   }
   
   //update the comparison source field in detailed comparison 
   public static void updateComparisonSourceDetailedComparison(map<Id,Id> pmapMatchedObjectPairs){
   	    
   	   system.debug('pmapMatchedObjectPairs$$$$$$'+pmapMatchedObjectPairs);
   	   //list for updateing records.													 
	   List<Object_Information__c> lstUpdateTargetObjectInfo = new List<Object_Information__c>();
	   list<Object_Information__c> lstTargetObjectInfo = [select Id
   	                                                      from Object_Information__c
   	                                                       where Id IN: pmapMatchedObjectPairs.keySet()];
	    //creating list to update the comparison source field
   	   for(Object_Information__c objTargetInfo : lstTargetObjectInfo){
   	   	  objTargetInfo.Comparison_Source__c = pmapMatchedObjectPairs.get(objTargetInfo.Id);
		  lstUpdateTargetObjectInfo.add(objTargetInfo);
   	   }
   	   
   	   system.debug('lstUpdateTargetObjectInfo$$$$$$'+lstUpdateTargetObjectInfo);
   	   
   	   try{
		  if(!lstUpdateTargetObjectInfo.isEmpty()){
		  	//update the list to update the comparison source field 
		  	List<Database.Saveresult> saveResult = Database.update(lstUpdateTargetObjectInfo);
           	boolean isSuccess = true;                  //check for success if DML operation
           	for(Database.SaveResult sr:saveResult){
           		if(!sr.isSuccess())                    
                    isSuccess = false;
           		} 
           		// if Update is successfull, schedule the MetadataComparisonBatch using the resp scheduler.
           		if(isSuccess){
           			    updateFieldComparisonSource(pmapMatchedObjectPairs);
           		}  
           	 }
		  }
        catch(DmlException genException){
        	  //inserting the exception into custom object, Error Log 
           	  ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
          } 
   	   
   }
   
   
   	//Update Comparison Souce field of Target Field Information record match with Sorce record Api Name.
	public static void updateFieldComparisonSource(map<Id,Id> pmapMatchedObjectPairs)
	{
		map<Id,list<Field_Information__c>> mapTargetIdToFieldInfo = new map<Id,list<Field_Information__c>>();
		map<Id,list<Field_Information__c>> mapSourceIdToFieldInfo = new map<Id,list<Field_Information__c>>();
		
		set<Id> setSourceId = new set<Id>();
        for(Id objTargetId : pmapMatchedObjectPairs.keySet()){
           setSourceId.add(pmapMatchedObjectPairs.get(objTargetId));
        }
        
         for(Field_Information__c objFieldInfo : [Select Id,Api_Name__c, 
        											  Comparison_Source__c, 
        											  Parent_Object__c 
    												 From Field_Information__c 
                                                     Where Parent_Object__c IN: pmapMatchedObjectPairs.keyset()])
            {	
	          	if(mapTargetIdToFieldInfo.get(objFieldInfo.Parent_Object__c) == null)
	          	{
	          		List<Field_Information__c> lstFI = new List<Field_Information__c>();
	          		lstFI.add(objFieldInfo);
	          		mapTargetIdToFieldInfo.put(objFieldInfo.Parent_Object__c, lstFI);
	          	}
	          	else
	          	{
	          		mapTargetIdToFieldInfo.get(objFieldInfo.Parent_Object__c).add(objFieldInfo);
	          	}
           }	
        
        
          system.debug('mapTargetIdToFieldInfo........'+mapTargetIdToFieldInfo.size());
          
    
          for(Field_Information__c objFieldInfo : [Select Id,Api_Name__c, 
        											  Comparison_Source__c, 
        											  Parent_Object__c 
    												 From Field_Information__c 
                                                     Where Parent_Object__c IN: setSourceId])
          {	
	          	if(mapSourceIdToFieldInfo.get(objFieldInfo.Parent_Object__c) == null)
	          	{
	          		List<Field_Information__c> lstFI = new List<Field_Information__c>();
	          		lstFI.add(objFieldInfo);
	          		mapSourceIdToFieldInfo.put(objFieldInfo.Parent_Object__c, lstFI);
	          	}
	          	else
	          	{
	          		mapSourceIdToFieldInfo.get(objFieldInfo.Parent_Object__c).add(objFieldInfo);
	          	}
          }	
          
          system.debug('mapSourceIdToFieldInfo........'+mapSourceIdToFieldInfo.size());
          map<Id,map<String, Id>> mapSourceAPitoId = new map<Id,map<String, Id>>();
          
          if(mapSourceIdToFieldInfo!=null){
          	for(Id objSource : mapSourceIdToFieldInfo.keySet()){
          	 map<String, Id> mapTemp = new map<String, Id>();
	          	for(Field_Information__c objSourceFieldInfo : mapSourceIdToFieldInfo.get(objSource)){
	          		mapTemp.put(objSourceFieldInfo.Api_Name__c, objSourceFieldInfo.Id);
	          	}
          	    mapSourceAPitoId.put(objSource,mapTemp);
            } 
          }
          
          
          system.debug('mapSourceAPitoId........'+mapSourceAPitoId.size());                                           
	      List<Field_Information__c> lstUpdateTargetObjectFieldInfoRecord = new List<Field_Information__c>();
	    if(mapTargetIdToFieldInfo!=null){
	     for(Id objTarget: mapTargetIdToFieldInfo.keySet()){
	      	map<String, Id> mapTemp = mapSourceAPitoId.get(pmapMatchedObjectPairs.get(objTarget));
	      	for(Field_Information__c objTargetFieldInfo : mapTargetIdToFieldInfo.get(objTarget)){
	      		if(mapTemp.containsKey(objTargetFieldInfo.Api_Name__c)){
	      			objTargetFieldInfo.Comparison_Source__c = mapTemp.get(objTargetFieldInfo.Api_Name__c);
				    lstUpdateTargetObjectFieldInfoRecord.add(objTargetFieldInfo);
	      		}
	      	}
	     }
	    }  
	      
	          
	   system.debug('lstUpdateTargetObjectFieldInfoRecord........'+lstUpdateTargetObjectFieldInfoRecord.size());  
	   
	    try{
		  if(!lstUpdateTargetObjectFieldInfoRecord.isEmpty()){
		  	//update the list to update the comparison source field 
		  	List<Database.Saveresult> saveResult = Database.update(lstUpdateTargetObjectFieldInfoRecord);
           	boolean isSuccess = true;                  //check for success if DML operation
           	for(Database.SaveResult sr:saveResult){
           		if(!sr.isSuccess())                    
                    isSuccess = false;
           		} 
           		// if Update is successfull, schedule the MetadataComparisonBatch using the resp scheduler.
           		if(isSuccess){
           			    Datetime systemDateTime = System.now();
    	                systemDateTime = systemDateTime.addSeconds(20);
    	                String cronExpression = constructCronExpression();
    	               System.schedule(METADATA_COMPARER_SCHEDULER + systemDateTime.getTime(), 
    	                         cronExpression, new MetadataComparerScheduler(pmapMatchedObjectPairs));
           		}  
           	 }
		  }
        catch(DmlException genException){
        	  //inserting the exception into custom object, Error Log 
           	  ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
          } 
	   
	}
	
	
   //detailed comparison - map the Sobjets which are matched wrt API Name only, map the UnMatched map otherwise
   public static void matchingObjects(list<DynamicCustomField> plstObjectsToMatch){
     system.debug('plstObjectsToMatch................'+plstObjectsToMatch);
     map<Double,Id> mapSourceId = new map<Double,Id>();
     map<Double,Id> mapTargetId = new map<Double,Id>();
     map<Id,Id> mapMatchedObjectPairsToUpdateCompSource = new map<Id,Id>();
     
     for(Object_Information__c objObjectInfo : [select Id,
                                                Comparison_Pair__c
                                                from Object_Information__c
                                                where Org_Id__c=:Userinfo.getOrganizationId()]){
     	mapSourceId.put(objObjectInfo.Comparison_Pair__c,objObjectInfo.Id);
     }
     
     for(Object_Information__c objObjectInfo : [select Id,
                                                Comparison_Pair__c
                                                from Object_Information__c
                                                where Org_Id__c!=:Userinfo.getOrganizationId()]){
     	mapTargetId.put(objObjectInfo.Comparison_Pair__c,objObjectInfo.Id);
     }
     for(Double objmapTargetId : mapTargetId.keySet()){
     	mapMatchedObjectPairsToUpdateCompSource.put(mapTargetId.get(objmapTargetId),mapSourceId.get(objmapTargetId));
     }
           
     updateComparisonSourceDetailedComparison(mapMatchedObjectPairsToUpdateCompSource);
     /*  map<String,String> mapMatchedObjectPairs = new map<String,String>();
      
       map<String,String> mapUnMatchedObjectPairs = new map<String,String>();
      
       map<Id,Id> mapMatchedObjectPairsToUpdateCompSource = new map<Id,Id>();
        system.debug('pMapObjectsToMatch$$$$$$'+pMapObjectsToMatch);
       
       if(pMapObjectsToMatch!=null){
       	   for(String objStr:pMapObjectsToMatch.keySet()){
	       	  if(objStr.compareTo(pMapObjectsToMatch.get(objStr))==0)
	       	     mapMatchedObjectPairs.put(objStr,pMapObjectsToMatch.get(objStr));
	       	  else
	       	     mapUnMatchedObjectPairs.put(objStr,pMapObjectsToMatch.get(objStr));   
           }
       }
       
       system.debug('mapMatchedObjectPairs$$$$$$'+mapMatchedObjectPairs);
       
       set<String> setTargetMatchIds = new set<String>();
       if(mapMatchedObjectPairs!=null){
       	   for(String objStr:mapMatchedObjectPairs.keySet()){
       	     setTargetMatchIds.add(mapMatchedObjectPairs.get(objStr));
           }
       }
       system.debug('setTargetMatchIds$$$$$$'+setTargetMatchIds);
       
       map<String,Id> mapSourceApiToId = new map<String,Id>();
       map<String,Id> mapTargetApiToId = new map<String,Id>();
       
       for(Object_Information__c objSourceId : [select API_Name__c,Id from Object_Information__c
                                                where API_Name__c IN:mapMatchedObjectPairs.keySet()
                                                and Org_Id__c=:Userinfo.getOrganizationId()]){
       	  mapSourceApiToId.put(objSourceId.API_Name__c,objSourceId.Id);
       }
       system.debug('mapSourceApiToId$$$$$$'+mapSourceApiToId);
       
       for(Object_Information__c objtargetId : [select API_Name__c,Id from Object_Information__c
                                                where API_Name__c IN:setTargetMatchIds
                                                and Org_Id__c!=:Userinfo.getOrganizationId()]){
       	  mapTargetApiToId.put(objtargetId.API_Name__c,objtargetId.Id);
       }
       system.debug('mapTargetApiToId$$$$$$'+mapTargetApiToId);
       
       if(mapTargetApiToId!=null){
        	for(String str:mapTargetApiToId.keySet()){
       	      mapMatchedObjectPairsToUpdateCompSource.put(mapTargetApiToId.get(str),mapSourceApiToId.get(str));
         }
      }
       
       system.debug('mapMatchedObjectPairsToUpdateCompSource$$$$$$'+mapMatchedObjectPairsToUpdateCompSource);
       
       updateComparisonSourceDetailedComparison(mapMatchedObjectPairsToUpdateCompSource,mapUnMatchedObjectPairs);
   */
   } 
   
    //Method which constructs a cron expression fror scheduler
	private static String constructCronExpression(){
		Datetime currentDateTime = System.now();
	    currentDateTime = currentDateTime.addSeconds(30);
	    return '' + currentDateTime.second() + ' ' + currentDateTime.minute() + ' ' + currentDateTime.hour() 
	              + ' ' + currentDateTime.day() + ' ' + currentDateTime.month() + ' ? ' + currentDateTime.year();
	}
	
}