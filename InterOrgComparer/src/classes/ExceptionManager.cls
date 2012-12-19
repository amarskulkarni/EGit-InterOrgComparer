/*  Class which serves the purpose of inserting the record into error log everytime after 
 *  an exception is raised
 *	
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0			  Amol Chaudhari	  22/11/2012			Intial Draft 
 */
 
public with sharing class ExceptionManager {
	
	//Method which is used to insert a record into error log everytime after an exception is raised
	public static void logError(DateTime pDateTime, String pErrorDescription, Id pUserId){
		Error_Log__c errorLogObject = new Error_Log__c(Error_DateTime__c = pDateTime, 
							    Error_Description__c = pErrorDescription, User__c =pUserId);
		
		if(errorLogObject != null && Limits.getDmlStatements() < 150){
			insert errorLogObject;
		}
	}

}