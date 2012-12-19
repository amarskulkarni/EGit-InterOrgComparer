/*  Helper class which computes comma separated  values of a picklist field
 *	
 *	Revision History: 
 *	
 *	Version			Author				Date				Description 
 *	1.0				Amol Chaudhari		23/11/2012			Intial Draft
 */
public with sharing class PicklistHelper {
    
    //Method to get picklist values of a field
     public static String getFieldPicklistValues(Schema.Describefieldresult pFieldResult){
        if(pFieldResult.getType().name().toLowerCase().contains(system.Label.Picklist_String)){
            return createPicklistValueCSV(pFieldResult.getPicklistValues());
        }
        return system.Label.NA;
     }
     
     //Method which generates picklist values in a specific format
     public static String createPicklistValueCSV(List<Schema.Picklistentry> pPicklistEntries){

        String strCSV = '';
        list<String> lstPicklist = new list<String>();
        for(Schema.Picklistentry pEntry : pPicklistEntries){
              lstPicklist.add(pEntry.getValue());
        }
        
        lstPicklist.sort();
        
        for(String pEntry : lstPicklist){

            //Append the picklist values in a comma separated string format  e.g.: a,b,c,d
            if(strCSV <> NULL){
                if(pEntry <> NULL)                
                strCSV = strCSV + pEntry + system.Label.Comma + '';
            }
            else{
                if(pEntry<> NULL)                
                strCSV = pEntry + system.Label.Comma + '';
            }
        }
        
        //Remove the extra comma and space appended at the end
        strCSV  = strCSV.contains(system.Label.Comma) ? strCSV.substring(0, strCSV.length() - 1) : system.Label.No_Values;
        return strCSV;  
     }  
}