/*  Helper class which computes number of digits in an integer field
 *	
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0				Amol Chaudhari		23/11/2012			Intial Draft
 */
public with sharing class IntegerHelper {
    
    //Method which returns the maximum number of digits specified for integer field
    public static Integer getFieldDigits(Schema.Describefieldresult pFieldResult){
        if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Integer_String)){
            return pFieldResult.getLength();
        }      
        return NULL;
     }
}