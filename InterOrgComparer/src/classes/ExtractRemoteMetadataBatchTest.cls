/* Test class for ExtractRemoteMetadataBatch
*  Revision History:
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          19/12/2012          Initial Draft 
*/
@isTest
public with sharing class ExtractRemoteMetadataBatchTest {
    static testMethod void extractRemoteMeatadataQuick(){
    	CreateTestData.createObjectApi('Account');
     	ExtractRemoteMetadataBatch objExtractMetadataBatch = new ExtractRemoteMetadataBatch(CreateTestData.SESSION_ID, 
     	                                                   CreateTestData.SERVER_URL, 
     	                                                           CreateTestData.ORG_ID);
     	Test.startTest();
     	   Database.executeBatch(objExtractMetadataBatch);
     	Test.stopTest();
    }
    
    static testMethod void extractRemoteMeatadataDetailed(){
    	RestResponse restResponse = new RestResponse();
     	SendRequests objSendRequests = new SendRequests();
     	AddMetadata addMetadata = new AddMetadata();
     	JSONMetadataParser jsonparser = new JSONMetadataParser();
     	ObjectMetadata objMetadata = new ObjectMetadata();
     	
    	CreateTestData.createObjectApiDetailed('Account');
    	Object_Information__c objSrc = [select Id from Object_Information__c where API_Name__c='Account'];
        Id srcId = objSrc.Id;       
     	CreateTestData.createObjectApi('Contact');
     	DynamicCustomField objDynamic = new DynamicCustomField();
     	objDynamic.sourceObject = 'Account';
     	objDynamic.targetObject = 'Contact';
     	objDynamic.srNo = 1;
     	list<DynamicCustomField> lstDynamicCustomField = new list<DynamicCustomField>();
     	lstDynamicCustomField.add(objDynamic);
     	restResponse =  objSendRequests.getObjectMetadata(CreateTestData.SESSION_ID
                                                                    ,CreateTestData.SERVER_URL,'Account');
        objMetadata = jsonparser.getSobjectMetadata(restResponse.rest_response_body);
        addMetadata.insertObjectInfo(objMetadata,srcId,'t001');
        
     	ExtractRemoteMetadataBatch objExtractMetadataBatch = new ExtractRemoteMetadataBatch(CreateTestData.SESSION_ID, 
     	                                                   CreateTestData.SERVER_URL, 
     	                                                           CreateTestData.ORG_ID,lstDynamicCustomField);
     	Test.startTest();
     	   Database.executeBatch(objExtractMetadataBatch);
     	Test.stopTest();
    }
}