public class VFC_Console_VueSynthetiqueCompte {
    
    public Account currentEnhancedAcc{ get; set; }
    Public list<Case> listeDemandeEnCours{ get; set; }
    public boolean demandeEstEncours{get;set;}
    public boolean opptyEstEnCours{get;set;}
    public boolean commandeEncours{get;set;}
    Public List<Opportunity> listeOpptyEnCours{ get; set; }
    Public List<Order__c> listeCommandeEnCours{ get; set; }
    Public Contact contactMarketing{ get; set; }
    public List<Campaign> listeCampagne{ get; set; }
    Public VFC_Console_VueSynthetiqueCompte(ApexPages.StandardController controller){
          /* 
        controller.addFields(new List<String>{'cases', 'Opportunities', 'Orders_Account__r'});
         this.currentEnhancedAcc=(Account)controller.getRecord();
*/
        this.currentEnhancedAcc= [
              Select id,MontantCourtageGEC__c,
                    (Select id,CaseNumber,Subject,AccountId/*,ModeDePaiementSouhaite__c */
                     From Cases 
                     where isClosed=false
                   ),
                    (SELECT Id,name,Prescriber_Account__c,Commission_Status__c
                     FROM Opportunities
                      where isClosed=false
                    ),
                    (Select id,name
                     From Orders_Account__r
                     where Order_Status__c = '0'
                     and Deletion_flag__c = false)commandes,
                    (Select id,name
                     From contacts
                    where  Contact_Marketing__c= true)
              From Account 
              where Id =: controller.getId() 
          ];

        System.debug('cases  : '+this.currentEnhancedAcc.cases);
        System.debug('Opportunities  : '+this.currentEnhancedAcc.Opportunities);
        System.debug('Orders_Account__r  : '+this.currentEnhancedAcc.Orders_Account__r);
       
       this.listeDemandeEnCours=  this.currentEnhancedAcc.cases;
        this.demandeEstEncours = ((null!=this.listeDemandeEnCours) && (!this.listeDemandeEnCours.isEmpty()));
       
        
       this.listeOpptyEnCours=  this.currentEnhancedAcc.Opportunities;
         this.opptyEstEnCours = ((null!=this.listeOpptyEnCours) && (!this.listeOpptyEnCours.isEmpty()));
       this.listeCommandeEnCours=  this.currentEnhancedAcc.Orders_Account__r;
        this.commandeEncours = ((null!=this.listeCommandeEnCours) && (!this.listeCommandeEnCours.isEmpty()));
        
    }

    
    Public void queryAccountRelated (){
        
    }
}