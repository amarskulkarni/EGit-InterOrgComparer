/*  Schedular class for scheduling DeleteMetadataBatch batch job  
*	Revision History: 
*	Version				 Author				  Date				Description 
*	1.0				  Amol Chaudhari		22/11/2012			Intial Draft 
*/
global with sharing class DeleteMetadataBatchScheduler implements Schedulable{
	//remote org session details
	private string sessionId;       
	private string serverUrl;
	private string remoteOrgId; 
	private map<String,String> mapComparisonObjects;
	private list<DynamicCustomField> lstObjectsToCompare;
	private string selfSession;              
	
	 
	global DeleteMetadataBatchScheduler(string pSessionId, string pServerUrl, string pRemoteOrgId){
		this.sessionId = pSessionId;
		this.serverUrl = pServerUrl;
		this.remoteOrgId = pRemoteOrgId;
	}
	
	global DeleteMetadataBatchScheduler(string pSessionId, string pServerUrl, string pRemoteOrgId,
	                                     list<DynamicCustomField> plstObjectsToCompare,string pselfSession){
		this.sessionId = pSessionId;
		this.serverUrl = pServerUrl;
		this.remoteOrgId = pRemoteOrgId;
		this.selfSession = pselfSession;
		//mapComparisonObjects = new map<String,String>();
		//mapComparisonObjects = pmapComparisonObjects;
		lstObjectsToCompare = plstObjectsToCompare;
	}
	 
	//calling DeleteMetadataBatch for deleting object, field and child relationships level metadata information
	global void execute(SchedulableContext pSchedulableContext)
    {
    	if(lstObjectsToCompare==null)
    	    Database.executeBatch(new DeleteMetadataBatch(sessionId, serverUrl, remoteOrgId), 1);
    	else
    	    Database.executeBatch(new DeleteMetadataBatch(sessionId, serverUrl, remoteOrgId, lstObjectsToCompare,selfSession), 1);
    	    
    } 
}