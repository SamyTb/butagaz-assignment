/**
 *--------------------------------
 * Helper d'interfaçage avec le processus de vente
 *--------------------------------
 */
public without sharing class Signea_CustumTriggerHelper {


    public static void updateQuotesOnSignedCircuit(List<Quote> processingQuotes ) {
        
        List<Quote> quotes = new List<Quote>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Quote processingQuote : processingQuotes ) {
            System.debug( '\n\n\n   ===> Devis à modifier ' + processingQuote .Id + ' - ' + processingQuote .Signea_Circuit__c + '.\n\n\n');
            Opportunity processingOpp = new Opportunity (Id = processingQuote.OpportunityId);
            processingOpp.stageName = 'Closed Won';
            processingOpp.Opportunity_Won_Substage__c = 'Finalized by Sales';
            processingOpp.Reason_for_Closed_Lost__c = null;
            processingOpp.Statut_circuit_de_signature__c = 'Circuit clôturé' ;
    
            processingQuote.Signea_Date_Signature__c = Date.today();
            processingQuote.Statut_circuit_de_signature__c = 'Circuit clôturé';
            opps.add( processingOpp );
            quotes.add( processingQuote );
        }
        update removeDuplicatesOpp(opps);
        update removeDuplicatesQuote(quotes);
    }

    public static void updateQuotesOnRefusedCircuit(List<Quote> processingQuotes ) {
        List<Quote> quotes = new List<Quote>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Quote processingQuote : processingQuotes) {
            System.debug( '\n\n\n   ===> Devis à modifier ' + processingQuote .Id + ' - ' + processingQuote.Signea_Circuit__c + '.\n\n\n');
            Opportunity processingOpp = new Opportunity (Id = processingQuote.OpportunityId);
            processingOpp.stageName = 'Closed Lost';
            processingOpp.Opportunity_Won_Substage__c = null;
            processingOpp.Reason_for_Closed_Lost__c= 'Echec signature électronique';
            processingOpp.Statut_circuit_de_signature__c = 'Refusé' ;
            Signea__circuit__c myRefusedCircuit = [select id, Signea__Reject_Reason__c from signea__circuit__c where id=:processingQuote .Signea_Circuit__c];
            String rejectReason = null;
            if( myRefusedCircuit != null ) {
                rejectReason = myRefusedCircuit.Signea__Reject_Reason__c;
                processingQuote.Signea_Raison_Refus_Signature__c = rejectReason ;
                processingOpp.Signea_Raison_Refus_Signature__c = rejectReason ;
            }
    
            String statutRefus = 'Signature refusée';
            if(rejectReason != null) {
                if(rejectReason.containsIgnoreCase('client')) {
                    statutRefus += ' par le client';
                }
                if(rejectReason .containsIgnoreCase('conseiller')) {
                    statutRefus += ' par le conseiller';
                }
            }
            processingOpp.Statut_circuit_de_signature__c = statutRefus;
            processingQuote.Statut_circuit_de_signature__c = statutRefus ;
            
            opps.add( processingOpp );
            quotes.add( processingQuote );
        }
        update removeDuplicatesOpp(opps);
        update removeDuplicatesQuote(quotes);
    }
    
    public static void updateQuotesOnExpiredCircuit(List<Quote> processingQuotes ) {
        List<Quote> quotes = new List<Quote>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Quote processingQuote : processingQuotes ) {
            System.debug( '\n\n\n   ===> Devis à modifier ' + processingQuote .Id + ' - ' + processingQuote .Signea_Circuit__c + '.\n\n\n');
            Opportunity processingOpp = new Opportunity (Id = processingQuote.OpportunityId);

            // Erwan : 20210923 : We don't want to close the opty anymore
            //processingOpp.stageName = 'Closed Lost';        
            //processingOpp.Opportunity_Won_Substage__c = null;
            //processingOpp.Reason_for_Closed_Lost__c= 'Echec signature électronique';
            processingOpp.Statut_circuit_de_signature__c = 'Délai expiré' ;
            processingQuote.Statut_circuit_de_signature__c = 'Délai expiré';
    
            opps.add( processingOpp );
            quotes.add( processingQuote );
        }
        update removeDuplicatesOpp(opps);
        update removeDuplicatesQuote(quotes);
    }
    
    
    public static void updateQuotesOngoingCircuits (List<Quote> processingQuotes ) {
        updateQuotesOnInProgressCircuits (processingQuotes, 'Ongoing');
    }
    
    public static void updateQuotesFillingCircuits (List<Quote> processingQuotes ) {
        updateQuotesOnInProgressCircuits (processingQuotes, 'Filling');
    }
    
    public static void updateQuotesCancelledCircuits (List<Quote> processingQuotes ) {
        updateQuotesOnInProgressCircuits (processingQuotes, 'Cancelled');
    }
    
    public static void updateQuotesLaunchFailedCircuits (List<Quote> processingQuotes ) {
        updateQuotesOnInProgressCircuits (processingQuotes, 'Launch Failed');
    }
    
    private static void updateQuotesOnInProgressCircuits (List<Quote> processingQuotes, String statutCircuit) {
        List<Quote> quotes = new List<Quote>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Quote processingQuote : processingQuotes ) {
            System.debug( '\n\n\n   ===> Devis à modifier ' + processingQuote .Id + ' - ' + processingQuote .Signea_Circuit__c + '.\n\n\n');
            Opportunity processingOpp = new Opportunity (Id = processingQuote.OpportunityId);
            if(statutCircuit == 'Ongoing'){
                statutCircuit = 'En cours signature';
            }
            if(statutCircuit == 'Filling'){
                statutCircuit = 'En cours remplissage';
            }
            if(statutCircuit == 'Cancelled'){
                statutCircuit = 'Circuit annulé';
            }
            if(statutCircuit == 'Launch Failed'){
                statutCircuit = 'Echec Signature';
            }
            processingOpp.Statut_circuit_de_signature__c = statutCircuit ;
            processingQuote.Statut_circuit_de_signature__c = statutCircuit ;
            opps.add( processingOpp );
            quotes.add( processingQuote );
        }
        update removeDuplicatesOpp(opps);
        update removeDuplicatesQuote(quotes);
    }
    
    public static list<Opportunity> removeDuplicatesOpp(List<Opportunity> originalList) {
        Set<Opportunity> myset = new Set<Opportunity>();
        List<Opportunity> result = new List<Opportunity>();
        myset.addAll(originalList);
        result.addAll(myset);
        return result;
    }
    
    public static list<Quote> removeDuplicatesQuote(List<Quote> originalList) {
        Set<Quote> myset = new Set<Quote>();
        List<Quote> result = new List<Quote>();
        myset.addAll(originalList);
        result.addAll(myset);
        return result;
    }



    // Manage Circuits on CampaignMembers
    public static void updateCampaignMembersOnSignedCircuit(List<CampaignMember> processingCampaignMembers ) {
        
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for( CampaignMember processingCampaignMember : processingCampaignMembers ) {
            System.debug( '\n\n\n   ===> Membre de campagne à modifier ' + processingCampaignMember.Id + ' - ' + processingCampaignMember.Signea_Circuit__c + '.\n\n\n');
                
            processingCampaignMember.Signea_Date_Signature__c = Date.today();
            processingCampaignMember.Statut_circuit_de_signature__c = 'Circuit clôturé';
            campMembers.add( processingCampaignMember );
        }
        update removeDuplicatesCampMember(campMembers);
    }

    public static void updateCampaignMembersOnRefusedCircuit(List<CampaignMember> processingCampaignMembers ) {
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for( CampaignMember processingCampaignMember : processingCampaignMembers) {
            System.debug( '\n\n\n   ===> Membre de campagne à modifier ' + processingCampaignMember.Id + ' - ' + processingCampaignMember.Signea_Circuit__c + '.\n\n\n');
            Signea__circuit__c myRefusedCircuit = [select id, Signea__Reject_Reason__c from signea__circuit__c where id=:processingCampaignMember.Signea_Circuit__c];
            String rejectReason = null;
            if( myRefusedCircuit != null ) {
                rejectReason = myRefusedCircuit.Signea__Reject_Reason__c;
                processingCampaignMember.Signea_Raison_Refus_Signature__c = rejectReason ;
            }
    
            String statutRefus = 'Signature refusée';
            if(rejectReason != null) {
                if(rejectReason.containsIgnoreCase('client')) {
                    statutRefus += ' par le client';
                }
                if(rejectReason.containsIgnoreCase('conseiller')) {
                    statutRefus += ' par le conseiller';
                }
            }
            processingCampaignMember.Statut_circuit_de_signature__c = statutRefus ;
            
            campMembers.add( processingCampaignMember );
        }
        update removeDuplicatesCampMember(campMembers);
    }
    
    public static void updateCampaignMembersOnExpiredCircuit(List<CampaignMember> processingCampaignMembers ) {
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for( CampaignMember processingCampaignMember : processingCampaignMembers ) {
            System.debug( '\n\n\n   ===> Membre de campagne à modifier ' + processingCampaignMember.Id + ' - ' + processingCampaignMember.Signea_Circuit__c + '.\n\n\n');
            processingCampaignMember.Statut_circuit_de_signature__c = 'Délai expiré';
    
            campMembers.add( processingCampaignMember );
        }
        update removeDuplicatesCampMember(campMembers);
    }
    
    
    public static void updateCampaignMembersOngoingCircuits (List<CampaignMember> processingCampaignMembers ) {
        updateCampaignMembersOnInProgressCircuits (processingCampaignMembers, 'Ongoing');
    }
    
    public static void updateCampaignMembersFillingCircuits (List<CampaignMember> processingCampaignMembers ) {
        updateCampaignMembersOnInProgressCircuits (processingCampaignMembers, 'Filling');
    }
    
    public static void updateCampaignMembersCancelledCircuits (List<CampaignMember> processingCampaignMembers ) {
        updateCampaignMembersOnInProgressCircuits (processingCampaignMembers, 'Cancelled');
    }
    
    public static void updateCampaignMembersLaunchFailedCircuits (List<CampaignMember> processingCampaignMembers ) {
        updateCampaignMembersOnInProgressCircuits (processingCampaignMembers, 'Launch Failed');
    }
    
    private static void updateCampaignMembersOnInProgressCircuits (List<CampaignMember> processingCampaignMembers, String statutCircuit) {
        List<CampaignMember> campMembers = new List<CampaignMember>();
        for( CampaignMember processingCampaignMember : processingCampaignMembers ) {
            System.debug( '\n\n\n   ===> Membre de campagne à modifier ' + processingCampaignMember.Id + ' - ' + processingCampaignMember.Signea_Circuit__c + '.\n\n\n');
            if(statutCircuit == 'Ongoing'){
                statutCircuit = 'En cours signature';
            }
            if(statutCircuit == 'Filling'){
                statutCircuit = 'En cours remplissage';
            }
            if(statutCircuit == 'Cancelled'){
                statutCircuit = 'Circuit annulé';
            }
            if(statutCircuit == 'Launch Failed'){
                statutCircuit = 'Echec Signature';
            }
            processingCampaignMember.Statut_circuit_de_signature__c = statutCircuit ;
            campMembers.add( processingCampaignMember );
        }
        update removeDuplicatesCampMember(campMembers);
    }
    
    public static list<CampaignMember> removeDuplicatesCampMember(List<CampaignMember> originalList) {
        Set<CampaignMember> myset = new Set<CampaignMember>();
        List<CampaignMember> result = new List<CampaignMember>();
        myset.addAll(originalList);
        result.addAll(myset);
        return result;
    }



    // Manage Circuits on PECs
    public static void updatePECsOnSignedCircuit(List<PEC__c> processingPECs ) {
        
        List<PEC__c> lPECs = new List<PEC__c>();
        for( PEC__c processingPEC : processingPECs ) {
            System.debug( '\n\n\n   ===> PEC à modifier ' + processingPEC.Id + ' - ' + processingPEC.Signea_Circuit__c + '.\n\n\n');
            
            processingPEC.Status__c = 'Signée';

            processingPEC.Statut_circuit_de_signature__c = 'Circuit clôturé' ;
            processingPEC.Signea_Date_Signature__c = Date.today();
            lPECs.add( processingPEC );
        }
        update removeDuplicatesPEC(lPECs);
    }

    public static void updatePECsOnRefusedCircuit(List<PEC__c> processingPECs ) {
        List<PEC__c> lPECs = new List<PEC__c>();
        for( PEC__c processingPEC : processingPECs) {
            System.debug( '\n\n\n   ===> PEC à modifier ' + processingPEC.Id + ' - ' + processingPEC.Signea_Circuit__c + '.\n\n\n');
            Signea__circuit__c myRefusedCircuit = [select id, Signea__Reject_Reason__c from signea__circuit__c where id=:processingPEC.Signea_Circuit__c];
            String rejectReason = null;
            if( myRefusedCircuit != null ) {
                rejectReason = myRefusedCircuit.Signea__Reject_Reason__c;
                processingPEC.Signea_Raison_Refus_Signature__c = rejectReason ;
            }
    
            String statutRefus = 'Signature refusée';
            if(rejectReason != null) {
                if(rejectReason.containsIgnoreCase('client')) {
                    statutRefus += ' par le client';
                }
                if(rejectReason.containsIgnoreCase('conseiller')) {
                    statutRefus += ' par le conseiller';
                }
            }
            processingPEC.Statut_circuit_de_signature__c = statutRefus ;
            
            lPECs.add( processingPEC );
        }
        update removeDuplicatesPEC(lPECs);
    }
    
    public static void updatePECsOnExpiredCircuit(List<PEC__c> processingPECs ) {
        List<PEC__c> lPECs = new List<PEC__c>();
        for( PEC__c processingPEC : processingPECs ) {
            System.debug( '\n\n\n   ===> PEC à modifier ' + processingPEC.Id + ' - ' + processingPEC.Signea_Circuit__c + '.\n\n\n');
            processingPEC.Statut_circuit_de_signature__c = 'Délai expiré';
    
            lPECs.add( processingPEC );
        }
        update removeDuplicatesPEC(lPECs);
    }
    
    
    public static void updatePECsOngoingCircuits (List<PEC__c> processingPECs ) {
        updatePECsOnInProgressCircuits (processingPECs, 'Ongoing');
    }
    
    public static void updatePECsFillingCircuits (List<PEC__c> processingPECs ) {
        updatePECsOnInProgressCircuits (processingPECs, 'Filling');
    }
    
    public static void updatePECsCancelledCircuits (List<PEC__c> processingPECs ) {
        updatePECsOnInProgressCircuits (processingPECs, 'Cancelled');
    }
    
    public static void updatePECsLaunchFailedCircuits (List<PEC__c> processingPECs ) {
        updatePECsOnInProgressCircuits (processingPECs, 'Launch Failed');
    }
    
    private static void updatePECsOnInProgressCircuits (List<PEC__c> processingPECs, String statutCircuit) {
        List<PEC__c> lPECs = new List<PEC__c>();
        for( PEC__c processingPEC : processingPECs ) {
            System.debug( '\n\n\n   ===> PEC à modifier ' + processingPEC.Id + ' - ' + processingPEC.Signea_Circuit__c + '.\n\n\n');
            if(statutCircuit == 'Ongoing'){
                statutCircuit = 'En cours signature';
            }
            if(statutCircuit == 'Filling'){
                statutCircuit = 'En cours remplissage';
            }
            if(statutCircuit == 'Cancelled'){
                statutCircuit = 'Circuit annulé';
            }
            if(statutCircuit == 'Launch Failed'){
                statutCircuit = 'Echec Signature';
            }
            processingPEC.Statut_circuit_de_signature__c = statutCircuit ;
            lPECs.add( processingPEC );
        }
        update removeDuplicatesPEC(lPECs);
    }
    
    public static list<PEC__c> removeDuplicatesPEC(List<PEC__c> originalList) {
        Set<PEC__c> myset = new Set<PEC__c>();
        List<PEC__c> result = new List<PEC__c>();
        myset.addAll(originalList);
        result.addAll(myset);
        return result;
    }


    // Manage Circuits on CDSs
    public static void updateCDSsOnSignedCircuit(List<CDS__c> processingCDSs ) {
        
        List<CDS__c> lCDSs = new List<CDS__c>();
        for( CDS__c processingCDS : processingCDSs ) {
            System.debug( '\n\n\n   ===> CDS à modifier ' + processingCDS.Id + ' - ' + processingCDS.Signea_Circuit__c + '.\n\n\n');
            
            processingCDS.Status__c = 'Signé';

            processingCDS.Statut_circuit_de_signature__c = 'Circuit clôturé' ;
            processingCDS.Signea_Date_Signature__c = Date.today();
            lCDSs.add( processingCDS );
        }
        update removeDuplicatesCDS(lCDSs);
    }

    public static void updateCDSsOnRefusedCircuit(List<CDS__c> processingCDSs ) {
        List<CDS__c> lCDSs = new List<CDS__c>();
        for( CDS__c processingCDS : processingCDSs) {
            System.debug( '\n\n\n   ===> CDS à modifier ' + processingCDS.Id + ' - ' + processingCDS.Signea_Circuit__c + '.\n\n\n');
            Signea__circuit__c myRefusedCircuit = [select id, Signea__Reject_Reason__c from signea__circuit__c where id=:processingCDS.Signea_Circuit__c];
            String rejectReason = null;
            if( myRefusedCircuit != null ) {
                rejectReason = myRefusedCircuit.Signea__Reject_Reason__c;
                processingCDS.Signea_Raison_Refus_Signature__c = rejectReason ;
            }
    
            String statutRefus = 'Signature refusée';
            if(rejectReason != null) {
                if(rejectReason.containsIgnoreCase('client')) {
                    statutRefus += ' par le client';
                }
                if(rejectReason.containsIgnoreCase('conseiller')) {
                    statutRefus += ' par le conseiller';
                }
            }
            processingCDS.Statut_circuit_de_signature__c = statutRefus ;
            
            lCDSs.add( processingCDS );
        }
        update removeDuplicatesCDS(lCDSs);
    }
    
    public static void updateCDSsOnExpiredCircuit(List<CDS__c> processingCDSs ) {
        List<CDS__c> lCDSs = new List<CDS__c>();
        for( CDS__c processingCDS : processingCDSs ) {
            System.debug( '\n\n\n   ===> CDS à modifier ' + processingCDS.Id + ' - ' + processingCDS.Signea_Circuit__c + '.\n\n\n');
            processingCDS.Statut_circuit_de_signature__c = 'Délai expiré';
    
            lCDSs.add( processingCDS );
        }
        update removeDuplicatesCDS(lCDSs);
    }
    
    
    public static void updateCDSsOngoingCircuits (List<CDS__c> processingCDSs ) {
        updateCDSsOnInProgressCircuits (processingCDSs, 'Ongoing');
    }
    
    public static void updateCDSsFillingCircuits (List<CDS__c> processingCDSs ) {
        updateCDSsOnInProgressCircuits (processingCDSs, 'Filling');
    }
    
    public static void updateCDSsCancelledCircuits (List<CDS__c> processingCDSs ) {
        updateCDSsOnInProgressCircuits (processingCDSs, 'Cancelled');
    }
    
    public static void updateCDSsLaunchFailedCircuits (List<CDS__c> processingCDSs ) {
        updateCDSsOnInProgressCircuits (processingCDSs, 'Launch Failed');
    }
    
    private static void updateCDSsOnInProgressCircuits (List<CDS__c> processingCDSs, String statutCircuit) {
        List<CDS__c> lCDSs = new List<CDS__c>();
        for( CDS__c processingCDS : processingCDSs ) {
            System.debug( '\n\n\n   ===> CDS à modifier ' + processingCDS.Id + ' - ' + processingCDS.Signea_Circuit__c + '.\n\n\n');
            if(statutCircuit == 'Ongoing'){
                statutCircuit = 'En cours signature';
            }
            if(statutCircuit == 'Filling'){
                statutCircuit = 'En cours remplissage';
            }
            if(statutCircuit == 'Cancelled'){
                statutCircuit = 'Circuit annulé';
            }
            if(statutCircuit == 'Launch Failed'){
                statutCircuit = 'Echec Signature';
            }
            processingCDS.Statut_circuit_de_signature__c = statutCircuit ;
            lCDSs.add( processingCDS );
        }
        update removeDuplicatesCDS(lCDSs);
    }
    
    public static list<CDS__c> removeDuplicatesCDS(List<CDS__c> originalList) {
        Set<CDS__c> myset = new Set<CDS__c>();
        List<CDS__c> result = new List<CDS__c>();
        myset.addAll(originalList);
        result.addAll(myset);
        return result;
    }
    
    
    // Manage Circuits on BankDetails
    public static void updateBDsOnSignedCircuit(List<Bank_Detail__c> processingBDs ) {
        
        List<Bank_Detail__c> lBDs = new List<Bank_Detail__c>();
        for( Bank_Detail__c processingBD : processingBDs ) {
            System.debug( '\n\n\n   ===> BD à modifier ' + processingBD.Id + ' - ' + processingBD.Signea_Circuit__c + '.\n\n\n');
            
            processingBD.Status__c = 'Signé';

            processingBD.Statut_circuit_de_signature__c = 'Circuit clôturé' ;
            processingBD.Signea_Date_Signature__c = Date.today();
            lBDs.add( processingBD );
        }
        update removeDuplicatesBD(lBDs);
    }

    public static void updateBDsOnRefusedCircuit(List<Bank_Detail__c> processingBDs ) {
        List<Bank_Detail__c> lBDs = new List<Bank_Detail__c>();
        for( Bank_Detail__c processingBD : processingBDs) {
            System.debug( '\n\n\n   ===> BD à modifier ' + processingBD.Id + ' - ' + processingBD.Signea_Circuit__c + '.\n\n\n');
            Signea__circuit__c myRefusedCircuit = [select id, Signea__Reject_Reason__c from signea__circuit__c where id=:processingBD.Signea_Circuit__c];
            String rejectReason = null;
            if( myRefusedCircuit != null ) {
                rejectReason = myRefusedCircuit.Signea__Reject_Reason__c;
                processingBD.Signea_Raison_Refus_Signature__c = rejectReason ;
            }
            
            
            String statutRefus = 'Signature refusée';
            if(rejectReason != null) {
                if(rejectReason.containsIgnoreCase('client')) {
                    statutRefus += ' par le client';
                }
                if(rejectReason.containsIgnoreCase('conseiller')) {
                    statutRefus += ' par le conseiller';
                }
            }
            processingBD.Statut_circuit_de_signature__c = statutRefus ;
            
            lBDs.add( processingBD );
        }
        update removeDuplicatesBD(lBDs);
    }
    
    public static void updateBDsOnExpiredCircuit(List<Bank_Detail__c> processingBDs ) {
        List<Bank_Detail__c> lBDs = new List<Bank_Detail__c>();
        for( Bank_Detail__c processingBD : processingBDs ) {
            System.debug( '\n\n\n   ===> BD à modifier ' + processingBD.Id + ' - ' + processingBD.Signea_Circuit__c + '.\n\n\n');
            processingBD.Statut_circuit_de_signature__c = 'Délai expiré';
    
            lBDs.add( processingBD );
        }
        update removeDuplicatesBD(lBDs);
    }
    
    
    public static void updateBDsOngoingCircuits (List<Bank_Detail__c> processingBDs ) {
        updateBDsOnInProgressCircuits (processingBDs, 'Ongoing');
    }
    
    public static void updateBDsFillingCircuits (List<Bank_Detail__c> processingBDs ) {
        updateBDsOnInProgressCircuits (processingBDs, 'Filling');
    }
    
    public static void updateBDsCancelledCircuits (List<Bank_Detail__c> processingBDs ) {
        updateBDsOnInProgressCircuits (processingBDs, 'Cancelled');
    }
    
    public static void updateBDsLaunchFailedCircuits (List<Bank_Detail__c> processingBDs ) {
        updateBDsOnInProgressCircuits (processingBDs, 'Launch Failed');
    }
    
    private static void updateBDsOnInProgressCircuits (List<Bank_Detail__c> processingBDs, String statutCircuit) {
        List<Bank_Detail__c> lBDs = new List<Bank_Detail__c>();
        for( Bank_Detail__c processingBD : processingBDs ) {
            System.debug( '\n\n\n   ===> BD à modifier ' + processingBD.Id + ' - ' + processingBD.Signea_Circuit__c + '.\n\n\n');
            if(statutCircuit == 'Ongoing'){
                statutCircuit = 'En cours signature';
            }
            if(statutCircuit == 'Filling'){
                statutCircuit = 'En cours remplissage';
            }
            if(statutCircuit == 'Cancelled'){
                statutCircuit = 'Circuit annulé';
            }
            if(statutCircuit == 'Launch Failed'){
                statutCircuit = 'Echec Signature';
            }
            processingBD.Statut_circuit_de_signature__c = statutCircuit ;
            lBDs.add( processingBD );
        }
        update removeDuplicatesBD(lBDs);
    }
    
    public static list<Bank_Detail__c> removeDuplicatesBD(List<Bank_Detail__c> originalList) {
        Set<Bank_Detail__c> myset = new Set<Bank_Detail__c>();
        List<Bank_Detail__c> result = new List<Bank_Detail__c>();
        myset.addAll(originalList);
        result.addAll(myset);
        return result;
    }
    
    
    
    // Get SEPA details filled by the customer, save them to encrypted fields on the account and clear the metadata field on the SigneaDocument object
    public static void manageSEPADetails(List<Signea__Circuit__c> circuits) {
        
        List<Account> lAccToUpdate = New List<Account>();
        List<Signea__Document__c> lSigDocToUpdate = New List<Signea__Document__c>();

        List<Signea__Document__c> lSigneaDoc = [select Id, Signea__metadata__c, Signea__Circuit__c, Signea__Circuit__r.AccountBTZ__c
                                                from Signea__Document__c 
                                                where Signea__Circuit__c =: circuits
                                                and Signea__Circuit__r.signea__status__c = 'completed'
                                                and Signea__status__c = 'Sent'
                                                and Signea__Name__c like 'Mandat SEPA%'];


        for(Signea__Document__c oSD : lSigneaDoc) {
            
            System.debug(logginglevel.WARN,'### oSD.Signea__metadata__c = ' + oSD.Signea__metadata__c);
            String xml = oSD.Signea__metadata__c;
            
            if(xml != null){
                
                Account oAccount = new Account(Id = oSD.Signea__Circuit__r.AccountBTZ__c);
                
                Dom.Document doc = new Dom.Document();
                doc.load(xml);
                System.debug(logginglevel.WARN,'### xml = ' + xml);
                
                for(Dom.XMLNode xmlnodeobj:doc.getRootElement().getChildElements()){
                    
                    for(Dom.XMLNode child : xmlnodeobj.getChildElements()){
                        System.debug(logginglevel.WARN,'### child = ' + child);
                        
                        if(child.getText() != null && child.getName() == 'value'){
                            
                            String attributeFieldName = child.getAttribute('fieldName', null);
                            System.debug(logginglevel.WARN,'### attributeFieldName = ' + attributeFieldName);
                            
                            String attributeValue = child.getAttribute('value', null);
                            System.debug(logginglevel.WARN,'### attributeValue = ' + attributeValue);
                            
                            if(attributeFieldName == 'SEPA_BIC'){
                                oAccount.SEPA_BIC__c = attributeValue;
                            }else if(attributeFieldName == 'SEPA_IBAN'){
                                oAccount.SEPA_IBAN__c = attributeValue;
                            }else if(attributeFieldName == 'SEPA_NAME'){
                                oAccount.SEPA_NAME__c = attributeValue;
                            }else if(attributeFieldName == 'SEPA_ADDR'){
                                oAccount.SEPA_ADDR__c = attributeValue;
                            }else if(attributeFieldName == 'SEPA_CITY'){
                                oAccount.SEPA_CITY__c = attributeValue;
                            }
                            
                        }  
                    }
                    
                }
                lAccToUpdate.add(oAccount);
                System.debug(logginglevel.WARN,'### lAccToUpdate = ' + lAccToUpdate);
                
                // Clear field Signea__metadata__c so we don't keep the SEPA details in an unencrypted field
                oSD.Signea__metadata__c = '';
                lSigDocToUpdate.add(oSD);
            }
            
        }
        update lAccToUpdate;
        update lSigDocToUpdate;
    }
    
}