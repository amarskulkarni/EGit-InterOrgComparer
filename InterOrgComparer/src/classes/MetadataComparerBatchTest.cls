/* Test class for MetadataComparerBatch
*  Revision History:
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          19/12/2012          Initial Draft 
*/
@isTest
private class MetadataComparerBatchTest {

    static testMethod void metadataComparerDetailed() {
        CreateTestData.createObjectApiDetailed('Account');
        Object_Information__c objSrc = [select Id from Object_Information__c where API_Name__c='Account'];
        String srcId = objSrc.Id;       
        CreateTestData.createObjectApiDetailed('Contact');
        Object_Information__c objTarget = [select Id from Object_Information__c where API_Name__c='Contact'];
        String targetId = objTarget.Id;
    }
}