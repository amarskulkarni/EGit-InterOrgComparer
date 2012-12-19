/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SendRequestsTest {

    static testMethod void devLogin() {
        SendRequests objSendRequests = new SendRequests();
        Test.startTest();
        LoginResponse objLoginResponse = objSendRequests.login(CreateTestData.USERNAME, CreateTestData.PASSWORD
                                                 , CreateTestData.SECURITY_TOKEN, CreateTestData.ENVIORMENT_DEV);
        Test.stopTest();
        system.assert(objLoginResponse.sessionId!=null);                                                                    
    }
    
    static testMethod void sandboxLogin() {
        SendRequests objSendRequests = new SendRequests();
        Test.startTest();
        LoginResponse objLoginResponse = objSendRequests.login(CreateTestData.USERNAME, CreateTestData.PASSWORD
                                                 , CreateTestData.SECURITY_TOKEN, CreateTestData.ENVIORMENT_SANDBOX);
        Test.stopTest();
        system.assert(objLoginResponse.sessionId!=null);
    }
    
    static testMethod void checkForValidSession() {
        SendRequests objSendRequests = new SendRequests();
        RestResponse objRestResponse = new RestResponse();
        Test.startTest();
        objRestResponse = objSendRequests.CheckForValidSessionId(CreateTestData.SESSION_ID, CreateTestData.SERVER_URL);
        Test.stopTest();
        system.assert(objRestResponse.statusCode==200);
    }
    
      static testMethod void getObjectMetadata() {
        SendRequests objSendRequests = new SendRequests();
        RestResponse objRestResponse = new RestResponse();
        Test.startTest();
        objRestResponse = objSendRequests.getObjectMetadata(CreateTestData.SESSION_ID, CreateTestData.SERVER_URL, 'Account');
        Test.stopTest();
        system.assert(objRestResponse.statusCode==200);
    }
    
     static testMethod void getSobjectlist() {
        SendRequests objSendRequests = new SendRequests();
        RestResponse objRestResponse = new RestResponse();
        Test.startTest();
        objRestResponse = objSendRequests.getSobjectlist(CreateTestData.SESSION_ID, CreateTestData.SERVER_URL);
        Test.stopTest();
        system.assert(objRestResponse.statusCode==200);
    }
    
    static testMethod void sendMetadataRequest() {
        SendRequests objSendRequests = new SendRequests();
        RestResponse objRestResponse = new RestResponse();
        Test.startTest();
        objRestResponse = objSendRequests.sendMetadataRequest(CreateTestData.SESSION_ID, CreateTestData.SERVER_URL);
        Test.stopTest();
        system.assert(objRestResponse.statusCode==200);
    }
    
    static testMethod void addObjects() {
        CreateTestData.createRemoteObjectInformationTestData();
        list<Object_Information__c> lst = [select Id from Object_Information__c];
        Test.startTest();
        
        Test.stopTest();
        system.assert(!lst.isEmpty());
    }
}