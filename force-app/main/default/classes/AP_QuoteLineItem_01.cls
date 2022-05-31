public class AP_QuoteLineItem_01 {
    
    public static void checkItemsBeforeDelete(List<QuoteLineItem> lQuoteLineItems){
        //We don't perfom the control for administrator
        Profile p = [SELECT Id FROM Profile WHERE Name='Butagaz System Administrator'];
        if(UserInfo.getProfileId() != p.id){
            for(QuoteLineItem c : lQuoteLineItems){
                if(c.Got_From_SAP__c){
                    c.addError('Vous ne pouvez pas supprimer un poste de devis reçu de SAP en mode 2 (mode récupération des produits existants du client)');
                }
            }
        }    
    }

}