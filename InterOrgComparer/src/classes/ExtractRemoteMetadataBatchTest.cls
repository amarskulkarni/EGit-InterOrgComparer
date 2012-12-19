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
    	CreateTestData.createObjectApiDetailed('Account');
     	CreateTestData.createObjectApi('Contact');
     	DynamicCustomField objDynamic = new DynamicCustomField();
     	objDynamic.sourceObject = 'Account';
     	objDynamic.targetObject = 'Contact';
     	objDynamic.srNo = 1;
     	list<DynamicCustomField> lstDynamicCustomField = new list<DynamicCustomField>();
     	lstDynamicCustomField.add(objDynamic);
     	
     	ExtractMetadataBatch objExtractMetadataBatch = new ExtractMetadataBatch(CreateTestData.SESSION_ID, 
     	                                                   CreateTestData.SERVER_URL, 
     	                                                           CreateTestData.ORG_ID,lstDynamicCustomField,
     	                                                            CreateTestData.SESSION_ID);
     	Test.startTest();
     	   Database.executeBatch(objExtractMetadataBatch);
     	Test.stopTest();
    }
}