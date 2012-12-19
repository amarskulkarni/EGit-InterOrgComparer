/* Login Controller -  for calling functions of http request to other org and 
   getting corresponding sessionId and serverUrl
*  Revision History:
*
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          26/09/2012          Initial Draft 
*/

public with sharing class SFLoginController {
	public string username {get;set;}       //username of other org to connect
	public string password {get;set;}       // passowrd of other org to connect
	public string securitytoken {get;set;}  //security token of other org to connect
	public string enviroment {get;set;}     //org instance to connect
    private List<Selectoption> SFDCObjectList = new List<Selectoption>();  
    public string SFObject {get;set;} 
    public static string sessionID;
    private final string OK = 'ok';
    private final string STATUS = 'status';
    private final string DEV_PROD = 'Developer/Production';
    private final string SANDBOX = 'Sandbox';
    
  
	public List<SelectOption> getEnviromentOptions(){
		  List<SelectOption> options = new List<SelectOption>();    //list of all org instances
		  //adding select options in the select list
		  options.add(new Selectoption(DEV_PROD,DEV_PROD));
		  options.add(new Selectoption(SANDBOX,SANDBOX));
		  return options; 
	} 
	
	//call the sendrequest methods for http callouts and gets the SOAP reponse for login 
	public pageReference login(){
		 SendRequests objSendRequests = new SendRequests();         //object of sendrequest class  
	     LoginResponse loginresponse = objSendRequests.login(username, password, securitytoken, enviroment);  //calling login method to get connected
		 system.debug('loginresponse....:'+loginresponse);
		 system.debug('loginresponse.sessionId...:'+loginresponse.sessionId);
		 sessionID = loginresponse.sessionId;
	     system.debug('CONNECTED....!!!');
		 RestResponse restresponse = objSendRequests.sendMetadataRequest(loginresponse.sessionId, loginresponse.serverUrl);
	     system.debug('restresponse....'+restresponse.rest_response_body);
	     Pagereference pRef = page.InterOrgComparer;
	     pRef.getParameters().put(STATUS,OK);
		 return null;	
		
		//error to be displyed - validationn check depends on status
	} 
	 
}