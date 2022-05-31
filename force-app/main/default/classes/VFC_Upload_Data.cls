public class VFC_Upload_Data {

        public Blob csvFileBody{get;set;}
        public String csvAsString{get;set;}
        public String[] csvFileLines{get;set;}
        public List<Case> caselist{get;set;}
        public String contenttype{get;set;}
        public String msg{get;set;}
    	public Boolean afficheError{get;set;}
    	public Boolean notafficheError{get;set;}
    

        public VFC_Upload_Data()
        {
            csvFileLines = new String[]{};
            caselist= New List<Case>();
            this.afficheError = false;
        }

        public pageReference upload() 
        {
            this.afficheError = false;
            this.notafficheError = false;
            
            PageReference PageError = ApexPages.currentPage();
            PageError.setRedirect(true);
            Savepoint sp = null;
            List<Database.SaveResult> srcaseList = new List<Database.SaveResult>();

            try 
            {
                //empty list case
                caselist.clear();
                this.msg = '';

                if(contenttype != 'application/vnd.ms-excel' && contenttype != 'text/csv')
                {
                    this.afficheError = true;
                    this.notafficheError = false;
                    this.msg = 'Veuillez choisir un fichier csv.';
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Veuillez choisir un fichier csv.'));
                    return null;
                }
                else
                {

                    //flag bypass VR for the user        
                    String userId = UserInfo.getUserId();
                    User userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
                    userCurrent.Bypass_Validation_Rules__c = true;
                    update userCurrent;

                    Map<String, String> mapAccountNumber_IdAccount = new Map<String, String>();
                    List<String> listAccountNumber = new List<String>();  
                    Map<String, String> mapMandataire_IdMandataire = new Map<String, String>();  
                    List<String> listMandataire = new List<String>();  
                    Map<String, String> mapActiviteDomaine_IdActiviteDomaine = new Map<String, String>();  
                    List<String> listActiviteDomaine = new List<String>();  
                    Map<String, String> mapOwner_IdOwner = new Map<String, String>();
                    List<String> listOwner = new List<String>();  
                    Map<String, String> mapPTL_IdPTL = new Map<String, String>();  
                    List<String> listPTL = new List<String>();  
                    Map<String, String> mapCategoryDemande_IdCategoryDemande = new Map<String, String>();  
                    List<String> listCategoryDemande = new List<String>();  
                    Map<String, String> mapEquipement_IdEquipement = new Map<String, String>();  
                    List<String> listEquipement = new List<String>();  
                    Map<String, String> mapCommande_IdCommande = new Map<String, String>();  
                    List<String> listCommande = new List<String>();  

                    // Read CSV file body and store it in variable
                    csvAsString = csvFileBody.toString();
                    // Split CSV String to lines
                    csvFileLines = csvAsString.split('\r\n');
                    //list of fields
                    List<String> listChamp = csvFileLines[0].split(';');

                    //System.debug('listChamp:'+listChamp);
                    //loop to create case list
                    for(Integer j=1; j < csvFileLines.size(); j++)
                    {
                        String[] csvRecordData = csvFileLines[j].split(';');
                        
                        Map<String, String> field_fieldvalue = new Map<String, String>();  

                        for(Integer h=0; h < csvRecordData.size(); h++)
                        {

                            if((listChamp[h]=='numéro du compte')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapAccountNumber_IdAccount.put(csvRecordData[h], null);  
                                
                            if((listChamp[h]=='mandataire')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapMandataire_IdMandataire.put(csvRecordData[h], null);  
                                
                            if((listChamp[h]=='secteur d\'activité')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapActiviteDomaine_IdActiviteDomaine.put(csvRecordData[h], null);  

                            if((listChamp[h]=='propriétaire demande')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapOwner_IdOwner.put(csvRecordData[h], null);  

                            if((listChamp[h]=='point livré')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapPTL_IdPTL.put(csvRecordData[h], null);  

                            if((listChamp[h]=='catégorie demande')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapCategoryDemande_IdCategoryDemande.put(csvRecordData[h], null);  

                            if((listChamp[h]=='equipement')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapEquipement_IdEquipement.put(csvRecordData[h], null);  
                            
                            if((listChamp[h]=='commande')&&(csvRecordData[h]!='')&&(csvRecordData[h]!=null))
                                mapCommande_IdCommande.put(csvRecordData[h], null);  
                                
                        }

                    }
                    
                    //on créé la liste pour requeter
                    for (String accNUmber : mapAccountNumber_IdAccount.keySet()) 
                    {
                        listAccountNumber.add(accNUmber);
                    }

                    for (String mandataire : mapMandataire_IdMandataire.keySet()) 
                    {
                        listMandataire.add(mandataire);
                    }

                    for (String actDomaine : mapActiviteDomaine_IdActiviteDomaine.keySet()) 
                    {
                        listActiviteDomaine.add(actDomaine);
                    }

                    for (String owner : mapOwner_IdOwner.keySet()) 
                    {
                        listOwner.add(owner);
                    }

                    for (String ptl : mapPTL_IdPTL.keySet()) 
                    {
                        listPTL.add(ptl);
                    }

                    for (String catDemande : mapCategoryDemande_IdCategoryDemande.keySet()) 
                    {
                        listCategoryDemande.add(catDemande);
                    }

                    for (String equipement : mapEquipement_IdEquipement.keySet()) 
                    {
                        listEquipement.add(equipement);
                        
                    }
                    
                    for (String commande : mapCommande_IdCommande.keySet()) 
                    {
                        listCommande.add(commande);
                    }

                    //on requete chaque data
                    List<Account> listAccountNumberSOQL = [select Id, AccountNumber, Email__c, Email_2__c,No_E_mail__c from Account where AccountNumber in :listAccountNumber];    
                    for(Account acc:listAccountNumberSOQL)
                        mapAccountNumber_IdAccount.put(acc.AccountNumber, acc.Id);
                    
                    List<Mandataire__c> listMandataireSOQL = [select name, Id from Mandataire__c where name in :listMandataire];    
                    for(Mandataire__c m:listMandataireSOQL)
                        mapMandataire_IdMandataire.put(m.name, m.Id);   
                    
                    List<Activity_Domain__c> listActiviteDomaineSOQL = [select name, Id from Activity_Domain__c where name in :listActiviteDomaine];    
                    for(Activity_Domain__c ad:listActiviteDomaineSOQL)
                        mapActiviteDomaine_IdActiviteDomaine.put(ad.name, ad.Id);
                    
                    //requete User and Queue
                    List<User> listOwnerSOQL = [select name, Id from User where name in :listOwner];    
                    for(User u:listOwnerSOQL)
                        mapOwner_IdOwner.put(u.name, u.Id);

                    List<Group> listQueueSOQL = [Select Id, Name, Type from Group where Type = 'Queue' AND name in :listOwner];    
                    for(Group g:listQueueSOQL)
                        mapOwner_IdOwner.put(g.name, g.Id);                     

                    List<PTL__c> listPTLSOQL = [select name, Id from PTL__c where name in :listPTL];    
                    for(PTL__c ptl:listPTLSOQL)
                        mapPTL_IdPTL.put(ptl.name, ptl.Id);

                    List<Request_Category__c> listCategoryDemandeSOQL = [select name, Id from Request_Category__c where name in :listCategoryDemande];    
                    for(Request_Category__c rc:listCategoryDemandeSOQL)
                        mapCategoryDemande_IdCategoryDemande.put(rc.name, rc.Id);

                    List<Equipement__c> listEquipementSOQL = [select name, Id from Equipement__c where name in :listEquipement];    
                    for(Equipement__c e:listEquipementSOQL)
                        mapEquipement_IdEquipement.put(e.name, e.Id);

                    List<Order__c> listCommandeSOQL = [select name, Id from Order__c where name in :listCommande];    
                    for(Order__c o:listCommandeSOQL)
                        mapCommande_IdCommande.put(o.name, o.Id);
                    
                    //on vérifie si tous les objets ont été trouvé
                    Boolean errorTrouve = false;
                    List<String> listAccountNumberInconnu = new List<String>();
                    for (String an : mapAccountNumber_IdAccount.keySet()) 
                    {
                        if((mapAccountNumber_IdAccount.get(an) == '')||(mapAccountNumber_IdAccount.get(an) == null))
                            listAccountNumberInconnu.add(an);
                    }
                    if(listAccountNumberInconnu.size()>0)
                    {
                        //this.msg = this.msg + 'Numero de compte inconnu:'+listAccountNumberInconnu+'\n';
                        errorTrouve = true;
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listAccountNumberInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg + 'Numero de compte inconnu:\n';
                        this.msg = this.msg+msg1+'\n';
                    }    

                    List<String> listMandataireInconnu = new List<String>();
                    for (String m : mapMandataire_IdMandataire.keySet()) 
                    {
                        if((mapMandataire_IdMandataire.get(m) == '')||(mapMandataire_IdMandataire.get(m) == null))
                            listMandataireInconnu.add(m);
                    }
                    if(listMandataireInconnu.size()>0)
                    {
                        //this.msg = this.msg + 'Mandataire inconnu:'+listMandataireInconnu+'\n';
                        errorTrouve = true;
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listMandataireInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg + 'Mandataire inconnu:\n';
                        this.msg = this.msg+msg1+'\n';
                    }
                   
                    List<String> listActivityDomaineInconnu = new List<String>();
                    for (String ac : mapActiviteDomaine_IdActiviteDomaine.keySet()) 
                    {
                        if((mapActiviteDomaine_IdActiviteDomaine.get(ac) == '')||(mapActiviteDomaine_IdActiviteDomaine.get(ac) == null))
                            listActivityDomaineInconnu.add(ac);
                    }
                    
                    if(listActivityDomaineInconnu.size()>0)
                    {
                        errorTrouve = true;
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listActivityDomaineInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg + 'Secteur d activité inconnu:\n';
                        this.msg = this.msg+msg1+'\n';
                        //this.msg = this.msg + 'Secteur d\'activité inconnu:'+listActivityDomaineInconnu+'\n';
                    }

                    List<String> listOwnerInconnu = new List<String>();
                    for (String o : mapOwner_IdOwner.keySet()) 
                    {
                        if((mapOwner_IdOwner.get(o) == '')||(mapOwner_IdOwner.get(o) == null))
                            listOwnerInconnu.add(o);
                    }
                    if(listOwnerInconnu.size()>0)
                    {
                        errorTrouve = true;
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listOwnerInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg + 'Propriétaire inconnu:\n';
                        this.msg = this.msg+msg1+'\n';
                        //this.msg = this.msg + 'Propriétaire inconnu:'+listOwnerInconnu+'\n';
                    }

                    List<String> listPTLInconnu = new List<String>();
                    for (String ptl : mapPTL_IdPTL.keySet()) 
                    {
                        if((mapPTL_IdPTL.get(ptl) == '')||(mapPTL_IdPTL.get(ptl) == null))
                            listPTLInconnu.add(ptl);
                    }

                    if(listPTLInconnu.size()>0)
                    {
                        errorTrouve = true;
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listPTLInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg + 'PTL inconnu:\n';
                        this.msg = this.msg+msg1+'\n';
                        //this.msg = this.msg + 'PTL inconnu:'+listPTLInconnu+'\n';
                    }

                    List<String> listCategoryDemandeInconnu = new List<String>();
                    for (String cd : mapCategoryDemande_IdCategoryDemande.keySet()) 
                    {
                        if((mapCategoryDemande_IdCategoryDemande.get(cd) == '')||(mapCategoryDemande_IdCategoryDemande.get(cd) == null))
                            listCategoryDemandeInconnu.add(cd);
                    }
                    if(listCategoryDemandeInconnu.size()>0)
                    {
                        errorTrouve = true;
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listCategoryDemandeInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg + 'Catégorie de demande inconnue:\n';
                        this.msg = this.msg+msg1+'\n';
                        //this.msg = this.msg + 'Catégorie de demande inconnue:'+listCategoryDemandeInconnu+'\n';
                    }
                    List<String> listEquipementInconnu = new List<String>();
                    for (String eq : mapEquipement_IdEquipement.keySet()) 
                    {
                        if((mapEquipement_IdEquipement.get(eq) == '')||(mapEquipement_IdEquipement.get(eq) == null))
                            listEquipementInconnu.add(eq);
                    }
                    if(listEquipementInconnu.size()>0)
                    {
                        errorTrouve = true;
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listEquipementInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg + 'Equipement inconnu:\n';
                        this.msg = this.msg+msg1+'\n';
                    }
                    List<String> listCommandeInconnu = new List<String>();
                    for (String cde : mapCommande_IdCommande.keySet()) 
                    {
                        if((mapCommande_IdCommande.get(cde) == '')||(mapCommande_IdCommande.get(cde) == null))
                            listCommandeInconnu.add(cde);
                    }
                    if(listCommandeInconnu.size()>0)
                    {
                        errorTrouve = true;
                        this.msg = this.msg + 'Commande inconnu:\n';
                        String msg1 = '';
                        Integer i=1;
                        for(String o:listCommandeInconnu)
                        {
                            if(math.mod(i, 10)==0)
								msg1 = msg1+o+',\n';
							else
                            	msg1 = msg1+o+',';
                            i++;
                        }
                        this.msg = this.msg+msg1+'\n';
                    }


                    if(errorTrouve == true)
                    {
                        this.afficheError = true;
                        this.notafficheError = false;
                        this.msg = 'Veuillez corriger les différentes erreurs, puis relancer le chargement.\n'+this.msg;
                        return null;
                    }
                    else
                    {
                        //loop to create case list
                        for(Integer j=1; j < csvFileLines.size(); j++)
                        {
                            String[] csvRecordData = csvFileLines[j].split(';');
                            
                            Map<String, String> field_fieldvalue = new Map<String, String>();  

                            for(Integer h=0; h < csvRecordData.size(); h++)
                            {
                                
                                if(listChamp[h] == 'numéro du compte')
                                    field_fieldvalue.put('AccountId', mapAccountNumber_IdAccount.get(csvRecordData[h]));
                                else if(listChamp[h] == 'mandataire')
                                    field_fieldvalue.put('Mandataire__c', mapMandataire_IdMandataire.get(csvRecordData[h]));
                                else if(listChamp[h] == 'secteur d\'activité')
                                    field_fieldvalue.put('Activity_Domain__c', mapActiviteDomaine_IdActiviteDomaine.get(csvRecordData[h]));
                                else if(listChamp[h] == 'propriétaire demande')
                                    field_fieldvalue.put('OwnerId', mapOwner_IdOwner.get(csvRecordData[h]));
                                else if(listChamp[h] == 'point livré')
                                    field_fieldvalue.put('PTL__c', mapPTL_IdPTL.get(csvRecordData[h]));
                                else if(listChamp[h] == 'catégorie demande')
                                    field_fieldvalue.put('Category__c', mapCategoryDemande_IdCategoryDemande.get(csvRecordData[h]));
                                else if(listChamp[h] == 'equipement')
                                    field_fieldvalue.put('Equipement__c', mapEquipement_IdEquipement.get(csvRecordData[h]));
                                else if(listChamp[h] == 'commande')
                                    field_fieldvalue.put('Order__c', mapCommande_IdCommande.get(csvRecordData[h]));
                                else field_fieldvalue.put( listChamp[h], csvRecordData[h]);                            

                            }

                            //creation des cases
                            Case caseObj = new Case() ;
                            for (String f : field_fieldvalue.keySet()) 
                            {
                                caseObj.put(f, field_fieldvalue.get(f));
                            }
                            caselist.add(caseObj);
                            
                        }
                        
                        sp = Database.setSavepoint();

						List<Database.SaveResult> results = Database.insert(caselist, false);
						Map<String, String> mapTargets = new Map<String, String>();
                        for(Integer index = 0, size = results.size(); index < size; index++) 
                        {
                            if(results[index].isSuccess()==false)
                            {   
                                for (Database.SaveResult result : results) 
                                {
                                	for(Database.Error error : result.getErrors()) 
                                    {
                                        mapTargets.put(caselist[index].AccountId, caselist[index]+'\n'+error.getMessage()+'\n\n');
                                    }
                                }
							}
                        }
                        if(mapTargets.size()==0)
                        {
                            this.afficheError = false;
                            this.notafficheError = true;
                        	this.msg = 'Vos demandes ont été chargées avec succès.\n';
                        }    
                        else
                        {
                            this.afficheError = true;
                    		this.notafficheError = false;
                        	Database.rollback( sp );  
                            //Integer i = 0;
                         	for (String key : mapTargets.keySet())
                            {
                                this.msg = this.msg+mapTargets.get(key)+'\n';
                                
								/*if(math.mod(i, 10)==0)
                                	this.msg = this.msg+mapTargets.get(key)+'\n';
								else*/
                                    //this.msg = this.msg+mapTargets.get(key);
                                //i++;
        					}   
                            this.msg = 'Veuillez corriger les différentes erreurs, puis relancer le chargement.\n'+this.msg;
                        }
                        //flag bypass VR for the user        
                        userId = UserInfo.getUserId();
                        userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
                        userCurrent.Bypass_Validation_Rules__c = false;
                        update userCurrent;

                        
						return null;
                    }
                }
            } 
            catch (Exception e) 
            { 
                //flag bypass VR for the user        
                String userId = UserInfo.getUserId();
                User userCurrent = [select Id, Bypass_Validation_Rules__c from User where Id= :userId];
                userCurrent.Bypass_Validation_Rules__c = false;
                update userCurrent;

                Database.rollback( sp );
                this.afficheError = true;
                this.notafficheError = false;
                this.msg = 'Une erreur est survenue. Veuillez corriger vos données ou contacter votre administrateur système.\n';
				this.msg = this.msg +e.getMessage();
                return null;
            } 

        }//fin upload

}