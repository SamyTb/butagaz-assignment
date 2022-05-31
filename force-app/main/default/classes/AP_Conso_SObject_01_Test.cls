@isTest
public class AP_Conso_SObject_01_Test {
    public static void clearAndInsertQuotePTL(Quote_PTL__c oQuotePTLToInsert){
        // Used to remove all Quote PTLS (uniqueness constraint) and insert one
        delete [
            SELECT Id 
            FROM Quote_PTL__c 
            WHERE 
                Quote__c = :oQuotePTLToInsert.Quote__c 
             OR Opportunity_PTL__c = :oQuotePTLToInsert.Opportunity_PTL__c
        ];
        insert oQuotePTLToInsert;
    }

    public static City_Postal_Code__c getCity(){
    
         //Mandataire
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '777',Active__c = true,MatriculeEnCours__c=3);
        insert mandataire1;
        Canton__c oCanton  = new Canton__c(INSEE_Code__c = '123',Mandataire__c=mandataire1.id);
        insert oCanton;
        City__c oCity = new City__c(INSEE_Code__c = '456', Canton__c = oCanton.Id);
        insert oCity;
        City_Postal_Code__c oCPC = new City_Postal_Code__c(HEXAPOSTE_Code__c = '789', City__c = oCity.Id, Code_Type__c = 'M');
        insert oCPC;
        return oCPC;
    }

    public static Quote_PTL__c getQuotePTL(){
    
        //Mandataire
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '111',Active__c = true,MatriculeEnCours__c=3);
        insert mandataire1;
    
        Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
        insert oDomain;
        
        //Canton
        Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
        insert Canton1;
        
        City_Postal_Code__c oCPC = AP_Conso_SObject_01_Test.getCity();
        Opportunity oOpty = new Opportunity(name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oCPC.Id, Project_City_Postal_Code__c = oCPC.Id, Do_Activity_Domain__c = oDomain.Id, T_Pack__c = '');
        insert oOpty;

        Quote oQuote = new Quote(OpportunityId = oOpty.Id, Name='C');
        oQuote.Payment_Spread__c = 'Z000';
        oQuote.DO_Payment_method__c = 'C';
        oQuote.Contract_Duration__c = '5'; 
        insert oQuote;

        Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
        insert attCom50;   
        
        // Insert after the Quote so Quote trigger won't fire
        Opportunity_PTL__c oOptyPTL = new Opportunity_PTL__c(
            Opportunity__c = oOpty.Id, 
            PTL_Name__c = '123',
            PTL_Street_Type__c = '456',
            PTL_Street_Name__c = '789',
            PTL_City_Postal_Code__c = oCPC.Id,
            Code_AC_administrator_New__c = attCom50.Id,
			Code_marche__c =  'P100'

        );
        insert oOptyPTL;

        return new Quote_PTL__c(Quote__c = oQuote.Id, Opportunity_PTL__c = oOptyPTL.Id);
    }

    public static testmethod void testTriggerRunsQPTL(){
        Test.StartTest();
        Quote_PTL__c oPTL = AP_Conso_SObject_01_Test.getQuotePTL();
        oPTL.Consumption_From_Excel__c = '9.78, 3.88, 0.34, 2.34, 7.20, 4.57, 5.84, 0.46, 6.16, 6.28, 6.17, 4.75, 1.57, 0.45, 4.83, 1.40, 8.91, 0.24, 2.65, 6.59, 6.80, 8.81, 7.39, 4.72 20';
        AP_Conso_SObject_01_Test.clearAndInsertQuotePTL(oPTL);
        oPTL = [SELECT Id, Consumption_From_Excel__c FROM Quote_PTL__c WHERE Id = :oPTL.Id];
        System.assertEquals(null, oPTL.Consumption_From_Excel__c);
        update oPTL;
        Test.StopTest();
    }

    public static testmethod void testTriggerRunsOpty(){
        Test.StartTest();
         //Mandataire
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
        insert mandataire1;
        Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
        insert oDomain;
        //Canton
        Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
        insert Canton1;
        
        City_Postal_Code__c oCPC = AP_Conso_SObject_01_Test.getCity();
        Opportunity oOpty = new Opportunity(name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oCPC.Id, Project_City_Postal_Code__c = oCPC.Id, Do_Activity_Domain__c = oDomain.Id, T_Pack__c = '');
        oOpty.Consumption_From_Excel__c = '9.78, 3.88, 0.34, 2.34, 7.20, 4.57, 5.84, 0.46, 6.16, 6.28, 6.17, 4.75, 1.57, 0.45, 4.83, 1.40, 8.91, 0.24, 2.65, 6.59, 6.80, 8.81, 7.39, 4.72 20';
        insert oOpty;
        oOpty = [SELECT Id, Consumption_From_Excel__c FROM Opportunity WHERE Id = :oOpty.Id];
        System.assertEquals(null, oOpty.Consumption_From_Excel__c);
        update oOpty;
        Test.StopTest();
    }

    public static testmethod void testTriggerAddError(){
        Boolean hasErrored0 = false;
        Boolean hasErrored1 = false;

        Test.startTest();
        Quote_PTL__c oPTL = AP_Conso_SObject_01_Test.getQuotePTL();
        oPTL.Consumption_From_Excel__c = '9.78, 3.88, 0.34, 2.34, 7.20, 4.57, 5.84, 0.46, 6.16, 6.28, 6.17, 4.75, 1.57, 0.45, 4.83, 1.40, 8.91, 0.24, 2.65, 6.59, 6.80, 8.81, 7.39, 4.72, 1.22 20'; // One in excess!
        try {
            AP_Conso_SObject_01_Test.clearAndInsertQuotePTL(oPTL);
        } catch (System.DmlException e){
            System.assert(e.getMessage().contains(System.Label.SObject_Consumption_InvalidInput), e.getMessage());
            hasErrored0 = true;
        }
        oPTL.Consumption_From_Excel__c = '9.78, 3.88, 0.34, 2.34, 7.20, 4.57, 5.84, 0.46, 6.16, 6.28, 6.17, 4.75, 1.57, 0.45, 4.83, 1.40, 8.91, 0.24, 2.65, 6.59, 6.80, 8.81, 7.39 20'; // Missing one!
        try {
            AP_Conso_SObject_01_Test.clearAndInsertQuotePTL(oPTL);
        } catch (System.DmlException e){
            System.assert(e.getMessage().contains(System.Label.SObject_Consumption_InvalidInput));
            hasErrored1 = true;
        }

        System.assert(hasErrored0);
        System.assert(hasErrored1);

        Test.stopTest();
    }

    public static testmethod void testUpdateConsoQPTL(){
        test.starttest();
        Quote_PTL__c oPTL = AP_Conso_SObject_01_Test.getQuotePTL();
        oPTL.Consumption_From_Excel__c = '9,78, 3,88, 0,34, 2,34, 7,20, 4,57, 5,84, 0,46, 6.16, 6.28, 6.17, 4.75, 1.57, 0.45, 4.83, 1.40, 8.91, 0.24, 2.65, 6.59, 6.80, 8.81, 7.39, 4.72 20'; // Some commas, some points..
        AP_Conso_SObject_01.updateConso(new List<Quote_PTL__c>{oPTL});

        System.assertEquals(Decimal.valueOf('9.78'), oPTL.get('consumption_fixed_jan__c')   );
        System.assertEquals(Decimal.valueOf('3.88'), oPTL.get('consumption_fixed_feb__c')   );
        System.assertEquals(Decimal.valueOf('0.34'), oPTL.get('consumption_fixed_mar__c')   );
        System.assertEquals(Decimal.valueOf('2.34'), oPTL.get('consumption_fixed_apr__c')   );
        System.assertEquals(Decimal.valueOf('7.20'), oPTL.get('consumption_fixed_may__c')   );
        System.assertEquals(Decimal.valueOf('4.57'), oPTL.get('consumption_fixed_jun__c')   );
        System.assertEquals(Decimal.valueOf('5.84'), oPTL.get('consumption_fixed_jul__c')   );
        System.assertEquals(Decimal.valueOf('0.46'), oPTL.get('consumption_fixed_aug__c')   );
        System.assertEquals(Decimal.valueOf('6.16'), oPTL.get('consumption_fixed_sep__c')   );
        System.assertEquals(Decimal.valueOf('6.28'), oPTL.get('consumption_fixed_oct__c')   );
        System.assertEquals(Decimal.valueOf('6.17'), oPTL.get('consumption_fixed_nov__c')   );
        System.assertEquals(Decimal.valueOf('4.75'), oPTL.get('consumption_fixed_dec__c')   );
        System.assertEquals(Decimal.valueOf('1.57'), oPTL.get('consumption_variable_jan__c'));
        System.assertEquals(Decimal.valueOf('0.45'), oPTL.get('consumption_variable_feb__c'));
        System.assertEquals(Decimal.valueOf('4.83'), oPTL.get('consumption_variable_mar__c'));
        System.assertEquals(Decimal.valueOf('1.40'), oPTL.get('consumption_variable_apr__c'));
        System.assertEquals(Decimal.valueOf('8.91'), oPTL.get('consumption_variable_may__c'));
        System.assertEquals(Decimal.valueOf('0.24'), oPTL.get('consumption_variable_jun__c'));
        System.assertEquals(Decimal.valueOf('2.65'), oPTL.get('consumption_variable_jul__c'));
        System.assertEquals(Decimal.valueOf('6.59'), oPTL.get('consumption_variable_aug__c'));
        System.assertEquals(Decimal.valueOf('6.80'), oPTL.get('consumption_variable_sep__c'));
        System.assertEquals(Decimal.valueOf('8.81'), oPTL.get('consumption_variable_oct__c'));
        System.assertEquals(Decimal.valueOf('7.39'), oPTL.get('consumption_variable_nov__c'));
        System.assertEquals(Decimal.valueOf('4.72'), oPTL.get('consumption_variable_dec__c'));
        System.assertEquals(Decimal.valueOf('20'),   oPTL.get('temperature__c'));

        Test.stopTest();
    }

    public static testmethod void testUpdateConsoOpty(){
        test.starttest();
         //Mandataire
         Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3);
         insert mandataire1;
        Activity_Domain__c oDomain = new Activity_Domain__c(Name = '123'); 
        insert oDomain;
        //Canton
        Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
        insert Canton1;
        City_Postal_Code__c oCPC = AP_Conso_SObject_01_Test.getCity();
        Opportunity oOpty = new Opportunity(name='SomeName', Assign__c=false, StageName='A', CloseDate=Date.today(), DO_Street_Type__c = 'A', DO_Street_Name__c = 'A', DO_City_Postal_Code__c = oCPC.Id, Project_City_Postal_Code__c = oCPC.Id, Do_Activity_Domain__c = oDomain.Id, T_Pack__c = '');
        oOpty.Consumption_From_Excel__c = '9,78, 3,88, 0,34, 2,34, 7,20, 4,57, 5,84, 0,46, 6.16, 6.28, 6.17, 4.75, 1.57, 0.45, 4.83, 1.40, 8.91, 0.24, 2.65, 6.59, 6.80, 8.81, 7.39, 4.72 20'; // Some commas, some points..
        AP_Conso_SObject_01.updateConso(new List<Opportunity>{oOpty});

        System.assertEquals(Decimal.valueOf('9.78'), oOpty.get('consumption_fixed_jan__c')   );
        System.assertEquals(Decimal.valueOf('3.88'), oOpty.get('consumption_fixed_feb__c')   );
        System.assertEquals(Decimal.valueOf('0.34'), oOpty.get('consumption_fixed_mar__c')   );
        System.assertEquals(Decimal.valueOf('2.34'), oOpty.get('consumption_fixed_apr__c')   );
        System.assertEquals(Decimal.valueOf('7.20'), oOpty.get('consumption_fixed_may__c')   );
        System.assertEquals(Decimal.valueOf('4.57'), oOpty.get('consumption_fixed_jun__c')   );
        System.assertEquals(Decimal.valueOf('5.84'), oOpty.get('consumption_fixed_jul__c')   );
        System.assertEquals(Decimal.valueOf('0.46'), oOpty.get('consumption_fixed_aug__c')   );
        System.assertEquals(Decimal.valueOf('6.16'), oOpty.get('consumption_fixed_sep__c')   );
        System.assertEquals(Decimal.valueOf('6.28'), oOpty.get('consumption_fixed_oct__c')   );
        System.assertEquals(Decimal.valueOf('6.17'), oOpty.get('consumption_fixed_nov__c')   );
        System.assertEquals(Decimal.valueOf('4.75'), oOpty.get('consumption_fixed_dec__c')   );
        System.assertEquals(Decimal.valueOf('1.57'), oOpty.get('consumption_variable_jan__c'));
        System.assertEquals(Decimal.valueOf('0.45'), oOpty.get('consumption_variable_feb__c'));
        System.assertEquals(Decimal.valueOf('4.83'), oOpty.get('consumption_variable_mar__c'));
        System.assertEquals(Decimal.valueOf('1.40'), oOpty.get('consumption_variable_apr__c'));
        System.assertEquals(Decimal.valueOf('8.91'), oOpty.get('consumption_variable_may__c'));
        System.assertEquals(Decimal.valueOf('0.24'), oOpty.get('consumption_variable_jun__c'));
        System.assertEquals(Decimal.valueOf('2.65'), oOpty.get('consumption_variable_jul__c'));
        System.assertEquals(Decimal.valueOf('6.59'), oOpty.get('consumption_variable_aug__c'));
        System.assertEquals(Decimal.valueOf('6.80'), oOpty.get('consumption_variable_sep__c'));
        System.assertEquals(Decimal.valueOf('8.81'), oOpty.get('consumption_variable_oct__c'));
        System.assertEquals(Decimal.valueOf('7.39'), oOpty.get('consumption_variable_nov__c'));
        System.assertEquals(Decimal.valueOf('4.72'), oOpty.get('consumption_variable_dec__c'));
        System.assertEquals(Decimal.valueOf('20'),   oOpty.get('temperature__c'));

        Test.stopTest();
    }
}