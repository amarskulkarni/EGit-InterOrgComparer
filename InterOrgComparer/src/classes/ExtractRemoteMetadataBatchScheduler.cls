global with sharing class ExtractRemoteMetadataBatchScheduler implements Schedulable{
	private string sessionId;
	private string serverUrl;
	private string remoteOrgId; 
	private map<String,String> mapComparisonObjects;
	private list<DynamicCustomField> lstObjectsToCompare;
	 
	public ExtractRemoteMetadataBatchScheduler(string pSessionId, string pServerUrl){
		sessionId = pSessionId;
		serverUrl = pServerUrl;    
	}
	
	public ExtractRemoteMetadataBatchScheduler(string pSessionId, string pServerUrl, string pRemoteOrgId,
	                                     list<DynamicCustomField> plstObjectsToCompare){
		sessionId = pSessionId;
		serverUrl = pServerUrl;
		remoteOrgId = pRemoteOrgId;
		lstObjectsToCompare = plstObjectsToCompare;    
	}
	
	 
	global void execute(SchedulableContext pSchedulableContext)
    { 
		if(lstObjectsToCompare==null)
    	    Database.executeBatch(new ExtractRemoteMetadataBatch(sessionId, serverUrl, remoteOrgId), 1);
    	else
    	    Database.executeBatch(new ExtractRemoteMetadataBatch(sessionId, serverUrl, remoteOrgId, 
    	                                      lstObjectsToCompare), 1);	
    } 
}