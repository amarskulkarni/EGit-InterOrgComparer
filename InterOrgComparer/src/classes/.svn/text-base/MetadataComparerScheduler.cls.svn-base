/*  batch class which is used to compare the Sobjects and added the corresponding data
 *  into the ComparisonLog custom object for reportinng n all. 
 *		
 *	Revision History: 
 *	Version				Author				Date				Description 
 *	1.0				  Amol Chaudhari	  27/11/2012			Intial Draft 
 */
global with sharing class MetadataComparerScheduler implements Schedulable
{  
	//Constructor
	map<Id,Id> mapMatchingObject = new map<Id,Id>();
	set<Id> setSelfUnMatch = new set<Id>();
	set<Id> setTargetUnMatch = new set<Id>();
	
	map<Id,Id> mapMatchingObjectPairs = new map<Id,Id>();
	map<String,String> mapUmMatchedObjectPairs = new map<String,String>();
	
	global MetadataComparerScheduler(map<Id,Id> pmapMatchingObject,
                                      set<Id> psetSelfUnMatch,
                                      set<Id> psetTargetUnMatch){
        mapMatchingObject = pmapMatchingObject;
        setSelfUnMatch = psetSelfUnMatch;
        setTargetUnMatch = psetTargetUnMatch;                            	
    }
    
    global MetadataComparerScheduler(map<Id,Id> pmapMatchingObjectPairs){
       mapMatchingObjectPairs = pmapMatchingObjectPairs; 
      // mapUmMatchedObjectPairs = pmapUmMatchedObjectPairs;           	
    }
                                      
	global void execute(SchedulableContext pSchedulableContext)
    {
      if(mapMatchingObject!=null)
          Database.executeBatch(new MetadataComparerBatch(mapMatchingObject, setSelfUnMatch, setTargetUnMatch), 1); 
      else
          Database.executeBatch(new MetadataComparerBatch(mapMatchingObjectPairs), 1);     
    }
}