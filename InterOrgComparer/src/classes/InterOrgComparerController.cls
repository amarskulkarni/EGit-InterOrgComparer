/* SFMetadataController - connection to remote SFDC org and getting the session information, 
                          maintaining the same information across the org using cookies,
                          calling of REST requests to get the related metadata information
*  Revision History:
*
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          28/09/2012          Initial Draft 
*/
public with sharing class InterOrgComparerController {
	//list of SOjects of self org
	private List<Selectoption> SFDCCompleteObjectList = new List<Selectoption>();
    private List<Selectoption> SFDCObjectList = new List<Selectoption>();
    private List<Selectoption> SFDCObjectList1 = new List<Selectoption>();
    private List<Selectoption> SFDCObjectList2 = new List<Selectoption>();           
	//property of selected picklist values of SOjects self org 
	public string SFObject {get;set;}   //selected self org objects to compare
	public string SFObject1 {get;set;}
	public string SFObject2 {get;set;}
	//boolean property to check for remote SFDC sobjects slection panel                            
	public boolean isConnectedObjects{get;set;}                                 
	public string SFRemoteObject {get;set;}        //selected remote objects to compare
	public string SFRemoteObject1 {get;set;}  
	public string SFRemoteObject2 {get;set;} 
	//list of all metadata object list of other org
	private List<Selectoption> CompleteMetadataObjectList = new List<Selectoption>();
	private List<Selectoption> MetadataObjectList = new List<Selectoption>();
	private List<Selectoption> MetadataObjectList1 = new List<Selectoption>();  
	private List<Selectoption> MetadataObjectList2 = new List<Selectoption>();     
    public string username {get;set;}       //username of other org to connect
	public string password {get;set;}       // passowrd of other org to connect
	public string securitytoken {get;set;}  //security token of other org to connect
	public string enviroment {get;set;}     //org instance to connect
	public static string sessionID;         //sessionID of remote SFDC org 
	public boolean isloggedin{get;set;}    
	public string interOrgUsername{get;set;}   //Username for remote connected SFDC org
	public final Integer STATUS_SUCCSS_CODE = 200;              //status code http callout
    SendRequests sendRequests = new SendRequests();         //object of sendrequest class  
    JSONMetadataParser jsonMetadataParser = new JSONMetadataParser(); //object of JsonMetadataParser
    //List of select option to display as radio buttons
	private List<Selectoption> objectReportLabelList = new List<Selectoption>();
	//Selected radio option
	public String selectedObjectReport{get; set;}
	//Boolean variable to indicate when to display Extract Metadata button                      
	public Boolean isQuickCompareBtnDisabled{get; set;}
	//Boolean variable to indicate when to display Compare Objects button				
	public Boolean isFullCompareBtnDisabled{get; set;}
	//Boolean variable to indicate when to display radio inputs				
	public Boolean isRadioEnabled{get; set;}
	//Boolean variable to indicate when to display comparison output panel				
	public Boolean isComparisonPanelVisible{get; set;}	
    public final string INTER_ORG_SESSIONID = 'esplInterOrgSessionId';  //cookie name sessionID 
    public final string INTER_ORG_SERVERURL = 'esplInterOrgServerUrl';  //cookie name serverUrl
    public final string INTER_ORG_USERNAME = 'esplInterOrgUserName';    //cookie name username
    public final string INTER_ORG_ORGID = 'esplInterOrgOrgId';    //cookie name username
    public final string INTER_ORG_ORGUSERNAME = 'esplInterOrgUserName';    //cookie name username
    public final string INTER_ORG_ORGNAME = 'esplInterOrgName';    //cookie name username
    //characters used in the code for appending strings
    public final string APPEND_CHAR = '#';
    public final string OPEN_BRACKET = '(';
    public final string CLOSED_BRACKET = ')'; 
    public final string DEV_OR_PRODUCTION_NAME = system.label.Developer_Production;   //dev or prod 
    public final string SANDBOX_NAME = system.label.Sandbox;                          //sandbox
    private static final String RADIO_QUICK_COMPARE = system.label.Quick_Compare;   
	private static final String RADIO_DETAILED_COMPARE = system.label.Detailed_Compare;
	private Boolean isQuickCompareSelected;
	public string orgId{get;set;}                  // org Id of the org to which connected remotely
	public boolean isCompareButtonVisible{get;set;}
	public boolean isAdd2Row{get;set;}
	public boolean isAdd3Row{get;set;}
	public boolean isRemove2Row{get;set;}
	public boolean isRemove3Row{get;set;}
	public boolean removeRow{get;set;}
	public boolean addRow{get;set;}
	public string selfOrgUserName{get;set;}
	public string selfOrgName{get;set;}
	public string remoteOrgName{get;set;}
	public string remoteOrgUserName{get;set;}
	public CookieResponse objCookieResp;                     //instance of CookieResponse class
	private final string BATCH_PROGRESS_1 = 'Your request is in progress, you will receive an email notification at ';
    private final string BATCH_PROGRESS_2 = ', once the data extraction is completed';
    public List<DynamicCustomField> fieldList { get; set; }
	public boolean isButtonDisabled {get;set;}
	public boolean isCookieResponse{get;set;}
	public list<CookieResponse> lstCookieResp;
    //constructor for controller which sets and check for initial values and remote connection if exists
    public InterOrgComparerController(){
	 isButtonDisabled = false;
	 isCookieResponse = false;
	 lstCookieResp = new list<CookieResponse>();
	 checkforButtonDisable();
	 fieldList = new List<DynamicCustomField>();
     DynamicCustomField cf = new DynamicCustomField();
     cf.srNo = 1; 
     fieldList.add(cf);
     //getting the session information from stored cookies
 	 if(!Test.isRunningTest())
 	     lstCookieResp = CookieManager.getCookies();
 	 else
 	     setCookieResponse();    
 	 RestResponse restResponse = new RestResponse();   //instance of RestResponse class
 	 isCookieResponse = ((!lstCookieResp.isEmpty())&&(lstCookieResp[0].remoteSessionId!='')) ? true : false;
     //checking for sessionId is still valid -  if not show the login module again
     if(isCookieResponse){
	     objCookieResp = lstCookieResp[0];
	     restResponse = sendRequests.CheckForValidSessionId(objCookieResp.remoteSessionId,
		 	                                             objCookieResp.remoteServerUrl);                  
	     interOrgUsername = objCookieResp.remoteOrgUserName;
	     remoteOrgUserName = objCookieResp.remoteOrgUserName;
	     remoteOrgName = objCookieResp.remoteOrgName;
     }     
    //checking for status code - if 200, hide the login panel and get the remote SObject list
    if(restResponse!=null){
    	if(restResponse.statusCode == STATUS_SUCCSS_CODE){
	    getAllSFDCObjects();
	    system.debug('lstCookieResp..........'+lstCookieResp);
	    SFDCObjectList1 =  SFDCObjectList;
	    SFDCCompleteObjectList =  SFDCObjectList; 
	    isConnectedObjects=true;
	 	isloggedin =false;
	 	restResponse = sendRequests.getSobjectlist(objCookieResp.remoteSessionId,
	 	                                             objCookieResp.remoteServerUrl);
	    MetadataObjectList = jsonMetadataParser.getSobjectList(restResponse.rest_response_body);
	    CompleteMetadataObjectList = MetadataObjectList;
	    isQuickCompareBtnDisabled=true;
	    isFullCompareBtnDisabled = false;
	    isRadioEnabled = true;
	    isCompareButtonVisible = true;
		addRow = true;
		selfOrgUserName = UserInfo.getUserName();
		selfOrgName = UserInfo.getOrganizationName();
     }else{
    	setVariables();
      }
    }else{
    	setVariables();
    }    
    removeRow = false;
    selectedObjectReport = RADIO_DETAILED_COMPARE;
	isComparisonPanelVisible=true;
  }

	public void setCookieResponse(){
		CookieResponse objCookieResp = new CookieResponse();
        objCookieResp.remoteSessionId = CreateTestData.SESSION_ID;
        objCookieResp.remoteServerUrl = CreateTestData.SERVER_URL;
        objCookieResp.remoteOrgId = CreateTestData.ORG_ID;
        objCookieResp.remoteOrgName = CreateTestData.ORGNAME;
        objCookieResp.remoteOrgUserName = CreateTestData.USERNAME;
        lstCookieResp.add(objCookieResp);
	}
	
	public void setVariables(){
		isQuickCompareBtnDisabled=true;
		isFullCompareBtnDisabled = true;
		isRadioEnabled = false;
		isConnectedObjects=false;
		isloggedin =true;
		isCompareButtonVisible = false;
	}
	
//Method which populates a list to show as radio buttons on visualforce page
	public List<Selectoption> getObjectReportLabel(){
        if(ObjectReportLabelList.isEmpty()){
            ObjectReportLabelList.add(new Selectoption(RADIO_QUICK_COMPARE, RADIO_QUICK_COMPARE));
            ObjectReportLabelList.add(new Selectoption(RADIO_DETAILED_COMPARE, RADIO_DETAILED_COMPARE));
        }
        return ObjectReportLabelList;
    }
    
    
//Method which determines when to enable or disable Extract Metadata button
	public PageReference displayPanel(){
		if(selectedObjectReport.compareTo(RADIO_QUICK_COMPARE)==0){
			//isQuickCompareBtnDisabled=false;
			//isFullCompareBtnDisabled = true;
			isComparisonPanelVisible=false;
			isQuickCompareSelected = true;
			addRow = false;
			removeRow = false;
		}
		if(selectedObjectReport.compareTo(RADIO_DETAILED_COMPARE)==0){
			//isQuickCompareBtnDisabled=true;
			//isFullCompareBtnDisabled = false;
			new InterOrgComparerController();
			isComparisonPanelVisible=true;
			isQuickCompareSelected = false;
			if(fieldList.size()==3)
			   removeRow =true;
			else if(fieldList.size()==2){removeRow =true;addRow =true;}
			else
			    addRow =true;   
		}     
		return null; 
	}
	 
	//picklist for selection of remote org instance
	public List<SelectOption> getEnviromentOptions(){
		List<SelectOption> options = new List<SelectOption>();    //list of all org instances
		//adding select options in the select list
		options.add(new Selectoption(DEV_OR_PRODUCTION_NAME,DEV_OR_PRODUCTION_NAME));
		options.add(new Selectoption(SANDBOX_NAME,SANDBOX_NAME));
		return options; 
	}

	//calling the method for API names and label in the remotely connected SFDC org 
	public List<SelectOption> getMetadataObjectList() {
		return MetadataObjectList;
	}
     
	//calling the method for API names and label in the same org 
	public List<SelectOption> getSFDCObjectList() { 
		return SFDCObjectList;
	}

	//call the sendrequest methods for http callouts and gets the SOAP reponse for login 
	public pageReference login(){
		//calling login method to get connected
		LoginResponse loginresponse = sendRequests.login(username, password, securitytoken, enviroment);  
	    system.debug('loginresponse...$$$'+loginresponse);
		if(loginresponse.statusCode == 200){
		    system.debug('CONNECTED....!!!');
			RestResponse restResponse = new RestResponse();
			CookieManager.addCookies(loginresponse.sessionId, loginresponse.ServerUrl, 
			                           loginresponse.orgId, loginresponse.orgUserName, loginresponse.orgName);
			list<CookieResponse> lstCookieResp =CookieManager.getCookies();
			if((!lstCookieResp.isEmpty())&&(lstCookieResp[0].remoteSessionId!=''))
				objCookieResp = lstCookieResp[0];
			restResponse = sendRequests.getSobjectlist(loginresponse.sessionId,
		 	                                              loginresponse.ServerUrl);                 
			MetadataObjectList = jsonMetadataParser.getSobjectList(restResponse.rest_response_body);
		    getAllSFDCObjects();
		    SFDCObjectList1 =  SFDCObjectList;
		    SFDCCompleteObjectList =  SFDCObjectList; 
		    CompleteMetadataObjectList = MetadataObjectList;
			remoteOrgName = loginresponse.orgName;
			remoteOrgUserName =loginresponse.orgUserName;
			interOrgUsername = loginresponse.userName;
			isloggedin =false;
			isConnectedObjects = true;
			isQuickCompareBtnDisabled=true;
		    isFullCompareBtnDisabled = false;
		    isRadioEnabled = true;
		    isCompareButtonVisible = true;
		    addRow = true;
		    selfOrgUserName = UserInfo.getUserName();
			selfOrgName = UserInfo.getOrganizationName();
		}
		if(loginresponse.isError){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,system.label.Check_Credentials));
			return null;
		}
		RestResponse restResponse = sendRequests.getSobjectlist(loginresponse.sessionId, loginresponse.serverUrl);
		MetadataObjectList = jsonMetadataParser.getSobjectList(restResponse.rest_response_body);
		system.debug('restresponse--toParse....'+restResponse.rest_response_body);
		return null;
	} 
 
	//Retreives the API Name and Label of all SFDC objects in the self org  
	public void getAllSFDCObjects() {
	    Schema.Sobjecttype objSFDCObject;
	    //Retreive a Map of all SFDC Object Tokens and SFDC Objects from the Org
	    Map<String, Schema.Sobjecttype> GlobalDescribeMap = Schema.getGlobalDescribe();
	    //Check if new objects are created or Object list is requested for the first time
	    if(GlobalDescribeMap.size() > SFDCObjectList.size() || SFDCObjectList.isEmpty()) {
	        List<String> KeyList = new List<String>();
	        KeyList.addAll(GlobalDescribeMap.keySet());
	        KeyList.sort();  //Sort the Objects according to their names
	       
	    if(!SFDCObjectList.isEmpty())    //clear the list, if elements exist
	        SFDCObjectList.clear();
	           
	    for(String strKey : KeyList){
	        if(GlobalDescribeMap.containsKey(strKey))   //check whether the key exists
		        objSFDCObject = GlobalDescribeMap.get(strKey);
		        //Add the Label and API Name values to be displayed in the picklist in the following format: API Name(Label)
		        SFDCObjectList.add(new Selectoption(
		        objSFDCObject.getDescribe().getName(), 
		        objSFDCObject.getDescribe().getName() +OPEN_BRACKET+ objSFDCObject.getDescribe().getLabel()+CLOSED_BRACKET));
	        }
	     }
	}
	
	//getting the REST response by callouts and string the same metadata information(detailed) to the custom
	//object after JSON parsing
	public void detailedCompare(){
		system.debug('-----------------fieldList'+fieldList);
		ObjectMetadata objMetadata = new ObjectMetadata();
	
	 	RestResponse restResponse = new RestResponse();
		system.debug('SFObject......'+SFObject+'=='+SFRemoteObject);
		system.debug('Inter_org_SessionId......'+Inter_org_SessionId);
		//list<string> lstSFRemoteObject = SFRemoteObject.split(APPEND_CHAR);
		list<string> lstSelectedObjects = new list<string>();
		
	    updateReportStatus(system.label.Radio_Option_Detailed_Comparison);
	    String selfSession = Userinfo.getSessionId();
	    system.debug('-------------------------detailedCompare'+fieldList.size());
	    list<CookieResponse> lstCookieResp = CookieManager.getCookies();
	    Database.executeBatch(new DeleteComparisonLogBatch(objCookieResp.remoteSessionId,
		                                                    objCookieResp.remoteServerUrl,
		                                                    objCookieResp.remoteOrgId,
		                                                       fieldList,selfSession));
	  
	} 

	//getting the REST response by callouts and string the same metadata information(for all objects) to the custom
	//object after JSON parsing
	public void quickCompare(){
		updateReportStatus(system.label.Radio_Option_Quick_Comparison);
		Database.executeBatch(new DeleteComparisonLogBatch(objCookieResp.remoteSessionId, objCookieResp.remoteServerUrl, 
		                                                      objCookieResp.remoteOrgId));     
	}
	
	//getting the REST response by callouts and string the same metadata information to the custom
	//object after JSON parsing
	public pageReference compareMetadataObjects(){
		checkforButtonDisable();
	    if(selectedObjectReport.compareTo(RADIO_QUICK_COMPARE)==0){
	       quickCompare();
	    }
	    if(selectedObjectReport.compareTo(RADIO_DETAILED_COMPARE)==0){
	   	  detailedCompare();
	    }
		return null;
	}

	//insert the the object records(just a name here)  
	public static void initialBatchStep(string pSessionId, string pServerUrl, string pRemoteOrgId,
	                                                 list<DynamicCustomField> plstObjectsToCompare,string pselfSession){
	    List<Object_Information__c> objectInfoList = new List<Object_Information__c>();
	    for(DynamicCustomField objDynamicField : plstObjectsToCompare){
	    	Object_Information__c srcObjectInfo = new Object_Information__c();
	    	Object_Information__c targetObjectInfo = new Object_Information__c();
	    	srcObjectInfo.API_Name__c = objDynamicField.sourceObject;
		    srcObjectInfo.Org_Id__c = Userinfo.getOrganizationId();
		    srcObjectInfo.Comparison_Pair__c = objDynamicField.srNo;
		    objectInfoList.add(srcObjectInfo);
		    
		    targetObjectInfo.API_Name__c = objDynamicField.targetObject;
		    targetObjectInfo.Comparison_Pair__c = objDynamicField.srNo;
		    objectInfoList.add(targetObjectInfo);
	    }
		if(!objectInfoList.isEmpty()){
	        try{
				List<Database.Saveresult> saveResult = Database.insert(objectInfoList);
	           	boolean isSuccess = true;
	           	for(Database.SaveResult sr:saveResult){
	           		if(!sr.isSuccess())
	                    isSuccess = false;
	           		} 
	           		if(isSuccess)  
	           			Database.executeBatch(new ExtractMetadataBatch(pSessionId, pServerUrl, 
	           			                             pRemoteOrgId, plstObjectsToCompare,pselfSession),1);
	           		}
	         catch(DmlException genException){ 
	           	  ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
	           	}
	     }    
	 }
	 
	 
	 //invalidated the remotely connected sessionId 
	 public Pagereference logout(){
		//	Cookie Inter_org_SessionId= ApexPages.currentPage().getCookies().get(INTER_ORG_SESSIONID);
	    Cookie Inter_org_SessionId= new Cookie('esplInterOrgSessionId',null,null,-1,false);
		ApexPages.currentPage().setCookies(new Cookie[]{Inter_org_SessionId});
		Pagereference pref = new Pagereference('https://c.ap1.visual.force.com/apex/InterOrgComparer');
		return pref; 
     }
 
    //Method which retrieves all the objects in an org and inserts those records in
	//custom object Object_Information__c 
	public static void initialBatchStep(string pSessionId, string pServerUrl, string pRemoteOrgId){
     	Schema.Sobjecttype objSFDCObject;
		List<Object_Information__c> objectInfoList;
       
       	//Retreive a Map of all SFDC Object Tokens and SFDC Objects from the Org
       	Map<String, Schema.Sobjecttype> globalDescribeMap = Schema.getGlobalDescribe();
       
       	if(globalDescribeMap.size() > 0){
       		objectInfoList = new List<Object_Information__c>();
           	List<String> keyList = new List<String>();
           	keyList.addAll(globalDescribeMap.keySet());
           	keyList.sort();
           
           	for(String strKey : keyList){
                if(globalDescribeMap.containsKey(strKey))
                    objSFDCObject = globalDescribeMap.get(strKey);
                     
                Schema.Describesobjectresult objectResult = objSFDCObject.getDescribe();   
          		objectInfoList.add(new Object_Information__c(API_Name__c = objectResult.getName(), 
          								Org_Id__c = Userinfo.getOrganizationId(),
          								Label__c = objectResult.getLabel()));                                       
           	} 
           	 
           	if(!objectInfoList.isEmpty()){
           		try{
					List<Database.Saveresult> saveResult = Database.insert(objectInfoList);
           			boolean isSuccess = true;
           			for(Database.SaveResult sr:saveResult){
           				if(!sr.isSuccess())
                            isSuccess = false;
           			} 
           			if(isSuccess)  
           			   Database.executeBatch(new ExtractMetadataBatch(pSessionId, pServerUrl, pRemoteOrgId),1);
           		}
           		catch(DmlException genException){ 
           			ExceptionManager.logError(system.now(), genException.getMessage(), UserInfo.getUserId());
           		}
           	}
     	}
     }	

	//adding dynamic selectlist in form
	public void addRow1() {
	    system.debug('--------------fieldList'+fieldList);
        if(fieldList.size() < 3){
		    DynamicCustomField cf = new DynamicCustomField();
		    cf.srNo = fieldList.size()+1;
		    fieldList.add(cf);
		    removeRow = true;
		    system.debug('--------------fieldList ==end'+fieldList);
	    }
	    if(fieldList.size()==3)
	    	addRow = false;
    }
    
    //removing dynamic selectlist from form
    public void removeRow1() {
        if(fieldList.size()!=1){
        	 Integer cntDelete =0;
            for(Integer i = fieldList.size()-1; i>=0; i--) {
            cntDelete = cntDelete + 1;
            if(cntDelete  == 1) {
                fieldList.remove(i);
                addRow = true;
            }
          }
        }
       if(fieldList.size()==1)
           removeRow = false;
    }    
    
    
   //Method to update or insert the report status on selection of a radio option
	private void updateReportStatus(String pReportStatus){
		List<Report_Type__c> reportTypeList= [select Id, Report_Status__c from Report_Type__c limit 1];
		if(!reportTypeList.isEmpty()){
			reportTypeList[0].Report_Status__c = pReportStatus;
			update reportTypeList;
		}
		else{
			Report_Type__c reportTypeObject = new Report_Type__c(Report_Status__c = pReportStatus);
			insert reportTypeObject;
		}
	}
	
	//checks for whether to disable the compare button or not
	public void checkforButtonDisable(){
		Integer batchStatus = CheckForBatchStatus.checkforBatchStatus('MetadataComparerBatch');
		system.debug('batchStatus...........'+batchStatus);
		if(batchStatus!=1){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
	        			BATCH_PROGRESS_1+getRecipientEmailAddress()+BATCH_PROGRESS_2));
	        isButtonDisabled = true; 			
		}  
		else
		     isButtonDisabled = false; 
	}
	
	
	//Method used to populate recipient's email address list
	public static String getRecipientEmailAddress(){
		List<String> recipientEmailList = new List<String>();  //List to hold recipient's email address
		Batch_Job_Configuration__c batchJobConfigurationCustomSetting = Batch_Job_Configuration__c.getOrgDefaults();
		if(batchJobConfigurationCustomSetting != null)
			if(batchJobConfigurationCustomSetting.Email_Address__c != null)
				recipientEmailList.add(batchJobConfigurationCustomSetting.Email_Address__c);
			else{
				User activeUser = [Select Email From User where Id =: UserInfo.getUserId() limit 1];
	    		String userEmail = activeUser.Email;	    
	    		recipientEmailList.add(userEmail);				
			}
	    if(!recipientEmailList.isEmpty())
	    	return recipientEmailList[0];
	    return null;
	}  
}