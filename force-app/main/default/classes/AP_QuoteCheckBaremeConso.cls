public with sharing class AP_QuoteCheckBaremeConso {
	
	
	public static void checkQuotesBaremeConso(List<Quote> quotesToValidate, Boolean isInsert){
	    	    
	    for(Quote quote:quotesToValidate) {
			AP_QuoteCheckBaremeConso.checkQuoteBaremeConso(quote, isInsert);
	    }
	}
	
	
	private static void checkQuoteBaremeConso(Quote quoteToValidate, Boolean isInsert){
		
		// Récupération de l'instance du custom setting OrganizationSettings__c
	    OrganizationSettings__c orgSettings = OrganizationSettings__c.getInstance();
		
		if(isGEBCS(quoteToValidate)) {
        	
        	quoteToValidate.Estimated_consumption_CS_2__c = calculateEstimatedConsumption(quoteToValidate);
	    
	        if(quoteToValidate.Project_Type__c != 'CREA'
	           && isGEBChallenge(quoteToValidate)
	           && String.isBlank(quoteToValidate.DO_Groupement__c)
	           && isBaremeConsoInvalid(quoteToValidate)
	          )
	        {
	            if(isInsert) {
	                System.debug('RecordTypeId : '+ String.valueOf(orgSettings.RecordTypeId_GEB_Challenge__c));
	                quoteToValidate.Product_Scale__c.addError('La consommation estimée doit être supérieure à 0 et en cohérence avec le barème produit. Consommation estimée = ' + quoteToValidate.Estimated_consumption_CS_2__c);
	            }
	            else {
	                System.debug('RecordTypeId : '+ String.valueOf(orgSettings.RecordTypeId_GEB_Challenge__c));
	                quoteToValidate.Product_Scale__c.addError('La consommation estimée doit être supérieure à 0 et en cohérence avec le barème produit. Nouvelle consommation estimée = ' + quoteToValidate.Estimated_consumption_CS_2__c);
	            }
	        }
		}
	}
	
	
	
	private static Double calculateEstimatedConsumption(Quote quote){
		return (
                (quote.Consommation_calculee_Prop_Carb__c * quote.Nb_Working_Weeks_Per_Year__c) * 13 
                + (
                    (quote.Consommation_CP_per_Week__c * 5)
                    + (quote.Consommation_CB_per_Week__c * 6)
                    + (quote.Consommation_G_per_Week__c* 13)
                    + (quote.Consommation_BD_per_Week__c * 13)
                    + (quote.Consommation_P_per_Week__c * 35)
                ) * quote.Nb_Working_Weeks_Per_Year__c 
            ) / 1000;
	}
	
	
	private static Boolean isGEBCS(Quote quote){
		return quote.Activity_Domain_ID__c == '41' && quote.Client_Type__c == 'CS';
	}
	
	
	private static Boolean isGEBChallenge(Quote quote){
		// Récupération de l'instance du custom setting OrganizationSettings__c
	    OrganizationSettings__c orgSettings = OrganizationSettings__c.getInstance();
	    
		return quote.OptyRecordTypeId__c != String.valueOf(orgSettings.RecordTypeId_GEB_Challenge__c);
	}
	
	
	private static Boolean isBaremeConsoInvalid(Quote quoteToValidate){
		return (quoteToValidate.Estimated_consumption_CS_2__c <= 0
	               || (quoteToValidate.Product_Scale__c == 'T0'
	                   && (quoteToValidate.Estimated_consumption_CS_2__c < 0 
	                       || quoteToValidate.Estimated_consumption_CS_2__c >= 0.5
	                      )
	                  )
	               || (quoteToValidate.Product_Scale__c == 'T1'
	                   && (quoteToValidate.Estimated_consumption_CS_2__c < 0.5 
	                       || quoteToValidate.Estimated_consumption_CS_2__c >= 2
	                      )
	                  )
	               || (quoteToValidate.Product_Scale__c == 'T2'
	                   && (quoteToValidate.Estimated_consumption_CS_2__c < 2 
	                       || quoteToValidate.Estimated_consumption_CS_2__c >= 5
	                      )
	                  )
	               || (quoteToValidate.Product_Scale__c == 'T3'
	                   && (quoteToValidate.Estimated_consumption_CS_2__c < 5 
	                       || quoteToValidate.Estimated_consumption_CS_2__c >= 10
	                      )
	                  )
	               || (quoteToValidate.Product_Scale__c == 'T4'
	                   && (quoteToValidate.Estimated_consumption_CS_2__c < 10 
	                       || quoteToValidate.Estimated_consumption_CS_2__c >= 40
	                      )
	                  )
	               || (quoteToValidate.Product_Scale__c == 'T5'
	                   && (quoteToValidate.Estimated_consumption_CS_2__c < 40 
	                       || quoteToValidate.Estimated_consumption_CS_2__c >= 100
	                      )
	                  )
	               || (quoteToValidate.Product_Scale__c == 'T6'
	                   && quoteToValidate.Estimated_consumption_CS_2__c < 100
	                  )
	              );
		}
}