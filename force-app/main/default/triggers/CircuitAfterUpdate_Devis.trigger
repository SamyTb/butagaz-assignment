trigger CircuitAfterUpdate_Devis on Signea__Circuit__c (after Update) {
    
    // Récupération des circuits signés
    List<string> signedCircuits = new List<String>();
    List<string> refusedCircuits = new List<String>();
    List<string> expiredCircuits = new List<String>();
    List<string> ongoingCircuits = new List<String>();
    List<string> cancelledCircuits = new List<String>();
    List<string> fillingCircuits = new List<String>();
    List<string> launchfailedCircuits = new List<String>();
    for( Signea__Circuit__c circuit:Trigger.new ) {
        if(circuit.signea__status__c == 'completed') {
            System.debug( '\n\n\n   ===> ajout du circuit ' + circuit.id + ' à la liste des circuits signés.\n\n\n');
        } else if (circuit.signea__status__c == 'refused') {
            System.debug( '\n\n\n   ===> ajout du circuit ' + circuit.id + ' à la liste des circuits refusés.\n\n\n');
        } else if (circuit.signea__status__c == 'expired') {
            System.debug( '\n\n\n   ===> ajout du circuit ' + circuit.id + ' à la liste des circuits expirés.\n\n\n');
        } else if (circuit.signea__status__c == 'cancelled') {
            System.debug( '\n\n\n   ===> ajout du circuit ' + circuit.id + ' à la liste des circuits annules.\n\n\n');
        } else if (circuit.signea__status__c == 'ongoing') {
            System.debug( '\n\n\n   ===> ajout du circuit ' + circuit.id + ' à la liste des circuits en signature.\n\n\n');
        } else if (circuit.signea__status__c == 'filling') {
            System.debug( '\n\n\n   ===> ajout du circuit ' + circuit.id + ' à la liste des circuits en remplissage.\n\n\n');
        } else if (circuit.signea__status__c == 'Launch Failed') {
            System.debug( '\n\n\n   ===> ajout du circuit ' + circuit.id + ' à la liste des circuits en echec lancement.\n\n\n');
        }
    }
    
    /*
    List<Quote> signedQuotes = [select Id, OpportunityId, Signea_Circuit__c from quote where signea_circuit__c in :signedCircuits  ];
    List<Quote> refusedQuotes = [select Id, OpportunityId, Signea_Circuit__c from quote where signea_circuit__c in :refusedCircuits ];
    List<Quote> expiredQuotes = [select Id, OpportunityId, Signea_Circuit__c from quote where signea_circuit__c in :expiredCircuits ];
    
    List<Quote> onGoingQuotes = [select Id, OpportunityId, Signea_Circuit__c from quote where signea_circuit__c in :onGoingCircuits ];
    List<Quote> fillingQuotes = [select Id, OpportunityId, Signea_Circuit__c from quote where signea_circuit__c in :fillingCircuits ];
    List<Quote> cancelledQuotes = [select Id, OpportunityId, Signea_Circuit__c from quote where signea_circuit__c in :cancelledCircuits ];
    List<Quote> launchFailedQuotes = [select Id, OpportunityId, Signea_Circuit__c from quote where signea_circuit__c in :launchfailedCircuits ];
    */
    
    List<Quote> signedQuotes = new List<Quote>();
    List<Quote> refusedQuotes = new List<Quote>();
    List<Quote> expiredQuotes = new List<Quote>();
    List<Quote> onGoingQuotes = new List<Quote>();
    List<Quote> fillingQuotes = new List<Quote>();
    List<Quote> cancelledQuotes = new List<Quote>();
    List<Quote> launchFailedQuotes = new List<Quote>();
    
    List<Quote> triggerQuotes = [select Id, OpportunityId, Signea_Circuit__c, Signea_Circuit__r.signea__status__c from quote where signea_circuit__c in :Trigger.new and Opportunity.Opportunity_Won_Substage__c != 'Data validated by BO' ];
    
    for( Quote oQuote:triggerQuotes ) {
        if(oQuote.Signea_Circuit__r.signea__status__c == 'completed') {
            signedQuotes.add(oQuote);
        } else if (oQuote.Signea_Circuit__r.signea__status__c == 'refused') {
            refusedQuotes.add(oQuote);
        } else if (oQuote.Signea_Circuit__r.signea__status__c == 'expired') {
            expiredQuotes.add(oQuote);
        } else if (oQuote.Signea_Circuit__r.signea__status__c == 'cancelled') {
            cancelledQuotes.add(oQuote);
        } else if (oQuote.Signea_Circuit__r.signea__status__c == 'ongoing') {
            onGoingQuotes.add(oQuote);
        } else if (oQuote.Signea_Circuit__r.signea__status__c == 'filling') {
            fillingQuotes.add(oQuote);
        } else if (oQuote.Signea_Circuit__r.signea__status__c == 'Launch Failed') {
            launchFailedQuotes.add(oQuote);
        }
    }
    
    Signea_CustumTriggerHelper.updateQuotesOnSignedCircuit(signedQuotes);
    Signea_CustumTriggerHelper.updateQuotesOnRefusedCircuit(refusedQuotes );
    Signea_CustumTriggerHelper.updateQuotesOnExpiredCircuit(expiredQuotes );
    Signea_CustumTriggerHelper.updateQuotesOngoingCircuits (onGoingQuotes );
    Signea_CustumTriggerHelper.updateQuotesFillingCircuits (fillingQuotes );
    Signea_CustumTriggerHelper.updateQuotesCancelledCircuits (cancelledQuotes );
    Signea_CustumTriggerHelper.updateQuotesLaunchFailedCircuits (launchFailedQuotes );

    // Manage Campaign Members
    /*
    List<CampaignMember> signedCampaignMembers = [select Id, Signea_Circuit__c from CampaignMember where signea_circuit__c in :signedCircuits  ];
    List<CampaignMember> refusedCampaignMembers = [select Id, Signea_Circuit__c from CampaignMember where signea_circuit__c in :refusedCircuits ];
    List<CampaignMember> expiredCampaignMembers = [select Id, Signea_Circuit__c from CampaignMember where signea_circuit__c in :expiredCircuits ];
    
    List<CampaignMember> onGoingCampaignMembers = [select Id, Signea_Circuit__c from CampaignMember where signea_circuit__c in :onGoingCircuits ];
    List<CampaignMember> fillingCampaignMembers = [select Id, Signea_Circuit__c from CampaignMember where signea_circuit__c in :fillingCircuits ];
    List<CampaignMember> cancelledCampaignMembers = [select Id, Signea_Circuit__c from CampaignMember where signea_circuit__c in :cancelledCircuits ];
    List<CampaignMember> launchFailedCampaignMembers = [select Id, Signea_Circuit__c from CampaignMember where signea_circuit__c in :launchfailedCircuits ];
    */
    
    List<CampaignMember> signedCampaignMembers = new List<CampaignMember>();
    List<CampaignMember> refusedCampaignMembers = new List<CampaignMember>();
    List<CampaignMember> expiredCampaignMembers = new List<CampaignMember>();
    List<CampaignMember> onGoingCampaignMembers = new List<CampaignMember>();
    List<CampaignMember> fillingCampaignMembers = new List<CampaignMember>();
    List<CampaignMember> cancelledCampaignMembers = new List<CampaignMember>();
    List<CampaignMember> launchFailedCampaignMembers = new List<CampaignMember>();
    
    List<CampaignMember> triggerCampaignMembers = [select Id, Signea_Circuit__c, Signea_Circuit__r.signea__status__c from CampaignMember where signea_circuit__c in :Trigger.new ];
    
    for( CampaignMember oCampaignMember:triggerCampaignMembers ) {
        if(oCampaignMember.Signea_Circuit__r.signea__status__c == 'completed') {
            signedCampaignMembers.add(oCampaignMember);
        } else if (oCampaignMember.Signea_Circuit__r.signea__status__c == 'refused') {
            refusedCampaignMembers.add(oCampaignMember);
        } else if (oCampaignMember.Signea_Circuit__r.signea__status__c == 'expired') {
            expiredCampaignMembers.add(oCampaignMember);
        } else if (oCampaignMember.Signea_Circuit__r.signea__status__c == 'cancelled') {
            cancelledCampaignMembers.add(oCampaignMember);
        } else if (oCampaignMember.Signea_Circuit__r.signea__status__c == 'ongoing') {
            onGoingCampaignMembers.add(oCampaignMember);
        } else if (oCampaignMember.Signea_Circuit__r.signea__status__c == 'filling') {
            fillingCampaignMembers.add(oCampaignMember);
        } else if (oCampaignMember.Signea_Circuit__r.signea__status__c == 'Launch Failed') {
            launchFailedCampaignMembers.add(oCampaignMember);
        }
    }
    
    Signea_CustumTriggerHelper.updateCampaignMembersOnSignedCircuit(signedCampaignMembers);
    Signea_CustumTriggerHelper.updateCampaignMembersOnRefusedCircuit(refusedCampaignMembers );
    Signea_CustumTriggerHelper.updateCampaignMembersOnExpiredCircuit(expiredCampaignMembers );
    Signea_CustumTriggerHelper.updateCampaignMembersOngoingCircuits (onGoingCampaignMembers );
    Signea_CustumTriggerHelper.updateCampaignMembersFillingCircuits (fillingCampaignMembers );
    Signea_CustumTriggerHelper.updateCampaignMembersCancelledCircuits (cancelledCampaignMembers );
    Signea_CustumTriggerHelper.updateCampaignMembersLaunchFailedCircuits (launchFailedCampaignMembers );

    // Manage PECs
    /*
    List<PEC__c> signedPECs = [select Id, Signea_Circuit__c from PEC__c where signea_circuit__c in :signedCircuits  ];
    List<PEC__c> refusedPECs = [select Id, Signea_Circuit__c from PEC__c where signea_circuit__c in :refusedCircuits ];
    List<PEC__c> expiredPECs = [select Id, Signea_Circuit__c from PEC__c where signea_circuit__c in :expiredCircuits ];
    
    List<PEC__c> onGoingPECs = [select Id, Signea_Circuit__c from PEC__c where signea_circuit__c in :onGoingCircuits ];
    List<PEC__c> fillingPECs = [select Id, Signea_Circuit__c from PEC__c where signea_circuit__c in :fillingCircuits ];
    List<PEC__c> cancelledPECs = [select Id, Signea_Circuit__c from PEC__c where signea_circuit__c in :cancelledCircuits ];
    List<PEC__c> launchFailedPECs = [select Id, Signea_Circuit__c from PEC__c where signea_circuit__c in :launchfailedCircuits ];
    */
    
    List<PEC__c> signedPECs = new List<PEC__c>();
    List<PEC__c> refusedPECs = new List<PEC__c>();
    List<PEC__c> expiredPECs = new List<PEC__c>();
    List<PEC__c> onGoingPECs = new List<PEC__c>();
    List<PEC__c> fillingPECs = new List<PEC__c>();
    List<PEC__c> cancelledPECs = new List<PEC__c>();
    List<PEC__c> launchFailedPECs = new List<PEC__c>();
    
    List<PEC__c> triggerPECs = [select Id, Signea_Circuit__c, Signea_Circuit__r.signea__status__c from PEC__c where signea_circuit__c in :Trigger.new and Status__c != 'Validée par BO' ];
    
    for( PEC__c oPEC:triggerPECs ) {
        if(oPEC.Signea_Circuit__r.signea__status__c == 'completed') {
            signedPECs.add(oPEC);
        } else if (oPEC.Signea_Circuit__r.signea__status__c == 'refused') {
            refusedPECs.add(oPEC);
        } else if (oPEC.Signea_Circuit__r.signea__status__c == 'expired') {
            expiredPECs.add(oPEC);
        } else if (oPEC.Signea_Circuit__r.signea__status__c == 'cancelled') {
            cancelledPECs.add(oPEC);
        } else if (oPEC.Signea_Circuit__r.signea__status__c == 'ongoing') {
            onGoingPECs.add(oPEC);
        } else if (oPEC.Signea_Circuit__r.signea__status__c == 'filling') {
            fillingPECs.add(oPEC);
        } else if (oPEC.Signea_Circuit__r.signea__status__c == 'Launch Failed') {
            launchFailedPECs.add(oPEC);
        }
    }
    
    Signea_CustumTriggerHelper.updatePECsOnSignedCircuit(signedPECs);
    Signea_CustumTriggerHelper.updatePECsOnRefusedCircuit(refusedPECs);
    Signea_CustumTriggerHelper.updatePECsOnExpiredCircuit(expiredPECs);
    Signea_CustumTriggerHelper.updatePECsOngoingCircuits(onGoingPECs);
    Signea_CustumTriggerHelper.updatePECsFillingCircuits(fillingPECs);
    Signea_CustumTriggerHelper.updatePECsCancelledCircuits(cancelledPECs);
    Signea_CustumTriggerHelper.updatePECsLaunchFailedCircuits(launchFailedPECs);

    // Manage CDSs
    /*
    List<CDS__c> signedCDSs = [select Id, Signea_Circuit__c from CDS__c where signea_circuit__c in :signedCircuits  ];
    List<CDS__c> refusedCDSs = [select Id, Signea_Circuit__c from CDS__c where signea_circuit__c in :refusedCircuits ];
    List<CDS__c> expiredCDSs = [select Id, Signea_Circuit__c from CDS__c where signea_circuit__c in :expiredCircuits ];
    
    List<CDS__c> onGoingCDSs = [select Id, Signea_Circuit__c from CDS__c where signea_circuit__c in :onGoingCircuits ];
    List<CDS__c> fillingCDSs = [select Id, Signea_Circuit__c from CDS__c where signea_circuit__c in :fillingCircuits ];
    List<CDS__c> cancelledCDSs = [select Id, Signea_Circuit__c from CDS__c where signea_circuit__c in :cancelledCircuits ];
    List<CDS__c> launchFailedCDSs = [select Id, Signea_Circuit__c from CDS__c where signea_circuit__c in :launchfailedCircuits ];
    */
    
    List<CDS__c> signedCDSs = new List<CDS__c>();
    List<CDS__c> refusedCDSs = new List<CDS__c>();
    List<CDS__c> expiredCDSs = new List<CDS__c>();
    List<CDS__c> onGoingCDSs = new List<CDS__c>();
    List<CDS__c> fillingCDSs = new List<CDS__c>();
    List<CDS__c> cancelledCDSs = new List<CDS__c>();
    List<CDS__c> launchFailedCDSs = new List<CDS__c>();
    
    List<CDS__c> triggerCDSs = [select Id, Signea_Circuit__c, Signea_Circuit__r.signea__status__c from CDS__c where signea_circuit__c in :Trigger.new and Status__c != 'Validé par BO' ];
    
    for( CDS__c oCDS:triggerCDSs ) {
        if(oCDS.Signea_Circuit__r.signea__status__c == 'completed') {
            signedCDSs.add(oCDS);
        } else if (oCDS.Signea_Circuit__r.signea__status__c == 'refused') {
            refusedCDSs.add(oCDS);
        } else if (oCDS.Signea_Circuit__r.signea__status__c == 'expired') {
            expiredCDSs.add(oCDS);
        } else if (oCDS.Signea_Circuit__r.signea__status__c == 'cancelled') {
            cancelledCDSs.add(oCDS);
        } else if (oCDS.Signea_Circuit__r.signea__status__c == 'ongoing') {
            onGoingCDSs.add(oCDS);
        } else if (oCDS.Signea_Circuit__r.signea__status__c == 'filling') {
            fillingCDSs.add(oCDS);
        } else if (oCDS.Signea_Circuit__r.signea__status__c == 'Launch Failed') {
            launchFailedCDSs.add(oCDS);
        }
    }
    
    Signea_CustumTriggerHelper.updateCDSsOnSignedCircuit(signedCDSs);
    Signea_CustumTriggerHelper.updateCDSsOnRefusedCircuit(refusedCDSs);
    Signea_CustumTriggerHelper.updateCDSsOnExpiredCircuit(expiredCDSs);
    Signea_CustumTriggerHelper.updateCDSsOngoingCircuits(onGoingCDSs);
    Signea_CustumTriggerHelper.updateCDSsFillingCircuits(fillingCDSs);
    Signea_CustumTriggerHelper.updateCDSsCancelledCircuits(cancelledCDSs);
    Signea_CustumTriggerHelper.updateCDSsLaunchFailedCircuits(launchFailedCDSs);
    
    
    // Manage BankDetails
    
    List<Bank_Detail__c> signedBDs = new List<Bank_Detail__c>();
    List<Bank_Detail__c> refusedBDs = new List<Bank_Detail__c>();
    List<Bank_Detail__c> expiredBDs = new List<Bank_Detail__c>();
    List<Bank_Detail__c> onGoingBDs = new List<Bank_Detail__c>();
    List<Bank_Detail__c> fillingBDs = new List<Bank_Detail__c>();
    List<Bank_Detail__c> cancelledBDs = new List<Bank_Detail__c>();
    List<Bank_Detail__c> launchFailedBDs = new List<Bank_Detail__c>();
    
    List<Bank_Detail__c> triggerBDs = [select Id, Signea_Circuit__c, Signea_Circuit__r.signea__status__c from Bank_Detail__c where signea_circuit__c in :Trigger.new and Status__c != 'Validé par BO' ];
    
    for( Bank_Detail__c oBD:triggerBDs ) {
        if(oBD.Signea_Circuit__r.signea__status__c == 'completed') {
            signedBDs.add(oBD);
        } else if (oBD.Signea_Circuit__r.signea__status__c == 'refused') {
            refusedBDs.add(oBD);
        } else if (oBD.Signea_Circuit__r.signea__status__c == 'expired') {
            expiredBDs.add(oBD);
        } else if (oBD.Signea_Circuit__r.signea__status__c == 'cancelled') {
            cancelledBDs.add(oBD);
        } else if (oBD.Signea_Circuit__r.signea__status__c == 'ongoing') {
            onGoingBDs.add(oBD);
        } else if (oBD.Signea_Circuit__r.signea__status__c == 'filling') {
            fillingBDs.add(oBD);
        } else if (oBD.Signea_Circuit__r.signea__status__c == 'Launch Failed') {
            launchFailedBDs.add(oBD);
        }
    }
    
    Signea_CustumTriggerHelper.updateBDsOnSignedCircuit(signedBDs);
    Signea_CustumTriggerHelper.updateBDsOnRefusedCircuit(refusedBDs);
    Signea_CustumTriggerHelper.updateBDsOnExpiredCircuit(expiredBDs);
    Signea_CustumTriggerHelper.updateBDsOngoingCircuits(onGoingBDs);
    Signea_CustumTriggerHelper.updateBDsFillingCircuits(fillingBDs);
    Signea_CustumTriggerHelper.updateBDsCancelledCircuits(cancelledBDs);
    Signea_CustumTriggerHelper.updateBDsLaunchFailedCircuits(launchFailedBDs);
    
    
    // Manage SEPA Details
    Signea_CustumTriggerHelper.manageSEPADetails(Trigger.new);
    
}