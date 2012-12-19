public with sharing class JSONMetadataParser {
    //list of all metadata object list of other org
	private list<Selectoption> metadataObjectList = new list<Selectoption>();
	//appending characters
	public final string APPEND_CHAR = '#';
    public final string OPEN_BRACKET = '(';
    public final string CLOSED_BRACKET = ')';
    //token names for Json Parsing
    public final string TOKEN_NAME = 'name';
    public final string TOKEN_LABEL = 'label';
    
    //getting the list of Sobject list of remote SFDC org, returning the selectoption list
    public list<Selectoption> getSobjectList(string pJsonResponse){
        JSONParser parser = JSON.createParser(pJsonResponse);
	    //getting the tokens 'name' from SObject list
	    while (parser.nextToken() != null) {
	        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                   (parser.getText() == TOKEN_NAME)) {
                parser.nextToken();
                string label;
                string name;
                name = parser.getText();
                //system.debug('lstSobjectsRemote....'+parser.getText());
                while (parser.nextToken() != null){
                	if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == TOKEN_LABEL)) {
                	   parser.nextToken();
                	   label = parser.getText();
                	   break; 
                	}
                }
                metadataObjectList.add(new Selectoption(name,name+OPEN_BRACKET+label+CLOSED_BRACKET));
            }
	     }
	    return metadataObjectList;     
    }
    
    //getting the SObject metadata from connected remote Org, returning instance of ObjectMetadata class
     public ObjectMetadata getSobjectMetadata(string pJsonResponse){
        ObjectMetadata objMetadata = new ObjectMetadata();
        JSONParser parser = JSON.createParser(pJsonResponse);
        system.debug('pJsonResponse.....'+pJsonResponse);
        list<ObjectMetadata> lstsobjectMetadata = new list<ObjectMetadata>();
	     while (parser.nextToken() != null) {
	     	  //Read Metadata Json response as Class 'ObjectMetadata' 
              objMetadata = (ObjectMetadata)parser.readValueAs(ObjectMetadata.class);
              system.debug('objMetadata....$$'+objMetadata);
       }
      
	    return objMetadata;     
    }
    
    
     //getting the SObject leve metadata from connected remote Org, returning instance of ObjectMetadata class
     public list<ObjectMetadata> getSobjectQuickMetadata(string pJsonResponse){   
        JSONParser parser = JSON.createParser(pJsonResponse);
        ObjectMetadata objMetadata = new ObjectMetadata();
        system.debug('pJsonResponse.....'+pJsonResponse);
        list<ObjectMetadata> lstsobjectMetadata = new list<ObjectMetadata>();
	    while (parser.nextToken() != null) {
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    objMetadata = (ObjectMetadata)parser.readValueAs(ObjectMetadata.class);
                    lstsobjectMetadata.add(objMetadata);
                    parser.skipChildren();
                }
            }
        }
    }
	    return lstsobjectMetadata;     
    }
}