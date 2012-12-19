/*  Class to get the status of the comparison reports.
 *  Revision History: 
 *  
 *  Version         Author              Date                Description 
 *  1.0            Amol Chaudhari      17/12/2012          Intial Draft 
 */
public with sharing class ReportStatus {
	//method will give the status of the report that which report is being genrated currently
	public static string reportType(){
	    Report_Type__c objReportType = [select Report_Status__c
	                                    from Report_Type__c];
	    if(objReportType != null)
	        return objReportType.Report_Status__c;
	    else
	        return '';             	
	} 
}