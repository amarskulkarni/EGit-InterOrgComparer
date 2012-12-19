/* Test class for InterOrgController
*  Revision History:
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          19/12/2012          Initial Draft 
*/
@isTest
private class InterOrgComparerControllerTest {
 
    static testMethod void login() {
        InterOrgComparerController objInterOrgController = new InterOrgComparerController();
        objInterOrgController.username = CreateTestData.USERNAME;
        objInterOrgController.password = CreateTestData.PASSWORD;
        objInterOrgController.securitytoken = CreateTestData.SECURITY_TOKEN;
        objInterOrgController.enviroment = CreateTestData.ENVIORMENT_DEV;
        Test.startTest();
        objInterOrgController.login();
        Test.stopTest();
    }
    
    static testMethod void displayPanelQuick(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	objInterOrgController.selectedObjectReport = system.label.Quick_Compare;
    	Test.startTest();
        objInterOrgController.displayPanel();
        Test.stopTest();
    }
    
    static testMethod void displayPanelDetailed(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	objInterOrgController.selectedObjectReport = system.label.Detailed_Compare;
    	Test.startTest();
        objInterOrgController.displayPanel();
        list<Selectoption> lstReportOptions = objInterOrgController.getObjectReportLabel();
        list<Selectoption> lstEnvOptions = objInterOrgController.getEnviromentOptions();
        Test.stopTest();
    }
    
    static testMethod void getRecipientEmailAddress(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	objInterOrgController.selectedObjectReport = system.label.Detailed_Compare;
    	Test.startTest();
        objInterOrgController.displayPanel();
        String userMail = InterOrgComparerController.getRecipientEmailAddress();
        Test.stopTest();
    }
    
    static testMethod void addRow(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	DynamicCustomField objDynamic = new DynamicCustomField();
    	Test.startTest();
        objInterOrgController.addRow1();
        objInterOrgController.addRow1();
        objInterOrgController.addRow1();
        Test.stopTest();
    }
    
     static testMethod void removeRow(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	DynamicCustomField objDynamic = new DynamicCustomField();
    	Test.startTest();
    	objInterOrgController.addRow1();
        objInterOrgController.addRow1();
        objInterOrgController.addRow1();
        objInterOrgController.removeRow1();
        objInterOrgController.removeRow1();
        Test.stopTest();
    }
    
    static testMethod void compareMetadataObjectsQuick(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	objInterOrgController.selectedObjectReport = system.label.Quick_Compare;
    	CreateTestData.createRemoteObjectInformationTestData();
    	CookieResponse  objCookieResp2 = new CookieResponse();
    	objCookieResp2.remoteSessionId = CreateTestData.SESSION_ID;
    	objCookieResp2.remoteServerUrl = CreateTestData.SERVER_URL;
    	objCookieResp2.remoteOrgId = CreateTestData.ORG_ID;
    	objInterOrgController.objCookieResp = objCookieResp2;
    	Test.startTest(); 
    	objInterOrgController.compareMetadataObjects();
        Test.stopTest();
    }
    
    static testMethod void compareMetadataObjectsDetailed(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	objInterOrgController.selectedObjectReport = system.label.Detailed_Compare;
    	CreateTestData.createRemoteObjectInformationTestData();
    	CookieResponse  objCookieResp2 = new CookieResponse();
    	objCookieResp2.remoteSessionId = CreateTestData.SESSION_ID;
    	objCookieResp2.remoteServerUrl = CreateTestData.SERVER_URL;
    	objCookieResp2.remoteOrgId = CreateTestData.ORG_ID;
    	objInterOrgController.objCookieResp = objCookieResp2;
    	Test.startTest();
    	objInterOrgController.compareMetadataObjects();
        Test.stopTest();
    }
    
    static testMethod void logout(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	Test.startTest();
    	objInterOrgController.setVariables();
    	objInterOrgController.logout();
        Test.stopTest();
    }
    
    static testMethod void getObjectList(){
    	InterOrgComparerController objInterOrgController = new InterOrgComparerController();
    	Test.startTest();
    	objInterOrgController.getSFDCObjectList();
    	objInterOrgController.getMetadataObjectList();
        Test.stopTest();
    }
}