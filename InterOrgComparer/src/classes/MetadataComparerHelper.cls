/*  This a Helper class have all constant values and utility method.	
*	Revision History: 
*	Version				Author				Date				Description 
*	1.0				 Amol Chaudhari		  27/11/2012			Intial Draft 
*/

public with sharing class MetadataComparerHelper
{
	public static final String MATCH_YES = 'Yes';
	public static final String MATCH_NO = 'No';
	public static final String NO_FIELDS_MATCH_FOUND = 'No Field Match Found';
	public static final Boolean IS_OBJECT_INFORMATION_FIELD = true;
	public static final String RELATIONSHIP_FIELD_ATTRIBUTE = 'Type__c,Relationship_Name__c,Child_Object__c,isDeprecatedAndHidden__c,isRestrictedDelete__c,Relationship_FieldName__c';
    
    //Retrun Comma separated field Name string basis of boolean field parameter. 
    public static String getCommaSeparatedFields(Boolean pIsObjectInformationField)
    {
		if(pIsObjectInformationField)  
			return 'Field_Count__c,Plural_Label__c,Label__c,Key_Prefix__c,Is_Updateable__c,Is_Searchable__c,Is_Queryable__c,Is_Mergeable__c,Is_Deprecated__c,'+
                   'Is_Deletable__c,Is_Custom_Setting__c,Is_Custom_Object__c,Is_Createable__c,Chatter_Feed_Enabled__c,API_Name__c,Is_Undeletable__c';
        else
        	return 'Use_in_Where_Clause__c,Use_in_Order_By_Clause__c,Use_in_Group_By_Clause__c,' +
	               'Type__c,Soap_Type__c,Scale__c,Relationship_Name__c,Precision__c,'+
	               'Picklist_Values__c,Length__c,'+ 
	               'Label__c,Is_Unique__c,Is_Required__c,Is_Field_Visible__c,'+ 
	               'Is_External_ID__c,Is_Deprecated__c,Is_Dependent_Picklist__c,Is_Case_Sensitive__c,'+
	               'Is_Auto_Number__c,Help_Text__c,Has_Multiple_SObject_Parents__c,'+ 
	               'Formula_Used__c,Field_Category__c,Digits__c,Contains_HTML_Data__c,Can_Upsert__c,Can_Update__c,'+ 
	               'Can_Create__c,Byte_Length__c,API_Name__c,Default_Value__c';
    }
}