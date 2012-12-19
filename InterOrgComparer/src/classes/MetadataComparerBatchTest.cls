/* Test class for MetadataComparerBatch
*  Revision History:
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          19/12/2012          Initial Draft 
*/
@isTest
private class MetadataComparerBatchTest {

    static testMethod void metadataComparerDetailed() {
    	RestResponse restResponse = new RestResponse();
     	SendRequests objSendRequests = new SendRequests();
     	AddMetadata addMetadata = new AddMetadata();
     	JSONMetadataParser jsonparser = new JSONMetadataParser();
     	ObjectMetadata objMetadata = new ObjectMetadata();
     	
        CreateTestData.createObjectApiDetailed('Account');
        Object_Information__c objSrc = [select Id from Object_Information__c where API_Name__c='Account'];
        Id srcId = objSrc.Id;       
        List<Object_Information__c> objectInfoList = new List<Object_Information__c>();
		objectInfoList.add(new Object_Information__c(API_Name__c = 'Contact',
		                                                 Comparison_Source__c=srcId));
		insert objectInfoList;
        Object_Information__c objTarget = [select Id from Object_Information__c where API_Name__c='Contact'];
        Id targetId = objTarget.Id;
        map<Id,Id> mapObjectsToMatch = new map<Id,Id>();
        map<Id,Id> mapTargetVsSrc = new map<Id,Id>();
        mapObjectsToMatch.put(srcId, targetId);
        mapTargetVsSrc.put(targetId, srcId);
        restResponse =  objSendRequests.getObjectMetadata(CreateTestData.SESSION_ID
                                                                    ,CreateTestData.SERVER_URL,'Account');
        objMetadata = jsonparser.getSobjectMetadata(restResponse.rest_response_body);
        addMetadata.insertObjectInfo(objMetadata,srcId,'t001');
        
        restResponse =  objSendRequests.getObjectMetadata(CreateTestData.SESSION_ID
                                                                    ,CreateTestData.SERVER_URL,'Contact');
        objMetadata = jsonparser.getSobjectMetadata(restResponse.rest_response_body);
        addMetadata.insertObjectInfo(objMetadata,targetId,'s001');
        MatchObjects.updateComparisonSourceDetailedComparison(mapTargetVsSrc);
        
        MetadataComparerBatch objMetadataComparerBatch = new MetadataComparerBatch(mapObjectsToMatch);
        Test.startTest();
            Database.executeBatch(objMetadataComparerBatch);
        Test.stopTest();
    }
    
     static testMethod void metadataComparerQuick(){
     	
     	set<Id> setSrcUnMatch = new set<Id>();
        set<Id> settargetUnMatch = new set<Id>();
     	CreateTestData.createObjectApiDetailed('Account');
     	CreateTestData.createObjectApiDetailed('Lead');
     	CreateTestData.createObjectApiDetailed('Product2');
     	Object_Information__c objSrc = [select Id from Object_Information__c where API_Name__c='Account'];
        Id srcId = objSrc.Id;       
        List<Object_Information__c> objectInfoList = new List<Object_Information__c>();
		objectInfoList.add(new Object_Information__c(API_Name__c = 'Contact',Org_Id__c=CreateTestData.ORG_ID,
		                                                 Comparison_Source__c=srcId));
		insert objectInfoList;
        Object_Information__c objTarget = [select Id from Object_Information__c where API_Name__c='Contact'];
        Id targetId = objTarget.Id;
        map<Id,Id> mapObjectsToMatch = new map<Id,Id>();
        mapObjectsToMatch.put(srcId, targetId);
        Object_Information__c objSrcUnMatch = [select Id from Object_Information__c where API_Name__c='Lead'];
        Object_Information__c objTargetUnMatch = [select Id from Object_Information__c where API_Name__c='Product2'];
        setSrcUnMatch.add(objSrcUnMatch.Id);
        settargetUnMatch.add(objTargetUnMatch.Id);
        MetadataComparerBatch objMetadataComparerBatch = new MetadataComparerBatch(mapObjectsToMatch,setSrcUnMatch,setTargetUnMatch);
        Test.startTest();
            Database.executeBatch(objMetadataComparerBatch);
        Test.stopTest();
     }
}