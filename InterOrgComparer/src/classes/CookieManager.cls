/* CookieManager - Handles all the Cookies which is to set or get for maintaing across the current SFDC org.
*  Revision History:
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari         30/11/2012          Initial Draft 
*/
public with sharing class CookieManager {
	//final variables
	public static final string INTER_ORG_SESSIONID = system.label.cookie_esplInterOrgSessionId; //cookie name sessionID 
    public static final string INTER_ORG_SERVERURL = system.label.cookie_esplInterOrgServerUrl;  //cookie name serverUrl
    public static final string INTER_ORG_USERNAME = system.label.cookie_esplInterOrgUserName;    //cookie name username
    public static final string INTER_ORG_ORGID = system.label.cookie_esplInterOrgOrgId;    //cookie name username
    public static final string INTER_ORG_ORGUSERNAME = system.label.cookie_esplInterOrgUserName;    //cookie name username
    public static final string INTER_ORG_ORGNAME = system.label.cookie_esplInterOrgName;    //cookie name username
   
    // getting the Cookie values of remotely connected org and returns the CookieResponse instance 
    public static list<CookieResponse> getCookies(){
    	//list of CookieResponse class which is to be returned as a response
    	list<CookieResponse> lstCookies = new list<CookieResponse>();
    	//instance of the CookieResponse class which is to be added in list for return  
    	CookieResponse objCookies = new CookieResponse();
    	//getting the values of all cookies
    	Cookie Inter_org_SessionId1 = ApexPages.currentPage().getCookies().get(INTER_ORG_SESSIONID);
	 	Cookie Inter_org_ServerUrl1= ApexPages.currentPage().getCookies().get(INTER_ORG_SERVERURL);
	 	Cookie Inter_org_userName1 = ApexPages.currentPage().getCookies().get(INTER_ORG_USERNAME);
	 	Cookie Inter_org_orgName1 = ApexPages.currentPage().getCookies().get(INTER_ORG_ORGNAME);
	 	Cookie Inter_org_orgId1 = ApexPages.currentPage().getCookies().get(INTER_ORG_ORGID);
	 	//assigning the cookies values to CookieResponse class's instance
	 	if(Inter_org_SessionId1 != null && Inter_org_ServerUrl1 != null && Inter_org_userName1 !=null 
	 	         && Inter_org_orgName1!=null && Inter_org_orgId1!=null){ 
				 	    objCookies.remoteSessionId = Inter_org_SessionId1.getValue();
				 	    objCookies.remoteServerUrl = Inter_org_ServerUrl1.getValue();
				 	    objCookies.remoteOrgName = Inter_org_orgName1.getValue();
				 	    objCookies.remoteOrgId = Inter_org_orgId1.getValue();
				 	    objCookies.remoteOrgUserName = Inter_org_userName1.getValue();
	 	}
	 	
	 	//add instance to the list
	 	if(objCookies!=null)
	 	   lstCookies.add(objCookies);
	 	//returning CookieResponse list as a response
	 	return lstCookies;   
    }
    
    public static void addCookies(String pSessionId, String pServerUrl, String pOrgId,
                                      String pOrgUserName, String pOrgName){
    	
    	Cookie Inter_org_SessionId1 = new Cookie(INTER_ORG_SESSIONID,pSessionId,null,-1,false);
		Cookie Inter_org_ServerUrl1 = new Cookie(INTER_ORG_SERVERURL,pServerUrl,null,-1,false);
		Cookie Inter_org_userName1 = new Cookie(INTER_ORG_USERNAME,pOrgUserName,null,-1,false);
		Cookie Inter_org_orgId1 = new Cookie(INTER_ORG_ORGID,pOrgId,null,-1,false);
		Cookie Inter_org_orgUserName1 = new Cookie(INTER_ORG_ORGUSERNAME,pOrgUserName,null,-1,false);
		Cookie Inter_org_orgName1 = new Cookie(INTER_ORG_ORGNAME,pOrgName,null,-1,false);
		
		ApexPages.currentPage().setCookies(new Cookie[]{Inter_org_SessionId1});
		ApexPages.currentPage().setCookies(new Cookie[]{Inter_org_ServerUrl1});
		ApexPages.currentPage().setCookies(new Cookie[]{Inter_org_userName1});
		ApexPages.currentPage().setCookies(new Cookie[]{Inter_org_orgId1});
		ApexPages.currentPage().setCookies(new Cookie[]{Inter_org_orgName1});
		ApexPages.currentPage().setCookies(new Cookie[]{Inter_org_orgUserName1});
    }
    
}