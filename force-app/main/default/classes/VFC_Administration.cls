public with sharing class VFC_Administration {
	
	public string menuEntry = 'None'; //{get;set;}
	public string blockTitle = '';

	public List<mandataireGEBSdTQuota> finalMdtSdTQuotaList {get;set;}


	/*ApexPages.StandardController stdController*/
	public VFC_Administration() {
		
	}
	
	// Creates list to display in main menu
	public SelectOption[] getMenuEntries() {
        //return new SelectOption[] { new SelectOption('None', 'Sélectionner une action'),
        //    new SelectOption('QuotasGEB', 'Quotas sauts de tranche GEB') };

        List<SelectOption> entries = new List<SelectOption>();
        entries.add(new SelectOption('None','Sélectionner une action'));
        entries.add(new SelectOption('QuotasGEB','Quotas sauts de tranche GEB'));
        entries.add(new SelectOption('SigneaUsers','Licenses de package Signea utilisées'));
        return entries;
    }

    public String getMenuEntry() {
        return menuEntry;
    }

    public void setMenuEntry(String menuEntry) {
        this.menuEntry = menuEntry;
        if(menuEntry=='None'){
			blockTitle = '';
        }else if(menuEntry=='QuotasGEB'){
        	blockTitle = 'Quotas sauts de tranche GEB';
        }else if(menuEntry=='SigneaUsers'){
        	blockTitle = 'Licenses de package Signea utilisées';
        }
    }

    public String getBlockTitle() {
        return blockTitle;
    }


	// Creates list of opties vs quota to display in VFP
	public List<mandataireGEBSdTQuota> getOptiesAndQuotaToDisplay(){
		
		Integer nbOpties;
		finalMdtSdTQuotaList = new list<mandataireGEBSdTQuota>();
		//finalMdtSdTQuotaList.clear();
		
		// Retrieving SdT Quota for the current year
		List<Ref_Quota_Saut_de_Tranche_GEB_RE__c> quotasList = [SELECT Mandataire__r.Id, Mandataire__c, Mandataire__r.Name, Quota__c 
																	FROM Ref_Quota_Saut_de_Tranche_GEB_RE__c 
																	WHERE Type_PDV__c = 'All'
																	ORDER BY Mandataire__r.Name];

		// Retrieving current values for each mandataire
		List<AggregateResult> OptiesList = [SELECT count(Id) optiesCount, DO_Mandataire__c, DO_Mandataire__r.Name
												FROM Opportunity
												WHERE Account.Activity_Domain__r.ExternalID__c = 41
												AND Client_Type__c = 'RE'
												AND CloseDate = THIS_YEAR
												AND StageName = 'Closed Won'
												AND SyncedQuote.Saut_de_tranche__c != '0' AND SyncedQuote.Saut_de_tranche__c != null
												GROUP BY DO_Mandataire__c, DO_Mandataire__r.Name
												ORDER BY DO_Mandataire__r.Name];

		for (Ref_Quota_Saut_de_Tranche_GEB_RE__c oQuota : quotasList){
			nbOpties = 0;
			for (AggregateResult oOpty : OptiesList){
				if(oQuota.Mandataire__c == (string)oOpty.get('DO_Mandataire__c')){
					nbOpties = (Integer)oOpty.get('optiesCount');
				}
			}
			finalMdtSdTQuotaList.add(new mandataireGEBSdTQuota(oQuota.Mandataire__r.Id, oQuota.Mandataire__r.Name, (Integer)oQuota.Quota__c, nbOpties));
		}
		
		return finalMdtSdTQuotaList;
		
	}
	
	public class mandataireGEBSdTQuota {
		public String mandataireId {get;set;}
    	public String mandataireName {get;set;}
        public Integer mandataireQuota {get;set;}
        public Integer mandataireCurrentValue {get;set;}
        
        public mandataireGEBSdTQuota(String mdtId, String mdtName, Integer mdtQuota, Integer mdtCurrentValue) {
        	this.mandataireId = mdtId;
            this.mandataireName = mdtName;
            this.mandataireQuota = mdtQuota;
            this.mandataireCurrentValue = mdtCurrentValue;
        }
    }

    // Retrieving Package License details
	public List<PackageLicense> getSigneaPackageLicenseDetails(){

		List<PackageLicense> signeaPackageLicenseDetailsList = [SELECT Id, NamespacePrefix , AllowedLicenses, UsedLicenses, 
															           ExpirationDate, CreatedDate, 
															           IsProvisioned, Status
															   FROM PackageLicense 
															   WHERE NamespacePrefix = 'Signea'
															   LIMIT 1];

		return signeaPackageLicenseDetailsList;
		
	}

    // Creates list of users with Signea Package License
	public List<User> getSigneaUsersList(){
		
		List<User> signeaUsersList = [SELECT Id, Name, Mandataire__c, Profile.Name, UserRole.Name
										FROM User
										WHERE Id in (
											SELECT UserId
											FROM UserPackageLicense
											WHERE (PackageLicense.NamespacePrefix = 'Signea')
										)	
										ORDER BY Name];

		/*List<User> signeaUsersList = [SELECT Id, Name, Profile.Id, Profile.Name
										FROM User
										ORDER BY Name
										];*/

		return signeaUsersList;
		
	}


}