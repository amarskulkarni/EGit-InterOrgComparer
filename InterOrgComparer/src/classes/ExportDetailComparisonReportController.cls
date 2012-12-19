/*  Class allows to extract the Detail level metadata comparison.
*   Revision History: 
*   Version             Author              Date                Description 
*   1.0               Amol Chaudhari       10/12/2012           Intial Draft 
*/
public with sharing class ExportDetailComparisonReportController {
	public list<ObjectComparisonLog> objectComparisonLogList{get;set;}
	public list<FieldComparisonLog> fieldComparisonLogList{get;set;}
	public list<ChildComparisonLog> childComparisonLogList{get;set;}
	public String sourceFieldObject{get; set;}
	public String sourceChildObject{get; set;}
	public String targetFieldObject{get; set;}
	public String targetChildObject{get; set;}
	public String dateToAppendToExcel{get;set;} 
	//final variables
	private final string COOKIE_CHILD_TARGET = 'targetChild';
	private final string COOKIE_CHILD_SOURCE = 'sourceChild';
	private final string COOKIE_FIELD_TARGET = 'targetField';
	private final string COOKIE_FIELD_SOURCE = 'sourceField';
    
    public list<ObjectComparisonLog> getcomparisonLogList(){
    	return objectComparisonLogList;  
    }
    
    public ExportDetailComparisonReportController(){
    	dateToAppendToExcel = String.valueof(date.today());
    	Cookie targetChild = ApexPages.currentPage().getCookies().get(COOKIE_CHILD_TARGET);
    	Cookie sourceChild = ApexPages.currentPage().getCookies().get(COOKIE_CHILD_SOURCE);
    	Cookie targetField = ApexPages.currentPage().getCookies().get(COOKIE_FIELD_TARGET);
    	Cookie sourceField = ApexPages.currentPage().getCookies().get(COOKIE_FIELD_SOURCE);
    	
    	if(targetChild!=null && sourceChild!=null){
    		sourceChildObject = sourceChild.getValue();
    		targetChildObject = targetChild.getValue();
    	}
    	if(targetField!=null && sourceField!=null){
    		sourceFieldObject = sourceField.getValue();
    		targetFieldObject = targetField.getValue();
    	}
    	system.debug('sourceFieldObject................'+sourceFieldObject);
    	system.debug('targetFieldObject................'+targetFieldObject);
    	system.debug('sourceChildObject................'+sourceChildObject);
    	system.debug('targetChildObject................'+targetChildObject);
    }
    
    public Pagereference MetadataComparison(){
    	ObjectMetadataComparisonExtractor objMetadataExtractor = new ObjectMetadataComparisonExtractor();
    	FieldMetadataComparisonExtractor objFieldExtractor = new FieldMetadataComparisonExtractor();
    	ChildMetadataComparisonExtractor objChildExtractor = new ChildMetadataComparisonExtractor();
    	
    	objectComparisonLogList = new list<ObjectComparisonLog>();                                                                       
        objectComparisonLogList = objMetadataExtractor.getcomparisonLogList();
        
        fieldComparisonLogList = new list<FieldComparisonLog>();
        fieldComparisonLogList = objFieldExtractor.getFieldComparisonLogList(sourceFieldObject, targetFieldObject);
        
        childComparisonLogList = new list<ChildComparisonLog>();
        childComparisonLogList = objChildExtractor.getChildComparisonLogList(sourceChildObject, targetChildObject);
        return null;
    }
}