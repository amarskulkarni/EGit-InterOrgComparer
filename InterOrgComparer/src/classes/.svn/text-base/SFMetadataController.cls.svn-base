/* SFMetadataController - Extracting the metadata from self org
*  Revision History:
*
*  Version             Author                  Date                Description
*  1.0                 Amol Chaudhari          26/09/2012          Initial Draft 
*/

public with sharing class SFMetadataController {
 private List<Selectoption> SFDCObjectList = new List<Selectoption>();  
 public string SFObject {get;set;}
 public boolean isConnected{get;set;}
 private final string STATUS = 'status';
 private final string PASS = 'pass';
 
  public SFMetadataController(){
  	string status= ApexPages.currentPage().getParameters().get(STATUS);
  	if(status.equalsIgnoreCase(PASS)){
  		isConnected = true;
  		system.debug('Connected..........!!!'+status+isConnected);	
  	}
  	system.debug('Connected-out..........!!!'+status+isConnected);	
    system.debug('isConnected..........!!!'+isConnected);
  }
  
  public List<SelectOption> getSFDCObjectList() { 
        this.getAllSFDCObjects(); 
        return SFDCObjectList;
     }
   
   //Retreives the API Name and Label of all SFDC objects in the org  
   public void getAllSFDCObjects() {
       Schema.Sobjecttype objSFDCObject;
       //Retreive a Map of all SFDC Object Tokens and SFDC Objects from the Org
       Map<String, Schema.Sobjecttype> GlobalDescribeMap = Schema.getGlobalDescribe();
       //Check if new objects are created or Object list is requested for the first time
       if(GlobalDescribeMap.size() > SFDCObjectList.size() || SFDCObjectList.isEmpty())
       {
           List<String> KeyList = new List<String>();
           KeyList.addAll(GlobalDescribeMap.keySet());
           KeyList.sort();  //Sort the Objects according to their names
           
           if(!SFDCObjectList.isEmpty())    //clear the list, if elements exist
                SFDCObjectList.clear();
           
           for(String strKey : KeyList)
           {
                if(GlobalDescribeMap.containsKey(strKey))   //check whether the key exists
                    objSFDCObject = GlobalDescribeMap.get(strKey);
                //Add the Label and API Name values to be displayed in the picklist in the following format: API Name(Label)
                 SFDCObjectList.add(new Selectoption(
                    objSFDCObject.getDescribe().getName()+ '#' + objSFDCObject.getDescribe().getLabel(), 
                    objSFDCObject.getDescribe().getName() + ' (' + objSFDCObject.getDescribe().getLabel()  + ')'));
           }
       }
     }   
}