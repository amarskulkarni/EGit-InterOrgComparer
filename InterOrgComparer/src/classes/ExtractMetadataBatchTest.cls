/* Test class for ExtractMetadataBatch
*  Revision History:
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          19/12/2012          Initial Draft 
*/
@isTest
public with sharing class ExtractMetadataBatchTest {
     static testMethod void extractMeatadataQuick() {
     	CreateTestData.createObjectApi(system.Label.Account_String);
     	ExtractMetadataBatch objExtractMetadataBatch = new ExtractMetadataBatch(CreateTestData.SESSION_ID, 
     	                                                   CreateTestData.SERVER_URL, 
     	                                                           CreateTestData.ORG_ID);
     	Test.startTest();
     	   Database.executeBatch(objExtractMetadataBatch);
     	Test.stopTest();
     	
     }
     
     static testMethod void extractMeatadataDetailed() {
     	CreateTestData.createObjectApiDetailed(system.Label.Account_String);
     	CreateTestData.createObjectApi(system.Label.Contact_String);
     	DynamicCustomField objDynamic = new DynamicCustomField();
     	objDynamic.sourceObject = system.Label.Account_String;
     	objDynamic.targetObject = system.Label.Contact_String;
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