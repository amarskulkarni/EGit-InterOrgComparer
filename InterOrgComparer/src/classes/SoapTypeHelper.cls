/*  Helper class which computes SOAP type of a field
 *	
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0				Amol Chaudhari		23/11/2012			Intial Draft
 */
public with sharing class SoapTypeHelper {
	
    //Method which the SOAP Type enum values for a field
	public static String getSOAPTypeEnumValues(Schema.Describefieldresult pFieldResult){ 
        String soapTypeEnumValue = '';
        
        if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Anytype_String)){
            soapTypeEnumValue = system.Label.Anytype_String;
        }
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Base64Binary_String)){
            soapTypeEnumValue = system.Label.Base64Binary_String;
        }
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Boolean_String)){
            soapTypeEnumValue = system.Label.Boolean_String1;
        }
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Date_String)){
            soapTypeEnumValue = system.Label.Date_String1;
        }
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Date_Time_String)){
            soapTypeEnumValue = system.Label.Date_Time_String1;
        } 
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Double_String)){
            soapTypeEnumValue = system.Label.Double_String1; 
        }
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.ID_String)){
            soapTypeEnumValue = system.Label.ID_String1;
        }
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Integer_String)){
            soapTypeEnumValue = system.Label.Integer_String1;
        } 
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.String_String)){
            soapTypeEnumValue = system.Label.String_String1;
        }  
        else if(pFieldResult.getSoapType().name().toLowerCase().contains(system.Label.Time_String)){
            soapTypeEnumValue = system.Label.Time_String1;
        }             
        return soapTypeEnumValue;        
    }
}