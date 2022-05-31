@isTest
public class matriceSAP_Test {


    @isTest static void matriceSAP_Test() 
    {
        Test.startTest();
        
        matriceSAP mapSAP = new matriceSAP('SUCC', 'SUCC', 'opportunityReason', 'storageModificationReason', 
        'PTL', 'sDO', 'hierarchie', 'remise', 'calendrierFacturation', 'contrat', 'raisonCdeContratCrea', 
        'raisonCdeMvt', 'cdeMvtCiterne');

        Test.stopTest();
        System.assertEquals('SUCC', mapSAP.projetType);


    }


}