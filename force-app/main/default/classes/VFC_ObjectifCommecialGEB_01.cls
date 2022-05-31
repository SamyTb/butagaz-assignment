public class VFC_ObjectifCommecialGEB_01 {
	
	public ObjCom_GEB__c oObjCom {get;set;}	
    public string sMode {get;set;}// Page mode : New, Edit
    ApexPages.StandardController oControl;      
	public List<Item__c> lBouteilles {get;set;}//Articles of type Bouteille
	public List<cObjArticleYearMonth> lcObjArticleYearMonth {get;set;}
    public transient Savepoint sp; //Database Savepoint

	public VFC_ObjectifCommecialGEB_01(ApexPages.StandardController oControl_in){
        this.oControl=oControl_in;        
        // Recover page mode
        oObjCom=(ObjCom_GEB__c)oControl.getRecord();
        sMode=(oObjCom.Id==null?'New':'Edit'); 
        lBouteilles = [SELECT id, Name,Type__c, Code_Article__c ,Ordre_de_tri__c, ExternalID__c FROM Item__c WHERE Type__c='Bouteille' ORDER BY Ordre_de_tri__c];
       
         if(sMode=='New') {  
         	 //Create Objective for each Article per Year/Month
         	 lcObjArticleYearMonth = new List<cObjArticleYearMonth>();
         	 for(Item__c oBouteille:lBouteilles){
         	 	createObjArticleYearMonth(oBouteille);        	 	        	 	
         	 }
     	  //Create total Objecive per Year/Month
		  createtotalObjYearMonth();
     	 
         }  		
		 else {
            // Recover all Article objectives  
			list<Objectif_Article_YearMonth__c>	lObjArticleYearMonth= [select id, ObjCom_GEB__c, Objective_Date__c, Article__c, Article__r.Name,Article__r.ExternalID__c,Article__r.Type__c,Article__r.Code_Article__c, Consignations_nettes_mandataire__c, Tonnage_Global__c
             	from Objectif_Article_YearMonth__c where ObjCom_GEB__c=:oObjCom.id];  
            
            //Prepare the list to be displayed		                 
			lcObjArticleYearMonth = new List<cObjArticleYearMonth>();					
			for(Item__c oBouteille:lBouteilles){
				map<decimal, Objectif_Article_YearMonth__c> mObjArticleYearMonth = new map<decimal, Objectif_Article_YearMonth__c>();				
				lcObjArticleYearMonth.add(new cObjArticleYearMonth(oBouteille,mObjArticleYearMonth));	
			}
			//fill the map with the exisiting objectives         
            for(Objectif_Article_YearMonth__c oObjArticleYearMonth: lObjArticleYearMonth){                
	            //lcObjArticleYearMonth.add
	            Integer imonth;
	            imonth = oObjArticleYearMonth.Objective_Date__c.month();	         
		        if(mObjArticleContainsElement(oObjArticleYearMonth.Article__r)!=null){
		            	mObjArticleContainsElement(oObjArticleYearMonth.Article__r).put(imonth,oObjArticleYearMonth);
		            	if(!mObjArticleContainsElement(oObjArticleYearMonth.Article__r).containskey(13)){
		            		mObjArticleContainsElement(oObjArticleYearMonth.Article__r).put(13,new Objectif_Article_YearMonth__c(ObjCom_GEB__c=oObjCom.id,Article__c=oObjArticleYearMonth.Article__c, Article__r=oObjArticleYearMonth.Article__r));					            		
		            	}
		        }         
			}
			createtotalObjYearMonth();

			//initialize the total
			//total for Volume
			for(decimal iMonth:getTotalObjectives().mObjArticleYearMonth.keySet()){
				for(cObjArticleYearMonth  ocObjArticleYearMonth:lcObjArticleYearMonth){
					if(ocObjArticleYearMonth.bIsTotal!=true && ocObjArticleYearMonth.oArticle.ExternalID__c=='000000000000000100' && ocObjArticleYearMonth.mObjArticleYearMonth.containsKey(iMonth) && ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Tonnage_Global__c!=null){
						getTotalObjectives().mObjArticleYearMonth.get(iMonth).Tonnage_Global__c=ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Tonnage_Global__c;
						break;
					}
				}
			}						
			calcTotal();
			
		}	
	}
	
	
	public void createObjArticleYearMonth(Item__c oArticle){
		//create Article objectives for each month
		map<decimal, Objectif_Article_YearMonth__c> mObjArticleYearMonth = new map<decimal, Objectif_Article_YearMonth__c>();				
		Integer[] lMonths = new Integer[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12};
		for (Integer iMonth : lMonths) {		
			date dObjective_Date = date.newInstance(date.today().year(), iMonth, 1);
			mObjArticleYearMonth.put(iMonth,new Objectif_Article_YearMonth__c(ObjCom_GEB__c=oObjCom.id,Objective_Date__c=dObjective_Date,Article__c=oArticle.Id, Article__r=oArticle));			
		}
		//create Article  objectives for the year
			mObjArticleYearMonth.put(13,new Objectif_Article_YearMonth__c(ObjCom_GEB__c=oObjCom.id,Article__c=oArticle.Id, Article__r=oArticle));			
		
		lcObjArticleYearMonth.add(new cObjArticleYearMonth(oArticle,mObjArticleYearMonth));
	}

	public void createtotalObjYearMonth(){		
		map<decimal, Objectif_Article_YearMonth__c> mObjArticleYearMonth = new map<decimal, Objectif_Article_YearMonth__c>();		
		Integer[] lMonths = new Integer[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12};
		for (Integer iMonth : lMonths) {		
			date dObjective_Date = date.newInstance(date.today().year(), iMonth, 1);
			mObjArticleYearMonth.put(iMonth,new Objectif_Article_YearMonth__c(ObjCom_GEB__c=oObjCom.id,Objective_Date__c=dObjective_Date));			
		}
		mObjArticleYearMonth.put(13,new Objectif_Article_YearMonth__c(ObjCom_GEB__c=oObjCom.id));			
		
		lcObjArticleYearMonth.add(new cObjArticleYearMonth(mObjArticleYearMonth));
	}	
	
	public void calcTotal(){
		
		//Total Consignation
		for(decimal iMonth:getTotalObjectives().mObjArticleYearMonth.keySet()){
			getTotalObjectives().mObjArticleYearMonth.get(iMonth).Consignations_nettes_mandataire__c=0;			
		}		
		for(cObjArticleYearMonth  ocObjArticleYearMonth:lcObjArticleYearMonth){
			if(ocObjArticleYearMonth.bIsTotal!=true){
				ocObjArticleYearMonth.mObjArticleYearMonth.get(13).Consignations_nettes_mandataire__c=0;				
				for(decimal iMonth:ocObjArticleYearMonth.mObjArticleYearMonth.keySet()){
					if(iMonth!=13 && ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Consignations_nettes_mandataire__c!=null ){						
						ocObjArticleYearMonth.mObjArticleYearMonth.get(13).Consignations_nettes_mandataire__c +=ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Consignations_nettes_mandataire__c;
						getTotalObjectives().mObjArticleYearMonth.get(iMonth).Consignations_nettes_mandataire__c+=ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Consignations_nettes_mandataire__c;
						getTotalObjectives().mObjArticleYearMonth.get(13).Consignations_nettes_mandataire__c+=ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Consignations_nettes_mandataire__c;
					}
				}	
			}
		}
		
		//Total Volume
		getTotalObjectives().mObjArticleYearMonth.get(13).Tonnage_Global__c=0;
		for(decimal iMonth:getTotalObjectives().mObjArticleYearMonth.keySet()){
			if(iMonth!=13){
				if(getTotalObjectives().mObjArticleYearMonth.get(iMonth).Tonnage_Global__c!=null ){				
					getTotalObjectives().mObjArticleYearMonth.get(13).Tonnage_Global__c +=getTotalObjectives().mObjArticleYearMonth.get(iMonth).Tonnage_Global__c;
					for(cObjArticleYearMonth  ocObjArticleYearMonth:lcObjArticleYearMonth){
						if(ocObjArticleYearMonth.bIsTotal!=true && ocObjArticleYearMonth.oArticle.ExternalID__c=='000000000000000100' && ocObjArticleYearMonth.mObjArticleYearMonth.containsKey(iMonth)){					
							ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Tonnage_Global__c=getTotalObjectives().mObjArticleYearMonth.get(iMonth).Tonnage_Global__c;
						}
						else if (ocObjArticleYearMonth.bIsTotal!=true && ocObjArticleYearMonth.mObjArticleYearMonth.containsKey(iMonth)) 
						{
							ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Tonnage_Global__c=null;
						}
					}
				}
				else {
					for(cObjArticleYearMonth  ocObjArticleYearMonth:lcObjArticleYearMonth){
						if(ocObjArticleYearMonth.bIsTotal!=true && ocObjArticleYearMonth.mObjArticleYearMonth.containsKey(iMonth)){					
							ocObjArticleYearMonth.mObjArticleYearMonth.get(iMonth).Tonnage_Global__c=null;
						}
					}					
				}				
			}									
		}
	
	}

	public pageReference saveBtn(){  
        list<Objectif_Article_YearMonth__c> lObjArticleYearMonthToUpsert = new list<Objectif_Article_YearMonth__c>();//Objectif_Article_YearMonth to be upserted           
        calcTotal();
        // Define a save point
        sp = Database.setSavepoint();
        ObjCom_GEB__c oNewObjCom;
        
        try{
               
            //upsert New PEC;
            oNewObjCom =oObjCom.clone(true);
            oNewObjCom.External_Id__c = string.valueof(oNewObjCom.ObjCOm_date__c.year())+oNewObjCom.Code_AC__c;
            upsert oNewObjCom;       
                
            // Upsert Objectif_Article_YearMonth       
            for(cObjArticleYearMonth  ocObjArticleYearMonth:lcObjArticleYearMonth){
            	if(ocObjArticleYearMonth.bIsTotal==false){
	            	for(Decimal dMonth:ocObjArticleYearMonth.mObjArticleYearMonth.keySet()){
	            		if(dMonth!=13){
	            			Objectif_Article_YearMonth__c oNewObjArticleYearMonth = ocObjArticleYearMonth.mObjArticleYearMonth.get(dMonth).clone(true);
		            		if(sMode=='New') {
		            			oNewObjArticleYearMonth.ObjCom_GEB__c=oNewObjCom.id;
		            		}
		            		//update the objectives date
		            		Integer iMonth = (Integer)dMonth;           		
		            		date dObjective_Date = date.newInstance(oNewObjCom.ObjCOm_date__c.year(), iMonth, 1);
		            		oNewObjArticleYearMonth.Objective_Date__c=dObjective_Date;
		      				
		      				lObjArticleYearMonthToUpsert.add(oNewObjArticleYearMonth);

	            		}

	            	}            		
            	}
            }           
            
            if(lObjArticleYearMonthToUpsert.size()>0){
                upsert lObjArticleYearMonthToUpsert;
            } 
        }         
        catch(DmlException ex){            
            Database.rollback(sp);           
	    	if(ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE ){
	            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.ERROR,System.Label.ComObj_duplicateError));				    		
        	}else {
        		ApexPages.AddMessages(ex);	
        	}
            return null;
        }   
        return new PageReference('/' + oNewObjCom.id); 
	}
	
	private  void overrideExceptionMesg(DmlException ex){
	    if(ex.getDmlType(0) == StatusCode.DUPLICATE_VALUE ){
           ex.setMessage('Valeur dupliquée: un Objectif Commercial existe déjà pour le Commercial et l\'année choisis.');			            	
        }
	}
	
	public cObjArticleYearMonth getTotalObjectives(){		
		cObjArticleYearMonth oTotalObjectives;
		for(cObjArticleYearMonth  ocObjArticleYearMonth:lcObjArticleYearMonth){
			if(ocObjArticleYearMonth.bIsTotal==true){
				oTotalObjectives=ocObjArticleYearMonth;
			}
		}		
		return oTotalObjectives;
	}

	public map<decimal, Objectif_Article_YearMonth__c>  mObjArticleContainsElement(Item__c oArticle){
		map<decimal, Objectif_Article_YearMonth__c> result = null;
		for(cObjArticleYearMonth  ocObjArticleYearMonth:lcObjArticleYearMonth){
			if(oArticle!=null && ocObjArticleYearMonth.oArticle!=null){
				if(oArticle.id==ocObjArticleYearMonth.oArticle.id){
					result=ocObjArticleYearMonth.mObjArticleYearMonth;
				}
			}
			else if (oArticle==null && ocObjArticleYearMonth.oArticle==null){
				result=ocObjArticleYearMonth.mObjArticleYearMonth;
			}			
		}
		return result;		
	}
	    	
	public class cObjArticleYearMonth {
        public Item__c oArticle {get;set;}
        public boolean bIsTotal {get;set;}
        public map<decimal, Objectif_Article_YearMonth__c> mObjArticleYearMonth {get;set;}

        public cObjArticleYearMonth(Item__c oArticle, map<decimal, Objectif_Article_YearMonth__c> mObjArticleYearMonth){
            this.bIsTotal=false;
            this.oArticle = oArticle;
            this.mObjArticleYearMonth = mObjArticleYearMonth;
        }		
        
        public cObjArticleYearMonth(map<decimal, Objectif_Article_YearMonth__c> mObjArticleYearMonth){
        	this.bIsTotal=true;
            this.oArticle = oArticle;
            this.mObjArticleYearMonth = mObjArticleYearMonth;
        }		
	}
	

}