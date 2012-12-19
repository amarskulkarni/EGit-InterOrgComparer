/*  Batch class used to delete records of Comparison Log a custom obejct
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				 Amol Chaudhari		  22/11/2012			Intial Draft 
*/
global with sharing class DeleteComparisonLogBatch implements Database.Batchable<sObject>, Database.Stateful{
    private	String query;              //variable to store the query
    private string sessionId;          // variable to store the session Id parameter to batch
    private string serverUrl;          // varibale to store the server Url parameter to batch
    private string remoteOrgId;        // variable to store the org Id parameter to batch
    private map<String,String> mapComparisonObjects;
    private list<DynamicCustomField> lstObjectsToCompare;
    private string selfSession;
     
    global DeleteComparisonLogBatch(string pSessionId,string pServerUrl,string pRemoteOrgId){
    	sessionId = pSessionId;
    	serverUrl = pServerUrl; 
    	remoteOrgId = pRemoteOrgId;
		query = 'select Id, Name from Comparison_Log__c where Id!=null'; 
	}
	
	global DeleteComparisonLogBatch(string pSessionId,string pServerUrl,string pRemoteOrgId,
	                                                 list<DynamicCustomField> plstObjectsToCompare,String pselfSession){
    	sessionId = pSessionId;
    	serverUrl = pServerUrl; 
    	remoteOrgId = pRemoteOrgId;
    	//mapComparisonObjects = new map<String,String>();
    	//mapComparisonObjects = pmapComparisonObjects;
    	lstObjectsToCompare = plstObjectsToCompare;
    	selfSession = pselfSession;
		query = 'select Id, Name from Comparison_Log__c where Id!=null'; 
	}
	 
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
       	List<Comparison_Log__c> comparisonLogObjectList = (List<Comparison_Log__c>)scope;
       	try{ 
       		if(!comparisonLogObjectList.isEmpty())
        		delete comparisonLogObjectList;
	    }
	    catch(Exception genException){
	   	   ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
	    }
    } 
	
	global void finish(Database.BatchableContext BC){
		Datetime systemDateTime = System.now();
    	systemDateTime = systemDateTime.addSeconds(20); 
    	String cronExpression = constructCronExpression();
    	system.debug('cronExpression..............'+cronExpression);
    	if(lstObjectsToCompare==null)
    	System.schedule('DeleteComparisonLog'+ systemDateTime.getTime(), cronExpression, 
    						new DeleteMetadataBatchScheduler(sessionId, serverUrl, remoteOrgId));
    	else
    	System.schedule('DeleteComparisonLog'+ systemDateTime.getTime(), cronExpression, 
    						new DeleteMetadataBatchScheduler(sessionId, serverUrl,
    						                                  remoteOrgId,lstObjectsToCompare,selfSession));					
	}
	
	 //Method which constructs a cron expression
	private String constructCronExpression(){
		Datetime currentDateTime = System.now();
	    currentDateTime = currentDateTime.addSeconds(10);
	    return '' + currentDateTime.second() + ' ' + currentDateTime.minute() + ' ' + currentDateTime.hour() 
	              + ' ' + currentDateTime.day() + ' ' + currentDateTime.month() + ' ? ' + currentDateTime.year();
	}

}