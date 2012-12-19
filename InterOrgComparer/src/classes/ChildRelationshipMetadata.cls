/* SObjectMetadata - Class of Child Relationship Metadata(Child Relationship Info's Json reponse
*                    will readvalue as this class)
*  Revision History:
*
*  Version             Author                  Date                Description
*  1.0                Amol Chaudhari          20/11/2012          Initial Draft 
*/
public with sharing class ChildRelationshipMetadata {
  public string relationshipName{get;set;}
  public string childSObject{get;set;}
  public Boolean cascadeDelete{get;set;}
  public string field{get;set;}
  public Boolean deprecatedAndHidden{get;set;}
  public Boolean restrictedDelete{get;set;}
}