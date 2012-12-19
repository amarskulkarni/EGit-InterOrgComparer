/*  Schedular class which used to call the InitialBatchstep which will add the basic API Name info
*    for further batch processing.	
*	Revision History: 
*	Version				 Author				  Date				Description 
*	1.0				  Amol Chaudhari		26/11/2012			Intial Draft 
*/

global with sharing class InitialBatchSetupScheduler implements Schedulable{
	private string sessionId;
	private string serverUrl;
	private string remoteOrgId;
	public map<String,String> mapComparisonObjects;
	private list<DynamicCustomField> lstObjectsToCompare;
	private string selfSession; 
	
	public InitialBatchSetupScheduler(string pSessionId, string pServerUrl, string pRemoteOrgId){
		this.sessionId = pSessionId;
		this.serverUrl = pServerUrl;
		this.remoteOrgId = pRemoteOrgId; 
	}
	
	public InitialBatchSetupScheduler(string pSessionId, string pServerUrl, string pRemoteOrgId,
	                                  list<DynamicCustomField> plstObjectsToCompare,string pselfSession){
		this.sessionId = pSessionId;
		this.serverUrl = pServerUrl; 
		this.remoteOrgId = pRemoteOrgId;
		//mapComparisonObjects = new map<String,String>();
    	//mapComparisonObjects = pmapComparisonObjects;
    	//lstObjectsToCompare =  new list<DynamicCustomField>();
    	this.selfSession = pselfSession;
    	lstObjectsToCompare =  plstObjectsToCompare;
	} 
	  
	global void execute(SchedulableContext pSchedulableContext){
		if(lstObjectsToCompare==null)
    	    InterOrgComparerController.initialBatchStep(sessionId, serverUrl, remoteOrgId);
    	else
    	    InterOrgComparerController.initialBatchStep(sessionId, serverUrl, remoteOrgId, lstObjectsToCompare, selfSession);    
    }
}