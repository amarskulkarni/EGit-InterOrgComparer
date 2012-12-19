/*  Helper class which computes scale and precision of a double field
 *	
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0				Amol Chaudhari		23/11/2012			Intial Draft
 */
public with sharing class DoubleHelper {
    
    //Method which returns precision of a double value
    public static Double getFieldPrecision(Schema.Describefieldresult pFieldResult){

        if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Double_String)){
            return pFieldResult.getPrecision();
        }      
        return NULL;        
     }
     
     //Method which returns scale of a double value
     public static Double getFieldScale(Schema.Describefieldresult pFieldResult){
        Double scale;
        if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Double_String)){
            return pFieldResult.getScale();
        }
        return NULL;        
     }
}