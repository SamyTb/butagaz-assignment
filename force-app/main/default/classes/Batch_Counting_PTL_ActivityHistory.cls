global class Batch_Counting_PTL_ActivityHistory implements Database.Batchable<sObject> {

    // Implement the interface to update the counting of YTD activities on PTLs 
    global String query;
    //global Integer iPTLToUpdateSize = 0;
    
    global  Batch_Counting_PTL_ActivityHistory (String q){
        this.query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<PTL__c> lPTLs) {
        
        decimal iCptVisites, iCptContactsTel, iCptVisitesAmoins1, iCptContactsTelAmoins1;
        decimal iQuotaVisites, iQuotaContactsTel, iQuotaVisitesAmoins1, iQuotaContactsTelAmoins1;
        decimal dCalculatedPercentVisit, dCalculatedPercentContactsTel, dCalculatedPercentVisitAmoins1, dCalculatedPercentContactsTelAmoins1; 
        List<PTL__c> lPTLtoUpdate = new List<PTL__c>();
        
        Map<String, Decimal> mNbVisitesParMedaille = new Map<String,Decimal>();
        Map<String, Decimal> mNbContactsTelParMedaille = new Map<String,Decimal>();
        Map<String, Decimal> mNbVisitesParMedailleAmoins1 = new Map<String,Decimal>();
        Map<String, Decimal> mNbContactsTelParMedailleAmoins1 = new Map<String,Decimal>();
        
        
        System.debug('## Batch_Counting_PTL_ActivityHistory - execute: lPTLs.size() : ' + lPTLs.size());
        
        // Set the goals for each medal
        Map<ID, Contact_Per_Medal__c> mCPM = new Map<ID, Contact_Per_Medal__c>([SELECT Id, Year__c, Contact_Type__c, Segmentation_medailles__c, Contact_Count__c FROM Contact_Per_Medal__c WHERE Year__c = :string.valueof(System.Today().Year()) OR Year__c = :string.valueof(System.Today().Year() - 1)]);
		
        for (ID idKey : mCPM.keyset()) {
        	
        	// Current year
        	if( mCPM.get(idKey).Year__c == string.valueof(System.Today().Year()) && mCPM.get(idKey).Contact_Type__c == 'Visite de suivi' ){
        		if(!mNbVisitesParMedaille.containsKey(mCPM.get(idKey).Segmentation_medailles__c)){
        			mNbVisitesParMedaille.put(mCPM.get(idKey).Segmentation_medailles__c, mCPM.get(idKey).Contact_Count__c);
        		}
        	}
        	if( mCPM.get(idKey).Year__c == string.valueof(System.Today().Year()) && mCPM.get(idKey).Contact_Type__c == 'Phone conference' ){
        		if(!mNbContactsTelParMedaille.containsKey(mCPM.get(idKey).Segmentation_medailles__c)){
        			mNbContactsTelParMedaille.put(mCPM.get(idKey).Segmentation_medailles__c, mCPM.get(idKey).Contact_Count__c);
        		}
        	}
        	// Last year
        	if( mCPM.get(idKey).Year__c == string.valueof(System.Today().Year()-1) && mCPM.get(idKey).Contact_Type__c == 'Visite de suivi' ){
        		if(!mNbVisitesParMedailleAmoins1.containsKey(mCPM.get(idKey).Segmentation_medailles__c)){
        			mNbVisitesParMedailleAmoins1.put(mCPM.get(idKey).Segmentation_medailles__c, mCPM.get(idKey).Contact_Count__c);
        		}
        	}
        	if( mCPM.get(idKey).Year__c == string.valueof(System.Today().Year()-1) && mCPM.get(idKey).Contact_Type__c == 'Phone conference' ){
        		if(!mNbContactsTelParMedailleAmoins1.containsKey(mCPM.get(idKey).Segmentation_medailles__c)){
        			mNbContactsTelParMedailleAmoins1.put(mCPM.get(idKey).Segmentation_medailles__c, mCPM.get(idKey).Contact_Count__c);
        		}
        	}
        	
		}
        
        //Map<String, Integer> mNbVisitesParMedaille = new Map<String,Integer>{'1. Or' => 8, '2. Argent' => 4, '3. Bronze' => 1, '4. Cuivre' => 0};
        //Map<String, Integer> mNbContactsTelParMedaille = new Map<String,Integer>{'1. Or' => 4, '2. Argent' => 2, '3. Bronze' => 2, '4. Cuivre' => 1};
        
        /*Map<String, Integer> mNbVisitesParMedaille = new Map<String, Integer>();
		mNbVisitesParMedaille.put('1. Or', 8);
		mNbVisitesParMedaille.put('2. Argent', 4);
		mNbVisitesParMedaille.put('3. Bronze', 1);
		mNbVisitesParMedaille.put('4. Cuivre', 0);
		
		Map<String, Integer> mNbContactsTelParMedaille = new Map<String, Integer>();
		mNbContactsTelParMedaille.put('1. Or', 4);
		mNbContactsTelParMedaille.put('2. Argent', 2);
		mNbContactsTelParMedaille.put('3. Bronze', 2);
		mNbContactsTelParMedaille.put('4. Cuivre', 1);*/
		
		
        
        // Reinitialize calculated fields
        for (PTL__c oPTL : lPTLs) {
        	oPTL.Nombre_de_visites__c = 0;
        	oPTL.Nombre_de_contacts_telephoniques__c = 0;
            oPTL.Nombre_de_visites_Percent__c = 0;
            oPTL.Nombre_de_contacts_telephoniques_Percent__c = 0;
            oPTL.Nombre_de_visites_Amoins1__c = 0;
            oPTL.Nombre_de_contacts_telephoniques_Amoins1__c = 0;
            oPTL.Nombre_de_visites_Percent_Amoins1__c = 0;
            oPTL.Nombre_de_contacts_telephoniques_Amoins1__c = 0;
        }
		
        
        // Update the PTLs
        if (lPTLs.size() > 0) {
            
            /*for (PTL__c  PTLwithActivityHistory: [
        		SELECT Id, Segmentation_medailles__c, 
				           (SELECT ActivityType, Subject, ActivityDate, Description, IsTask, WhatId
				            FROM ActivityHistories
				            WHERE Id != NULL
				            AND CALENDAR_YEAR(F_ActivityDate__c) = :System.Today().Year()
				            AND ActivityType IN ('Visite de suivi', 'Phone conference')
				            AND IsTask = False
				            AND Subject != '')
				FROM PTL__c  
				WHERE Activity_Domain__r.ExternalID__c = 41
				AND Code_Canal__c = 'RE'
				AND Id = :lPTLs
				]) {*/
			
			System.debug(logginglevel.WARN,'### Batch_Counting_PTL_ActivityHistory - System.Today().Year() : ' + System.Today().Year());
			System.debug(logginglevel.WARN,'### Batch_Counting_PTL_ActivityHistory - system.now() :' + string.valueof(system.now()));
			
			for (PTL__c  PTLwithActivityHistory: [
        		SELECT Id, Segmentation_medailles__c, 
				           (SELECT Type, Subject, Description, WhatId, EndDateTime
				            FROM Events
				            WHERE Id != NULL
				            AND ( CALENDAR_YEAR(EndDateTime) = :System.Today().Year()
				            	OR CALENDAR_YEAR(EndDateTime) = :System.Today().Year()-1 )
				            AND EndDateTime <= :system.now()
				            AND Type IN ('Visite de suivi', 'Phone conference')
				            AND Subject != '')
				FROM PTL__c  
				WHERE Activity_Domain__r.ExternalID__c = 41
				AND Code_Canal__c = 'RE'
				AND Id = :lPTLs
				]) {
					
					iCptVisites = 0;
					iCptContactsTel = 0;
					iQuotaVisites = 0;
					iQuotaContactsTel = 0;
					iCptVisitesAmoins1 = 0;
					iCptContactsTelAmoins1 = 0;
        			iQuotaVisitesAmoins1 = 0;
        			iQuotaContactsTelAmoins1 = 0;
					
					for (Event ah : PTLwithActivityHistory.Events) {
						// We only count events with description size >= 10 characters
						if (!String.isBlank(ah.Description) && ah.Description.length() >= 10 && ah.EndDateTime.Year()==System.Today().Year()){
							if (ah.Type=='Visite de suivi') iCptVisites++;
							if (ah.Type=='Phone conference') iCptContactsTel++;
						}
						if (!String.isBlank(ah.Description) && ah.Description.length() >= 10 && ah.EndDateTime.Year()==System.Today().Year()-1){
							if (ah.Type=='Visite de suivi') iCptVisitesAmoins1++;
							if (ah.Type=='Phone conference') iCptContactsTelAmoins1++;
						}
					}
					
					
					// Count events
					PTLwithActivityHistory.Nombre_de_visites__c = iCptVisites;
             		PTLwithActivityHistory.Nombre_de_contacts_telephoniques__c = iCptContactsTel;
             		PTLwithActivityHistory.Nombre_de_visites_Amoins1__c = iCptVisitesAmoins1;
             		PTLwithActivityHistory.Nombre_de_contacts_telephoniques_Amoins1__c = iCptContactsTelAmoins1;
					
					// Calculate percentage of events vs quota
					if (PTLwithActivityHistory.Segmentation_medailles__c != null){
						iQuotaVisites = mNbVisitesParMedaille.get(PTLwithActivityHistory.Segmentation_medailles__c);
						iQuotaContactsTel = mNbContactsTelParMedaille.get(PTLwithActivityHistory.Segmentation_medailles__c);
						iQuotaVisitesAmoins1 = mNbVisitesParMedailleAmoins1.get(PTLwithActivityHistory.Segmentation_medailles__c);
						iQuotaContactsTelAmoins1 = mNbContactsTelParMedailleAmoins1.get(PTLwithActivityHistory.Segmentation_medailles__c);
					}
					
					// A
					// Prevent division by 0
					if (iQuotaVisites != 0){
						// Prevent going above 100%
						if (iCptVisites > iQuotaVisites){
							PTLwithActivityHistory.Nombre_de_visites_Percent__c = 100;
						}else{
							dCalculatedPercentVisit = (((Decimal)iCptVisites) / iQuotaVisites) * 100;
							PTLwithActivityHistory.Nombre_de_visites_Percent__c = dCalculatedPercentVisit.round();
						}
					}else{
						PTLwithActivityHistory.Nombre_de_visites_Percent__c = 0;
					}
					
					// Prevent division by 0
					if (iQuotaContactsTel != 0){
						// Prevent going above 100%
						if (iCptContactsTel > iQuotaContactsTel){
							PTLwithActivityHistory.Nombre_de_contacts_telephoniques_Percent__c = 100;
						}else{
							dCalculatedPercentContactsTel = (((Decimal)iCptContactsTel) / iQuotaContactsTel) * 100;
							PTLwithActivityHistory.Nombre_de_contacts_telephoniques_Percent__c = dCalculatedPercentContactsTel.round();
						}
					}else{
						PTLwithActivityHistory.Nombre_de_contacts_telephoniques_Percent__c = 0;
					}
					
					// A-1
					// Prevent division by 0
					if (iQuotaVisitesAmoins1 != 0){
						// Prevent going above 100%
						if (iCptVisitesAmoins1 > iQuotaVisitesAmoins1){
							PTLwithActivityHistory.Nombre_de_visites_Percent_Amoins1__c = 100;
						}else{
							dCalculatedPercentVisitAmoins1 = (((Decimal)iCptVisitesAmoins1) / iQuotaVisitesAmoins1) * 100;
							PTLwithActivityHistory.Nombre_de_visites_Percent_Amoins1__c = dCalculatedPercentVisitAmoins1.round();
						}
					}else{
						PTLwithActivityHistory.Nombre_de_visites_Percent_Amoins1__c = 0;
					}
					
					// Prevent division by 0
					if (iQuotaContactsTelAmoins1 != 0){
						// Prevent going above 100%
						if (iCptContactsTelAmoins1 > iQuotaContactsTelAmoins1){
							PTLwithActivityHistory.Nombre_de_contacts_tel_Percent_Amoins1__c = 100;
						}else{
							dCalculatedPercentContactsTelAmoins1 = (((Decimal)iCptContactsTelAmoins1) / iQuotaContactsTelAmoins1) * 100;
							PTLwithActivityHistory.Nombre_de_contacts_tel_Percent_Amoins1__c = dCalculatedPercentContactsTelAmoins1.round();
						}
					}else{
						PTLwithActivityHistory.Nombre_de_contacts_tel_Percent_Amoins1__c = 0;
					}
					
					
					// Add records to be updated to the final list
             		lPTLtoUpdate.add(PTLwithActivityHistory);
             		
			}
			
            System.debug('## Batch_Counting_PTL_ActivityHistory - execute: lPTLtoUpdate.size() : ' + lPTLtoUpdate.size());
            //this.iPTLToUpdateSize = lPTLtoUpdate.size();
            update lPTLtoUpdate;
        }
    }
	
    global void finish(Database.BatchableContext BC) {
    	/*// Send an email after the batch completes
    	string sInstanceName = '';
    	List<String> lMailingList = new List<String>();
    	lMailingList.addAll(AP_PricingUtilities.getCustomSettingValue('MailingList').split(';'));
    	
    	// Get SFDC instance name
    	if(UserInfo.getUserName().substringAfterLast('.com') != null){
            sInstanceName = UserInfo.getUserName().substringAfterLast('.');
    	}else{
            sInstanceName = 'PROD';
		}
    	
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(lMailingList);
		mail.setSubject('BobContact | ' + sInstanceName + ' | Batch_Counting_PTL_ActivityHistory');
		mail.setPlainTextBody('Le batch Apex est terminé. ' + string.valueof(this.iPTLToUpdateSize) + ' PTLs ont été mis à jour.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
}