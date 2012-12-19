/*  Class to calculate match percentage for Quick and Detailed Comparison
 *  
 *  Revision History: 
 *  
 *  Version         Author              Date                Description 
 *  1.0            Amol Chaudhari      29/11/2012          Intial Draft 
 */
global with sharing class MatchPercentage {
	global boolean isReportVisibleQuick{get;set;}
	global boolean isReportVisibleDetailed{get;set;}
    global boolean isQuickReport{get;set;}
    global boolean isBatchRunning{get;set;}
    global boolean isBatchFailed{get;set;}
    global string batchFailed{get;set;}
    global string batchProgressInfo{get;set;}
    global boolean isChartVisibleQuick{get;set;}
    global boolean isChartVisibleDetailed{get;set;}
    global list<Selectoption> lstmetadata{get;set;}
    global string metadataToCompare{get;set;}
    global string selfOrgUser{get;set;}                                    //self SFDC org username
    global string targetOrgUser{get;set;}                                  //remote SFDC org username
    global final string INTER_ORG_ORGUSERNAME = 'esplInterOrgUserName';    //cookie name username
    global static final string NO = 'NO';
    global static final string SEPERATER = '-'; 
    global static final string NO_FIELD_MATCH_FOUND = 'No Field Match Found';
    global static final string FIELD_COMPARISON = 'Field Comparison';
    private static final string CHILD_RELATIONSHIP = 'Child Relationship';
    private final string STATUS_OF_BATCH_TO_CHECK = 'MetadataComparerBatch';
    private final string BATCH_PROGRESS_1 = 'Your request is in progress, you will receive an email notification at ';
    private final string BATCH_PROGRESS_2 = ', once the data extraction is completed';
    global string report{get;set;}
    
    //Inner class for match percentage of Quick object comparison
	global class TargetObjectPercentage{
		Double matchPercentage;
		Double noMatchPercentage;
	}
	
	//Inner class for match percentage of Detail Metadata comparison
	global class DetailComparisonMatchPercentage{
		String sourceObjectName;
		String targetObjectName;
		Double matchPercentage;
		Double noMatchPercentage;
	}
	
	global list<Selectoption> getMetadata(){
		return lstmetadata;
	}
	
	//constructor which will assign the corresponding values of self and target SFDC orgs
	public MatchPercentage(){
		batchProgressInfo = BATCH_PROGRESS_1+InterOrgComparerController.getRecipientEmailAddress()+BATCH_PROGRESS_2;
		Integer batchStatus;
		isChartVisibleQuick = false;
		isChartVisibleDetailed = false;
		 
		String report = '';
		report = ReportStatus.reportType();
		if(report.equalsIgnoreCase('Quick Comparison')){
			  isChartVisibleQuick = true;
			  isReportVisibleQuick = true;
		}
		if(report.equalsIgnoreCase('Detailed Comparison')){
			 isChartVisibleDetailed = true;
			 isReportVisibleDetailed = true;
		}
		        
		report = isChartVisibleQuick ? 'Quick Comparison' : 'Detailed Comparison';

	  	 batchStatus = CheckForBatchStatus.checkforBatchStatusReport(STATUS_OF_BATCH_TO_CHECK, report);
	  	 system.debug('batchStatus.............'+batchStatus);
	  	 isBatchRunning = (batchStatus != 1) ? true : false;
	  	 isBatchFailed = (batchStatus == 4) ? true : false;
	  	 if(isChartVisibleDetailed)
	  	     isReportVisibleDetailed = (isBatchFailed || isBatchRunning) ? false : true;
	  	 if(isChartVisibleQuick)
	  	     isReportVisibleQuick = (isBatchFailed || isBatchRunning) ? false : true;
	  	 system.debug('isBatchRunning.........'+isBatchRunning);
	  	 system.debug('isBatchFailed.........'+isBatchFailed);
        
          

		Cookie Inter_org_orgUserName = ApexPages.currentPage().getCookies().get(INTER_ORG_ORGUSERNAME);
		selfOrgUser =  Userinfo.getUserName();
		if(Inter_org_orgUserName!=null)
		    targetOrgUser = Inter_org_orgUserName.getValue();
		 
		lstmetadata = new list<Selectoption>();
		lstmetadata.add(new Selectoption('Object Comparison','Object Comparison'));
		lstmetadata.add(new Selectoption('Field Comparison','Field Comparison'));    
		lstmetadata.add(new Selectoption('Child Relationship Comparison','Child Relationship Comparison'));        
	}
		
	//Method which calculates match percentage for object level comparison - Quick Comparison
    @RemoteAction
    global static Double calculateObjectMatchPercentage(){      
    	 //variables to store the matching counts for calculating overall match percentage in turn.
    	 double yesCount = 0.0;
    	 double noCount = 0.0;
    	 double yesCountPercentage = 0.0;
    	 //getting the list of Matching target objects from custom object Object Information
         list<Object_Information__c> lstTargetMatchObjectInfo = [select Id,API_Name__c
		    	                                                from Object_Information__c
		    	                                                where Comparison_Source__c!=null];
		 system.debug('lstTargetMatchObjectInfo.....'+lstTargetMatchObjectInfo.size());   	           
		 //set for matching target Id's
		 set<Id> setMatchingTargetIds = new set<Id>();
		 //creating the set if Id's
		 for(Object_Information__c objMatchingTargetId : lstTargetMatchObjectInfo){
		 	setMatchingTargetIds.add(objMatchingTargetId.Id);
		 }
		 system.debug('setMatchingTargetIds.....'+setMatchingTargetIds.size());
		 
		 //list of all Comparison Log of matching Target Id's
		 list<Comparison_Log__c> lstMatchingCompLog = [select Attribute__c,
		                                                     Match__c,
		                                                     ComparisonType__c,
		                                                     Object__c,
		                                                     SourceObject__c,
		                                                     TargetObject__c
		                                                     from Comparison_Log__c
		                                                     where ComparisonType__c='Object Comparison'
		                                                     and Object__c IN: setMatchingTargetIds];
		  system.debug('lstMatchingCompLog.....'+lstMatchingCompLog.size()); 
		  
		  map<Id,list<Comparison_Log__c>> mapMatchingCompLog = new map<Id,list<Comparison_Log__c>>();
		  
		  //mapping the matching objects with corresponding comparison log
		  if(!lstMatchingCompLog.isEmpty()){
			  for(Comparison_Log__c objCompLog : lstMatchingCompLog){
			  	if(!(mapMatchingCompLog.containsKey(objCompLog.Object__c))){
			  		List<Comparison_Log__c> lstFI = new List<Comparison_Log__c>();
		          	lstFI.add(objCompLog);
		          	mapMatchingCompLog.put(objCompLog.Object__c, lstFI);
			  	}else{
			  		mapMatchingCompLog.get(objCompLog.Object__c).add(objCompLog);
			  	}
			  }
		  }
		  
		  system.debug('mapMatchingCompLog.....'+mapMatchingCompLog.size()); 
		  set<Id> setNoMatchCount = new set<Id>();
		  
		  //set of Id's who have single Match as NO in comp log
		  if(mapMatchingCompLog!=null){
		  	 for(Id objTargetMatchingId : mapMatchingCompLog.keySet()){
		  	 	 for(Comparison_Log__c objComparisonLog1:mapMatchingCompLog.get(objTargetMatchingId)){
		  	 	 	if(objComparisonLog1.Match__c.trim().toLowerCase().compareTo(system.Label.No_String) == 0){
		  	 	 		setNoMatchCount.add(objComparisonLog1.Object__c);
		  	 	 	}
		  	 	 }
		  	 }
		  }
		  system.debug('setNoMatchCount.....'+setNoMatchCount.size());
		  noCount =  setNoMatchCount.size();
		  
		  list<Comparison_Log__c> lstNotMatchedObj = [select Id 
		                                                  from Comparison_Log__c
		                                                  where Attribute__c =: MetadataComparerHelper.NO_FIELDS_MATCH_FOUND];                                                  
		  system.debug('lstNotMatchedObj.....'+lstNotMatchedObj.size());
		  
		  if(!lstNotMatchedObj.isEmpty()){
		  	  noCount =  noCount + lstNotMatchedObj.size();
		  }
		  
		  system.debug('noCount.....'+noCount);
		  
		  list<Object_Information__c> lstTotalObj = [select Id 
		                                                  from Object_Information__c
		                                                  where Id != null];
		                                                  
		
		  	yesCount = (lstTargetMatchObjectInfo.size()+lstNotMatchedObj.size()) - noCount;
		  
		  
		  system.debug('yesCount.....'+yesCount);
		  yesCountPercentage = ((yesCount * 100)/(yesCount+noCount));
		  system.debug('yesCountPercentage.....'+yesCountPercentage);
		   
		  return yesCountPercentage;                                     
    }
    
       //Method which calculates match percentage for object level comparison
    @RemoteAction
    global static List<DetailComparisonMatchPercentage> calculateDetailObjectMatchPercentage(){       //List<TargetObjectPercentage>
        list<DetailComparisonMatchPercentage> targetObjectPercentageList = new list<DetailComparisonMatchPercentage>();
        list<Comparison_Log__c> lstObjCompLog =[select SourceObject__c,
                                                TargetObject__c,
                                                Attribute__c,
                                                ComparisonType__c,
                                                Match__c
                                                from Comparison_Log__c
                                                where ComparisonType__c='Object Comparison'];
        system.debug('lstObjCompLog........'+lstObjCompLog.size());
        
        map<string,list<Comparison_Log__c>> mapObjCompLog = new map<string,list<Comparison_Log__c>>();
        for(Comparison_Log__c objCompLog : lstObjCompLog){
        	string strPair = objCompLog.SourceObject__c+'-'+objCompLog.TargetObject__c;
        	list<Comparison_Log__c> lstTemp = new list<Comparison_Log__c>();
            if(!mapObjCompLog.keySet().contains(strPair)){
            	lstTemp.add(objCompLog);
            	mapObjCompLog.put(strPair,lstTemp);
            }else
            	mapObjCompLog.get(strPair).add(objCompLog);
        }
        
        system.debug('mapObjCompLog........'+mapObjCompLog.size());
        
        map<string,Double> mapMatchObjCompLog = new map<string,Double>();
        
        for(String str : mapObjCompLog.keySet()){
        	Double noCount = 0.0;
        	for(Comparison_Log__c objCompLog : mapObjCompLog.get(str)){
        		if(objCompLog.Match__c.equalsIgnoreCase(NO))
        			noCount++; 
        	}
        	mapMatchObjCompLog.put(str,noCount);
        }                         
        system.debug('mapMatchObjCompLog........'+mapMatchObjCompLog.size());
        system.debug('mapMatchObjCompLog........'+mapMatchObjCompLog);
        
        for(String str : mapMatchObjCompLog.keySet()){
        	DetailComparisonMatchPercentage objMatchPercentage = new DetailComparisonMatchPercentage();
        	//objMatchPercentage.sourceObjectName = str.split(SEPERATER)[0];
        	objMatchPercentage.targetObjectName = str;
        	objMatchPercentage.noMatchPercentage = ((100*(mapMatchObjCompLog.get(str)))/(mapObjCompLog.get(str).size()));
        	objMatchPercentage.matchPercentage = (100 - objMatchPercentage.noMatchPercentage);
        	targetObjectPercentageList.add(objMatchPercentage);
        }
        system.debug('targetObjectPercentageList........'+targetObjectPercentageList.size());
        system.debug('targetObjectPercentageList........'+targetObjectPercentageList); 
        
       	return targetObjectPercentageList;
    }	
    
     @RemoteAction
    global static List<DetailComparisonMatchPercentage> calculateDetailFieldMatchPercentage(){ 
        list<DetailComparisonMatchPercentage> targetObjectPercentageList = new list<DetailComparisonMatchPercentage>();
    	 set<String> setMatchedPairs = new set<String>();
        
        for(Comparison_Log__c objCompLog : [select SourceObject__c,TargetObject__c
                                            from Comparison_Log__c 
                                            where ComparisonType__c='Object Comparison']){
        	setMatchedPairs.add(objCompLog.SourceObject__c+'-'+objCompLog.TargetObject__c);
        }
        system.debug('setMatchedPairs........'+setMatchedPairs.size());
        
    	list<Comparison_Log__c> lstnotMatchingSourceFields =[select Id,
                                     Attribute__c,
                                     ComparisonSourceField__c,
                                     Match__c,
                                     SourceFieldObject__c,
                                     TargetFieldObject__c,
                                     ComparisonType__c,
                                     Field__c
                                     from Comparison_Log__c
                                     where ComparisonType__c=:FIELD_COMPARISON
                                     and Attribute__c=:NO_FIELD_MATCH_FOUND];                           
        system.debug('lstnotMatchingSourceFields...........'+lstnotMatchingSourceFields.size());
    	
    	map<String,list<Comparison_Log__c>> mapNotMatchCompLog = new map<String,list<Comparison_Log__c>>();
    	
    	if(!lstnotMatchingSourceFields.isEmpty()){
    		for(Comparison_Log__c objCompLog : lstnotMatchingSourceFields){
        	string strPair = objCompLog.SourceFieldObject__c+'-'+objCompLog.TargetFieldObject__c;
        	list<Comparison_Log__c> lstTemp = new list<Comparison_Log__c>();
            if(!mapNotMatchCompLog.keySet().contains(strPair)){
            	lstTemp.add(objCompLog);
            	mapNotMatchCompLog.put(strPair,lstTemp);
            }else
            	mapNotMatchCompLog.get(strPair).add(objCompLog);
    	    }
    	}
    	system.debug('mapNotMatchCompLog...........'+mapNotMatchCompLog.size());
    	
    	for(String str : setMatchedPairs){
    		list<Comparison_Log__c> lstTemp = new list<Comparison_Log__c>();
    		if(!mapNotMatchCompLog.keySet().contains(str)){
    			mapNotMatchCompLog.put(str,lstTemp);
    		}
    	}
    	system.debug('mapNotMatchCompLog...........after'+mapNotMatchCompLog.size());
    	
    	map<String,Double> mapNoCount = new map<String,Double>();
    	for(String str : mapNotMatchCompLog.keySet()){
    		list<Comparison_Log__c> lstTemp = mapNotMatchCompLog.get(str);
    		mapNoCount.put(str,lstTemp.size());
    	}
    	system.debug('mapNoCount...........'+mapNoCount.size());
    	system.debug('mapNoCount...........a'+mapNoCount);
    	
    		
    	list<Comparison_Log__c> lstMatchingFields=[select Id,
                                  Attribute__c,
                                  ComparisonSourceField__c,
                                  Match__c,
                                  Field__c,
                                  SourceFieldObject__c,
                                  TargetFieldObject__c,
                                  ComparisonType__c
                                  from Comparison_Log__c
                                  where ComparisonType__c=:FIELD_COMPARISON
                                  and Attribute__c!=:NO_FIELD_MATCH_FOUND];      
    	system.debug('lstMatchingFields.............'+lstMatchingFields.size());
    	
    	map<String,list<Comparison_Log__c>> mapMatchCompLog = new map<String,list<Comparison_Log__c>>();
    	if(!lstMatchingFields.isEmpty()){
    		for(Comparison_Log__c objCompLog : lstMatchingFields){
        	string strPair = objCompLog.SourceFieldObject__c+'-'+objCompLog.TargetFieldObject__c;
        	list<Comparison_Log__c> lstTemp = new list<Comparison_Log__c>();
            if(!mapMatchCompLog.keySet().contains(strPair)){
            	lstTemp.add(objCompLog);
            	mapMatchCompLog.put(strPair,lstTemp);
            }else
            	mapMatchCompLog.get(strPair).add(objCompLog);
    	    }
    	}
    	system.debug('mapMatchCompLog...........'+mapMatchCompLog.size());
    	
        map<String,set<Id>> mapNomatch1 = new map<String,set<Id>>(); 
        map<String,set<Id>> mapTotalMatchCount = new map<String,set<Id>>();
         set<Id> setTemp = new set<Id>();
         
        if(mapMatchCompLog!=null){
            for(String str : mapMatchCompLog.keySet()){
                 for(Comparison_Log__c objCompLog : mapMatchCompLog.get(str)){
                     setTemp.add(objCompLog.Field__c);
                      if(objCompLog.Match__c.trim().toLowerCase().compareTo(system.Label.No_String) == 0){
                          if(!(mapNomatch1.containsKey(str))){
							   set<Id> temp = new set<Id>();
							   temp.add(objCompLog.Field__c);
							   mapNomatch1.put(str, temp);
	                       }else{
	                           mapNomatch1.get(str).add(objCompLog.Field__c);
	                       }
                       }
                   }
                   mapTotalMatchCount.put(str,setTemp);
               }
        }
       
        system.debug('mapNomatch1...........'+mapNomatch1.size());
         system.debug('mapTotalMatchCount...........'+mapTotalMatchCount.size());
        
        for(String str : setMatchedPairs){
    		set<Id> setTemp1 = new set<Id>();
    		if(!mapNomatch1.keySet().contains(str)){
    			mapNomatch1.put(str,setTemp1);
    		}
    		if(!mapTotalMatchCount.keySet().contains(str)){
    			mapTotalMatchCount.put(str,setTemp1);
    		}
    	}
    	system.debug('mapNomatch1...........after'+mapNomatch1.size());
    	system.debug('mapTotalMatchCount...........after'+mapTotalMatchCount.size());
    	
    	for(String str : setMatchedPairs){
    		Double noCount = 0.0;Double yesCount = 0.0;Double totalCount = 0.0;
    		DetailComparisonMatchPercentage objPercentage = new DetailComparisonMatchPercentage();
    		noCount = mapNomatch1.get(str).size() + mapNotMatchCompLog.get(str).size();
    		system.debug('str...........noCount'+noCount);
    		system.debug('str...........mapMatchCompLog/31'+(mapMatchCompLog.get(str).size()/31));
    		totalCount = (mapNotMatchCompLog.get(str).size() + ((mapMatchCompLog.get(str).size())/31));
    		system.debug('str...........totalCount'+totalCount);
    		objPercentage.noMatchPercentage = (noCount * 100) / totalCount;
    		objPercentage.matchPercentage = 100 - objPercentage.noMatchPercentage;
    		objPercentage.targetObjectName = str;
    		targetObjectPercentageList.add(objPercentage);
    	}
    	system.debug('targetObjectPercentageList...........'+targetObjectPercentageList.size());
    	system.debug('targetObjectPercentageList...........'+targetObjectPercentageList);
    	
    	return targetObjectPercentageList;
    }
    
     @RemoteAction
    global static List<DetailComparisonMatchPercentage> calculateDetailChildMatchPercentage(){ 
    	list<DetailComparisonMatchPercentage> targetObjectPercentageList = new list<DetailComparisonMatchPercentage>();
    	set<String> setMatchedPairs = new set<String>();
        for(Comparison_Log__c objCompLog : [select SourceObject__c,TargetObject__c
                                            from Comparison_Log__c 
                                            where ComparisonType__c='Object Comparison']){
        	setMatchedPairs.add(objCompLog.SourceObject__c+'-'+objCompLog.TargetObject__c);
        }
        system.debug('setMatchedPairs........'+setMatchedPairs.size());
        
        list<Comparison_Log__c> lstmatchingchildComparisonLog = [select TargetObject__c,
                                                                SourceObject__c,
						    	                                Attribute__c,
						    	                                Match__c,
						    	                              ComparisonRelationshipSource__c,
						    	                                Relationship__c
						    	                                from Comparison_Log__c
						    	                                where ComparisonRelationshipSource__c!=null
						    	                                and Relationship__c!=null
						    	                                and Attribute__c!=:NO_FIELD_MATCH_FOUND 
					                                            and ComparisonType__c =:CHILD_RELATIONSHIP];
		system.debug('lstmatchingchildComparisonLog........'+lstmatchingchildComparisonLog.size());
		
		list<Comparison_Log__c> lstUnmatchedTargetChild = [select TargetObject__c,
                                                            SourceObject__c,
					    	                                Attribute__c,
					    	                                Relationship__c,
					    	                                Match__c
					    	                                from Comparison_Log__c  
					    	                                where Attribute__c=:NO_FIELD_MATCH_FOUND and
				 	                                        ComparisonType__c =:CHILD_RELATIONSHIP];
		system.debug('lstUnmatchedTargetChild........'+lstUnmatchedTargetChild.size());
		
		map<String,list<Comparison_Log__c>> mapUnMatchCompLog = new map<String,list<Comparison_Log__c>>();
		if(!lstUnmatchedTargetChild.isEmpty()){
    		for(Comparison_Log__c objCompLog : lstUnmatchedTargetChild){
        	string strPair = objCompLog.SourceObject__c+'-'+objCompLog.TargetObject__c;
        	list<Comparison_Log__c> lstTemp = new list<Comparison_Log__c>();
            if(!mapUnMatchCompLog.keySet().contains(strPair)){
            	lstTemp.add(objCompLog);
            	mapUnMatchCompLog.put(strPair,lstTemp);
            }else
            	mapUnMatchCompLog.get(strPair).add(objCompLog);
    	    }
    	}	 	                                         			                                            
    	system.debug('mapUnMatchCompLog........'+mapUnMatchCompLog.size());
    	
    	for(String str : setMatchedPairs){
    		list<Comparison_Log__c> lstTemp = new list<Comparison_Log__c>();
    		if(!mapUnMatchCompLog.keySet().contains(str)){
    			mapUnMatchCompLog.put(str,lstTemp);
    		}
    	}
    	system.debug('mapUnMatchCompLog...........after'+mapUnMatchCompLog.size());
    	
    	map<String,Double> mapNoCount = new map<String,Double>();
    	for(String str : mapUnMatchCompLog.keySet()){
    		list<Comparison_Log__c> lstTemp = mapUnMatchCompLog.get(str);
    		mapNoCount.put(str,lstTemp.size());
    	}
    	system.debug('mapNoCount...........'+mapNoCount.size());
    	system.debug('mapNoCount...........a'+mapNoCount);
    	
    	map<String,list<Comparison_Log__c>> mapMatchCompLog = new map<String,list<Comparison_Log__c>>();
    	if(!lstmatchingchildComparisonLog.isEmpty()){
    		for(Comparison_Log__c objCompLog : lstmatchingchildComparisonLog){
        	string strPair = objCompLog.SourceObject__c+'-'+objCompLog.TargetObject__c;
        	list<Comparison_Log__c> lstTemp = new list<Comparison_Log__c>();
            if(!mapMatchCompLog.keySet().contains(strPair)){
            	lstTemp.add(objCompLog);
            	mapMatchCompLog.put(strPair,lstTemp);
            }else
            	mapMatchCompLog.get(strPair).add(objCompLog);
    	    }
    	}
    	system.debug('mapMatchCompLog...........'+mapMatchCompLog.size());
    	
    	map<String,set<Id>> mapNomatch1 = new map<String,set<Id>>(); 
        map<String,set<Id>> mapTotalMatchCount = new map<String,set<Id>>();
         set<Id> setTemp = new set<Id>();
         
        if(mapMatchCompLog!=null){
            for(String str : mapMatchCompLog.keySet()){
                 for(Comparison_Log__c objCompLog : mapMatchCompLog.get(str)){
                     setTemp.add(objCompLog.Relationship__c);
                      if(objCompLog.Match__c.trim().toLowerCase().compareTo(system.Label.No_String) == 0){
                          if(!(mapNomatch1.containsKey(str))){
							   set<Id> temp = new set<Id>();
							   temp.add(objCompLog.Relationship__c);
							   mapNomatch1.put(str, temp);
	                       }else{
	                           mapNomatch1.get(str).add(objCompLog.Relationship__c);
	                       }
                       }
                   }
                   mapTotalMatchCount.put(str,setTemp);
               }
        }
       
        system.debug('mapNomatch1...........'+mapNomatch1.size());
         system.debug('mapTotalMatchCount...........'+mapTotalMatchCount.size());
         
         for(String str : setMatchedPairs){
    		set<Id> setTemp1 = new set<Id>();
    		if(!mapNomatch1.keySet().contains(str)){
    			mapNomatch1.put(str,setTemp1);
    		}
    		if(!mapTotalMatchCount.keySet().contains(str)){
    			mapTotalMatchCount.put(str,setTemp1);
    		}
    	}
    	system.debug('mapNomatch1...........after'+mapNomatch1.size());
    	system.debug('mapTotalMatchCount...........after'+mapTotalMatchCount.size());
    	
    	for(String str : setMatchedPairs){
    		Double noCount = 0.0;Double yesCount = 0.0;Double totalCount = 0.0;
    		DetailComparisonMatchPercentage objPercentage = new DetailComparisonMatchPercentage();
    		noCount = mapNomatch1.get(str).size() + mapUnMatchCompLog.get(str).size();
    		system.debug('str...........noCount'+noCount);
    		system.debug('str...........mapMatchCompLog/31'+(mapMatchCompLog.get(str).size()/6));
    		totalCount = (mapUnMatchCompLog.get(str).size() + ((mapMatchCompLog.get(str).size())/6));
    		system.debug('str...........totalCount'+totalCount);
    		objPercentage.noMatchPercentage = (noCount * 100) / totalCount;
    		objPercentage.matchPercentage = 100 - objPercentage.noMatchPercentage;
    		objPercentage.targetObjectName = str;
    		targetObjectPercentageList.add(objPercentage);
    	}
    	
    	system.debug('targetObjectPercentageList...........after'+targetObjectPercentageList.size());
    	system.debug('targetObjectPercentageList...........after'+targetObjectPercentageList);
    	return targetObjectPercentageList;
    }
}