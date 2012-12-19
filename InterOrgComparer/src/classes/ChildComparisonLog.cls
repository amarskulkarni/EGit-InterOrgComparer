/*  Inner class which is to binded with UI for Child Comparison List, detail comparison
*	
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				  Amol Chaudhari		07/12/2012			Intial Draft 
*/
public with sharing class ChildComparisonLog {
	private final string TARGET_BLANK = 'targetBlank'; 
	private final string SOURCE_BLANK= 'sourceBlank';
	public Integer srNo{get;set;}
	
    public string sourceChildRelationshipName{get;set;}
    public string targetChildRelationshipName{get;set;}
    public string matchChildRelationshipName{get;set;}
    
    public string sourceChildParentObject{get;set;}
    public string targetChildParentObject{get;set;}
    public string matchChildParentObject{get;set;}
    
    public string sourceChildChildObject{get;set;}
    public string targetChildChildObject{get;set;}
    public string matchChildChildObject{get;set;}
    
    public string sourceChildRelationshipType{get;set;}
    public string targetChildRelationshipType{get;set;}
    public string matchChildRelationshipType{get;set;}
    
    public string sourceChildRelationshipFieldName{get;set;}
    public string targetChildRelationshipFieldName{get;set;}
    public string matchChildRelationshipFieldName{get;set;}
    
    public Boolean sourceChildIsRestrictedDelete{get;set;}
    public Boolean targetChildIsRestrictedDelete{get;set;}
    public string matchChildIsRestrictedDelete{get;set;}
    
    public Boolean sourceChildIsDeprecatedAndHidden{get;set;}
    public Boolean targetChildIsDeprecatedAndHidden{get;set;}
    public string matchChildIsDeprecatedAndHidden{get;set;}
    
    public ChildComparisonLog(){}
    
    public ChildComparisonLog(string pBlank){
    	if(pBlank.equalsIgnoreCase(SOURCE_BLANK)){
	        sourceChildRelationshipName = null;
	    	sourceChildParentObject = null;
	    	sourceChildChildObject = null;
	    	sourceChildRelationshipType = null;
	    	sourceChildIsDeprecatedAndHidden = null;
	    	sourceChildIsRestrictedDelete = null;
    	}
    	if(pBlank.equalsIgnoreCase(TARGET_BLANK)){
    		targetChildRelationshipName = null;
	    	targetChildParentObject = null;
	    	targetChildChildObject = null;
	    	targetChildRelationshipType = null;
	    	targetChildIsDeprecatedAndHidden = null;
	    	targetChildIsRestrictedDelete = null;
    	}
    	
    	matchChildRelationshipName = MetadataComparerHelper.MATCH_NO;
    	matchChildParentObject = MetadataComparerHelper.MATCH_NO;
    	matchChildChildObject = MetadataComparerHelper.MATCH_NO;
    	matchChildRelationshipType = MetadataComparerHelper.MATCH_NO;
    	matchChildIsDeprecatedAndHidden = MetadataComparerHelper.MATCH_NO;
    	matchChildIsRestrictedDelete = MetadataComparerHelper.MATCH_NO;
    } 
    
    
}