/*  Controller class which handles the requests related to the Comparison Log report 
*   for the Detailed Comparison Report    
*       Revision History: 
*       Version                         Author                          Date                            Description 
*       1.0                           Amol Chaudhari                   06/12/2012                      Intial Draft 
*/
public with sharing class DetailComparisonReportController {
   public boolean isReportVisible{get;set;}
   public boolean isDetailedReport{get;set;}
   public string urlToExport{get;set;}
   public boolean isBatchRunning{get;set;}
   public boolean isBatchFailed{get;set;}
   public string batchProgressInfo{get;set;}
   public string batchFailed{get;set;}
   public boolean isFormVisible{get;set;}
   //final variables
   private final string VF_PAGE_EXPORT = '/apex/ExportDetailComparisonReport';
   private final string BATCH_FAILED = system.label.Batch_Failed;
   private final string STATUS_OF_BATCH_TO_CHECK = 'MetadataComparerBatch';
   private final string BATCH_PROGRESS_1 = 'Your request is in progress, you will receive an email notification at ';
   private final string BATCH_PROGRESS_2 = ', once the data extraction is completed';
   private final string DETAILED_COMPARISON = 'Detailed Comparison';
    
   public DetailComparisonReportController(){
   	  Integer batchStatus;
   	  isDetailedReport = false;
   	  String report = '';
	  report = ReportStatus.reportType();
	  batchProgressInfo = BATCH_PROGRESS_1+InterOrgComparerController.getRecipientEmailAddress()+BATCH_PROGRESS_2; 
	  if(report.equalsIgnoreCase('Detailed Comparison'))
	      isDetailedReport = true;
	  if(isDetailedReport){
	  	 batchStatus = CheckForBatchStatus.checkforBatchStatusReport(STATUS_OF_BATCH_TO_CHECK, DETAILED_COMPARISON);
	  	 system.debug('batchStatus.............'+batchStatus);
	  	 isBatchRunning = (batchStatus != 1) ? true : false;
	  	 isBatchFailed = (batchStatus == 4) ? true : false;
	  	 isReportVisible = (isBatchRunning || isBatchFailed) ? false : true;
	  }
	  system.debug('isBatchRunning.............'+isBatchRunning); 
	  system.debug('isBatchFailed.............'+isBatchFailed);
	  system.debug('isReportVisible.............'+isReportVisible);    
   	  urlToExport = System.URL.getSalesforceBaseUrl().toExternalForm()+VF_PAGE_EXPORT;
   }
}