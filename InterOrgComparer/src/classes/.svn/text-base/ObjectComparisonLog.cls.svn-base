/*  Class which helps to bind to the respective comparison page
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				  Amol Chaudhari	 28/11/2012			    Intial Draft 
*/
public with sharing class ObjectComparisonLog {
    //to set the target or source as null if not matched
    private final string TARGET_BLANK = 'targetBlank'; 
	private final string SOURCE_BLANK= 'sourceBlank';
	
    public Integer srNo{get;set;}
    public Integer sourceFieldCount{get;set;}
    public Integer targetFieldCount{get;set;}
    public string sourceLabel{get;set;}
    public string targetLabel{get;set;}
    public string matchLabel{get;set;}
    
    public string sourceAPIName{get;set;}
    public string targetAPIName{get;set;}
    public string matchAPIName{get;set;}
    
    public boolean sourcechatterFeedEnabled{get;set;}
    public boolean targetchatterFeedEnabled{get;set;}
    public string matchchatterFeedEnabled{get;set;}

	public boolean sourceCreateable{get;set;}
	public boolean targetCreateable{get;set;}
	public string matchCreateable{get;set;}
	
	public boolean sourceAccessible{get;set;}
	public boolean targetAccessible{get;set;}
	public string matchAccessible{get;set;}
	
	public boolean sourceCustomObject{get;set;}
	public boolean targetCustomObject{get;set;}
	public string matchCustomObject{get;set;}
	
	public boolean sourceCustomSetting{get;set;}
	public boolean targetCustomSetting{get;set;}
	public string matchCustomSetting{get;set;}
	
	public boolean sourceDeletable{get;set;}
	public boolean targetDeletable{get;set;}
	public string matchDeletable{get;set;}
	
	public boolean sourceDeprecated{get;set;}
	public boolean targetDeprecated{get;set;}
	public string matchDeprecated{get;set;}
	
	public boolean sourceMergeable{get;set;}
	public boolean targetMergeable{get;set;}
	public string matchMergeable{get;set;}
	
	public boolean sourceQueryable{get;set;}
	public boolean targetQueryable{get;set;}
	public string matchQueryable{get;set;}
	
	public boolean sourceSearchable{get;set;}
	public boolean targetSearchable{get;set;}
	public string matchSearchable{get;set;}
	
	public boolean sourceUndeletable{get;set;}
	public boolean targetUndeletable{get;set;}
	public string matchUndeletable{get;set;}
	
	public boolean sourceUpdateable{get;set;}
	public boolean targetUpdateable{get;set;}
	public string matchUpdateable{get;set;}
	
	public string sourceKeyPrefix{get;set;}
	public string targetKeyPrefix{get;set;}
	public string matchKeyPrefix{get;set;}
	
	public string sourceOrgId{get;set;}
	public string targetOrgId{get;set;}
	public string matchOrgId{get;set;}
	
	public string sourcePluralLabel{get;set;}
	public string targetPluralLabel{get;set;}
	public string matchPluralLabel{get;set;}
	
	 public ObjectComparisonLog(){
	 	
	 }
	 
	 //constructor which sets the target or source as null if not matched
	 public ObjectComparisonLog(string pBlankValue){
    	if(pBlankValue.equalsIgnoreCase(TARGET_BLANK)){
    		targetLabel=null;
			targetAPIName=null;
			targetchatterFeedEnabled =null;
			targetAccessible = null;
			targetCreateable = null;
			targetCustomObject = null;
			targetCustomSetting = null;
			targetDeletable = null;
			targetDeprecated = null;
			targetMergeable = null;
			targetQueryable = null;
			targetSearchable = null;
			targetUndeletable = null;
			targetUpdateable = null;
			targetKeyPrefix =null;
			targetOrgId = null;
			targetPluralLabel = null;
			targetFieldCount = null;
    	}
    	if(pBlankValue.equalsIgnoreCase(SOURCE_BLANK)){
    		sourceLabel=null;
			sourceAPIName=null;
			sourcechatterFeedEnabled =null;
			sourceAccessible = null;
			sourceCreateable = null;
			sourceCustomObject = null;
			sourceCustomSetting = null;
			sourceDeletable = null;
			sourceDeprecated = null;
			sourceMergeable = null;
			sourceQueryable = null;
			sourceSearchable = null;
			sourceUndeletable = null;
			sourceUpdateable = null;
			sourceKeyPrefix =null;
			sourceOrgId = null;
			sourcePluralLabel = null;
			sourceFieldCount = null;
    	}
    	matchLabel=MetadataComparerHelper.MATCH_NO;
		matchAPIName=MetadataComparerHelper.MATCH_NO;
		matchchatterFeedEnabled =MetadataComparerHelper.MATCH_NO;
		matchAccessible = MetadataComparerHelper.MATCH_NO;
		matchCreateable = MetadataComparerHelper.MATCH_NO;
		matchCustomObject = MetadataComparerHelper.MATCH_NO;
	    matchCustomSetting = MetadataComparerHelper.MATCH_NO;
		matchDeletable = MetadataComparerHelper.MATCH_NO;
		matchDeprecated = MetadataComparerHelper.MATCH_NO;
		matchMergeable = MetadataComparerHelper.MATCH_NO;
		matchQueryable = MetadataComparerHelper.MATCH_NO;
		matchSearchable = MetadataComparerHelper.MATCH_NO;
		matchUndeletable = MetadataComparerHelper.MATCH_NO;
		matchUpdateable = MetadataComparerHelper.MATCH_NO;
		matchKeyPrefix =MetadataComparerHelper.MATCH_NO;
		matchOrgId = MetadataComparerHelper.MATCH_NO;
		matchPluralLabel = MetadataComparerHelper.MATCH_NO;
    }
}