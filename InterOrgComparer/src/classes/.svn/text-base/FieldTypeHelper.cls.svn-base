/*  Helper class which computes the data type of a field
 *	
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0				Amol Chaudhari		23/11/2012			Intial Draft
 */
public with sharing class FieldTypeHelper {

    //Determines the Salesforce Data Type of the Field from the provided Metadata Information 
     public static String getFieldTypeDetails(Schema.Describefieldresult pFieldResult){

        String strFieldType = '';
        if(pFieldResult.getType().name().toLowerCase().contains(system.Label.String_String)){
            strFieldType = system.Label.Text_String;
        }
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Integer_String) || 
                pFieldResult.getType().name().toLowerCase().contains(system.Label.Double_String)){
            strFieldType = system.Label.Number_String;
        }
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Reference_String)){
            strFieldType = system.Label.Reference_String1;
        }
        else if(pFieldResult.getType().name().trim().toLowerCase().contains(system.Label.Text_Area_String)){
            strFieldType = system.Label.Text_Area_String1;
        }
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Picklist_String)){
            strFieldType = system.Label.Picklist_String1;
        } 
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Currency_String)){
            strFieldType = system.Label.Currency_String1;
        }
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Date_String)){
            strFieldType = system.Label.Date_String1;
        }
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Date_Time_String)){
            strFieldType = system.Label.Date_Time_String1;
        } 
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.ID_String)){
            strFieldType = system.Label.ID_String1;
        }  
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Percent_String)){
            strFieldType = system.Label.Percent_String1;
        }  
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Phone_String)){
            strFieldType = system.Label.Phone_String1;
        }  
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Url_String)){
            strFieldType = system.Label.Url_String1;
        }  
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Email_String)){
            strFieldType = system.Label.Email_String1;
        }  
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Encrypted_String)){
            strFieldType = system.Label.Encrypted_String1;
        } 
        else if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Boolean_String)){
            strFieldType = system.Label.Checkbox_String;
        }           
        return strFieldType;
     }
}