/*  Class which serves the purpose of creating test data for object, field and child
 *  relationship information
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0			  Amol Chaudhari		18/12/2012			Intial Draft 
 */
public with sharing class CreateTestData {
	//final variables 
	public static final string USERNAME = 'test@test.com';
	public static final string PASSWORD = 'test@12345';
	public static final string SECURITY_TOKEN = ''; 
	public static final string ENVIORMENT_DEV = 'Developer/Production';
	public static final string ENVIORMENT_SANDBOX = 'Sandbox';
	public static final string SESSION_ID = '00D90000000YYpr!AQkAQGItxGayPzRLb3g2z96MsVuJnidnW2fZAUpNEKcq_i5tjmV_oj.eZZHn90l0A9PbZtgvuTIVUlahKDPYqgXuhR5Y9Md4';
	public static final string SERVER_URL = 'https://ap1-api.salesforce.com/services/Soap/u/21.0/00D90000000YYpr';
	public static final string ORG_ID = 't001';
	public static final string ORGNAME = 'test';
	
	//Method to create test data for Object_Information__c custom object
	public static void createObjectInformationTestData(){
		List<Object_Information__c> objectInfoList = new List<Object_Information__c>();
		objectInfoList.add(new Object_Information__c(API_Name__c = system.Label.Account_String));
		objectInfoList.add(new Object_Information__c(API_Name__c = system.Label.Contact_String));
		insert objectInfoList;
		List<Object_Information__c> objInfoList = new List<Object_Information__c>();
		for(Object_Information__c objInfo: objectInfoList){
			objInfoList.add(MetadataManager.getObjectMetadata(objInfo.API_Name__c, objInfo.Id));	
		}
		update objInfoList;
		createFieldInformationTestData(objInfoList);
		createChildRelationshipTestData(objInfoList);
	}
	
	//Mehtod to create test data for Field_Information__c custom object
	public static void createFieldInformationTestData(List<Object_Information__c> pObjInfoList){
		List<Field_Information__c> fieldInfoList = new List<Field_Information__c>();
		for(Object_Information__c objInfo: pObjInfoList){
			fieldInfoList.addAll(MetadataManager.getFieldMetadata(objInfo.API_Name__c, objInfo.Id));
		}
		insert fieldInfoList;
	}
	
	//Method to create test data for Child_Relationship__c custom object
	public static void createChildRelationshipTestData(List<Object_Information__c> pObjInfoList){
		List<Child_Relationship__c> childRelationshipList = new List<Child_Relationship__c>();
		for(Object_Information__c objInfo: pObjInfoList){
			childRelationshipList.addAll(MetadataManager.getChildRelationshipMetadata(objInfo.API_Name__c, objInfo.Id));
		}
		insert childRelationshipList;
	}
	
	public static void createReportType(){
		Report_Type__c objReportType = new Report_Type__c(Report_Status__c=System.Label.Radio_Comparison_Report);
	    insert objReportType;
	}
	
	//Object data - remote org
	public static void createRemoteObjectInformationTestData(){
		SendRequests objSendRequests = new SendRequests();
		RestResponse objRestResponse = new RestResponse();
		ObjectMetadata objMetadata = new ObjectMetadata();
		AddMetadata objAddData = new AddMetadata();
		JSONMetadataParser objJsonParser = new JSONMetadataParser();
		 
		List<Object_Information__c> objectInfoList = new List<Object_Information__c>();
		objectInfoList.add(new Object_Information__c(API_Name__c = system.Label.Account_String));
		insert objectInfoList;
		objRestResponse = objSendRequests.getObjectMetadata(SESSION_ID, SERVER_URL, system.Label.Account_String);
		objMetadata = objJsonParser.getSobjectMetadata(objRestResponse.rest_response_body);
		String interOrgId = Userinfo.getOrganizationId();
		List<Object_Information__c> objInfoList = new List<Object_Information__c>();
		for(Object_Information__c objInfo: objectInfoList){
			objAddData.insertObjectInfo(objMetadata, objInfo.Id,interOrgId);	
		}
	//	objAddData.insertObjectInfo(objMetadata, objectInformationId, interOrgId)
	} 
	
	//initial setup
	public static void createObjectApi(String pObject){
		List<Object_Information__c> objectInfoList = new List<Object_Information__c>();
		objectInfoList.add(new Object_Information__c(API_Name__c = pObject));
		insert objectInfoList;
	}
	
	public static void createObjectApiDetailed(String pObject){
		List<Object_Information__c> objectInfoList = new List<Object_Information__c>();
		objectInfoList.add(new Object_Information__c(API_Name__c = pObject,Org_Id__c=ORG_ID));
		insert objectInfoList;
	}
}