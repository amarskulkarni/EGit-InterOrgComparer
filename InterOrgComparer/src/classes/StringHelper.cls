/*  Helper class which computes length of a text or text area field
 *	
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0				Amol Chaudhari		23/11/2012			Intial Draft
 */
public with sharing class StringHelper {
    
    //Method which returns the length of a text or textarea
    public static Integer getFieldLength(Schema.Describefieldresult pFieldResult){

        if(pFieldResult.getType().name().toLowerCase().contains(system.Label.String_String) || 
           pFieldResult.getType().name().toLowerCase().contains(system.Label.Text_Area_String)){
            return pFieldResult.getLength();
        }       
        return NULL;        
     }
}