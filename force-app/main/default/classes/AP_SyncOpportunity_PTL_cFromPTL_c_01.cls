public class AP_SyncOpportunity_PTL_cFromPTL_c_01 {
  
    public static Map<Id, PTL__c> getPTL_cs(List<Opportunity_PTL__c> lOpportunity_PTL_cs){
        // Sync the created Opportunity_PTL__cs with their PTL__cs
        Set<Id> sPTL_cIds = new Set<Id>();
        for (Opportunity_PTL__c oOpportunity_PTL_c : lOpportunity_PTL_cs){
            sPTL_cIds.add(oOpportunity_PTL_c.PTL__c);
                System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.getPTL_cs] Adding ID from [oOpportunity_PTL_c.PTL__c( ' + oOpportunity_PTL_c.Id + ')] : [' + oOpportunity_PTL_c.PTL__c + ']');
            
        }

        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.getPTL_cs] Ids of Queried Objects: [' + sPTL_cIds + ']');

        return new Map<Id, PTL__c>([
            SELECT
                Id,
                // BEGIN_AUTO_PTL__c_FIELDS
                Value_added_tax_within_the_Community__c,
                Department__c,
                Scale__c,
                Limitation_of_Vehicle__c,
                Postal_code__c,
                Street_name__c,
                Payment_Delay__c,
                Blocking_Commands_ADV__c,
                Account_Groupement__c,
                Fax_Number__c,
                Activity_Domain__c,
                Code_NACE__c,
                Code_division__c,
                Blocking_Delivery_General__c,
                Limitation_of_Tonnage__c,
            	Value_of_tonnage_limitation__c,
                Blocking_Delivery_ADV__c,
                Code_division_value__c,
                //Code_NACE_value__c,
                Place_Called__c,
                Estimated_or_Real_Capacity__c,
                Phone__c,
                Mobile_Phone_Number__c,
                Code_branche_value__c,
                City_code__c,
                Etimated_or_Real_Consumption__c,
                Mandataire__c,
                Number_extention__c,
                Shipping_Condition__c,
                /*Code_AC_administrator__c,
                Code_AC_administrator_value__c,*/
                Code_AC_administrator_New__c,
                First_and_Last_Name__c,
                ADV_deletion_flag__c,
                Seasonal_Date_of_Period_Start__c,
                Period_Frequency__c,
                Address__c,
                Gasdeliverymode__c,
                Street_type__c,
                Temporary_dispensation__c,
                Name,
                Gal_deletion_flag__c,
                Date_at_the_End_of_Dispensation__c,
                Permanent_dispensation__c,
                Seasonal_Date_of_Period_End__c,
                Title__c,
                Date_Connecting__c,
                Delivery_possible_in_absence_of_client__c,
                E_mail__c,
                Street_number__c,
                Code_branche__c,
                Market_Sub_Type__c,
                Postal_Box__c,
                Country__c,
                City_Postal_Code__c,
                Customer_presence__c,
                Work_Phone_Number__c,
                Code_NAF__c,
                City__c,
                Blocking_Commands_General__c,
                Market_type__c,
                Label__c,
                Days_no_Delivery_possible__c, 
                Precheck_Truck_needed__c, 
                PDF_Hours_of_delivery_not_possible__c,
                
                // Ajout ELC 20160302
                Client_ouvert_toute_l_annee__c,
                Periode_de_fermeture_2_semaines__c,
                Periode_similaire_tous_les_ans__c,
                Debut_periode__c,
                Fin_periode__c,
                Client_avec_sous_depot__c,
                Necessaire_de_prevenir_le_client__c,
                La_presence_systemathique__c,
                Emballage_Pivot__c,
                Consommation_estimee_Butane_10__c,
                Consommation_estimee_Butane_13__c,
                Consommation_estimee_Cube_But__c,
                Consommation_estimee_Cube_Prop__c,
                Consommation_estimee_propane_13__c,
                Consommation_estimee_Propane_35__c,
                Consommation_estimee_Prop_Carb__c,
                Commande_generer_a_partir_du__c,
                Frequence_des_premieres_commandes__c,
                Frequence_semaine_quinzaine_mois__c,
                Indication_supplementaire__c,
                Indication_supplementaire_depot__c,
                Accessible_par_tout_type_de_vehicule__c,
                Ensemble_semi__c,
                Porteurs__c,
                Vehicules_utilitaires__c,
                Chargement__c,
                Acces_clients__c,
                Stationnement__c,
                Consignes_specifiques__c,
                Aire_de_livraison__c,
                Documents__c,
                Reglement__c,
                Acces_difficile__c,
                Acces_reglemente__c,
                Acces_particulier__c,
                Reimplantation_date__c,
                Type_d_implantation__c,
                Enclos__c,
                Enclos_sur__c,
                Presence_pompiste__c,
                Si_pas_pompiste_ou_partielle__c,
                Nombre_de_pompes_essence_sur_le_PTL__c,
                PTL_Drive__c,
                Preciser_l_emplacement_du_depot_Drive__c,
                Type_de_Drive__c,
                Livraison_domicile__c,
                Distributeur_automatique_bouteilles__c,
                Marques_distributeurs_aut_bouteilles__c,
                Presence_distributeur_automatique_cles__c,
                Marques_distributeurs_cles__c,
                Texte_Chauffeur_2__c,
                Apporter_le_bon_de_commande__c,
                Particularites_acces__c,
                Particularites_HSE__c,
                Particularites_revendeur__c,
                Type_de_presentoir_1__c,
                Type_de_presentoir_2__c,
                Type_de_presentoir_3__c,
                Type_de_presentoir_4__c,
                Type_de_presentoir_5__c,
                Nombre_type_de_presentoir_1__c,
                Nombre_type_de_presentoir_2__c,
                Nombre_type_de_presentoir_3__c,
                Nombre_type_de_presentoir_4__c,
                Nombre_type_de_presentoir_5__c,
                Nombre_de_bandeaux__c,
                Nombre_de_surmontoirs__c,
                Presence_porte_affiche_Butagaz__c,
                Si_oui_sur_quel_presentoir__c,
                Information_prix__c,
                Lourde_Legere__c,
                Presentoirs_autres_marques_presents_30__c,
                Tete_de_gondole__c,
                Gribouille__c,
                Prix_BD_Ref__c,
                Concurrent_1__c,
                Concurrent_2__c,
                Concurrent_3__c,
                Zone_stockage__c,
                Bassin_de_vie__c,
                Depot_de_livraison_PLV__c,
                Memes_horaires_toute_la_semaine__c,
                Horaires_possible_Lundi__c,
                Horaires_possible_Mardi__c,
                Horaires_possible_Mercredi__c,
                Horaires_possible_Jeudi__c,
                Horaires_possible_Vendredi__c,
                Horaires_possible_Samedi__c,
                Horaires_preferees_Lundi_txt__c,
                Horaires_preferees_Mardi_txt__c,
                Horaires_preferees_Mercredi_txt__c,
                Horaires_preferees_Jeudi_txt__c,
                Horaires_preferees_Vendredi_txt__c,
                Horaires_preferees_Samedi_txt__c,
                Service_de_Drive__c,
                Vente_de_Gaz_dans_ce_Drive__c,
                Marques_de_Gaz_vendues__c,
                Canal_d_achat_de_la_Bouteille_Butagaz__c,
                Informations_sur_le_Drive__c,
                Segmentation__c,
                Description__c,
                Nombre_bouteilles_distributeur_cles__c

                // END_AUTO_PTL__c_FIELDS
            FROM  PTL__c
            WHERE Id IN :sPTL_cIds
        ]);
    }

    public static void syncOpportunity_PTL_cFromPTL_c(Map<Id, Opportunity_PTL__c> mOpportunity_PTL_csBeforeUpdate, Map<Id, Opportunity_PTL__c> mOpportunity_PTL_csAfterUpdate){
        // If we change an PTL__c (DO, Payer of Billed) to the Opportunity_PTL__c, its fields should be synced
        // with the Actual PTL__cs themselves.

        Map<Id, PTL__c> mPTL_cs = AP_SyncOpportunity_PTL_cFromPTL_c_01.getPTL_cs(mOpportunity_PTL_csAfterUpdate.values());

        for (Opportunity_PTL__c oOpportunity_PTL_c : mOpportunity_PTL_csAfterUpdate.values()){
            if (mOpportunity_PTL_csBeforeUpdate.get(oOpportunity_PTL_c.Id).PTL__c != oOpportunity_PTL_c.PTL__c){
                    AP_SyncOpportunity_PTL_cFromPTL_c_01.syncPTL_Fields(oOpportunity_PTL_c, mPTL_cs);
                }
            
        }
    }

    public static void syncOpportunity_PTL_cFromPTL_c(List<Opportunity_PTL__c> lOpportunity_PTL_cs){
        // When we create an Opportunity_PTL__c, we should add the fields form the PTL__cs (DO, Payer, Billed) to
        // the PTL__c Fields on the Opportunity_PTL__c.
        Map<Id, PTL__c> mPTL_cs = AP_SyncOpportunity_PTL_cFromPTL_c_01.getPTL_cs(lOpportunity_PTL_cs);
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromPTL_c]: lOpportunity_PTL_cs:' + lOpportunity_PTL_cs);
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromPTL_c]: SIZE(lOpportunity_PTL_cs):' + lOpportunity_PTL_cs.size());
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromPTL_c]: mPTL_cs:' + mPTL_cs);
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.syncOpportunity_PTL_cFromPTL_c]: SIZE(mPTL_cs):' + mPTL_cs.keySet().size());

        for (Opportunity_PTL__c oOpportunity_PTL_c : lOpportunity_PTL_cs){
            AP_SyncOpportunity_PTL_cFromPTL_c_01.syncPTL_Fields(oOpportunity_PTL_c, mPTL_cs);
            
        }
    }

    public static void syncPTL_Fields(Opportunity_PTL__c oOpportunity_PTL_c, Map<Id, PTL__c> mPTL_cs){
        if (oOpportunity_PTL_c.PTL__c != null){
            PTL__c oPTL_c = mPTL_cs.get(oOpportunity_PTL_c.PTL__c); // This can't be null. If the PTL__c is not null then it's an PTL__c AND we queried it!
            // BEGIN_AUTO_SYNC_PTL__r
            oOpportunity_PTL_c.PTL_ADV_deletion_flag__c = oPTL_c.ADV_deletion_flag__c;
            oOpportunity_PTL_c.PTL_Account_Groupement__c = oPTL_c.Account_Groupement__c;
            oOpportunity_PTL_c.PTL_Activity_Domain__c = oPTL_c.Activity_Domain__c;
            oOpportunity_PTL_c.PTL_Address__c = oPTL_c.Address__c;
            oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c = oPTL_c.Blocking_Commands_ADV__c;
            oOpportunity_PTL_c.PTL_Blocking_Commands_General__c = oPTL_c.Blocking_Commands_General__c;
            oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c = oPTL_c.Blocking_Delivery_ADV__c;
            oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c = oPTL_c.Blocking_Delivery_General__c;
            oOpportunity_PTL_c.PTL_City_Postal_Code__c = oPTL_c.City_Postal_Code__c;
            oOpportunity_PTL_c.PTL_City__c = oPTL_c.City__c;
            oOpportunity_PTL_c.PTL_City_code__c = oPTL_c.City_code__c;
            /*oOpportunity_PTL_c.PTL_Code_AC_administrator__c = oPTL_c.Code_AC_administrator__c;
            oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c = oPTL_c.Code_AC_administrator_value__c;*/
            oOpportunity_PTL_c.Code_AC_administrator_New__c = oPTL_c.Code_AC_administrator_New__c;
            if(oOpportunity_PTL_c.PTL_Code_NACE__c == null) oOpportunity_PTL_c.PTL_Code_NACE__c = oPTL_c.Code_NACE__c;
            //oOpportunity_PTL_c.PTL_Code_NACE_value__c = oPTL_c.Code_NACE_value__c;
            oOpportunity_PTL_c.PTL_Code_NAF__c = oPTL_c.Code_NAF__c;
            oOpportunity_PTL_c.PTL_Code_branche__c = oPTL_c.Code_branche__c;
            oOpportunity_PTL_c.PTL_Code_branche_value__c = oPTL_c.Code_branche_value__c;
            oOpportunity_PTL_c.PTL_Code_division__c = oPTL_c.Code_division__c;
            oOpportunity_PTL_c.PTL_Code_division_value__c = oPTL_c.Code_division_value__c;
            oOpportunity_PTL_c.PTL_Country__c = oPTL_c.Country__c;
            oOpportunity_PTL_c.PTL_Customer_presence__c = oPTL_c.Customer_presence__c;
            oOpportunity_PTL_c.PTL_Date_Connecting__c = oPTL_c.Date_Connecting__c;
            oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c = oPTL_c.Date_at_the_End_of_Dispensation__c;
            oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c = oPTL_c.Seasonal_Date_of_Period_End__c;
            oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c = oPTL_c.Seasonal_Date_of_Period_Start__c;
            oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c = string.valueof(oPTL_c.Delivery_possible_in_absence_of_client__c);
            oOpportunity_PTL_c.PTL_Department__c = oPTL_c.Department__c;
            oOpportunity_PTL_c.PTL_E_mail__c = oPTL_c.E_mail__c;
            oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c = oPTL_c.Estimated_or_Real_Capacity__c;
            oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c = oPTL_c.Etimated_or_Real_Consumption__c;
            //oOpportunity_PTL_c.PTL_Fax_Number__c = oPTL_c.Fax_Number__c;
            //oOpportunity_PTL_c.PTL_First_and_Last_Name__c = oPTL_c.First_and_Last_Name__c;
            oOpportunity_PTL_c.PTL_Gal_deletion_flag__c = oPTL_c.Gal_deletion_flag__c;
            oOpportunity_PTL_c.PTL_Gasdeliverymode__c = oPTL_c.Gasdeliverymode__c;
            oOpportunity_PTL_c.PTL_Label__c = oPTL_c.Label__c;
            oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c = oPTL_c.Limitation_of_Tonnage__c;
            oOpportunity_PTL_c.Valeur_limitation_tonnage__c = oPTL_c.Value_of_tonnage_limitation__c;
            oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c = oPTL_c.Limitation_of_Vehicle__c;
            oOpportunity_PTL_c.PTL_Mandataire__c = oPTL_c.Mandataire__c;
            oOpportunity_PTL_c.PTL_Market_Sub_Type__c = oPTL_c.Market_Sub_Type__c;
            oOpportunity_PTL_c.PTL_Market_type__c = oPTL_c.Market_type__c;
            //oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c = oPTL_c.Mobile_Phone_Number__c;
            oOpportunity_PTL_c.PTL_Number_extention__c = oPTL_c.Number_extention__c;
            oOpportunity_PTL_c.PTL_Payment_Delay__c = oPTL_c.Payment_Delay__c;
            oOpportunity_PTL_c.PTL_Period_Frequency__c = oPTL_c.Period_Frequency__c;
            oOpportunity_PTL_c.PTL_Permanent_dispensation__c = oPTL_c.Permanent_dispensation__c;
            //oOpportunity_PTL_c.PTL_Phone__c = oPTL_c.Phone__c;
            oOpportunity_PTL_c.PTL_Place_Called__c = oPTL_c.Place_Called__c;
            oOpportunity_PTL_c.PTL_Postal_Box__c = oPTL_c.Postal_Box__c;
            oOpportunity_PTL_c.PTL_Postal_code__c = oPTL_c.Postal_code__c;
            oOpportunity_PTL_c.PTL_Scale__c = oPTL_c.Scale__c;
            oOpportunity_PTL_c.PTL_Shipping_Condition__c = oPTL_c.Shipping_Condition__c;
            //FLA:08/11/2021
            String streetName = oPTL_c.Street_name__c;
            if(streetName !=''&&streetName != null)
            {
                if(streetName.length()<=27)
                oOpportunity_PTL_c.PTL_Street_name__c = oPTL_c.Street_name__c;
                else
                {
                    oOpportunity_PTL_c.PTL_Street_name__c = streetName.substring(0, 27);//limit 27c dans SAP
                    Integer reste = streetName.length()-27;
                    if(reste <= 35)
                        oOpportunity_PTL_c.PTL_Place_Called__c = streetName.substring(27, streetName.length());
                    else
                        oOpportunity_PTL_c.PTL_Place_Called__c = streetName.substring(27, 62);//limit 35c dans SAP
                }
            }

            oOpportunity_PTL_c.PTL_Street_number__c = oPTL_c.Street_number__c;
            oOpportunity_PTL_c.PTL_Street_type__c = oPTL_c.Street_type__c;
            oOpportunity_PTL_c.PTL_Temporary_dispensation__c = oPTL_c.Temporary_dispensation__c;
            oOpportunity_PTL_c.PTL_Title__c = oPTL_c.Title__c;
            oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c = oPTL_c.Value_added_tax_within_the_Community__c;
            //oOpportunity_PTL_c.PTL_Work_Phone_Number__c = oPTL_c.Work_Phone_Number__c;
            oOpportunity_PTL_c.PTL_Name__c = oPTL_c.Name;
            oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c = oPTL_c.Days_no_Delivery_possible__c;
            oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c = oPTL_c.Precheck_Truck_needed__c;
            oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c = oPTL_c.PDF_Hours_of_delivery_not_possible__c;
            
            // Ajout ELC 20160302
            oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c = oPTL_c.Client_ouvert_toute_l_annee__c;
            oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c = oPTL_c.Periode_de_fermeture_2_semaines__c;
            oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c = oPTL_c.Periode_similaire_tous_les_ans__c;
            oOpportunity_PTL_c.Debut_periode__c = oPTL_c.Debut_periode__c;
            oOpportunity_PTL_c.Fin_periode__c = oPTL_c.Fin_periode__c;
            oOpportunity_PTL_c.Client_avec_sous_depot__c = oPTL_c.Client_avec_sous_depot__c;
            oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c = oPTL_c.Necessaire_de_prevenir_le_client__c;
            oOpportunity_PTL_c.La_presence_systemathique__c = oPTL_c.La_presence_systemathique__c;
            oOpportunity_PTL_c.Emballage_Pivot__c = oPTL_c.Emballage_Pivot__c;
            oOpportunity_PTL_c.Consommation_estimee_Butane_10__c = oPTL_c.Consommation_estimee_Butane_10__c;
            oOpportunity_PTL_c.Consommation_estimee_Butane_13__c = oPTL_c.Consommation_estimee_Butane_13__c;
            oOpportunity_PTL_c.Consommation_estimee_Cube_But__c = oPTL_c.Consommation_estimee_Cube_But__c;
            oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c = oPTL_c.Consommation_estimee_Cube_Prop__c;
            oOpportunity_PTL_c.Consommation_estimee_propane_13__c = oPTL_c.Consommation_estimee_propane_13__c;
            oOpportunity_PTL_c.Consommation_estimee_Propane_35__c = oPTL_c.Consommation_estimee_Propane_35__c;
            oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c = oPTL_c.Consommation_estimee_Prop_Carb__c;
            oOpportunity_PTL_c.Commande_generer_a_partir_du__c = oPTL_c.Commande_generer_a_partir_du__c;
            oOpportunity_PTL_c.Frequence_des_premieres_commandes__c = oPTL_c.Frequence_des_premieres_commandes__c;
            oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c = oPTL_c.Frequence_semaine_quinzaine_mois__c;
            oOpportunity_PTL_c.Indication_supplementaire__c = oPTL_c.Indication_supplementaire__c;
            oOpportunity_PTL_c.Indication_supplementaire_depot__c = oPTL_c.Indication_supplementaire_depot__c;
            oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c = oPTL_c.Accessible_par_tout_type_de_vehicule__c;
            oOpportunity_PTL_c.Ensemble_semi__c = oPTL_c.Ensemble_semi__c;
            oOpportunity_PTL_c.Porteurs__c = oPTL_c.Porteurs__c;
            oOpportunity_PTL_c.Vehicules_utilitaires__c = oPTL_c.Vehicules_utilitaires__c;
            oOpportunity_PTL_c.Chargement__c = oPTL_c.Chargement__c;
            oOpportunity_PTL_c.Acces_clients__c = oPTL_c.Acces_clients__c;
            oOpportunity_PTL_c.Stationnement__c = oPTL_c.Stationnement__c;
            oOpportunity_PTL_c.Consignes_specifiques__c = oPTL_c.Consignes_specifiques__c;
            oOpportunity_PTL_c.Aire_de_livraison__c = oPTL_c.Aire_de_livraison__c;
            oOpportunity_PTL_c.Documents__c = oPTL_c.Documents__c;
            oOpportunity_PTL_c.Reglement__c = oPTL_c.Reglement__c;
            oOpportunity_PTL_c.Acces_difficile__c = oPTL_c.Acces_difficile__c;
            oOpportunity_PTL_c.Acces_reglemente__c = oPTL_c.Acces_reglemente__c;
            oOpportunity_PTL_c.Acces_particulier__c = oPTL_c.Acces_particulier__c;
            oOpportunity_PTL_c.Reimplantation_date__c = oPTL_c.Reimplantation_date__c;
            oOpportunity_PTL_c.Type_d_implantation__c = oPTL_c.Type_d_implantation__c;
            oOpportunity_PTL_c.Enclos__c = oPTL_c.Enclos__c;
            oOpportunity_PTL_c.Enclos_sur__c = oPTL_c.Enclos_sur__c;
            oOpportunity_PTL_c.Presence_pompiste__c = oPTL_c.Presence_pompiste__c;
            oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c = oPTL_c.Si_pas_pompiste_ou_partielle__c;
            oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c = oPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c;
            oOpportunity_PTL_c.PTL_Drive__c = oPTL_c.PTL_Drive__c;
            oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c = oPTL_c.Preciser_l_emplacement_du_depot_Drive__c;
            oOpportunity_PTL_c.Type_de_Drive__c = oPTL_c.Type_de_Drive__c;
            oOpportunity_PTL_c.Livraison_domicile__c = oPTL_c.Livraison_domicile__c;
            oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c = oPTL_c.Distributeur_automatique_bouteilles__c;
            oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c = oPTL_c.Marques_distributeurs_aut_bouteilles__c;
            oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c = oPTL_c.Presence_distributeur_automatique_cles__c;
            oOpportunity_PTL_c.Marques_distributeurs_cles__c = oPTL_c.Marques_distributeurs_cles__c;
            oOpportunity_PTL_c.Texte_Chauffeur_2__c = oPTL_c.Texte_Chauffeur_2__c;
            oOpportunity_PTL_c.Apporter_le_bon_de_commande__c = oPTL_c.Apporter_le_bon_de_commande__c;
            oOpportunity_PTL_c.Particularites_acces__c = oPTL_c.Particularites_acces__c;
            oOpportunity_PTL_c.Particularites_HSE__c = oPTL_c.Particularites_HSE__c;
            oOpportunity_PTL_c.Particularites_revendeur__c = oPTL_c.Particularites_revendeur__c;
            oOpportunity_PTL_c.Type_de_presentoir_1__c = oPTL_c.Type_de_presentoir_1__c;
            oOpportunity_PTL_c.Type_de_presentoir_2__c = oPTL_c.Type_de_presentoir_2__c;
            oOpportunity_PTL_c.Type_de_presentoir_3__c = oPTL_c.Type_de_presentoir_3__c;
            oOpportunity_PTL_c.Type_de_presentoir_4__c = oPTL_c.Type_de_presentoir_4__c;
            oOpportunity_PTL_c.Type_de_presentoir_5__c = oPTL_c.Type_de_presentoir_5__c;
            oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c = oPTL_c.Nombre_type_de_presentoir_1__c;
            oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c = oPTL_c.Nombre_type_de_presentoir_2__c;
            oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c = oPTL_c.Nombre_type_de_presentoir_3__c;
            oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c = oPTL_c.Nombre_type_de_presentoir_4__c;
            oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c = oPTL_c.Nombre_type_de_presentoir_5__c;
            oOpportunity_PTL_c.Nombre_de_bandeaux__c = oPTL_c.Nombre_de_bandeaux__c;
            oOpportunity_PTL_c.Nombre_de_surmontoirs__c = oPTL_c.Nombre_de_surmontoirs__c;
            oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c = oPTL_c.Presence_porte_affiche_Butagaz__c;
            oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c = oPTL_c.Si_oui_sur_quel_presentoir__c;
            oOpportunity_PTL_c.Information_prix__c = oPTL_c.Information_prix__c;
            oOpportunity_PTL_c.Lourde_Legere__c = oPTL_c.Lourde_Legere__c;
            oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c = oPTL_c.Presentoirs_autres_marques_presents_30__c;
            oOpportunity_PTL_c.Tete_de_gondole__c = oPTL_c.Tete_de_gondole__c;
            oOpportunity_PTL_c.Gribouille__c = oPTL_c.Gribouille__c;
            oOpportunity_PTL_c.Prix_BD_Ref__c = oPTL_c.Prix_BD_Ref__c;
            oOpportunity_PTL_c.Concurrent_1__c = oPTL_c.Concurrent_1__c;
            oOpportunity_PTL_c.Concurrent_2__c = oPTL_c.Concurrent_2__c;
            oOpportunity_PTL_c.Concurrent_3__c = oPTL_c.Concurrent_3__c;
            oOpportunity_PTL_c.Zone_stockage__c = oPTL_c.Zone_stockage__c;
            oOpportunity_PTL_c.Bassin_de_vie__c = oPTL_c.Bassin_de_vie__c;
            oOpportunity_PTL_c.Depot_de_livraison_PLV__c = oPTL_c.Depot_de_livraison_PLV__c;
            oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c = oPTL_c.Memes_horaires_toute_la_semaine__c;
            oOpportunity_PTL_c.Lundi__c = oPTL_c.Horaires_possible_Lundi__c;
            oOpportunity_PTL_c.Mardi__c = oPTL_c.Horaires_possible_Mardi__c;
            oOpportunity_PTL_c.Mercredi__c = oPTL_c.Horaires_possible_Mercredi__c;
            oOpportunity_PTL_c.Jeudi__c = oPTL_c.Horaires_possible_Jeudi__c;
            oOpportunity_PTL_c.Vendredi__c = oPTL_c.Horaires_possible_Vendredi__c;
            oOpportunity_PTL_c.Samedi__c = oPTL_c.Horaires_possible_Samedi__c;
            oOpportunity_PTL_c.Horaires_preferees_Lundi__c = oPTL_c.Horaires_preferees_Lundi_txt__c;
            oOpportunity_PTL_c.Horaires_preferees_Mardi__c = oPTL_c.Horaires_preferees_Mardi_txt__c;
            oOpportunity_PTL_c.Horaires_preferees_Mercredi__c = oPTL_c.Horaires_preferees_Mercredi_txt__c;
            oOpportunity_PTL_c.Horaires_preferees_Jeudi__c = oPTL_c.Horaires_preferees_Jeudi_txt__c;
            oOpportunity_PTL_c.Horaires_preferees_Vendredi__c = oPTL_c.Horaires_preferees_Vendredi_txt__c;
            oOpportunity_PTL_c.Horaires_preferees_Samedi__c = oPTL_c.Horaires_preferees_Samedi_txt__c;
            oOpportunity_PTL_c.Service_de_Drive__c = oPTL_c.Service_de_Drive__c;
            oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c = oPTL_c.Vente_de_Gaz_dans_ce_Drive__c;
            oOpportunity_PTL_c.Marques_de_Gaz_vendues__c = oPTL_c.Marques_de_Gaz_vendues__c;
            oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c = oPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c;
            oOpportunity_PTL_c.Informations_sur_le_Drive__c = oPTL_c.Informations_sur_le_Drive__c;
            oOpportunity_PTL_c.Segmentation__c = oPTL_c.Segmentation__c;
            oOpportunity_PTL_c.Description__c = oPTL_c.Description__c;
            oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c = oPTL_c.Nombre_bouteilles_distributeur_cles__c;
            // END_AUTO_SYNC_PTL__r
        }
    }
    

    public static void syncOpportunity_PTL_cFromOpportunity_PTL_c(Map<Id, Opportunity_PTL__c> mOldOpportunity_PTL_cs, Map<Id, Opportunity_PTL__c> mNewOpportunity_PTL_cs){
        Opportunity_PTL__c oOldOpportunity_PTL_c; // loop variable.
        for (Opportunity_PTL__c oNewOpportunity_PTL_c : mNewOpportunity_PTL_cs.values()){
            oOldOpportunity_PTL_c = mOldOpportunity_PTL_cs.get(oNewOpportunity_PTL_c.Id); // The API guarantees this key will be there.
            oNewOpportunity_PTL_c.T_PTL_cFieldsToChange__c = '___';
            
        }
    }

    public static void propagatePTL_cToOpportunity_PTL_c(Map<Id, PTL__c> mOldPTL_cs, Map<Id, PTL__c> mNewPTL_cs){
        // Propagate changes to the PTL__c to the Opportunity_PTL__cs.
        List<Opportunity_PTL__c> lOpportunity_PTL_cs = [
            SELECT
                Id,
                PTL__c,
                // BEGIN_AUTO_Opportunity_PTL__c_FIELDS
                PTL_Mobile_Phone_Number__c,
                PTL_Code_NAF__c,
                PTL_Limitation_of_Vehicle__c,
                PTL_Blocking_Delivery_ADV__c,
                PTL_Payment_Delay__c,
                PTL_Phone__c,
                PTL_Shipping_Condition__c,
                PTL_Code_branche__c,
                PTL_Seasonal_Date_of_Period_End__c,
                PTL_City__c,
                PTL_Market_type__c,
                PTL_City_Postal_Code__c,
                PTL_Temporary_dispensation__c,
                PTL_Code_NACE__c,
                PTL_Street_type__c,
                PTL_Blocking_Delivery_General__c,
                PTL_Number_extention__c,
                PTL_Work_Phone_Number__c,
                PTL_Blocking_Commands_ADV__c,
                PTL_City_code__c,
                PTL_First_and_Last_Name__c,
                /*PTL_Code_AC_administrator__c,
                PTL_Code_AC_administrator_value__c,*/
                //Code_AC_administrator_New__c,
                PTL_Seasonal_Date_of_Period_Start__c,
                PTL_Limitation_of_Tonnage__c,
				Valeur_limitation_tonnage__c,            
                PTL_Date_Connecting__c,
                PTL_Value_added_tax_within_the_Community__c,
                PTL_Code_division__c,
                PTL_Estimated_or_Real_Capacity__c,
                PTL_Blocking_Commands_General__c,
                PTL_Activity_Domain__c,
                PTL_Place_Called__c,
                PTL_Code_division_value__c,
                PTL_Gal_deletion_flag__c,
                PTL_Postal_Box__c,
                PTL_Date_at_the_End_of_Dispensation__c,
                PTL_Account_Groupement__c,
                PTL_Fax_Number__c,
                //PTL_Code_NACE_value__c,
                PTL_Code_branche_value__c,
                PTL_Permanent_dispensation__c,
                PTL_Street_number__c,
                PTL_Country__c,
                PTL_Name__c,
                PTL_Etimated_or_Real_Consumption__c,
                PTL_Market_Sub_Type__c,
                PTL_Period_Frequency__c,
                PTL_E_mail__c,
                PTL_ADV_deletion_flag__c,
                PTL_Street_name__c,
                PTL_Label__c,
                PTL_Gasdeliverymode__c,
                PTL_Mandataire__c,
                PTL_Title__c,
                PTL_Delivery_possible_in_absence_of_clie__c,
                PTL_Address__c,
                PTL_Customer_presence__c,
                PTL_Scale__c,
                PTL_Postal_code__c,
                PTL_Department__c,
                PTL_Days_no_Delivery_possible__c,
                PTL_Precheck_Truck_needed__c,
                PTL_PDF_Hours_of_delivery_not_possible__c,
                
                // Ajout ELC 20160302
                Client_ouvert_toute_l_annee__c,
                Periode_de_fermeture_2_semaines__c,
                Periode_similaire_tous_les_ans__c,
                Debut_periode__c,
                Fin_periode__c,
                Client_avec_sous_depot__c,
                Necessaire_de_prevenir_le_client__c,
                La_presence_systemathique__c,
                Emballage_Pivot__c,
                Consommation_estimee_Butane_10__c,
                Consommation_estimee_Butane_13__c,
                Consommation_estimee_Cube_But__c,
                Consommation_estimee_Cube_Prop__c,
                Consommation_estimee_propane_13__c,
                Consommation_estimee_Propane_35__c,
                Consommation_estimee_Prop_Carb__c,
                Commande_generer_a_partir_du__c,
                Frequence_des_premieres_commandes__c,
                Frequence_semaine_quinzaine_mois__c,
                Indication_supplementaire__c,
                Indication_supplementaire_depot__c,
                Accessible_par_tout_type_de_vehicule__c,
                Ensemble_semi__c,
                Porteurs__c,
                Vehicules_utilitaires__c,
                Chargement__c,
                Acces_clients__c,
                Stationnement__c,
                Consignes_specifiques__c,
                Aire_de_livraison__c,
                Documents__c,
                Reglement__c,
                Acces_difficile__c,
                Acces_reglemente__c,
                Acces_particulier__c,
                Reimplantation_date__c,
                Type_d_implantation__c,
                Enclos__c,
                Enclos_sur__c,
                Presence_pompiste__c,
                Si_pas_pompiste_ou_partielle__c,
                Nombre_de_pompes_essence_sur_le_PTL__c,
                PTL_Drive__c,
                Preciser_l_emplacement_du_depot_Drive__c,
                Type_de_Drive__c,
                Livraison_domicile__c,
                Distributeur_automatique_bouteilles__c,
                Marques_distributeurs_aut_bouteilles__c,
                Presence_distributeur_automatique_cles__c,
                Marques_distributeurs_cles__c,
                Texte_Chauffeur_2__c,
                Apporter_le_bon_de_commande__c,
                Particularites_acces__c,
                Particularites_HSE__c,
                Particularites_revendeur__c,
                Type_de_presentoir_1__c,
                Type_de_presentoir_2__c,
                Type_de_presentoir_3__c,
                Type_de_presentoir_4__c,
                Type_de_presentoir_5__c,
                Nombre_type_de_presentoir_1__c,
                Nombre_type_de_presentoir_2__c,
                Nombre_type_de_presentoir_3__c,
                Nombre_type_de_presentoir_4__c,
                Nombre_type_de_presentoir_5__c,
                Nombre_de_bandeaux__c,
                Nombre_de_surmontoirs__c,
                Presence_porte_affiche_Butagaz__c,
                Si_oui_sur_quel_presentoir__c,
                Information_prix__c,
                Lourde_Legere__c,
                Presentoirs_autres_marques_presents_30__c,
                Tete_de_gondole__c,
                Gribouille__c,
                Prix_BD_Ref__c,
                Concurrent_1__c,
                Concurrent_2__c,
                Concurrent_3__c,
                Zone_stockage__c,
                Bassin_de_vie__c,
                Depot_de_livraison_PLV__c,
                Memes_horaires_toute_la_semaine__c,
                Lundi__c,
                Mardi__c,
                Mercredi__c,
                Jeudi__c,
                Vendredi__c,
                Samedi__c,
                Horaires_preferees_Lundi__c,
                Horaires_preferees_Mardi__c,
                Horaires_preferees_Mercredi__c,
                Horaires_preferees_Jeudi__c,
                Horaires_preferees_Vendredi__c,
                Horaires_preferees_Samedi__c,
                Service_de_Drive__c,
                Vente_de_Gaz_dans_ce_Drive__c,
                Marques_de_Gaz_vendues__c,
                Canal_d_achat_de_la_Bouteille_Butagaz__c,
                Informations_sur_le_Drive__c,
                Segmentation__c,
                Description__c,
                Nombre_bouteilles_distributeur_cles__c,
				Code_AC_administrator_New__c, 
            	Code_marche__c
                // END_AUTO_Opportunity_PTL__c_FIELDS
            FROM Opportunity_PTL__c
            WHERE
                PTL__c in :mNewPTL_cs.keySet()
                
        ];

        List<Opportunity_PTL__c> lUpdateOpportunity_PTL_cs = new List<Opportunity_PTL__c>();

        Boolean needsUpdate, needsUpdate_Part2, needsUpdate_Part3; // Loop variable.
        for (Opportunity_PTL__c oOpportunity_PTL_c : lOpportunity_PTL_cs){
            needsUpdate = false;
            needsUpdate_Part2 = false;
            needsUpdate_Part3 = false;
            // Do not use OR to block the first update from short-circuiting the others.
                if (AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields(oOpportunity_PTL_c, mOldPTL_cs, mNewPTL_cs)){
                    needsUpdate = true;
                }
                // ELC 20160302 Splitting method to avoid reaching APEX method code limit 
                if (AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2(oOpportunity_PTL_c, mOldPTL_cs, mNewPTL_cs)){
                    needsUpdate_Part2 = true;
                }
                if (AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part3(oOpportunity_PTL_c, mOldPTL_cs, mNewPTL_cs)){
                    needsUpdate_Part3 = true;
                }
            
            if (needsUpdate || needsUpdate_Part2 || needsUpdate_Part3) {
                lUpdateOpportunity_PTL_cs.add(oOpportunity_PTL_c);
            }
        }
        update lUpdateOpportunity_PTL_cs;
    }

    public static Boolean propagatePTL_Fields(Opportunity_PTL__c oOpportunity_PTL_c, Map<Id, PTL__c> mOldPTL_cs, Map<Id, PTL__c> mNewPTL_cs){
        PTL__c oOldPTL_c = mOldPTL_cs.get(oOpportunity_PTL_c.PTL__c);
        PTL__c oNewPTL_c = mNewPTL_cs.get(oOpportunity_PTL_c.PTL__c);
        Boolean status    = false;
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Starting.');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] oOldPTL_c:[' + oOldPTL_c + ']');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] oNewPTL_c:[' + oNewPTL_c + ']');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] oOpportunity_PTL_c:[' + oOpportunity_PTL_c + ']');
        if ((oOldPTL_c != null) && (oNewPTL_c != null)) { // that's equivalent. We're just checking whether the Opportunity_PTL__c had this specific PTL__c, PTL__c lookup updated
            // BEGIN_AUTO_PROPAGATE_PTL__r
            if ((oOldPTL_c.ADV_deletion_flag__c != oNewPTL_c.ADV_deletion_flag__c) && ((oOpportunity_PTL_c.PTL_ADV_deletion_flag__c == oOldPTL_c.ADV_deletion_flag__c) || (oOpportunity_PTL_c.PTL_ADV_deletion_flag__c == oNewPTL_c.ADV_deletion_flag__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_ADV_deletion_flag__c = oNewPTL_c.ADV_deletion_flag__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_ADV_deletion_flag__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_ADV_deletion_flag__c] to [' + String.valueOf(oNewPTL_c.ADV_deletion_flag__c) + ']');
                } else {
                    if (oOldPTL_c.ADV_deletion_flag__c == oNewPTL_c.ADV_deletion_flag__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_ADV_deletion_flag__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_ADV_deletion_flag__c != oOldPTL_c.ADV_deletion_flag__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_ADV_deletion_flag__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.ADV_deletion_flag__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_ADV_deletion_flag__c) + '])');
                    }
            }
            if ((oOldPTL_c.Account_Groupement__c != oNewPTL_c.Account_Groupement__c) && ((oOpportunity_PTL_c.PTL_Account_Groupement__c == oOldPTL_c.Account_Groupement__c) || (oOpportunity_PTL_c.PTL_Account_Groupement__c == oNewPTL_c.Account_Groupement__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Account_Groupement__c = oNewPTL_c.Account_Groupement__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Account_Groupement__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Account_Groupement__c] to [' + String.valueOf(oNewPTL_c.Account_Groupement__c) + ']');
                } else {
                    if (oOldPTL_c.Account_Groupement__c == oNewPTL_c.Account_Groupement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Account_Groupement__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Account_Groupement__c != oOldPTL_c.Account_Groupement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Account_Groupement__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Account_Groupement__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Account_Groupement__c) + '])');
                    }
            }
            if ((oOldPTL_c.Activity_Domain__c != oNewPTL_c.Activity_Domain__c) && ((oOpportunity_PTL_c.PTL_Activity_Domain__c == oOldPTL_c.Activity_Domain__c) || (oOpportunity_PTL_c.PTL_Activity_Domain__c == oNewPTL_c.Activity_Domain__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Activity_Domain__c = oNewPTL_c.Activity_Domain__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Activity_Domain__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Activity_Domain__c] to [' + String.valueOf(oNewPTL_c.Activity_Domain__c) + ']');
                } else {
                    if (oOldPTL_c.Activity_Domain__c == oNewPTL_c.Activity_Domain__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Activity_Domain__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Activity_Domain__c != oOldPTL_c.Activity_Domain__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Activity_Domain__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Activity_Domain__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Activity_Domain__c) + '])');
                    }
            }
            if ((oOldPTL_c.Address__c != oNewPTL_c.Address__c) && ((oOpportunity_PTL_c.PTL_Address__c == oOldPTL_c.Address__c) || (oOpportunity_PTL_c.PTL_Address__c == oNewPTL_c.Address__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Address__c = oNewPTL_c.Address__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Address__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Address__c] to [' + String.valueOf(oNewPTL_c.Address__c) + ']');
                } else {
                    if (oOldPTL_c.Address__c == oNewPTL_c.Address__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Address__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Address__c != oOldPTL_c.Address__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Address__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Address__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Address__c) + '])');
                    }
            }
            if ((oOldPTL_c.Blocking_Commands_ADV__c != oNewPTL_c.Blocking_Commands_ADV__c) && ((oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c == oOldPTL_c.Blocking_Commands_ADV__c) || (oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c == oNewPTL_c.Blocking_Commands_ADV__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c = oNewPTL_c.Blocking_Commands_ADV__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Blocking_Commands_ADV__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c] to [' + String.valueOf(oNewPTL_c.Blocking_Commands_ADV__c) + ']');
                } else {
                    if (oOldPTL_c.Blocking_Commands_ADV__c == oNewPTL_c.Blocking_Commands_ADV__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c != oOldPTL_c.Blocking_Commands_ADV__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Blocking_Commands_ADV__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Blocking_Commands_ADV__c) + '])');
                    }
            }
            if ((oOldPTL_c.Blocking_Commands_General__c != oNewPTL_c.Blocking_Commands_General__c) && ((oOpportunity_PTL_c.PTL_Blocking_Commands_General__c == oOldPTL_c.Blocking_Commands_General__c) || (oOpportunity_PTL_c.PTL_Blocking_Commands_General__c == oNewPTL_c.Blocking_Commands_General__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Blocking_Commands_General__c = oNewPTL_c.Blocking_Commands_General__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Blocking_Commands_General__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Blocking_Commands_General__c] to [' + String.valueOf(oNewPTL_c.Blocking_Commands_General__c) + ']');
                } else {
                    if (oOldPTL_c.Blocking_Commands_General__c == oNewPTL_c.Blocking_Commands_General__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Commands_General__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Blocking_Commands_General__c != oOldPTL_c.Blocking_Commands_General__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Commands_General__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Blocking_Commands_General__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Blocking_Commands_General__c) + '])');
                    }
            }
            if ((oOldPTL_c.Blocking_Delivery_ADV__c != oNewPTL_c.Blocking_Delivery_ADV__c) && ((oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c == oOldPTL_c.Blocking_Delivery_ADV__c) || (oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c == oNewPTL_c.Blocking_Delivery_ADV__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c = oNewPTL_c.Blocking_Delivery_ADV__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Blocking_Delivery_ADV__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c] to [' + String.valueOf(oNewPTL_c.Blocking_Delivery_ADV__c) + ']');
                } else {
                    if (oOldPTL_c.Blocking_Delivery_ADV__c == oNewPTL_c.Blocking_Delivery_ADV__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c != oOldPTL_c.Blocking_Delivery_ADV__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Blocking_Delivery_ADV__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Blocking_Delivery_ADV__c) + '])');
                    }
            }
            if ((oOldPTL_c.Blocking_Delivery_General__c != oNewPTL_c.Blocking_Delivery_General__c) && ((oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c == oOldPTL_c.Blocking_Delivery_General__c) || (oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c == oNewPTL_c.Blocking_Delivery_General__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c = oNewPTL_c.Blocking_Delivery_General__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Blocking_Delivery_General__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c] to [' + String.valueOf(oNewPTL_c.Blocking_Delivery_General__c) + ']');
                } else {
                    if (oOldPTL_c.Blocking_Delivery_General__c == oNewPTL_c.Blocking_Delivery_General__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c != oOldPTL_c.Blocking_Delivery_General__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Blocking_Delivery_General__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Blocking_Delivery_General__c) + '])');
                    }
            }
            if ((oOldPTL_c.City_Postal_Code__c != oNewPTL_c.City_Postal_Code__c) && ((oOpportunity_PTL_c.PTL_City_Postal_Code__c == oOldPTL_c.City_Postal_Code__c) || (oOpportunity_PTL_c.PTL_City_Postal_Code__c == oNewPTL_c.City_Postal_Code__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_City_Postal_Code__c = oNewPTL_c.City_Postal_Code__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_City_Postal_Code__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_City_Postal_Code__c] to [' + String.valueOf(oNewPTL_c.City_Postal_Code__c) + ']');
                } else {
                    if (oOldPTL_c.City_Postal_Code__c == oNewPTL_c.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_City_Postal_Code__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_City_Postal_Code__c != oOldPTL_c.City_Postal_Code__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_City_Postal_Code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.City_Postal_Code__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_City_Postal_Code__c) + '])');
                    }
            }
            if ((oOldPTL_c.City__c != oNewPTL_c.City__c) && ((oOpportunity_PTL_c.PTL_City__c == oOldPTL_c.City__c) || (oOpportunity_PTL_c.PTL_City__c == oNewPTL_c.City__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_City__c = oNewPTL_c.City__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_City__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_City__c] to [' + String.valueOf(oNewPTL_c.City__c) + ']');
                } else {
                    if (oOldPTL_c.City__c == oNewPTL_c.City__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_City__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_City__c != oOldPTL_c.City__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_City__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.City__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_City__c) + '])');
                    }
            }
            if ((oOldPTL_c.City_code__c != oNewPTL_c.City_code__c) && ((oOpportunity_PTL_c.PTL_City_code__c == oOldPTL_c.City_code__c) || (oOpportunity_PTL_c.PTL_City_code__c == oNewPTL_c.City_code__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_City_code__c = oNewPTL_c.City_code__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_City_code__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_City_code__c] to [' + String.valueOf(oNewPTL_c.City_code__c) + ']');
                } else {
                    if (oOldPTL_c.City_code__c == oNewPTL_c.City_code__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_City_code__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_City_code__c != oOldPTL_c.City_code__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_City_code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.City_code__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_City_code__c) + '])');
                    }
            }
            /*if ((oOldPTL_c.Code_AC_administrator__c != oNewPTL_c.Code_AC_administrator__c) && ((oOpportunity_PTL_c.PTL_Code_AC_administrator__c == oOldPTL_c.Code_AC_administrator__c) || (oOpportunity_PTL_c.PTL_Code_AC_administrator__c == oNewPTL_c.Code_AC_administrator__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_AC_administrator__c = oNewPTL_c.Code_AC_administrator__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_AC_administrator__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_AC_administrator__c] to [' + String.valueOf(oNewPTL_c.Code_AC_administrator__c) + ']');
                } else {
                    if (oOldPTL_c.Code_AC_administrator__c == oNewPTL_c.Code_AC_administrator__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_AC_administrator__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_AC_administrator__c != oOldPTL_c.Code_AC_administrator__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_AC_administrator__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_AC_administrator__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_AC_administrator__c) + '])');
                    }
            }
            if ((oOldPTL_c.Code_AC_administrator_value__c != oNewPTL_c.Code_AC_administrator_value__c) && ((oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c == oOldPTL_c.Code_AC_administrator_value__c) || (oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c == oNewPTL_c.Code_AC_administrator_value__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c = oNewPTL_c.Code_AC_administrator_value__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_AC_administrator_value__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c] to [' + String.valueOf(oNewPTL_c.Code_AC_administrator_value__c) + ']');
                } else {
                    if (oOldPTL_c.Code_AC_administrator_value__c == oNewPTL_c.Code_AC_administrator_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c != oOldPTL_c.Code_AC_administrator_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_AC_administrator_value__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_AC_administrator_value__c) + '])');
                    }
            }*/
            if ((oOldPTL_c.Code_AC_administrator_New__c != oNewPTL_c.Code_AC_administrator_New__c) && ((oOpportunity_PTL_c.Code_AC_administrator_New__c == oOldPTL_c.Code_AC_administrator_New__c) || (oOpportunity_PTL_c.Code_AC_administrator_New__c == oNewPTL_c.Code_AC_administrator_New__c))){
                    status = true;
                    oOpportunity_PTL_c.Code_AC_administrator_New__c = oNewPTL_c.Code_AC_administrator_New__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Code_AC_administrator_New__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Code_AC_administrator_New__c] to [' + String.valueOf(oNewPTL_c.Code_AC_administrator_New__c) + ']');
                } else {
                    if (oOldPTL_c.Code_AC_administrator_New__c == oNewPTL_c.Code_AC_administrator_New__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Code_AC_administrator_New__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Code_AC_administrator_New__c != oOldPTL_c.Code_AC_administrator_New__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Code_AC_administrator_New__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_AC_administrator_New__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Code_AC_administrator_New__c) + '])');
                    }
            }
            if ((oOldPTL_c.Code_NACE__c != oNewPTL_c.Code_NACE__c) && ((oOpportunity_PTL_c.PTL_Code_NACE__c == oOldPTL_c.Code_NACE__c) || (oOpportunity_PTL_c.PTL_Code_NACE__c == oNewPTL_c.Code_NACE__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_NACE__c = oNewPTL_c.Code_NACE__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_NACE__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_NACE__c] to [' + String.valueOf(oNewPTL_c.Code_NACE__c) + ']');
                } else {
                    if (oOldPTL_c.Code_NACE__c == oNewPTL_c.Code_NACE__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_NACE__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_NACE__c != oOldPTL_c.Code_NACE__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_NACE__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_NACE__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_NACE__c) + '])');
                    }
            }
            /*if ((oOldPTL_c.Code_NACE_value__c != oNewPTL_c.Code_NACE_value__c) && ((oOpportunity_PTL_c.PTL_Code_NACE_value__c == oOldPTL_c.Code_NACE_value__c) || (oOpportunity_PTL_c.PTL_Code_NACE_value__c == oNewPTL_c.Code_NACE_value__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_NACE_value__c = oNewPTL_c.Code_NACE_value__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_NACE_value__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_NACE_value__c] to [' + String.valueOf(oNewPTL_c.Code_NACE_value__c) + ']');
                } else {
                    if (oOldPTL_c.Code_NACE_value__c == oNewPTL_c.Code_NACE_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_NACE_value__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_NACE_value__c != oOldPTL_c.Code_NACE_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_NACE_value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_NACE_value__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_NACE_value__c) + '])');
                    }
            }*/
            if ((oOldPTL_c.Code_NAF__c != oNewPTL_c.Code_NAF__c) && ((oOpportunity_PTL_c.PTL_Code_NAF__c == oOldPTL_c.Code_NAF__c) || (oOpportunity_PTL_c.PTL_Code_NAF__c == oNewPTL_c.Code_NAF__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_NAF__c = oNewPTL_c.Code_NAF__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_NAF__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_NAF__c] to [' + String.valueOf(oNewPTL_c.Code_NAF__c) + ']');
                } else {
                    if (oOldPTL_c.Code_NAF__c == oNewPTL_c.Code_NAF__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_NAF__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_NAF__c != oOldPTL_c.Code_NAF__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_NAF__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_NAF__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_NAF__c) + '])');
                    }
            }
            if ((oOldPTL_c.Code_branche__c != oNewPTL_c.Code_branche__c) && ((oOpportunity_PTL_c.PTL_Code_branche__c == oOldPTL_c.Code_branche__c) || (oOpportunity_PTL_c.PTL_Code_branche__c == oNewPTL_c.Code_branche__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_branche__c = oNewPTL_c.Code_branche__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_branche__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_branche__c] to [' + String.valueOf(oNewPTL_c.Code_branche__c) + ']');
                } else {
                    if (oOldPTL_c.Code_branche__c == oNewPTL_c.Code_branche__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_branche__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_branche__c != oOldPTL_c.Code_branche__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_branche__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_branche__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_branche__c) + '])');
                    }
            }
            if ((oOldPTL_c.Code_branche_value__c != oNewPTL_c.Code_branche_value__c) && ((oOpportunity_PTL_c.PTL_Code_branche_value__c == oOldPTL_c.Code_branche_value__c) || (oOpportunity_PTL_c.PTL_Code_branche_value__c == oNewPTL_c.Code_branche_value__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_branche_value__c = oNewPTL_c.Code_branche_value__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_branche_value__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_branche_value__c] to [' + String.valueOf(oNewPTL_c.Code_branche_value__c) + ']');
                } else {
                    if (oOldPTL_c.Code_branche_value__c == oNewPTL_c.Code_branche_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_branche_value__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_branche_value__c != oOldPTL_c.Code_branche_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_branche_value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_branche_value__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_branche_value__c) + '])');
                    }
            }
            if ((oOldPTL_c.Code_division__c != oNewPTL_c.Code_division__c) && ((oOpportunity_PTL_c.PTL_Code_division__c == oOldPTL_c.Code_division__c) || (oOpportunity_PTL_c.PTL_Code_division__c == oNewPTL_c.Code_division__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_division__c = oNewPTL_c.Code_division__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_division__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_division__c] to [' + String.valueOf(oNewPTL_c.Code_division__c) + ']');
                } else {
                    if (oOldPTL_c.Code_division__c == oNewPTL_c.Code_division__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_division__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_division__c != oOldPTL_c.Code_division__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_division__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_division__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_division__c) + '])');
                    }
            }
            if ((oOldPTL_c.Code_division_value__c != oNewPTL_c.Code_division_value__c) && ((oOpportunity_PTL_c.PTL_Code_division_value__c == oOldPTL_c.Code_division_value__c) || (oOpportunity_PTL_c.PTL_Code_division_value__c == oNewPTL_c.Code_division_value__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Code_division_value__c = oNewPTL_c.Code_division_value__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Code_division_value__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Code_division_value__c] to [' + String.valueOf(oNewPTL_c.Code_division_value__c) + ']');
                } else {
                    if (oOldPTL_c.Code_division_value__c == oNewPTL_c.Code_division_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_division_value__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Code_division_value__c != oOldPTL_c.Code_division_value__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Code_division_value__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Code_division_value__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Code_division_value__c) + '])');
                    }
            }
            if ((oOldPTL_c.Country__c != oNewPTL_c.Country__c) && ((oOpportunity_PTL_c.PTL_Country__c == oOldPTL_c.Country__c) || (oOpportunity_PTL_c.PTL_Country__c == oNewPTL_c.Country__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Country__c = oNewPTL_c.Country__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Country__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Country__c] to [' + String.valueOf(oNewPTL_c.Country__c) + ']');
                } else {
                    if (oOldPTL_c.Country__c == oNewPTL_c.Country__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Country__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Country__c != oOldPTL_c.Country__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Country__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Country__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Country__c) + '])');
                    }
            }
            if ((oOldPTL_c.Customer_presence__c != oNewPTL_c.Customer_presence__c) && ((oOpportunity_PTL_c.PTL_Customer_presence__c == oOldPTL_c.Customer_presence__c) || (oOpportunity_PTL_c.PTL_Customer_presence__c == oNewPTL_c.Customer_presence__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Customer_presence__c = oNewPTL_c.Customer_presence__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Customer_presence__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Customer_presence__c] to [' + String.valueOf(oNewPTL_c.Customer_presence__c) + ']');
                } else {
                    if (oOldPTL_c.Customer_presence__c == oNewPTL_c.Customer_presence__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Customer_presence__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Customer_presence__c != oOldPTL_c.Customer_presence__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Customer_presence__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Customer_presence__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Customer_presence__c) + '])');
                    }
            }
            if ((oOldPTL_c.Date_Connecting__c != oNewPTL_c.Date_Connecting__c) && ((oOpportunity_PTL_c.PTL_Date_Connecting__c == oOldPTL_c.Date_Connecting__c) || (oOpportunity_PTL_c.PTL_Date_Connecting__c == oNewPTL_c.Date_Connecting__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Date_Connecting__c = oNewPTL_c.Date_Connecting__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Date_Connecting__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Date_Connecting__c] to [' + String.valueOf(oNewPTL_c.Date_Connecting__c) + ']');
                } else {
                    if (oOldPTL_c.Date_Connecting__c == oNewPTL_c.Date_Connecting__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Date_Connecting__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Date_Connecting__c != oOldPTL_c.Date_Connecting__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Date_Connecting__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Date_Connecting__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Date_Connecting__c) + '])');
                    }
            }
            if ((oOldPTL_c.Date_at_the_End_of_Dispensation__c != oNewPTL_c.Date_at_the_End_of_Dispensation__c) && ((oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c == oOldPTL_c.Date_at_the_End_of_Dispensation__c) || (oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c == oNewPTL_c.Date_at_the_End_of_Dispensation__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c = oNewPTL_c.Date_at_the_End_of_Dispensation__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Date_at_the_End_of_Dispensation__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c] to [' + String.valueOf(oNewPTL_c.Date_at_the_End_of_Dispensation__c) + ']');
                } else {
                    if (oOldPTL_c.Date_at_the_End_of_Dispensation__c == oNewPTL_c.Date_at_the_End_of_Dispensation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c != oOldPTL_c.Date_at_the_End_of_Dispensation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Date_at_the_End_of_Dispensation__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Date_at_the_End_of_Dispensation__c) + '])');
                    }
            }
            if ((oOldPTL_c.Seasonal_Date_of_Period_End__c != oNewPTL_c.Seasonal_Date_of_Period_End__c) && ((oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c == oOldPTL_c.Seasonal_Date_of_Period_End__c) || (oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c == oNewPTL_c.Seasonal_Date_of_Period_End__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c = oNewPTL_c.Seasonal_Date_of_Period_End__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Seasonal_Date_of_Period_End__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c] to [' + String.valueOf(oNewPTL_c.Seasonal_Date_of_Period_End__c) + ']');
                } else {
                    if (oOldPTL_c.Seasonal_Date_of_Period_End__c == oNewPTL_c.Seasonal_Date_of_Period_End__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c != oOldPTL_c.Seasonal_Date_of_Period_End__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Seasonal_Date_of_Period_End__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_End__c) + '])');
                    }
            }
            if ((oOldPTL_c.Seasonal_Date_of_Period_Start__c != oNewPTL_c.Seasonal_Date_of_Period_Start__c) && ((oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c == oOldPTL_c.Seasonal_Date_of_Period_Start__c) || (oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c == oNewPTL_c.Seasonal_Date_of_Period_Start__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c = oNewPTL_c.Seasonal_Date_of_Period_Start__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Seasonal_Date_of_Period_Start__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c] to [' + String.valueOf(oNewPTL_c.Seasonal_Date_of_Period_Start__c) + ']');
                } else {
                    if (oOldPTL_c.Seasonal_Date_of_Period_Start__c == oNewPTL_c.Seasonal_Date_of_Period_Start__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c != oOldPTL_c.Seasonal_Date_of_Period_Start__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Seasonal_Date_of_Period_Start__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Seasonal_Date_of_Period_Start__c) + '])');
                    }
            }
            if ((oOldPTL_c.Delivery_possible_in_absence_of_client__c != oNewPTL_c.Delivery_possible_in_absence_of_client__c) && ((oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c == string.valueof(oOldPTL_c.Delivery_possible_in_absence_of_client__c)) || (oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c == string.valueof(oNewPTL_c.Delivery_possible_in_absence_of_client__c)))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c = string.valueof(oNewPTL_c.Delivery_possible_in_absence_of_client__c);
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Delivery_possible_in_absence_of_clie__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c] to [' + String.valueOf(oNewPTL_c.Delivery_possible_in_absence_of_client__c) + ']');
                } else {
                    if (oOldPTL_c.Delivery_possible_in_absence_of_client__c == oNewPTL_c.Delivery_possible_in_absence_of_client__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c != string.valueof(oOldPTL_c.Delivery_possible_in_absence_of_client__c)) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Delivery_possible_in_absence_of_client__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Delivery_possible_in_absence_of_clie__c) + '])');
                    }
            }
            if ((oOldPTL_c.Department__c != oNewPTL_c.Department__c) && ((oOpportunity_PTL_c.PTL_Department__c == oOldPTL_c.Department__c) || (oOpportunity_PTL_c.PTL_Department__c == oNewPTL_c.Department__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Department__c = oNewPTL_c.Department__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Department__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Department__c] to [' + String.valueOf(oNewPTL_c.Department__c) + ']');
                } else {
                    if (oOldPTL_c.Department__c == oNewPTL_c.Department__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Department__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Department__c != oOldPTL_c.Department__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Department__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Department__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Department__c) + '])');
                    }
            }
            if ((oOldPTL_c.E_mail__c != oNewPTL_c.E_mail__c) && ((oOpportunity_PTL_c.PTL_E_mail__c == oOldPTL_c.E_mail__c) || (oOpportunity_PTL_c.PTL_E_mail__c == oNewPTL_c.E_mail__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_E_mail__c = oNewPTL_c.E_mail__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_E_mail__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_E_mail__c] to [' + String.valueOf(oNewPTL_c.E_mail__c) + ']');
                } else {
                    if (oOldPTL_c.E_mail__c == oNewPTL_c.E_mail__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_E_mail__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_E_mail__c != oOldPTL_c.E_mail__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_E_mail__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.E_mail__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_E_mail__c) + '])');
                    }
            }
            if ((oOldPTL_c.Estimated_or_Real_Capacity__c != oNewPTL_c.Estimated_or_Real_Capacity__c) && ((oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c == oOldPTL_c.Estimated_or_Real_Capacity__c) || (oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c == oNewPTL_c.Estimated_or_Real_Capacity__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c = oNewPTL_c.Estimated_or_Real_Capacity__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Estimated_or_Real_Capacity__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c] to [' + String.valueOf(oNewPTL_c.Estimated_or_Real_Capacity__c) + ']');
                } else {
                    if (oOldPTL_c.Estimated_or_Real_Capacity__c == oNewPTL_c.Estimated_or_Real_Capacity__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c != oOldPTL_c.Estimated_or_Real_Capacity__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Estimated_or_Real_Capacity__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Estimated_or_Real_Capacity__c) + '])');
                    }
            }
            if ((oOldPTL_c.Etimated_or_Real_Consumption__c != oNewPTL_c.Etimated_or_Real_Consumption__c) && ((oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c == oOldPTL_c.Etimated_or_Real_Consumption__c) || (oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c == oNewPTL_c.Etimated_or_Real_Consumption__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c = oNewPTL_c.Etimated_or_Real_Consumption__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Etimated_or_Real_Consumption__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c] to [' + String.valueOf(oNewPTL_c.Etimated_or_Real_Consumption__c) + ']');
                } else {
                    if (oOldPTL_c.Etimated_or_Real_Consumption__c == oNewPTL_c.Etimated_or_Real_Consumption__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c != oOldPTL_c.Etimated_or_Real_Consumption__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Etimated_or_Real_Consumption__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Etimated_or_Real_Consumption__c) + '])');
                    }
            }
            if ((oOldPTL_c.Fax_Number__c != oNewPTL_c.Fax_Number__c) && ((oOpportunity_PTL_c.PTL_Fax_Number__c == oOldPTL_c.Fax_Number__c) || (oOpportunity_PTL_c.PTL_Fax_Number__c == oNewPTL_c.Fax_Number__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Fax_Number__c = oNewPTL_c.Fax_Number__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Fax_Number__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Fax_Number__c] to [' + String.valueOf(oNewPTL_c.Fax_Number__c) + ']');
                } else {
                    if (oOldPTL_c.Fax_Number__c == oNewPTL_c.Fax_Number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Fax_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Fax_Number__c != oOldPTL_c.Fax_Number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Fax_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Fax_Number__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Fax_Number__c) + '])');
                    }
            }
            if ((oOldPTL_c.First_and_Last_Name__c != oNewPTL_c.First_and_Last_Name__c) && ((oOpportunity_PTL_c.PTL_First_and_Last_Name__c == oOldPTL_c.First_and_Last_Name__c) || (oOpportunity_PTL_c.PTL_First_and_Last_Name__c == oNewPTL_c.First_and_Last_Name__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_First_and_Last_Name__c = oNewPTL_c.First_and_Last_Name__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_First_and_Last_Name__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_First_and_Last_Name__c] to [' + String.valueOf(oNewPTL_c.First_and_Last_Name__c) + ']');
                } else {
                    if (oOldPTL_c.First_and_Last_Name__c == oNewPTL_c.First_and_Last_Name__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_First_and_Last_Name__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_First_and_Last_Name__c != oOldPTL_c.First_and_Last_Name__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_First_and_Last_Name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.First_and_Last_Name__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_First_and_Last_Name__c) + '])');
                    }
            }
            if ((oOldPTL_c.Gal_deletion_flag__c != oNewPTL_c.Gal_deletion_flag__c) && ((oOpportunity_PTL_c.PTL_Gal_deletion_flag__c == oOldPTL_c.Gal_deletion_flag__c) || (oOpportunity_PTL_c.PTL_Gal_deletion_flag__c == oNewPTL_c.Gal_deletion_flag__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Gal_deletion_flag__c = oNewPTL_c.Gal_deletion_flag__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Gal_deletion_flag__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Gal_deletion_flag__c] to [' + String.valueOf(oNewPTL_c.Gal_deletion_flag__c) + ']');
                } else {
                    if (oOldPTL_c.Gal_deletion_flag__c == oNewPTL_c.Gal_deletion_flag__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Gal_deletion_flag__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Gal_deletion_flag__c != oOldPTL_c.Gal_deletion_flag__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Gal_deletion_flag__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Gal_deletion_flag__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Gal_deletion_flag__c) + '])');
                    }
            }
            if ((oOldPTL_c.Gasdeliverymode__c != oNewPTL_c.Gasdeliverymode__c) && ((oOpportunity_PTL_c.PTL_Gasdeliverymode__c == oOldPTL_c.Gasdeliverymode__c) || (oOpportunity_PTL_c.PTL_Gasdeliverymode__c == oNewPTL_c.Gasdeliverymode__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Gasdeliverymode__c = oNewPTL_c.Gasdeliverymode__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Gasdeliverymode__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Gasdeliverymode__c] to [' + String.valueOf(oNewPTL_c.Gasdeliverymode__c) + ']');
                } else {
                    if (oOldPTL_c.Gasdeliverymode__c == oNewPTL_c.Gasdeliverymode__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Gasdeliverymode__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Gasdeliverymode__c != oOldPTL_c.Gasdeliverymode__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Gasdeliverymode__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Gasdeliverymode__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Gasdeliverymode__c) + '])');
                    }
            }
            if ((oOldPTL_c.Label__c != oNewPTL_c.Label__c) && ((oOpportunity_PTL_c.PTL_Label__c == oOldPTL_c.Label__c) || (oOpportunity_PTL_c.PTL_Label__c == oNewPTL_c.Label__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Label__c = oNewPTL_c.Label__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Label__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Label__c] to [' + String.valueOf(oNewPTL_c.Label__c) + ']');
                } else {
                    if (oOldPTL_c.Label__c == oNewPTL_c.Label__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Label__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Label__c != oOldPTL_c.Label__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Label__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Label__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Label__c) + '])');
                    }
            }
            if ((oOldPTL_c.Limitation_of_Tonnage__c != oNewPTL_c.Limitation_of_Tonnage__c) && ((oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c == oOldPTL_c.Limitation_of_Tonnage__c) || (oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c == oNewPTL_c.Limitation_of_Tonnage__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c = oNewPTL_c.Limitation_of_Tonnage__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Limitation_of_Tonnage__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c] to [' + String.valueOf(oNewPTL_c.Limitation_of_Tonnage__c) + ']');
                } else {
                    if (oOldPTL_c.Limitation_of_Tonnage__c == oNewPTL_c.Limitation_of_Tonnage__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c != oOldPTL_c.Limitation_of_Tonnage__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Limitation_of_Tonnage__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Limitation_of_Tonnage__c) + '])');
                    }
            }
            if ((oOldPTL_c.Limitation_of_Vehicle__c != oNewPTL_c.Limitation_of_Vehicle__c) && ((oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c == oOldPTL_c.Limitation_of_Vehicle__c) || (oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c == oNewPTL_c.Limitation_of_Vehicle__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c = oNewPTL_c.Limitation_of_Vehicle__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Limitation_of_Vehicle__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c] to [' + String.valueOf(oNewPTL_c.Limitation_of_Vehicle__c) + ']');
                } else {
                    if (oOldPTL_c.Limitation_of_Vehicle__c == oNewPTL_c.Limitation_of_Vehicle__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c != oOldPTL_c.Limitation_of_Vehicle__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Limitation_of_Vehicle__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Limitation_of_Vehicle__c) + '])');
                    }
            }
            if ((oOldPTL_c.Mandataire__c != oNewPTL_c.Mandataire__c) && ((oOpportunity_PTL_c.PTL_Mandataire__c == oOldPTL_c.Mandataire__c) || (oOpportunity_PTL_c.PTL_Mandataire__c == oNewPTL_c.Mandataire__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Mandataire__c = oNewPTL_c.Mandataire__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Mandataire__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Mandataire__c] to [' + String.valueOf(oNewPTL_c.Mandataire__c) + ']');
                } else {
                    if (oOldPTL_c.Mandataire__c == oNewPTL_c.Mandataire__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Mandataire__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Mandataire__c != oOldPTL_c.Mandataire__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Mandataire__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Mandataire__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Mandataire__c) + '])');
                    }
            }
            if ((oOldPTL_c.Market_Sub_Type__c != oNewPTL_c.Market_Sub_Type__c) && ((oOpportunity_PTL_c.PTL_Market_Sub_Type__c == oOldPTL_c.Market_Sub_Type__c) || (oOpportunity_PTL_c.PTL_Market_Sub_Type__c == oNewPTL_c.Market_Sub_Type__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Market_Sub_Type__c = oNewPTL_c.Market_Sub_Type__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Market_Sub_Type__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Market_Sub_Type__c] to [' + String.valueOf(oNewPTL_c.Market_Sub_Type__c) + ']');
                } else {
                    if (oOldPTL_c.Market_Sub_Type__c == oNewPTL_c.Market_Sub_Type__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Market_Sub_Type__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Market_Sub_Type__c != oOldPTL_c.Market_Sub_Type__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Market_Sub_Type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Market_Sub_Type__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Market_Sub_Type__c) + '])');
                    }
            }
            if ((oOldPTL_c.Market_type__c != oNewPTL_c.Market_type__c) && ((oOpportunity_PTL_c.PTL_Market_type__c == oOldPTL_c.Market_type__c) || (oOpportunity_PTL_c.PTL_Market_type__c == oNewPTL_c.Market_type__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Market_type__c = oNewPTL_c.Market_type__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Market_type__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Market_type__c] to [' + String.valueOf(oNewPTL_c.Market_type__c) + ']');
                } else {
                    if (oOldPTL_c.Market_type__c == oNewPTL_c.Market_type__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Market_type__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Market_type__c != oOldPTL_c.Market_type__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Market_type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Market_type__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Market_type__c) + '])');
                    }
            }
            if ((oOldPTL_c.Mobile_Phone_Number__c != oNewPTL_c.Mobile_Phone_Number__c) && ((oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c == oOldPTL_c.Mobile_Phone_Number__c) || (oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c == oNewPTL_c.Mobile_Phone_Number__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c = oNewPTL_c.Mobile_Phone_Number__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Mobile_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c] to [' + String.valueOf(oNewPTL_c.Mobile_Phone_Number__c) + ']');
                } else {
                    if (oOldPTL_c.Mobile_Phone_Number__c == oNewPTL_c.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c != oOldPTL_c.Mobile_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Mobile_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Mobile_Phone_Number__c) + '])');
                    }
            }
            if ((oOldPTL_c.Number_extention__c != oNewPTL_c.Number_extention__c) && ((oOpportunity_PTL_c.PTL_Number_extention__c == oOldPTL_c.Number_extention__c) || (oOpportunity_PTL_c.PTL_Number_extention__c == oNewPTL_c.Number_extention__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Number_extention__c = oNewPTL_c.Number_extention__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Number_extention__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Number_extention__c] to [' + String.valueOf(oNewPTL_c.Number_extention__c) + ']');
                } else {
                    if (oOldPTL_c.Number_extention__c == oNewPTL_c.Number_extention__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Number_extention__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Number_extention__c != oOldPTL_c.Number_extention__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Number_extention__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Number_extention__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Number_extention__c) + '])');
                    }
            }
            if ((oOldPTL_c.Payment_Delay__c != oNewPTL_c.Payment_Delay__c) && ((oOpportunity_PTL_c.PTL_Payment_Delay__c == oOldPTL_c.Payment_Delay__c) || (oOpportunity_PTL_c.PTL_Payment_Delay__c == oNewPTL_c.Payment_Delay__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Payment_Delay__c = oNewPTL_c.Payment_Delay__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Payment_Delay__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Payment_Delay__c] to [' + String.valueOf(oNewPTL_c.Payment_Delay__c) + ']');
                } else {
                    if (oOldPTL_c.Payment_Delay__c == oNewPTL_c.Payment_Delay__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Payment_Delay__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Payment_Delay__c != oOldPTL_c.Payment_Delay__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Payment_Delay__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Payment_Delay__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Payment_Delay__c) + '])');
                    }
            }
            if ((oOldPTL_c.Period_Frequency__c != oNewPTL_c.Period_Frequency__c) && ((oOpportunity_PTL_c.PTL_Period_Frequency__c == oOldPTL_c.Period_Frequency__c) || (oOpportunity_PTL_c.PTL_Period_Frequency__c == oNewPTL_c.Period_Frequency__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Period_Frequency__c = oNewPTL_c.Period_Frequency__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Period_Frequency__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Period_Frequency__c] to [' + String.valueOf(oNewPTL_c.Period_Frequency__c) + ']');
                } else {
                    if (oOldPTL_c.Period_Frequency__c == oNewPTL_c.Period_Frequency__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Period_Frequency__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Period_Frequency__c != oOldPTL_c.Period_Frequency__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Period_Frequency__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Period_Frequency__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Period_Frequency__c) + '])');
                    }
            }
            if ((oOldPTL_c.Permanent_dispensation__c != oNewPTL_c.Permanent_dispensation__c) && ((oOpportunity_PTL_c.PTL_Permanent_dispensation__c == oOldPTL_c.Permanent_dispensation__c) || (oOpportunity_PTL_c.PTL_Permanent_dispensation__c == oNewPTL_c.Permanent_dispensation__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Permanent_dispensation__c = oNewPTL_c.Permanent_dispensation__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Permanent_dispensation__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Permanent_dispensation__c] to [' + String.valueOf(oNewPTL_c.Permanent_dispensation__c) + ']');
                } else {
                    if (oOldPTL_c.Permanent_dispensation__c == oNewPTL_c.Permanent_dispensation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Permanent_dispensation__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Permanent_dispensation__c != oOldPTL_c.Permanent_dispensation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Permanent_dispensation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Permanent_dispensation__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Permanent_dispensation__c) + '])');
                    }
            }
            if ((oOldPTL_c.Phone__c != oNewPTL_c.Phone__c) && ((oOpportunity_PTL_c.PTL_Phone__c == oOldPTL_c.Phone__c) || (oOpportunity_PTL_c.PTL_Phone__c == oNewPTL_c.Phone__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Phone__c = oNewPTL_c.Phone__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Phone__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Phone__c] to [' + String.valueOf(oNewPTL_c.Phone__c) + ']');
                } else {
                    if (oOldPTL_c.Phone__c == oNewPTL_c.Phone__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Phone__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Phone__c != oOldPTL_c.Phone__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Phone__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Phone__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Phone__c) + '])');
                    }
            }
            if ((oOldPTL_c.Place_Called__c != oNewPTL_c.Place_Called__c) && ((oOpportunity_PTL_c.PTL_Place_Called__c == oOldPTL_c.Place_Called__c) || (oOpportunity_PTL_c.PTL_Place_Called__c == oNewPTL_c.Place_Called__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Place_Called__c = oNewPTL_c.Place_Called__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Place_Called__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Place_Called__c] to [' + String.valueOf(oNewPTL_c.Place_Called__c) + ']');
                } else {
                    if (oOldPTL_c.Place_Called__c == oNewPTL_c.Place_Called__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Place_Called__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Place_Called__c != oOldPTL_c.Place_Called__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Place_Called__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Place_Called__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Place_Called__c) + '])');
                    }
            }
            if ((oOldPTL_c.Postal_Box__c != oNewPTL_c.Postal_Box__c) && ((oOpportunity_PTL_c.PTL_Postal_Box__c == oOldPTL_c.Postal_Box__c) || (oOpportunity_PTL_c.PTL_Postal_Box__c == oNewPTL_c.Postal_Box__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Postal_Box__c = oNewPTL_c.Postal_Box__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Postal_Box__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Postal_Box__c] to [' + String.valueOf(oNewPTL_c.Postal_Box__c) + ']');
                } else {
                    if (oOldPTL_c.Postal_Box__c == oNewPTL_c.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Postal_Box__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Postal_Box__c != oOldPTL_c.Postal_Box__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Postal_Box__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Postal_Box__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Postal_Box__c) + '])');
                    }
            }
            if ((oOldPTL_c.Postal_code__c != oNewPTL_c.Postal_code__c) && ((oOpportunity_PTL_c.PTL_Postal_code__c == oOldPTL_c.Postal_code__c) || (oOpportunity_PTL_c.PTL_Postal_code__c == oNewPTL_c.Postal_code__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Postal_code__c = oNewPTL_c.Postal_code__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Postal_code__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Postal_code__c] to [' + String.valueOf(oNewPTL_c.Postal_code__c) + ']');
                } else {
                    if (oOldPTL_c.Postal_code__c == oNewPTL_c.Postal_code__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Postal_code__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Postal_code__c != oOldPTL_c.Postal_code__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Postal_code__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Postal_code__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Postal_code__c) + '])');
                    }
            }
            if ((oOldPTL_c.Scale__c != oNewPTL_c.Scale__c) && ((oOpportunity_PTL_c.PTL_Scale__c == oOldPTL_c.Scale__c) || (oOpportunity_PTL_c.PTL_Scale__c == oNewPTL_c.Scale__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Scale__c = oNewPTL_c.Scale__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Scale__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Scale__c] to [' + String.valueOf(oNewPTL_c.Scale__c) + ']');
                } else {
                    if (oOldPTL_c.Scale__c == oNewPTL_c.Scale__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Scale__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Scale__c != oOldPTL_c.Scale__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Scale__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Scale__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Scale__c) + '])');
                    }
            }
            if ((oOldPTL_c.Shipping_Condition__c != oNewPTL_c.Shipping_Condition__c) && ((oOpportunity_PTL_c.PTL_Shipping_Condition__c == oOldPTL_c.Shipping_Condition__c) || (oOpportunity_PTL_c.PTL_Shipping_Condition__c == oNewPTL_c.Shipping_Condition__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Shipping_Condition__c = oNewPTL_c.Shipping_Condition__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Shipping_Condition__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Shipping_Condition__c] to [' + String.valueOf(oNewPTL_c.Shipping_Condition__c) + ']');
                } else {
                    if (oOldPTL_c.Shipping_Condition__c == oNewPTL_c.Shipping_Condition__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Shipping_Condition__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Shipping_Condition__c != oOldPTL_c.Shipping_Condition__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Shipping_Condition__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Shipping_Condition__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Shipping_Condition__c) + '])');
                    }
            }
            if ((oOldPTL_c.Street_name__c != oNewPTL_c.Street_name__c) && ((oOpportunity_PTL_c.PTL_Street_name__c == oOldPTL_c.Street_name__c) || (oOpportunity_PTL_c.PTL_Street_name__c == oNewPTL_c.Street_name__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Street_name__c = oNewPTL_c.Street_name__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Street_name__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Street_name__c] to [' + String.valueOf(oNewPTL_c.Street_name__c) + ']');
                } else {
                    if (oOldPTL_c.Street_name__c == oNewPTL_c.Street_name__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Street_name__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Street_name__c != oOldPTL_c.Street_name__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Street_name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Street_name__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Street_name__c) + '])');
                    }
            }
            if ((oOldPTL_c.Street_number__c != oNewPTL_c.Street_number__c) && ((oOpportunity_PTL_c.PTL_Street_number__c == oOldPTL_c.Street_number__c) || (oOpportunity_PTL_c.PTL_Street_number__c == oNewPTL_c.Street_number__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Street_number__c = oNewPTL_c.Street_number__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Street_number__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Street_number__c] to [' + String.valueOf(oNewPTL_c.Street_number__c) + ']');
                } else {
                    if (oOldPTL_c.Street_number__c == oNewPTL_c.Street_number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Street_number__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Street_number__c != oOldPTL_c.Street_number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Street_number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Street_number__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Street_number__c) + '])');
                    }
            }
            if ((oOldPTL_c.Street_type__c != oNewPTL_c.Street_type__c) && ((oOpportunity_PTL_c.PTL_Street_type__c == oOldPTL_c.Street_type__c) || (oOpportunity_PTL_c.PTL_Street_type__c == oNewPTL_c.Street_type__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Street_type__c = oNewPTL_c.Street_type__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Street_type__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Street_type__c] to [' + String.valueOf(oNewPTL_c.Street_type__c) + ']');
                } else {
                    if (oOldPTL_c.Street_type__c == oNewPTL_c.Street_type__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Street_type__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Street_type__c != oOldPTL_c.Street_type__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Street_type__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Street_type__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Street_type__c) + '])');
                    }
            }
            if ((oOldPTL_c.Temporary_dispensation__c != oNewPTL_c.Temporary_dispensation__c) && ((oOpportunity_PTL_c.PTL_Temporary_dispensation__c == oOldPTL_c.Temporary_dispensation__c) || (oOpportunity_PTL_c.PTL_Temporary_dispensation__c == oNewPTL_c.Temporary_dispensation__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Temporary_dispensation__c = oNewPTL_c.Temporary_dispensation__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Temporary_dispensation__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Temporary_dispensation__c] to [' + String.valueOf(oNewPTL_c.Temporary_dispensation__c) + ']');
                } else {
                    if (oOldPTL_c.Temporary_dispensation__c == oNewPTL_c.Temporary_dispensation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Temporary_dispensation__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Temporary_dispensation__c != oOldPTL_c.Temporary_dispensation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Temporary_dispensation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Temporary_dispensation__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Temporary_dispensation__c) + '])');
                    }
            }
            if ((oOldPTL_c.Title__c != oNewPTL_c.Title__c) && ((oOpportunity_PTL_c.PTL_Title__c == oOldPTL_c.Title__c) || (oOpportunity_PTL_c.PTL_Title__c == oNewPTL_c.Title__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Title__c = oNewPTL_c.Title__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Title__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Title__c] to [' + String.valueOf(oNewPTL_c.Title__c) + ']');
                } else {
                    if (oOldPTL_c.Title__c == oNewPTL_c.Title__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Title__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Title__c != oOldPTL_c.Title__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Title__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Title__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Title__c) + '])');
                    }
            }
            if ((oOldPTL_c.Value_added_tax_within_the_Community__c != oNewPTL_c.Value_added_tax_within_the_Community__c) && ((oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c == oOldPTL_c.Value_added_tax_within_the_Community__c) || (oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c == oNewPTL_c.Value_added_tax_within_the_Community__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c = oNewPTL_c.Value_added_tax_within_the_Community__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Value_added_tax_within_the_Community__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c] to [' + String.valueOf(oNewPTL_c.Value_added_tax_within_the_Community__c) + ']');
                } else {
                    if (oOldPTL_c.Value_added_tax_within_the_Community__c == oNewPTL_c.Value_added_tax_within_the_Community__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c != oOldPTL_c.Value_added_tax_within_the_Community__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Value_added_tax_within_the_Community__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Value_added_tax_within_the_Community__c) + '])');
                    }
            }
            if ((oOldPTL_c.Work_Phone_Number__c != oNewPTL_c.Work_Phone_Number__c) && ((oOpportunity_PTL_c.PTL_Work_Phone_Number__c == oOldPTL_c.Work_Phone_Number__c) || (oOpportunity_PTL_c.PTL_Work_Phone_Number__c == oNewPTL_c.Work_Phone_Number__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Work_Phone_Number__c = oNewPTL_c.Work_Phone_Number__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Work_Phone_Number__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Work_Phone_Number__c] to [' + String.valueOf(oNewPTL_c.Work_Phone_Number__c) + ']');
                } else {
                    if (oOldPTL_c.Work_Phone_Number__c == oNewPTL_c.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Work_Phone_Number__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Work_Phone_Number__c != oOldPTL_c.Work_Phone_Number__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Work_Phone_Number__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Work_Phone_Number__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Work_Phone_Number__c) + '])');
                    }
            }
            if ((oOldPTL_c.Name != oNewPTL_c.Name) && ((oOpportunity_PTL_c.PTL_Name__c == oOldPTL_c.Name) || (oOpportunity_PTL_c.PTL_Name__c == oNewPTL_c.Name))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Name__c = oNewPTL_c.Name;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Name__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Name__c] to [' + String.valueOf(oNewPTL_c.Name) + ']');
                } else {
                    if (oOldPTL_c.Name == oNewPTL_c.Name) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Name__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Name__c != oOldPTL_c.Name) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Name__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Name) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Name__c) + '])');
                    }
            }
                        
            if ((oOldPTL_c.PDF_Hours_of_delivery_not_possible__c != oNewPTL_c.PDF_Hours_of_delivery_not_possible__c) && ((oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c == oOldPTL_c.PDF_Hours_of_delivery_not_possible__c) || (oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c == oNewPTL_c.PDF_Hours_of_delivery_not_possible__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c = oNewPTL_c.PDF_Hours_of_delivery_not_possible__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Days_no_Delivery_possible__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c] to [' + String.valueOf(oNewPTL_c.PDF_Hours_of_delivery_not_possible__c) + ']');
                } else {
                    if (oOldPTL_c.PDF_Hours_of_delivery_not_possible__c == oNewPTL_c.PDF_Hours_of_delivery_not_possible__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c != oOldPTL_c.PDF_Hours_of_delivery_not_possible__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.PDF_Hours_of_delivery_not_possible__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_PDF_Hours_of_delivery_not_possible__c) + '])');
                    }
            }
            if ((oOldPTL_c.Precheck_Truck_needed__c != oNewPTL_c.Precheck_Truck_needed__c) && ((oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c == oOldPTL_c.Precheck_Truck_needed__c) || (oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c == oNewPTL_c.Precheck_Truck_needed__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c = oNewPTL_c.Precheck_Truck_needed__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Days_no_Delivery_possible__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c] to [' + String.valueOf(oNewPTL_c.Precheck_Truck_needed__c) + ']');
                } else {
                    if (oOldPTL_c.Precheck_Truck_needed__c == oNewPTL_c.Precheck_Truck_needed__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c != oOldPTL_c.Precheck_Truck_needed__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Precheck_Truck_needed__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Precheck_Truck_needed__c) + '])');
                    }
            }
            if ((oOldPTL_c.Days_no_Delivery_possible__c != oNewPTL_c.Days_no_Delivery_possible__c) && ((oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c == oOldPTL_c.Days_no_Delivery_possible__c) || (oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c == oNewPTL_c.Days_no_Delivery_possible__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c = oNewPTL_c.Days_no_Delivery_possible__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Days_no_Delivery_possible__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c] to [' + String.valueOf(oNewPTL_c.Days_no_Delivery_possible__c) + ']');
                } else {
                    if (oOldPTL_c.Days_no_Delivery_possible__c == oNewPTL_c.Days_no_Delivery_possible__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c != oOldPTL_c.Days_no_Delivery_possible__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Days_no_Delivery_possible__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Days_no_Delivery_possible__c) + '])');
                    }
            }
            
            
            // END_AUTO_PROPAGATE_PTL__r
        }
        return status;
    }
    
    // ELC 20160302 : Splitting the method because I reached an APEX limit :
    // Save error: A method was found with too much code.  Please consider splitting methods with a lot of code into multiple methods.
    public static Boolean propagatePTL_Fields_Part2(Opportunity_PTL__c oOpportunity_PTL_c, Map<Id, PTL__c> mOldPTL_cs, Map<Id, PTL__c> mNewPTL_cs){
        PTL__c oOldPTL_c = mOldPTL_cs.get(oOpportunity_PTL_c.PTL__c);
        PTL__c oNewPTL_c = mNewPTL_cs.get(oOpportunity_PTL_c.PTL__c);
        Boolean status    = false;
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] Starting.');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] oOldPTL_c:[' + oOldPTL_c + ']');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] oNewPTL_c:[' + oNewPTL_c + ']');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] oOpportunity_PTL_c:[' + oOpportunity_PTL_c + ']');
        if ((oOldPTL_c != null) && (oNewPTL_c != null)) { // that's equivalent. We're just checking whether the Opportunity_PTL__c had this specific PTL__c, PTL__c lookup updated
            // BEGIN_AUTO_PROPAGATE_PTL__r
            
            if ((oOldPTL_c.Client_ouvert_toute_l_annee__c != oNewPTL_c.Client_ouvert_toute_l_annee__c) && ((oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c == oOldPTL_c.Client_ouvert_toute_l_annee__c) || (oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c == oNewPTL_c.Client_ouvert_toute_l_annee__c))){
                    status = true;
                    oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c = oNewPTL_c.Client_ouvert_toute_l_annee__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Client_ouvert_toute_l_annee__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] Synced field [oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c] to [' + String.valueOf(oNewPTL_c.Client_ouvert_toute_l_annee__c) + ']');
                } else {
                    if (oOldPTL_c.Client_ouvert_toute_l_annee__c == oNewPTL_c.Client_ouvert_toute_l_annee__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] Skipped field [oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c != oOldPTL_c.Client_ouvert_toute_l_annee__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] Skipped field [oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Client_ouvert_toute_l_annee__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Client_ouvert_toute_l_annee__c) + '])');
                    }
            }
            if ((oOldPTL_c.Periode_de_fermeture_2_semaines__c != oNewPTL_c.Periode_de_fermeture_2_semaines__c) && ((oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c == oOldPTL_c.Periode_de_fermeture_2_semaines__c) || (oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c == oNewPTL_c.Periode_de_fermeture_2_semaines__c))){
                    status = true;
                    oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c = oNewPTL_c.Periode_de_fermeture_2_semaines__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Periode_de_fermeture_2_semaines__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] Synced field [oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c] to [' + String.valueOf(oNewPTL_c.Periode_de_fermeture_2_semaines__c) + ']');
                } else {
                    if (oOldPTL_c.Periode_de_fermeture_2_semaines__c == oNewPTL_c.Periode_de_fermeture_2_semaines__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] Skipped field [oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c != oOldPTL_c.Periode_de_fermeture_2_semaines__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part2] Skipped field [oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Periode_de_fermeture_2_semaines__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Periode_de_fermeture_2_semaines__c) + '])');
                    }
            }
            if ((oOldPTL_c.Periode_similaire_tous_les_ans__c != oNewPTL_c.Periode_similaire_tous_les_ans__c) && ((oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c == oOldPTL_c.Periode_similaire_tous_les_ans__c) || (oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c == oNewPTL_c.Periode_similaire_tous_les_ans__c))){
                    status = true;
                    oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c = oNewPTL_c.Periode_similaire_tous_les_ans__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Periode_similaire_tous_les_ans__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c] to [' + String.valueOf(oNewPTL_c.Periode_similaire_tous_les_ans__c) + ']');
                } else {
                    if (oOldPTL_c.Periode_similaire_tous_les_ans__c == oNewPTL_c.Periode_similaire_tous_les_ans__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c != oOldPTL_c.Periode_similaire_tous_les_ans__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Periode_similaire_tous_les_ans__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Periode_similaire_tous_les_ans__c) + '])');
                    }
            }
            if ((oOldPTL_c.Debut_periode__c != oNewPTL_c.Debut_periode__c) && ((oOpportunity_PTL_c.Debut_periode__c == oOldPTL_c.Debut_periode__c) || (oOpportunity_PTL_c.Debut_periode__c == oNewPTL_c.Debut_periode__c))){
                    status = true;
                    oOpportunity_PTL_c.Debut_periode__c = oNewPTL_c.Debut_periode__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Debut_periode__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Debut_periode__c] to [' + String.valueOf(oNewPTL_c.Debut_periode__c) + ']');
                } else {
                    if (oOldPTL_c.Debut_periode__c == oNewPTL_c.Debut_periode__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Debut_periode__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Debut_periode__c != oOldPTL_c.Debut_periode__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Debut_periode__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Debut_periode__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Debut_periode__c) + '])');
                    }
            }
            if ((oOldPTL_c.Fin_periode__c != oNewPTL_c.Fin_periode__c) && ((oOpportunity_PTL_c.Fin_periode__c == oOldPTL_c.Fin_periode__c) || (oOpportunity_PTL_c.Fin_periode__c == oNewPTL_c.Fin_periode__c))){
                    status = true;
                    oOpportunity_PTL_c.Fin_periode__c = oNewPTL_c.Fin_periode__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Fin_periode__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Fin_periode__c] to [' + String.valueOf(oNewPTL_c.Fin_periode__c) + ']');
                } else {
                    if (oOldPTL_c.Fin_periode__c == oNewPTL_c.Fin_periode__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Fin_periode__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Fin_periode__c != oOldPTL_c.Fin_periode__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Fin_periode__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Fin_periode__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Fin_periode__c) + '])');
                    }
            }
            if ((oOldPTL_c.Client_avec_sous_depot__c != oNewPTL_c.Client_avec_sous_depot__c) && ((oOpportunity_PTL_c.Client_avec_sous_depot__c == oOldPTL_c.Client_avec_sous_depot__c) || (oOpportunity_PTL_c.Client_avec_sous_depot__c == oNewPTL_c.Client_avec_sous_depot__c))){
                    status = true;
                    oOpportunity_PTL_c.Client_avec_sous_depot__c = oNewPTL_c.Client_avec_sous_depot__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Client_avec_sous_depot__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Client_avec_sous_depot__c] to [' + String.valueOf(oNewPTL_c.Client_avec_sous_depot__c) + ']');
                } else {
                    if (oOldPTL_c.Client_avec_sous_depot__c == oNewPTL_c.Client_avec_sous_depot__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Client_avec_sous_depot__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Client_avec_sous_depot__c != oOldPTL_c.Client_avec_sous_depot__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Client_avec_sous_depot__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Client_avec_sous_depot__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Client_avec_sous_depot__c) + '])');
                    }
            }
            if ((oOldPTL_c.Necessaire_de_prevenir_le_client__c != oNewPTL_c.Necessaire_de_prevenir_le_client__c) && ((oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c == oOldPTL_c.Necessaire_de_prevenir_le_client__c) || (oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c == oNewPTL_c.Necessaire_de_prevenir_le_client__c))){
                    status = true;
                    oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c = oNewPTL_c.Necessaire_de_prevenir_le_client__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Necessaire_de_prevenir_le_client__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c] to [' + String.valueOf(oNewPTL_c.Necessaire_de_prevenir_le_client__c) + ']');
                } else {
                    if (oOldPTL_c.Necessaire_de_prevenir_le_client__c == oNewPTL_c.Necessaire_de_prevenir_le_client__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c != oOldPTL_c.Necessaire_de_prevenir_le_client__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Necessaire_de_prevenir_le_client__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Necessaire_de_prevenir_le_client__c) + '])');
                    }
            }
            if ((oOldPTL_c.La_presence_systemathique__c != oNewPTL_c.La_presence_systemathique__c) && ((oOpportunity_PTL_c.La_presence_systemathique__c == oOldPTL_c.La_presence_systemathique__c) || (oOpportunity_PTL_c.La_presence_systemathique__c == oNewPTL_c.La_presence_systemathique__c))){
                    status = true;
                    oOpportunity_PTL_c.La_presence_systemathique__c = oNewPTL_c.La_presence_systemathique__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___La_presence_systemathique__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.La_presence_systemathique__c] to [' + String.valueOf(oNewPTL_c.La_presence_systemathique__c) + ']');
                } else {
                    if (oOldPTL_c.La_presence_systemathique__c == oNewPTL_c.La_presence_systemathique__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.La_presence_systemathique__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.La_presence_systemathique__c != oOldPTL_c.La_presence_systemathique__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.La_presence_systemathique__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.La_presence_systemathique__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.La_presence_systemathique__c) + '])');
                    }
            }
            if ((oOldPTL_c.Emballage_Pivot__c != oNewPTL_c.Emballage_Pivot__c) && ((oOpportunity_PTL_c.Emballage_Pivot__c == oOldPTL_c.Emballage_Pivot__c) || (oOpportunity_PTL_c.Emballage_Pivot__c == oNewPTL_c.Emballage_Pivot__c))){
                    status = true;
                    oOpportunity_PTL_c.Emballage_Pivot__c = oNewPTL_c.Emballage_Pivot__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Emballage_Pivot__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Emballage_Pivot__c] to [' + String.valueOf(oNewPTL_c.Emballage_Pivot__c) + ']');
                } else {
                    if (oOldPTL_c.Emballage_Pivot__c == oNewPTL_c.Emballage_Pivot__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Emballage_Pivot__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Emballage_Pivot__c != oOldPTL_c.Emballage_Pivot__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Emballage_Pivot__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Emballage_Pivot__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Emballage_Pivot__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consommation_estimee_Butane_10__c != oNewPTL_c.Consommation_estimee_Butane_10__c) && ((oOpportunity_PTL_c.Consommation_estimee_Butane_10__c == oOldPTL_c.Consommation_estimee_Butane_10__c) || (oOpportunity_PTL_c.Consommation_estimee_Butane_10__c == oNewPTL_c.Consommation_estimee_Butane_10__c))){
                    status = true;
                    oOpportunity_PTL_c.Consommation_estimee_Butane_10__c = oNewPTL_c.Consommation_estimee_Butane_10__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consommation_estimee_Butane_10__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consommation_estimee_Butane_10__c] to [' + String.valueOf(oNewPTL_c.Consommation_estimee_Butane_10__c) + ']');
                } else {
                    if (oOldPTL_c.Consommation_estimee_Butane_10__c == oNewPTL_c.Consommation_estimee_Butane_10__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Butane_10__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consommation_estimee_Butane_10__c != oOldPTL_c.Consommation_estimee_Butane_10__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Butane_10__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consommation_estimee_Butane_10__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consommation_estimee_Butane_10__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consommation_estimee_Butane_13__c != oNewPTL_c.Consommation_estimee_Butane_13__c) && ((oOpportunity_PTL_c.Consommation_estimee_Butane_13__c == oOldPTL_c.Consommation_estimee_Butane_13__c) || (oOpportunity_PTL_c.Consommation_estimee_Butane_13__c == oNewPTL_c.Consommation_estimee_Butane_13__c))){
                    status = true;
                    oOpportunity_PTL_c.Consommation_estimee_Butane_13__c = oNewPTL_c.Consommation_estimee_Butane_13__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consommation_estimee_Butane_13__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consommation_estimee_Butane_13__c] to [' + String.valueOf(oNewPTL_c.Consommation_estimee_Butane_13__c) + ']');
                } else {
                    if (oOldPTL_c.Consommation_estimee_Butane_13__c == oNewPTL_c.Consommation_estimee_Butane_13__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Butane_13__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consommation_estimee_Butane_13__c != oOldPTL_c.Consommation_estimee_Butane_13__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Butane_13__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consommation_estimee_Butane_13__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consommation_estimee_Butane_13__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consommation_estimee_Cube_But__c != oNewPTL_c.Consommation_estimee_Cube_But__c) && ((oOpportunity_PTL_c.Consommation_estimee_Cube_But__c == oOldPTL_c.Consommation_estimee_Cube_But__c) || (oOpportunity_PTL_c.Consommation_estimee_Cube_But__c == oNewPTL_c.Consommation_estimee_Cube_But__c))){
                    status = true;
                    oOpportunity_PTL_c.Consommation_estimee_Cube_But__c = oNewPTL_c.Consommation_estimee_Cube_But__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consommation_estimee_Cube_But__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consommation_estimee_Cube_But__c] to [' + String.valueOf(oNewPTL_c.Consommation_estimee_Cube_But__c) + ']');
                } else {
                    if (oOldPTL_c.Consommation_estimee_Cube_But__c == oNewPTL_c.Consommation_estimee_Cube_But__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Cube_But__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consommation_estimee_Cube_But__c != oOldPTL_c.Consommation_estimee_Cube_But__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Cube_But__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consommation_estimee_Cube_But__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consommation_estimee_Cube_But__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consommation_estimee_Cube_Prop__c != oNewPTL_c.Consommation_estimee_Cube_Prop__c) && ((oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c == oOldPTL_c.Consommation_estimee_Cube_Prop__c) || (oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c == oNewPTL_c.Consommation_estimee_Cube_Prop__c))){
                    status = true;
                    oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c = oNewPTL_c.Consommation_estimee_Cube_Prop__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consommation_estimee_Cube_Prop__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c] to [' + String.valueOf(oNewPTL_c.Consommation_estimee_Cube_Prop__c) + ']');
                } else {
                    if (oOldPTL_c.Consommation_estimee_Cube_Prop__c == oNewPTL_c.Consommation_estimee_Cube_Prop__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c != oOldPTL_c.Consommation_estimee_Cube_Prop__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consommation_estimee_Cube_Prop__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consommation_estimee_Cube_Prop__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consommation_estimee_propane_13__c != oNewPTL_c.Consommation_estimee_propane_13__c) && ((oOpportunity_PTL_c.Consommation_estimee_propane_13__c == oOldPTL_c.Consommation_estimee_propane_13__c) || (oOpportunity_PTL_c.Consommation_estimee_propane_13__c == oNewPTL_c.Consommation_estimee_propane_13__c))){
                    status = true;
                    oOpportunity_PTL_c.Consommation_estimee_propane_13__c = oNewPTL_c.Consommation_estimee_propane_13__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consommation_estimee_propane_13__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consommation_estimee_propane_13__c] to [' + String.valueOf(oNewPTL_c.Consommation_estimee_propane_13__c) + ']');
                } else {
                    if (oOldPTL_c.Consommation_estimee_propane_13__c == oNewPTL_c.Consommation_estimee_propane_13__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_propane_13__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consommation_estimee_propane_13__c != oOldPTL_c.Consommation_estimee_propane_13__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_propane_13__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consommation_estimee_propane_13__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consommation_estimee_propane_13__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consommation_estimee_Propane_35__c != oNewPTL_c.Consommation_estimee_Propane_35__c) && ((oOpportunity_PTL_c.Consommation_estimee_Propane_35__c == oOldPTL_c.Consommation_estimee_Propane_35__c) || (oOpportunity_PTL_c.Consommation_estimee_Propane_35__c == oNewPTL_c.Consommation_estimee_Propane_35__c))){
                    status = true;
                    oOpportunity_PTL_c.Consommation_estimee_Propane_35__c = oNewPTL_c.Consommation_estimee_Propane_35__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consommation_estimee_Propane_35__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consommation_estimee_Propane_35__c] to [' + String.valueOf(oNewPTL_c.Consommation_estimee_Propane_35__c) + ']');
                } else {
                    if (oOldPTL_c.Consommation_estimee_Propane_35__c == oNewPTL_c.Consommation_estimee_Propane_35__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Propane_35__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consommation_estimee_Propane_35__c != oOldPTL_c.Consommation_estimee_Propane_35__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Propane_35__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consommation_estimee_Propane_35__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consommation_estimee_Propane_35__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consommation_estimee_Prop_Carb__c != oNewPTL_c.Consommation_estimee_Prop_Carb__c) && ((oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c == oOldPTL_c.Consommation_estimee_Prop_Carb__c) || (oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c == oNewPTL_c.Consommation_estimee_Prop_Carb__c))){
                    status = true;
                    oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c = oNewPTL_c.Consommation_estimee_Prop_Carb__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consommation_estimee_Prop_Carb__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c] to [' + String.valueOf(oNewPTL_c.Consommation_estimee_Prop_Carb__c) + ']');
                } else {
                    if (oOldPTL_c.Consommation_estimee_Prop_Carb__c == oNewPTL_c.Consommation_estimee_Prop_Carb__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c != oOldPTL_c.Consommation_estimee_Prop_Carb__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consommation_estimee_Prop_Carb__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consommation_estimee_Prop_Carb__c) + '])');
                    }
            }
            if ((oOldPTL_c.Commande_generer_a_partir_du__c != oNewPTL_c.Commande_generer_a_partir_du__c) && ((oOpportunity_PTL_c.Commande_generer_a_partir_du__c == oOldPTL_c.Commande_generer_a_partir_du__c) || (oOpportunity_PTL_c.Commande_generer_a_partir_du__c == oNewPTL_c.Commande_generer_a_partir_du__c))){
                    status = true;
                    oOpportunity_PTL_c.Commande_generer_a_partir_du__c = oNewPTL_c.Commande_generer_a_partir_du__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Commande_generer_a_partir_du__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Commande_generer_a_partir_du__c] to [' + String.valueOf(oNewPTL_c.Commande_generer_a_partir_du__c) + ']');
                } else {
                    if (oOldPTL_c.Commande_generer_a_partir_du__c == oNewPTL_c.Commande_generer_a_partir_du__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Commande_generer_a_partir_du__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Commande_generer_a_partir_du__c != oOldPTL_c.Commande_generer_a_partir_du__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Commande_generer_a_partir_du__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Commande_generer_a_partir_du__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Commande_generer_a_partir_du__c) + '])');
                    }
            }
            if ((oOldPTL_c.Frequence_des_premieres_commandes__c != oNewPTL_c.Frequence_des_premieres_commandes__c) && ((oOpportunity_PTL_c.Frequence_des_premieres_commandes__c == oOldPTL_c.Frequence_des_premieres_commandes__c) || (oOpportunity_PTL_c.Frequence_des_premieres_commandes__c == oNewPTL_c.Frequence_des_premieres_commandes__c))){
                    status = true;
                    oOpportunity_PTL_c.Frequence_des_premieres_commandes__c = oNewPTL_c.Frequence_des_premieres_commandes__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Frequence_des_premieres_commandes__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Frequence_des_premieres_commandes__c] to [' + String.valueOf(oNewPTL_c.Frequence_des_premieres_commandes__c) + ']');
                } else {
                    if (oOldPTL_c.Frequence_des_premieres_commandes__c == oNewPTL_c.Frequence_des_premieres_commandes__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Frequence_des_premieres_commandes__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Frequence_des_premieres_commandes__c != oOldPTL_c.Frequence_des_premieres_commandes__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Frequence_des_premieres_commandes__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Frequence_des_premieres_commandes__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Frequence_des_premieres_commandes__c) + '])');
                    }
            }
            if ((oOldPTL_c.Frequence_semaine_quinzaine_mois__c != oNewPTL_c.Frequence_semaine_quinzaine_mois__c) && ((oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c == oOldPTL_c.Frequence_semaine_quinzaine_mois__c) || (oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c == oNewPTL_c.Frequence_semaine_quinzaine_mois__c))){
                    status = true;
                    oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c = oNewPTL_c.Frequence_semaine_quinzaine_mois__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Frequence_semaine_quinzaine_mois__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c] to [' + String.valueOf(oNewPTL_c.Frequence_semaine_quinzaine_mois__c) + ']');
                } else {
                    if (oOldPTL_c.Frequence_semaine_quinzaine_mois__c == oNewPTL_c.Frequence_semaine_quinzaine_mois__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c != oOldPTL_c.Frequence_semaine_quinzaine_mois__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Frequence_semaine_quinzaine_mois__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Frequence_semaine_quinzaine_mois__c) + '])');
                    }
            }
            if ((oOldPTL_c.Indication_supplementaire__c != oNewPTL_c.Indication_supplementaire__c) && ((oOpportunity_PTL_c.Indication_supplementaire__c == oOldPTL_c.Indication_supplementaire__c) || (oOpportunity_PTL_c.Indication_supplementaire__c == oNewPTL_c.Indication_supplementaire__c))){
                    status = true;
                    oOpportunity_PTL_c.Indication_supplementaire__c = oNewPTL_c.Indication_supplementaire__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Indication_supplementaire__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Indication_supplementaire__c] to [' + String.valueOf(oNewPTL_c.Indication_supplementaire__c) + ']');
                } else {
                    if (oOldPTL_c.Indication_supplementaire__c == oNewPTL_c.Indication_supplementaire__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Indication_supplementaire__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Indication_supplementaire__c != oOldPTL_c.Indication_supplementaire__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Indication_supplementaire__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Indication_supplementaire__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Indication_supplementaire__c) + '])');
                    }
            }
            if ((oOldPTL_c.Indication_supplementaire_depot__c != oNewPTL_c.Indication_supplementaire_depot__c) && ((oOpportunity_PTL_c.Indication_supplementaire_depot__c == oOldPTL_c.Indication_supplementaire_depot__c) || (oOpportunity_PTL_c.Indication_supplementaire_depot__c == oNewPTL_c.Indication_supplementaire_depot__c))){
                    status = true;
                    oOpportunity_PTL_c.Indication_supplementaire_depot__c = oNewPTL_c.Indication_supplementaire_depot__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Indication_supplementaire_depot__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Indication_supplementaire_depot__c] to [' + String.valueOf(oNewPTL_c.Indication_supplementaire_depot__c) + ']');
                } else {
                    if (oOldPTL_c.Indication_supplementaire_depot__c == oNewPTL_c.Indication_supplementaire_depot__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Indication_supplementaire_depot__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Indication_supplementaire_depot__c != oOldPTL_c.Indication_supplementaire_depot__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Indication_supplementaire_depot__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Indication_supplementaire_depot__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Indication_supplementaire_depot__c) + '])');
                    }
            }
            if ((oOldPTL_c.Accessible_par_tout_type_de_vehicule__c != oNewPTL_c.Accessible_par_tout_type_de_vehicule__c) && ((oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c == oOldPTL_c.Accessible_par_tout_type_de_vehicule__c) || (oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c == oNewPTL_c.Accessible_par_tout_type_de_vehicule__c))){
                    status = true;
                    oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c = oNewPTL_c.Accessible_par_tout_type_de_vehicule__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Accessible_par_tout_type_de_vehicule__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c] to [' + String.valueOf(oNewPTL_c.Accessible_par_tout_type_de_vehicule__c) + ']');
                } else {
                    if (oOldPTL_c.Accessible_par_tout_type_de_vehicule__c == oNewPTL_c.Accessible_par_tout_type_de_vehicule__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c != oOldPTL_c.Accessible_par_tout_type_de_vehicule__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Accessible_par_tout_type_de_vehicule__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Accessible_par_tout_type_de_vehicule__c) + '])');
                    }
            }
            if ((oOldPTL_c.Ensemble_semi__c != oNewPTL_c.Ensemble_semi__c) && ((oOpportunity_PTL_c.Ensemble_semi__c == oOldPTL_c.Ensemble_semi__c) || (oOpportunity_PTL_c.Ensemble_semi__c == oNewPTL_c.Ensemble_semi__c))){
                    status = true;
                    oOpportunity_PTL_c.Ensemble_semi__c = oNewPTL_c.Ensemble_semi__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Ensemble_semi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Ensemble_semi__c] to [' + String.valueOf(oNewPTL_c.Ensemble_semi__c) + ']');
                } else {
                    if (oOldPTL_c.Ensemble_semi__c == oNewPTL_c.Ensemble_semi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Ensemble_semi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Ensemble_semi__c != oOldPTL_c.Ensemble_semi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Ensemble_semi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Ensemble_semi__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Ensemble_semi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Porteurs__c != oNewPTL_c.Porteurs__c) && ((oOpportunity_PTL_c.Porteurs__c == oOldPTL_c.Porteurs__c) || (oOpportunity_PTL_c.Porteurs__c == oNewPTL_c.Porteurs__c))){
                    status = true;
                    oOpportunity_PTL_c.Porteurs__c = oNewPTL_c.Porteurs__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Porteurs__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Porteurs__c] to [' + String.valueOf(oNewPTL_c.Porteurs__c) + ']');
                } else {
                    if (oOldPTL_c.Porteurs__c == oNewPTL_c.Porteurs__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Porteurs__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Porteurs__c != oOldPTL_c.Porteurs__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Porteurs__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Porteurs__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Porteurs__c) + '])');
                    }
            }
            if ((oOldPTL_c.Vehicules_utilitaires__c != oNewPTL_c.Vehicules_utilitaires__c) && ((oOpportunity_PTL_c.Vehicules_utilitaires__c == oOldPTL_c.Vehicules_utilitaires__c) || (oOpportunity_PTL_c.Vehicules_utilitaires__c == oNewPTL_c.Vehicules_utilitaires__c))){
                    status = true;
                    oOpportunity_PTL_c.Vehicules_utilitaires__c = oNewPTL_c.Vehicules_utilitaires__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Vehicules_utilitaires__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Vehicules_utilitaires__c] to [' + String.valueOf(oNewPTL_c.Vehicules_utilitaires__c) + ']');
                } else {
                    if (oOldPTL_c.Vehicules_utilitaires__c == oNewPTL_c.Vehicules_utilitaires__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Vehicules_utilitaires__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Vehicules_utilitaires__c != oOldPTL_c.Vehicules_utilitaires__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Vehicules_utilitaires__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Vehicules_utilitaires__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Vehicules_utilitaires__c) + '])');
                    }
            }
            if ((oOldPTL_c.Chargement__c != oNewPTL_c.Chargement__c) && ((oOpportunity_PTL_c.Chargement__c == oOldPTL_c.Chargement__c) || (oOpportunity_PTL_c.Chargement__c == oNewPTL_c.Chargement__c))){
                    status = true;
                    oOpportunity_PTL_c.Chargement__c = oNewPTL_c.Chargement__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Chargement__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Chargement__c] to [' + String.valueOf(oNewPTL_c.Chargement__c) + ']');
                } else {
                    if (oOldPTL_c.Chargement__c == oNewPTL_c.Chargement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Chargement__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Chargement__c != oOldPTL_c.Chargement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Chargement__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Chargement__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Chargement__c) + '])');
                    }
            }
            if ((oOldPTL_c.Acces_clients__c != oNewPTL_c.Acces_clients__c) && ((oOpportunity_PTL_c.Acces_clients__c == oOldPTL_c.Acces_clients__c) || (oOpportunity_PTL_c.Acces_clients__c == oNewPTL_c.Acces_clients__c))){
                    status = true;
                    oOpportunity_PTL_c.Acces_clients__c = oNewPTL_c.Acces_clients__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Acces_clients__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Acces_clients__c] to [' + String.valueOf(oNewPTL_c.Acces_clients__c) + ']');
                } else {
                    if (oOldPTL_c.Acces_clients__c == oNewPTL_c.Acces_clients__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_clients__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Acces_clients__c != oOldPTL_c.Acces_clients__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_clients__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Acces_clients__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Acces_clients__c) + '])');
                    }
            }
            if ((oOldPTL_c.Stationnement__c != oNewPTL_c.Stationnement__c) && ((oOpportunity_PTL_c.Stationnement__c == oOldPTL_c.Stationnement__c) || (oOpportunity_PTL_c.Stationnement__c == oNewPTL_c.Stationnement__c))){
                    status = true;
                    oOpportunity_PTL_c.Stationnement__c = oNewPTL_c.Stationnement__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Stationnement__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Stationnement__c] to [' + String.valueOf(oNewPTL_c.Stationnement__c) + ']');
                } else {
                    if (oOldPTL_c.Stationnement__c == oNewPTL_c.Stationnement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Stationnement__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Stationnement__c != oOldPTL_c.Stationnement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Stationnement__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Stationnement__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Stationnement__c) + '])');
                    }
            }
            if ((oOldPTL_c.Consignes_specifiques__c != oNewPTL_c.Consignes_specifiques__c) && ((oOpportunity_PTL_c.Consignes_specifiques__c == oOldPTL_c.Consignes_specifiques__c) || (oOpportunity_PTL_c.Consignes_specifiques__c == oNewPTL_c.Consignes_specifiques__c))){
                    status = true;
                    oOpportunity_PTL_c.Consignes_specifiques__c = oNewPTL_c.Consignes_specifiques__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Consignes_specifiques__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Consignes_specifiques__c] to [' + String.valueOf(oNewPTL_c.Consignes_specifiques__c) + ']');
                } else {
                    if (oOldPTL_c.Consignes_specifiques__c == oNewPTL_c.Consignes_specifiques__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consignes_specifiques__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Consignes_specifiques__c != oOldPTL_c.Consignes_specifiques__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Consignes_specifiques__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Consignes_specifiques__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Consignes_specifiques__c) + '])');
                    }
            }
            if ((oOldPTL_c.Aire_de_livraison__c != oNewPTL_c.Aire_de_livraison__c) && ((oOpportunity_PTL_c.Aire_de_livraison__c == oOldPTL_c.Aire_de_livraison__c) || (oOpportunity_PTL_c.Aire_de_livraison__c == oNewPTL_c.Aire_de_livraison__c))){
                    status = true;
                    oOpportunity_PTL_c.Aire_de_livraison__c = oNewPTL_c.Aire_de_livraison__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Aire_de_livraison__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Aire_de_livraison__c] to [' + String.valueOf(oNewPTL_c.Aire_de_livraison__c) + ']');
                } else {
                    if (oOldPTL_c.Aire_de_livraison__c == oNewPTL_c.Aire_de_livraison__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Aire_de_livraison__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Aire_de_livraison__c != oOldPTL_c.Aire_de_livraison__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Aire_de_livraison__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Aire_de_livraison__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Aire_de_livraison__c) + '])');
                    }
            }
            if ((oOldPTL_c.Documents__c != oNewPTL_c.Documents__c) && ((oOpportunity_PTL_c.Documents__c == oOldPTL_c.Documents__c) || (oOpportunity_PTL_c.Documents__c == oNewPTL_c.Documents__c))){
                    status = true;
                    oOpportunity_PTL_c.Documents__c = oNewPTL_c.Documents__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Documents__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Documents__c] to [' + String.valueOf(oNewPTL_c.Documents__c) + ']');
                } else {
                    if (oOldPTL_c.Documents__c == oNewPTL_c.Documents__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Documents__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Documents__c != oOldPTL_c.Documents__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Documents__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Documents__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Documents__c) + '])');
                    }
            }
            if ((oOldPTL_c.Reglement__c != oNewPTL_c.Reglement__c) && ((oOpportunity_PTL_c.Reglement__c == oOldPTL_c.Reglement__c) || (oOpportunity_PTL_c.Reglement__c == oNewPTL_c.Reglement__c))){
                    status = true;
                    oOpportunity_PTL_c.Reglement__c = oNewPTL_c.Reglement__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Reglement__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Reglement__c] to [' + String.valueOf(oNewPTL_c.Reglement__c) + ']');
                } else {
                    if (oOldPTL_c.Reglement__c == oNewPTL_c.Reglement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Reglement__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Reglement__c != oOldPTL_c.Reglement__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Reglement__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Reglement__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Reglement__c) + '])');
                    }
            }
            if ((oOldPTL_c.Acces_difficile__c != oNewPTL_c.Acces_difficile__c) && ((oOpportunity_PTL_c.Acces_difficile__c == oOldPTL_c.Acces_difficile__c) || (oOpportunity_PTL_c.Acces_difficile__c == oNewPTL_c.Acces_difficile__c))){
                    status = true;
                    oOpportunity_PTL_c.Acces_difficile__c = oNewPTL_c.Acces_difficile__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Acces_difficile__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Acces_difficile__c] to [' + String.valueOf(oNewPTL_c.Acces_difficile__c) + ']');
                } else {
                    if (oOldPTL_c.Acces_difficile__c == oNewPTL_c.Acces_difficile__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_difficile__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Acces_difficile__c != oOldPTL_c.Acces_difficile__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_difficile__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Acces_difficile__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Acces_difficile__c) + '])');
                    }
            }
            if ((oOldPTL_c.Acces_reglemente__c != oNewPTL_c.Acces_reglemente__c) && ((oOpportunity_PTL_c.Acces_reglemente__c == oOldPTL_c.Acces_reglemente__c) || (oOpportunity_PTL_c.Acces_reglemente__c == oNewPTL_c.Acces_reglemente__c))){
                    status = true;
                    oOpportunity_PTL_c.Acces_reglemente__c = oNewPTL_c.Acces_reglemente__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Acces_reglemente__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Acces_reglemente__c] to [' + String.valueOf(oNewPTL_c.Acces_reglemente__c) + ']');
                } else {
                    if (oOldPTL_c.Acces_reglemente__c == oNewPTL_c.Acces_reglemente__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_reglemente__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Acces_reglemente__c != oOldPTL_c.Acces_reglemente__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_reglemente__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Acces_reglemente__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Acces_reglemente__c) + '])');
                    }
            }
            if ((oOldPTL_c.Acces_particulier__c != oNewPTL_c.Acces_particulier__c) && ((oOpportunity_PTL_c.Acces_particulier__c == oOldPTL_c.Acces_particulier__c) || (oOpportunity_PTL_c.Acces_particulier__c == oNewPTL_c.Acces_particulier__c))){
                    status = true;
                    oOpportunity_PTL_c.Acces_particulier__c = oNewPTL_c.Acces_particulier__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Acces_particulier__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Acces_particulier__c] to [' + String.valueOf(oNewPTL_c.Acces_particulier__c) + ']');
                } else {
                    if (oOldPTL_c.Acces_particulier__c == oNewPTL_c.Acces_particulier__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_particulier__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Acces_particulier__c != oOldPTL_c.Acces_particulier__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Acces_particulier__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Acces_particulier__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Acces_particulier__c) + '])');
                    }
            }
            if ((oOldPTL_c.Reimplantation_date__c != oNewPTL_c.Reimplantation_date__c) && ((oOpportunity_PTL_c.Reimplantation_date__c == oOldPTL_c.Reimplantation_date__c) || (oOpportunity_PTL_c.Reimplantation_date__c == oNewPTL_c.Reimplantation_date__c))){
                    status = true;
                    oOpportunity_PTL_c.Reimplantation_date__c = oNewPTL_c.Reimplantation_date__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Reimplantation_date__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Reimplantation_date__c] to [' + String.valueOf(oNewPTL_c.Reimplantation_date__c) + ']');
                } else {
                    if (oOldPTL_c.Reimplantation_date__c == oNewPTL_c.Reimplantation_date__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Reimplantation_date__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Reimplantation_date__c != oOldPTL_c.Reimplantation_date__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Reimplantation_date__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Reimplantation_date__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Reimplantation_date__c) + '])');
                    }
            }
            if ((oOldPTL_c.Type_d_implantation__c != oNewPTL_c.Type_d_implantation__c) && ((oOpportunity_PTL_c.Type_d_implantation__c == oOldPTL_c.Type_d_implantation__c) || (oOpportunity_PTL_c.Type_d_implantation__c == oNewPTL_c.Type_d_implantation__c))){
                    status = true;
                    oOpportunity_PTL_c.Type_d_implantation__c = oNewPTL_c.Type_d_implantation__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Type_d_implantation__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Type_d_implantation__c] to [' + String.valueOf(oNewPTL_c.Type_d_implantation__c) + ']');
                } else {
                    if (oOldPTL_c.Type_d_implantation__c == oNewPTL_c.Type_d_implantation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_d_implantation__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Type_d_implantation__c != oOldPTL_c.Type_d_implantation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_d_implantation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Type_d_implantation__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Type_d_implantation__c) + '])');
                    }
            }
            if ((oOldPTL_c.Enclos__c != oNewPTL_c.Enclos__c) && ((oOpportunity_PTL_c.Enclos__c == oOldPTL_c.Enclos__c) || (oOpportunity_PTL_c.Enclos__c == oNewPTL_c.Enclos__c))){
                    status = true;
                    oOpportunity_PTL_c.Enclos__c = oNewPTL_c.Enclos__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Enclos__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Enclos__c] to [' + String.valueOf(oNewPTL_c.Enclos__c) + ']');
                } else {
                    if (oOldPTL_c.Enclos__c == oNewPTL_c.Enclos__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Enclos__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Enclos__c != oOldPTL_c.Enclos__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Enclos__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Enclos__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Enclos__c) + '])');
                    }
            }
            if ((oOldPTL_c.Enclos_sur__c != oNewPTL_c.Enclos_sur__c) && ((oOpportunity_PTL_c.Enclos_sur__c == oOldPTL_c.Enclos_sur__c) || (oOpportunity_PTL_c.Enclos_sur__c == oNewPTL_c.Enclos_sur__c))){
                    status = true;
                    oOpportunity_PTL_c.Enclos_sur__c = oNewPTL_c.Enclos_sur__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Enclos_sur__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Enclos_sur__c] to [' + String.valueOf(oNewPTL_c.Enclos_sur__c) + ']');
                } else {
                    if (oOldPTL_c.Enclos_sur__c == oNewPTL_c.Enclos_sur__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Enclos_sur__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Enclos_sur__c != oOldPTL_c.Enclos_sur__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Enclos_sur__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Enclos_sur__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Enclos_sur__c) + '])');
                    }
            }
            if ((oOldPTL_c.Presence_pompiste__c != oNewPTL_c.Presence_pompiste__c) && ((oOpportunity_PTL_c.Presence_pompiste__c == oOldPTL_c.Presence_pompiste__c) || (oOpportunity_PTL_c.Presence_pompiste__c == oNewPTL_c.Presence_pompiste__c))){
                    status = true;
                    oOpportunity_PTL_c.Presence_pompiste__c = oNewPTL_c.Presence_pompiste__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Presence_pompiste__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Presence_pompiste__c] to [' + String.valueOf(oNewPTL_c.Presence_pompiste__c) + ']');
                } else {
                    if (oOldPTL_c.Presence_pompiste__c == oNewPTL_c.Presence_pompiste__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presence_pompiste__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Presence_pompiste__c != oOldPTL_c.Presence_pompiste__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presence_pompiste__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Presence_pompiste__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Presence_pompiste__c) + '])');
                    }
            }
            if ((oOldPTL_c.Si_pas_pompiste_ou_partielle__c != oNewPTL_c.Si_pas_pompiste_ou_partielle__c) && ((oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c == oOldPTL_c.Si_pas_pompiste_ou_partielle__c) || (oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c == oNewPTL_c.Si_pas_pompiste_ou_partielle__c))){
                    status = true;
                    oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c = oNewPTL_c.Si_pas_pompiste_ou_partielle__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Si_pas_pompiste_ou_partielle__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c] to [' + String.valueOf(oNewPTL_c.Si_pas_pompiste_ou_partielle__c) + ']');
                } else {
                    if (oOldPTL_c.Si_pas_pompiste_ou_partielle__c == oNewPTL_c.Si_pas_pompiste_ou_partielle__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c != oOldPTL_c.Si_pas_pompiste_ou_partielle__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Si_pas_pompiste_ou_partielle__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Si_pas_pompiste_ou_partielle__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c != oNewPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c) && ((oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c == oOldPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c) || (oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c == oNewPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c = oNewPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_de_pompes_essence_sur_le_PTL__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c] to [' + String.valueOf(oNewPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c == oNewPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c != oOldPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_de_pompes_essence_sur_le_PTL__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_de_pompes_essence_sur_le_PTL__c) + '])');
                    }
            }
            if ((oOldPTL_c.PTL_Drive__c != oNewPTL_c.PTL_Drive__c) && ((oOpportunity_PTL_c.PTL_Drive__c == oOldPTL_c.PTL_Drive__c) || (oOpportunity_PTL_c.PTL_Drive__c == oNewPTL_c.PTL_Drive__c))){
                    status = true;
                    oOpportunity_PTL_c.PTL_Drive__c = oNewPTL_c.PTL_Drive__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___PTL_Drive__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.PTL_Drive__c] to [' + String.valueOf(oNewPTL_c.PTL_Drive__c) + ']');
                } else {
                    if (oOldPTL_c.PTL_Drive__c == oNewPTL_c.PTL_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Drive__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.PTL_Drive__c != oOldPTL_c.PTL_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.PTL_Drive__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.PTL_Drive__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.PTL_Drive__c) + '])');
                    }
            }
            if ((oOldPTL_c.Preciser_l_emplacement_du_depot_Drive__c != oNewPTL_c.Preciser_l_emplacement_du_depot_Drive__c) && ((oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c == oOldPTL_c.Preciser_l_emplacement_du_depot_Drive__c) || (oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c == oNewPTL_c.Preciser_l_emplacement_du_depot_Drive__c))){
                    status = true;
                    oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c = oNewPTL_c.Preciser_l_emplacement_du_depot_Drive__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Preciser_l_emplacement_du_depot_Drive__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c] to [' + String.valueOf(oNewPTL_c.Preciser_l_emplacement_du_depot_Drive__c) + ']');
                } else {
                    if (oOldPTL_c.Preciser_l_emplacement_du_depot_Drive__c == oNewPTL_c.Preciser_l_emplacement_du_depot_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c != oOldPTL_c.Preciser_l_emplacement_du_depot_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Preciser_l_emplacement_du_depot_Drive__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Preciser_l_emplacement_du_depot_Drive__c) + '])');
                    }
            }
            if ((oOldPTL_c.Type_de_Drive__c != oNewPTL_c.Type_de_Drive__c) && ((oOpportunity_PTL_c.Type_de_Drive__c == oOldPTL_c.Type_de_Drive__c) || (oOpportunity_PTL_c.Type_de_Drive__c == oNewPTL_c.Type_de_Drive__c))){
                    status = true;
                    oOpportunity_PTL_c.Type_de_Drive__c = oNewPTL_c.Type_de_Drive__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Type_de_Drive__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Type_de_Drive__c] to [' + String.valueOf(oNewPTL_c.Type_de_Drive__c) + ']');
                } else {
                    if (oOldPTL_c.Type_de_Drive__c == oNewPTL_c.Type_de_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_Drive__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Type_de_Drive__c != oOldPTL_c.Type_de_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_Drive__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Type_de_Drive__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Type_de_Drive__c) + '])');
                    }
            }
            if ((oOldPTL_c.Livraison_domicile__c != oNewPTL_c.Livraison_domicile__c) && ((oOpportunity_PTL_c.Livraison_domicile__c == oOldPTL_c.Livraison_domicile__c) || (oOpportunity_PTL_c.Livraison_domicile__c == oNewPTL_c.Livraison_domicile__c))){
                    status = true;
                    oOpportunity_PTL_c.Livraison_domicile__c = oNewPTL_c.Livraison_domicile__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Livraison_domicile__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Livraison_domicile__c] to [' + String.valueOf(oNewPTL_c.Livraison_domicile__c) + ']');
                } else {
                    if (oOldPTL_c.Livraison_domicile__c == oNewPTL_c.Livraison_domicile__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Livraison_domicile__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Livraison_domicile__c != oOldPTL_c.Livraison_domicile__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Livraison_domicile__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Livraison_domicile__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Livraison_domicile__c) + '])');
                    }
            }
            if ((oOldPTL_c.Distributeur_automatique_bouteilles__c != oNewPTL_c.Distributeur_automatique_bouteilles__c) && ((oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c == oOldPTL_c.Distributeur_automatique_bouteilles__c) || (oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c == oNewPTL_c.Distributeur_automatique_bouteilles__c))){
                    status = true;
                    oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c = oNewPTL_c.Distributeur_automatique_bouteilles__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Distributeur_automatique_bouteilles__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c] to [' + String.valueOf(oNewPTL_c.Distributeur_automatique_bouteilles__c) + ']');
                } else {
                    if (oOldPTL_c.Distributeur_automatique_bouteilles__c == oNewPTL_c.Distributeur_automatique_bouteilles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c != oOldPTL_c.Distributeur_automatique_bouteilles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Distributeur_automatique_bouteilles__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Distributeur_automatique_bouteilles__c) + '])');
                    }
            }
            if ((oOldPTL_c.Marques_distributeurs_aut_bouteilles__c != oNewPTL_c.Marques_distributeurs_aut_bouteilles__c) && ((oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c == oOldPTL_c.Marques_distributeurs_aut_bouteilles__c) || (oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c == oNewPTL_c.Marques_distributeurs_aut_bouteilles__c))){
                    status = true;
                    oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c = oNewPTL_c.Marques_distributeurs_aut_bouteilles__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Marques_distributeurs_aut_bouteilles__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c] to [' + String.valueOf(oNewPTL_c.Marques_distributeurs_aut_bouteilles__c) + ']');
                } else {
                    if (oOldPTL_c.Marques_distributeurs_aut_bouteilles__c == oNewPTL_c.Marques_distributeurs_aut_bouteilles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c != oOldPTL_c.Marques_distributeurs_aut_bouteilles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Marques_distributeurs_aut_bouteilles__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Marques_distributeurs_aut_bouteilles__c) + '])');
                    }
            }
            if ((oOldPTL_c.Presence_distributeur_automatique_cles__c != oNewPTL_c.Presence_distributeur_automatique_cles__c) && ((oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c == oOldPTL_c.Presence_distributeur_automatique_cles__c) || (oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c == oNewPTL_c.Presence_distributeur_automatique_cles__c))){
                    status = true;
                    oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c = oNewPTL_c.Presence_distributeur_automatique_cles__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Presence_distributeur_automatique_cles__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c] to [' + String.valueOf(oNewPTL_c.Presence_distributeur_automatique_cles__c) + ']');
                } else {
                    if (oOldPTL_c.Presence_distributeur_automatique_cles__c == oNewPTL_c.Presence_distributeur_automatique_cles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c != oOldPTL_c.Presence_distributeur_automatique_cles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Presence_distributeur_automatique_cles__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Presence_distributeur_automatique_cles__c) + '])');
                    }
            }
            
            
            // END_AUTO_PROPAGATE_PTL__r
        }
        return status;
    }
    
    
    public static Boolean propagatePTL_Fields_Part3(Opportunity_PTL__c oOpportunity_PTL_c, Map<Id, PTL__c> mOldPTL_cs, Map<Id, PTL__c> mNewPTL_cs){
        PTL__c oOldPTL_c = mOldPTL_cs.get(oOpportunity_PTL_c.PTL__c);
        PTL__c oNewPTL_c = mNewPTL_cs.get(oOpportunity_PTL_c.PTL__c);
        Boolean status    = false;
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part3] Starting.');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part3] oOldPTL_c:[' + oOldPTL_c + ']');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part3] oNewPTL_c:[' + oNewPTL_c + ']');
        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields_Part3] oOpportunity_PTL_c:[' + oOpportunity_PTL_c + ']');
        if ((oOldPTL_c != null) && (oNewPTL_c != null)) { // that's equivalent. We're just checking whether the Opportunity_PTL__c had this specific PTL__c, PTL__c lookup updated
            // BEGIN_AUTO_PROPAGATE_PTL__r
            
            if ((oOldPTL_c.Marques_distributeurs_cles__c != oNewPTL_c.Marques_distributeurs_cles__c) && ((oOpportunity_PTL_c.Marques_distributeurs_cles__c == oOldPTL_c.Marques_distributeurs_cles__c) || (oOpportunity_PTL_c.Marques_distributeurs_cles__c == oNewPTL_c.Marques_distributeurs_cles__c))){
                    status = true;
                    oOpportunity_PTL_c.Marques_distributeurs_cles__c = oNewPTL_c.Marques_distributeurs_cles__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Marques_distributeurs_cles__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Marques_distributeurs_cles__c] to [' + String.valueOf(oNewPTL_c.Marques_distributeurs_cles__c) + ']');
                } else {
                    if (oOldPTL_c.Marques_distributeurs_cles__c == oNewPTL_c.Marques_distributeurs_cles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Marques_distributeurs_cles__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Marques_distributeurs_cles__c != oOldPTL_c.Marques_distributeurs_cles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Marques_distributeurs_cles__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Marques_distributeurs_cles__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Marques_distributeurs_cles__c) + '])');
                    }
            }
            if ((oOldPTL_c.Texte_Chauffeur_2__c != oNewPTL_c.Texte_Chauffeur_2__c) && ((oOpportunity_PTL_c.Texte_Chauffeur_2__c == oOldPTL_c.Texte_Chauffeur_2__c) || (oOpportunity_PTL_c.Texte_Chauffeur_2__c == oNewPTL_c.Texte_Chauffeur_2__c))){
                    status = true;
                    oOpportunity_PTL_c.Texte_Chauffeur_2__c = oNewPTL_c.Texte_Chauffeur_2__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Texte_Chauffeur_2__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Texte_Chauffeur_2__c] to [' + String.valueOf(oNewPTL_c.Texte_Chauffeur_2__c) + ']');
                } else {
                    if (oOldPTL_c.Texte_Chauffeur_2__c == oNewPTL_c.Texte_Chauffeur_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Texte_Chauffeur_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Texte_Chauffeur_2__c != oOldPTL_c.Texte_Chauffeur_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Texte_Chauffeur_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Texte_Chauffeur_2__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Texte_Chauffeur_2__c) + '])');
                    }
            }
            if ((oOldPTL_c.Apporter_le_bon_de_commande__c != oNewPTL_c.Apporter_le_bon_de_commande__c) && ((oOpportunity_PTL_c.Apporter_le_bon_de_commande__c == oOldPTL_c.Apporter_le_bon_de_commande__c) || (oOpportunity_PTL_c.Apporter_le_bon_de_commande__c == oNewPTL_c.Apporter_le_bon_de_commande__c))){
                    status = true;
                    oOpportunity_PTL_c.Apporter_le_bon_de_commande__c = oNewPTL_c.Apporter_le_bon_de_commande__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Apporter_le_bon_de_commande__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Apporter_le_bon_de_commande__c] to [' + String.valueOf(oNewPTL_c.Apporter_le_bon_de_commande__c) + ']');
                } else {
                    if (oOldPTL_c.Apporter_le_bon_de_commande__c == oNewPTL_c.Apporter_le_bon_de_commande__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Apporter_le_bon_de_commande__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Apporter_le_bon_de_commande__c != oOldPTL_c.Apporter_le_bon_de_commande__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Apporter_le_bon_de_commande__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Apporter_le_bon_de_commande__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Apporter_le_bon_de_commande__c) + '])');
                    }
            }
            if ((oOldPTL_c.Particularites_acces__c != oNewPTL_c.Particularites_acces__c) && ((oOpportunity_PTL_c.Particularites_acces__c == oOldPTL_c.Particularites_acces__c) || (oOpportunity_PTL_c.Particularites_acces__c == oNewPTL_c.Particularites_acces__c))){
                    status = true;
                    oOpportunity_PTL_c.Particularites_acces__c = oNewPTL_c.Particularites_acces__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Particularites_acces__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Particularites_acces__c] to [' + String.valueOf(oNewPTL_c.Particularites_acces__c) + ']');
                } else {
                    if (oOldPTL_c.Particularites_acces__c == oNewPTL_c.Particularites_acces__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Particularites_acces__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Particularites_acces__c != oOldPTL_c.Particularites_acces__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Particularites_acces__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Particularites_acces__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Particularites_acces__c) + '])');
                    }
            }
            if ((oOldPTL_c.Particularites_HSE__c != oNewPTL_c.Particularites_HSE__c) && ((oOpportunity_PTL_c.Particularites_HSE__c == oOldPTL_c.Particularites_HSE__c) || (oOpportunity_PTL_c.Particularites_HSE__c == oNewPTL_c.Particularites_HSE__c))){
                    status = true;
                    oOpportunity_PTL_c.Particularites_HSE__c = oNewPTL_c.Particularites_HSE__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Particularites_HSE__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Particularites_HSE__c] to [' + String.valueOf(oNewPTL_c.Particularites_HSE__c) + ']');
                } else {
                    if (oOldPTL_c.Particularites_HSE__c == oNewPTL_c.Particularites_HSE__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Particularites_HSE__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Particularites_HSE__c != oOldPTL_c.Particularites_HSE__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Particularites_HSE__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Particularites_HSE__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Particularites_HSE__c) + '])');
                    }
            }
            if ((oOldPTL_c.Particularites_revendeur__c != oNewPTL_c.Particularites_revendeur__c) && ((oOpportunity_PTL_c.Particularites_revendeur__c == oOldPTL_c.Particularites_revendeur__c) || (oOpportunity_PTL_c.Particularites_revendeur__c == oNewPTL_c.Particularites_revendeur__c))){
                    status = true;
                    oOpportunity_PTL_c.Particularites_revendeur__c = oNewPTL_c.Particularites_revendeur__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Particularites_revendeur__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Particularites_revendeur__c] to [' + String.valueOf(oNewPTL_c.Particularites_revendeur__c) + ']');
                } else {
                    if (oOldPTL_c.Particularites_revendeur__c == oNewPTL_c.Particularites_revendeur__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Particularites_revendeur__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Particularites_revendeur__c != oOldPTL_c.Particularites_revendeur__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Particularites_revendeur__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Particularites_revendeur__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Particularites_revendeur__c) + '])');
                    }
            }
            if ((oOldPTL_c.Type_de_presentoir_1__c != oNewPTL_c.Type_de_presentoir_1__c) && ((oOpportunity_PTL_c.Type_de_presentoir_1__c == oOldPTL_c.Type_de_presentoir_1__c) || (oOpportunity_PTL_c.Type_de_presentoir_1__c == oNewPTL_c.Type_de_presentoir_1__c))){
                    status = true;
                    oOpportunity_PTL_c.Type_de_presentoir_1__c = oNewPTL_c.Type_de_presentoir_1__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Type_de_presentoir_1__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Type_de_presentoir_1__c] to [' + String.valueOf(oNewPTL_c.Type_de_presentoir_1__c) + ']');
                } else {
                    if (oOldPTL_c.Type_de_presentoir_1__c == oNewPTL_c.Type_de_presentoir_1__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_1__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Type_de_presentoir_1__c != oOldPTL_c.Type_de_presentoir_1__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_1__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Type_de_presentoir_1__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Type_de_presentoir_1__c) + '])');
                    }
            }
            if ((oOldPTL_c.Type_de_presentoir_2__c != oNewPTL_c.Type_de_presentoir_2__c) && ((oOpportunity_PTL_c.Type_de_presentoir_2__c == oOldPTL_c.Type_de_presentoir_2__c) || (oOpportunity_PTL_c.Type_de_presentoir_2__c == oNewPTL_c.Type_de_presentoir_2__c))){
                    status = true;
                    oOpportunity_PTL_c.Type_de_presentoir_2__c = oNewPTL_c.Type_de_presentoir_2__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Type_de_presentoir_2__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Type_de_presentoir_2__c] to [' + String.valueOf(oNewPTL_c.Type_de_presentoir_2__c) + ']');
                } else {
                    if (oOldPTL_c.Type_de_presentoir_2__c == oNewPTL_c.Type_de_presentoir_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Type_de_presentoir_2__c != oOldPTL_c.Type_de_presentoir_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Type_de_presentoir_2__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Type_de_presentoir_2__c) + '])');
                    }
            }
            if ((oOldPTL_c.Type_de_presentoir_3__c != oNewPTL_c.Type_de_presentoir_3__c) && ((oOpportunity_PTL_c.Type_de_presentoir_3__c == oOldPTL_c.Type_de_presentoir_3__c) || (oOpportunity_PTL_c.Type_de_presentoir_3__c == oNewPTL_c.Type_de_presentoir_3__c))){
                    status = true;
                    oOpportunity_PTL_c.Type_de_presentoir_3__c = oNewPTL_c.Type_de_presentoir_3__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Type_de_presentoir_3__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Type_de_presentoir_3__c] to [' + String.valueOf(oNewPTL_c.Type_de_presentoir_3__c) + ']');
                } else {
                    if (oOldPTL_c.Type_de_presentoir_3__c == oNewPTL_c.Type_de_presentoir_3__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_3__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Type_de_presentoir_3__c != oOldPTL_c.Type_de_presentoir_3__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_3__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Type_de_presentoir_3__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Type_de_presentoir_3__c) + '])');
                    }
            }
            if ((oOldPTL_c.Type_de_presentoir_4__c != oNewPTL_c.Type_de_presentoir_4__c) && ((oOpportunity_PTL_c.Type_de_presentoir_4__c == oOldPTL_c.Type_de_presentoir_4__c) || (oOpportunity_PTL_c.Type_de_presentoir_4__c == oNewPTL_c.Type_de_presentoir_4__c))){
                    status = true;
                    oOpportunity_PTL_c.Type_de_presentoir_4__c = oNewPTL_c.Type_de_presentoir_4__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Type_de_presentoir_4__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Type_de_presentoir_4__c] to [' + String.valueOf(oNewPTL_c.Type_de_presentoir_4__c) + ']');
                } else {
                    if (oOldPTL_c.Type_de_presentoir_4__c == oNewPTL_c.Type_de_presentoir_4__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_4__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Type_de_presentoir_4__c != oOldPTL_c.Type_de_presentoir_4__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_4__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Type_de_presentoir_4__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Type_de_presentoir_4__c) + '])');
                    }
            }
            if ((oOldPTL_c.Type_de_presentoir_5__c != oNewPTL_c.Type_de_presentoir_5__c) && ((oOpportunity_PTL_c.Type_de_presentoir_5__c == oOldPTL_c.Type_de_presentoir_5__c) || (oOpportunity_PTL_c.Type_de_presentoir_5__c == oNewPTL_c.Type_de_presentoir_5__c))){
                    status = true;
                    oOpportunity_PTL_c.Type_de_presentoir_5__c = oNewPTL_c.Type_de_presentoir_5__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Type_de_presentoir_5__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Type_de_presentoir_5__c] to [' + String.valueOf(oNewPTL_c.Type_de_presentoir_5__c) + ']');
                } else {
                    if (oOldPTL_c.Type_de_presentoir_5__c == oNewPTL_c.Type_de_presentoir_5__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_5__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Type_de_presentoir_5__c != oOldPTL_c.Type_de_presentoir_5__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Type_de_presentoir_5__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Type_de_presentoir_5__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Type_de_presentoir_5__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_type_de_presentoir_1__c != oNewPTL_c.Nombre_type_de_presentoir_1__c) && ((oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c == oOldPTL_c.Nombre_type_de_presentoir_1__c) || (oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c == oNewPTL_c.Nombre_type_de_presentoir_1__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c = oNewPTL_c.Nombre_type_de_presentoir_1__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_type_de_presentoir_1__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c] to [' + String.valueOf(oNewPTL_c.Nombre_type_de_presentoir_1__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_type_de_presentoir_1__c == oNewPTL_c.Nombre_type_de_presentoir_1__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c != oOldPTL_c.Nombre_type_de_presentoir_1__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_type_de_presentoir_1__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_type_de_presentoir_1__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_type_de_presentoir_2__c != oNewPTL_c.Nombre_type_de_presentoir_2__c) && ((oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c == oOldPTL_c.Nombre_type_de_presentoir_2__c) || (oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c == oNewPTL_c.Nombre_type_de_presentoir_2__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c = oNewPTL_c.Nombre_type_de_presentoir_2__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_type_de_presentoir_2__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c] to [' + String.valueOf(oNewPTL_c.Nombre_type_de_presentoir_2__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_type_de_presentoir_2__c == oNewPTL_c.Nombre_type_de_presentoir_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c != oOldPTL_c.Nombre_type_de_presentoir_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_type_de_presentoir_2__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_type_de_presentoir_2__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_type_de_presentoir_3__c != oNewPTL_c.Nombre_type_de_presentoir_3__c) && ((oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c == oOldPTL_c.Nombre_type_de_presentoir_3__c) || (oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c == oNewPTL_c.Nombre_type_de_presentoir_3__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c = oNewPTL_c.Nombre_type_de_presentoir_3__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_type_de_presentoir_3__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c] to [' + String.valueOf(oNewPTL_c.Nombre_type_de_presentoir_3__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_type_de_presentoir_3__c == oNewPTL_c.Nombre_type_de_presentoir_3__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c != oOldPTL_c.Nombre_type_de_presentoir_3__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_type_de_presentoir_3__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_type_de_presentoir_3__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_type_de_presentoir_4__c != oNewPTL_c.Nombre_type_de_presentoir_4__c) && ((oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c == oOldPTL_c.Nombre_type_de_presentoir_4__c) || (oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c == oNewPTL_c.Nombre_type_de_presentoir_4__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c = oNewPTL_c.Nombre_type_de_presentoir_4__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_type_de_presentoir_4__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c] to [' + String.valueOf(oNewPTL_c.Nombre_type_de_presentoir_4__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_type_de_presentoir_4__c == oNewPTL_c.Nombre_type_de_presentoir_4__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c != oOldPTL_c.Nombre_type_de_presentoir_4__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_type_de_presentoir_4__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_type_de_presentoir_4__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_type_de_presentoir_5__c != oNewPTL_c.Nombre_type_de_presentoir_5__c) && ((oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c == oOldPTL_c.Nombre_type_de_presentoir_5__c) || (oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c == oNewPTL_c.Nombre_type_de_presentoir_5__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c = oNewPTL_c.Nombre_type_de_presentoir_5__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_type_de_presentoir_5__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c] to [' + String.valueOf(oNewPTL_c.Nombre_type_de_presentoir_5__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_type_de_presentoir_5__c == oNewPTL_c.Nombre_type_de_presentoir_5__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c != oOldPTL_c.Nombre_type_de_presentoir_5__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_type_de_presentoir_5__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_type_de_presentoir_5__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_de_bandeaux__c != oNewPTL_c.Nombre_de_bandeaux__c) && ((oOpportunity_PTL_c.Nombre_de_bandeaux__c == oOldPTL_c.Nombre_de_bandeaux__c) || (oOpportunity_PTL_c.Nombre_de_bandeaux__c == oNewPTL_c.Nombre_de_bandeaux__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_de_bandeaux__c = oNewPTL_c.Nombre_de_bandeaux__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_de_bandeaux__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_de_bandeaux__c] to [' + String.valueOf(oNewPTL_c.Nombre_de_bandeaux__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_de_bandeaux__c == oNewPTL_c.Nombre_de_bandeaux__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_de_bandeaux__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_de_bandeaux__c != oOldPTL_c.Nombre_de_bandeaux__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_de_bandeaux__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_de_bandeaux__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_de_bandeaux__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_de_surmontoirs__c != oNewPTL_c.Nombre_de_surmontoirs__c) && ((oOpportunity_PTL_c.Nombre_de_surmontoirs__c == oOldPTL_c.Nombre_de_surmontoirs__c) || (oOpportunity_PTL_c.Nombre_de_surmontoirs__c == oNewPTL_c.Nombre_de_surmontoirs__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_de_surmontoirs__c = oNewPTL_c.Nombre_de_surmontoirs__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_de_surmontoirs__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_de_surmontoirs__c] to [' + String.valueOf(oNewPTL_c.Nombre_de_surmontoirs__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_de_surmontoirs__c == oNewPTL_c.Nombre_de_surmontoirs__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_de_surmontoirs__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_de_surmontoirs__c != oOldPTL_c.Nombre_de_surmontoirs__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_de_surmontoirs__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_de_surmontoirs__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_de_surmontoirs__c) + '])');
                    }
            }
            if ((oOldPTL_c.Presence_porte_affiche_Butagaz__c != oNewPTL_c.Presence_porte_affiche_Butagaz__c) && ((oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c == oOldPTL_c.Presence_porte_affiche_Butagaz__c) || (oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c == oNewPTL_c.Presence_porte_affiche_Butagaz__c))){
                    status = true;
                    oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c = oNewPTL_c.Presence_porte_affiche_Butagaz__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Presence_porte_affiche_Butagaz__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c] to [' + String.valueOf(oNewPTL_c.Presence_porte_affiche_Butagaz__c) + ']');
                } else {
                    if (oOldPTL_c.Presence_porte_affiche_Butagaz__c == oNewPTL_c.Presence_porte_affiche_Butagaz__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c != oOldPTL_c.Presence_porte_affiche_Butagaz__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Presence_porte_affiche_Butagaz__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Presence_porte_affiche_Butagaz__c) + '])');
                    }
            }
            if ((oOldPTL_c.Si_oui_sur_quel_presentoir__c != oNewPTL_c.Si_oui_sur_quel_presentoir__c) && ((oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c == oOldPTL_c.Si_oui_sur_quel_presentoir__c) || (oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c == oNewPTL_c.Si_oui_sur_quel_presentoir__c))){
                    status = true;
                    oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c = oNewPTL_c.Si_oui_sur_quel_presentoir__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Si_oui_sur_quel_presentoir__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c] to [' + String.valueOf(oNewPTL_c.Si_oui_sur_quel_presentoir__c) + ']');
                } else {
                    if (oOldPTL_c.Si_oui_sur_quel_presentoir__c == oNewPTL_c.Si_oui_sur_quel_presentoir__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c != oOldPTL_c.Si_oui_sur_quel_presentoir__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Si_oui_sur_quel_presentoir__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Si_oui_sur_quel_presentoir__c) + '])');
                    }
            }
            if ((oOldPTL_c.Information_prix__c != oNewPTL_c.Information_prix__c) && ((oOpportunity_PTL_c.Information_prix__c == oOldPTL_c.Information_prix__c) || (oOpportunity_PTL_c.Information_prix__c == oNewPTL_c.Information_prix__c))){
                    status = true;
                    oOpportunity_PTL_c.Information_prix__c = oNewPTL_c.Information_prix__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Information_prix__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Information_prix__c] to [' + String.valueOf(oNewPTL_c.Information_prix__c) + ']');
                } else {
                    if (oOldPTL_c.Information_prix__c == oNewPTL_c.Information_prix__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Information_prix__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Information_prix__c != oOldPTL_c.Information_prix__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Information_prix__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Information_prix__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Information_prix__c) + '])');
                    }
            }
            if ((oOldPTL_c.Lourde_Legere__c != oNewPTL_c.Lourde_Legere__c) && ((oOpportunity_PTL_c.Lourde_Legere__c == oOldPTL_c.Lourde_Legere__c) || (oOpportunity_PTL_c.Lourde_Legere__c == oNewPTL_c.Lourde_Legere__c))){
                    status = true;
                    oOpportunity_PTL_c.Lourde_Legere__c = oNewPTL_c.Lourde_Legere__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Lourde_Legere__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Lourde_Legere__c] to [' + String.valueOf(oNewPTL_c.Lourde_Legere__c) + ']');
                } else {
                    if (oOldPTL_c.Lourde_Legere__c == oNewPTL_c.Lourde_Legere__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Lourde_Legere__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Lourde_Legere__c != oOldPTL_c.Lourde_Legere__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Lourde_Legere__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Lourde_Legere__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Lourde_Legere__c) + '])');
                    }
            }
            if ((oOldPTL_c.Presentoirs_autres_marques_presents_30__c != oNewPTL_c.Presentoirs_autres_marques_presents_30__c) && ((oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c == oOldPTL_c.Presentoirs_autres_marques_presents_30__c) || (oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c == oNewPTL_c.Presentoirs_autres_marques_presents_30__c))){
                    status = true;
                    oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c = oNewPTL_c.Presentoirs_autres_marques_presents_30__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Presentoirs_autres_marques_presents_30__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c] to [' + String.valueOf(oNewPTL_c.Presentoirs_autres_marques_presents_30__c) + ']');
                } else {
                    if (oOldPTL_c.Presentoirs_autres_marques_presents_30__c == oNewPTL_c.Presentoirs_autres_marques_presents_30__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c != oOldPTL_c.Presentoirs_autres_marques_presents_30__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Presentoirs_autres_marques_presents_30__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Presentoirs_autres_marques_presents_30__c) + '])');
                    }
            }
            if ((oOldPTL_c.Tete_de_gondole__c != oNewPTL_c.Tete_de_gondole__c) && ((oOpportunity_PTL_c.Tete_de_gondole__c == oOldPTL_c.Tete_de_gondole__c) || (oOpportunity_PTL_c.Tete_de_gondole__c == oNewPTL_c.Tete_de_gondole__c))){
                    status = true;
                    oOpportunity_PTL_c.Tete_de_gondole__c = oNewPTL_c.Tete_de_gondole__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Tete_de_gondole__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Tete_de_gondole__c] to [' + String.valueOf(oNewPTL_c.Tete_de_gondole__c) + ']');
                } else {
                    if (oOldPTL_c.Tete_de_gondole__c == oNewPTL_c.Tete_de_gondole__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Tete_de_gondole__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Tete_de_gondole__c != oOldPTL_c.Tete_de_gondole__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Tete_de_gondole__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Tete_de_gondole__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Tete_de_gondole__c) + '])');
                    }
            }
            if ((oOldPTL_c.Gribouille__c != oNewPTL_c.Gribouille__c) && ((oOpportunity_PTL_c.Gribouille__c == oOldPTL_c.Gribouille__c) || (oOpportunity_PTL_c.Gribouille__c == oNewPTL_c.Gribouille__c))){
                    status = true;
                    oOpportunity_PTL_c.Gribouille__c = oNewPTL_c.Gribouille__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Gribouille__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Gribouille__c] to [' + String.valueOf(oNewPTL_c.Gribouille__c) + ']');
                } else {
                    if (oOldPTL_c.Gribouille__c == oNewPTL_c.Gribouille__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Gribouille__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Gribouille__c != oOldPTL_c.Gribouille__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Gribouille__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Gribouille__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Gribouille__c) + '])');
                    }
            }
            if ((oOldPTL_c.Prix_BD_Ref__c != oNewPTL_c.Prix_BD_Ref__c) && ((oOpportunity_PTL_c.Prix_BD_Ref__c == oOldPTL_c.Prix_BD_Ref__c) || (oOpportunity_PTL_c.Prix_BD_Ref__c == oNewPTL_c.Prix_BD_Ref__c))){
                    status = true;
                    oOpportunity_PTL_c.Prix_BD_Ref__c = oNewPTL_c.Prix_BD_Ref__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Prix_BD_Ref__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Prix_BD_Ref__c] to [' + String.valueOf(oNewPTL_c.Prix_BD_Ref__c) + ']');
                } else {
                    if (oOldPTL_c.Prix_BD_Ref__c == oNewPTL_c.Prix_BD_Ref__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Prix_BD_Ref__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Prix_BD_Ref__c != oOldPTL_c.Prix_BD_Ref__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Prix_BD_Ref__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Prix_BD_Ref__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Prix_BD_Ref__c) + '])');
                    }
            }
            if ((oOldPTL_c.Concurrent_1__c != oNewPTL_c.Concurrent_1__c) && ((oOpportunity_PTL_c.Concurrent_1__c == oOldPTL_c.Concurrent_1__c) || (oOpportunity_PTL_c.Concurrent_1__c == oNewPTL_c.Concurrent_1__c))){
                    status = true;
                    oOpportunity_PTL_c.Concurrent_1__c = oNewPTL_c.Concurrent_1__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Concurrent_1__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Concurrent_1__c] to [' + String.valueOf(oNewPTL_c.Concurrent_1__c) + ']');
                } else {
                    if (oOldPTL_c.Concurrent_1__c == oNewPTL_c.Concurrent_1__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Concurrent_1__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Concurrent_1__c != oOldPTL_c.Concurrent_1__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Concurrent_1__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Concurrent_1__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Concurrent_1__c) + '])');
                    }
            }
            if ((oOldPTL_c.Concurrent_2__c != oNewPTL_c.Concurrent_2__c) && ((oOpportunity_PTL_c.Concurrent_2__c == oOldPTL_c.Concurrent_2__c) || (oOpportunity_PTL_c.Concurrent_2__c == oNewPTL_c.Concurrent_2__c))){
                    status = true;
                    oOpportunity_PTL_c.Concurrent_2__c = oNewPTL_c.Concurrent_2__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Concurrent_2__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Concurrent_2__c] to [' + String.valueOf(oNewPTL_c.Concurrent_2__c) + ']');
                } else {
                    if (oOldPTL_c.Concurrent_2__c == oNewPTL_c.Concurrent_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Concurrent_2__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Concurrent_2__c != oOldPTL_c.Concurrent_2__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Concurrent_2__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Concurrent_2__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Concurrent_2__c) + '])');
                    }
            }
            if ((oOldPTL_c.Concurrent_3__c != oNewPTL_c.Concurrent_3__c) && ((oOpportunity_PTL_c.Concurrent_3__c == oOldPTL_c.Concurrent_3__c) || (oOpportunity_PTL_c.Concurrent_3__c == oNewPTL_c.Concurrent_3__c))){
                    status = true;
                    oOpportunity_PTL_c.Concurrent_3__c = oNewPTL_c.Concurrent_3__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Concurrent_3__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Concurrent_3__c] to [' + String.valueOf(oNewPTL_c.Concurrent_3__c) + ']');
                } else {
                    if (oOldPTL_c.Concurrent_3__c == oNewPTL_c.Concurrent_3__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Concurrent_3__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Concurrent_3__c != oOldPTL_c.Concurrent_3__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Concurrent_3__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Concurrent_3__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Concurrent_3__c) + '])');
                    }
            }
            if ((oOldPTL_c.Zone_stockage__c != oNewPTL_c.Zone_stockage__c) && ((oOpportunity_PTL_c.Zone_stockage__c == oOldPTL_c.Zone_stockage__c) || (oOpportunity_PTL_c.Zone_stockage__c == oNewPTL_c.Zone_stockage__c))){
                    status = true;
                    oOpportunity_PTL_c.Zone_stockage__c = oNewPTL_c.Zone_stockage__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Zone_stockage__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Zone_stockage__c] to [' + String.valueOf(oNewPTL_c.Zone_stockage__c) + ']');
                } else {
                    if (oOldPTL_c.Zone_stockage__c == oNewPTL_c.Zone_stockage__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Zone_stockage__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Zone_stockage__c != oOldPTL_c.Zone_stockage__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Zone_stockage__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Zone_stockage__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Zone_stockage__c) + '])');
                    }
            }
            if ((oOldPTL_c.Bassin_de_vie__c != oNewPTL_c.Bassin_de_vie__c) && ((oOpportunity_PTL_c.Bassin_de_vie__c == oOldPTL_c.Bassin_de_vie__c) || (oOpportunity_PTL_c.Bassin_de_vie__c == oNewPTL_c.Bassin_de_vie__c))){
                    status = true;
                    oOpportunity_PTL_c.Bassin_de_vie__c = oNewPTL_c.Bassin_de_vie__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Bassin_de_vie__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Bassin_de_vie__c] to [' + String.valueOf(oNewPTL_c.Bassin_de_vie__c) + ']');
                } else {
                    if (oOldPTL_c.Bassin_de_vie__c == oNewPTL_c.Bassin_de_vie__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Bassin_de_vie__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Bassin_de_vie__c != oOldPTL_c.Bassin_de_vie__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Bassin_de_vie__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Bassin_de_vie__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Bassin_de_vie__c) + '])');
                    }
            }
            if ((oOldPTL_c.Depot_de_livraison_PLV__c != oNewPTL_c.Depot_de_livraison_PLV__c) && ((oOpportunity_PTL_c.Depot_de_livraison_PLV__c == oOldPTL_c.Depot_de_livraison_PLV__c) || (oOpportunity_PTL_c.Depot_de_livraison_PLV__c == oNewPTL_c.Depot_de_livraison_PLV__c))){
                    status = true;
                    oOpportunity_PTL_c.Depot_de_livraison_PLV__c = oNewPTL_c.Depot_de_livraison_PLV__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Depot_de_livraison_PLV__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Depot_de_livraison_PLV__c] to [' + String.valueOf(oNewPTL_c.Depot_de_livraison_PLV__c) + ']');
                } else {
                    if (oOldPTL_c.Depot_de_livraison_PLV__c == oNewPTL_c.Depot_de_livraison_PLV__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Depot_de_livraison_PLV__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Depot_de_livraison_PLV__c != oOldPTL_c.Depot_de_livraison_PLV__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Depot_de_livraison_PLV__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Depot_de_livraison_PLV__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Depot_de_livraison_PLV__c) + '])');
                    }
            }
            if ((oOldPTL_c.Memes_horaires_toute_la_semaine__c != oNewPTL_c.Memes_horaires_toute_la_semaine__c) && ((oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c == oOldPTL_c.Memes_horaires_toute_la_semaine__c) || (oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c == oNewPTL_c.Memes_horaires_toute_la_semaine__c))){
                    status = true;
                    oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c = oNewPTL_c.Memes_horaires_toute_la_semaine__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Memes_horaires_toute_la_semaine__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c] to [' + String.valueOf(oNewPTL_c.Memes_horaires_toute_la_semaine__c) + ']');
                } else {
                    if (oOldPTL_c.Memes_horaires_toute_la_semaine__c == oNewPTL_c.Memes_horaires_toute_la_semaine__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c != oOldPTL_c.Memes_horaires_toute_la_semaine__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Memes_horaires_toute_la_semaine__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Memes_horaires_toute_la_semaine__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_possible_Lundi__c != oNewPTL_c.Horaires_possible_Lundi__c) && ((oOpportunity_PTL_c.Lundi__c == oOldPTL_c.Horaires_possible_Lundi__c) || (oOpportunity_PTL_c.Lundi__c == oNewPTL_c.Horaires_possible_Lundi__c))){
                    status = true;
                    oOpportunity_PTL_c.Lundi__c = oNewPTL_c.Horaires_possible_Lundi__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Lundi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Lundi__c] to [' + String.valueOf(oNewPTL_c.Horaires_possible_Lundi__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_possible_Lundi__c == oNewPTL_c.Horaires_possible_Lundi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Lundi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Lundi__c != oOldPTL_c.Horaires_possible_Lundi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Lundi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_possible_Lundi__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Lundi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_possible_Mardi__c != oNewPTL_c.Horaires_possible_Mardi__c) && ((oOpportunity_PTL_c.Mardi__c == oOldPTL_c.Horaires_possible_Mardi__c) || (oOpportunity_PTL_c.Mardi__c == oNewPTL_c.Horaires_possible_Mardi__c))){
                    status = true;
                    oOpportunity_PTL_c.Mardi__c = oNewPTL_c.Horaires_possible_Mardi__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Mardi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Mardi__c] to [' + String.valueOf(oNewPTL_c.Horaires_possible_Mardi__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_possible_Mardi__c == oNewPTL_c.Horaires_possible_Mardi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Mardi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Mardi__c != oOldPTL_c.Horaires_possible_Mardi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Mardi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_possible_Mardi__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Mardi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_possible_Mercredi__c != oNewPTL_c.Horaires_possible_Mercredi__c) && ((oOpportunity_PTL_c.Mercredi__c == oOldPTL_c.Horaires_possible_Mercredi__c) || (oOpportunity_PTL_c.Mercredi__c == oNewPTL_c.Horaires_possible_Mercredi__c))){
                    status = true;
                    oOpportunity_PTL_c.Mercredi__c = oNewPTL_c.Horaires_possible_Mercredi__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Mercredi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Mercredi__c] to [' + String.valueOf(oNewPTL_c.Horaires_possible_Mercredi__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_possible_Mercredi__c == oNewPTL_c.Horaires_possible_Mercredi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Mercredi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Mercredi__c != oOldPTL_c.Horaires_possible_Mercredi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Mercredi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_possible_Mercredi__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Mercredi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_possible_Jeudi__c != oNewPTL_c.Horaires_possible_Jeudi__c) && ((oOpportunity_PTL_c.Jeudi__c == oOldPTL_c.Horaires_possible_Jeudi__c) || (oOpportunity_PTL_c.Jeudi__c == oNewPTL_c.Horaires_possible_Jeudi__c))){
                    status = true;
                    oOpportunity_PTL_c.Jeudi__c = oNewPTL_c.Horaires_possible_Jeudi__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Jeudi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Jeudi__c] to [' + String.valueOf(oNewPTL_c.Horaires_possible_Jeudi__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_possible_Jeudi__c == oNewPTL_c.Horaires_possible_Jeudi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Jeudi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Jeudi__c != oOldPTL_c.Horaires_possible_Jeudi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Jeudi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_possible_Jeudi__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Jeudi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_possible_Vendredi__c != oNewPTL_c.Horaires_possible_Vendredi__c) && ((oOpportunity_PTL_c.Vendredi__c == oOldPTL_c.Horaires_possible_Vendredi__c) || (oOpportunity_PTL_c.Vendredi__c == oNewPTL_c.Horaires_possible_Vendredi__c))){
                    status = true;
                    oOpportunity_PTL_c.Vendredi__c = oNewPTL_c.Horaires_possible_Vendredi__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Vendredi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Vendredi__c] to [' + String.valueOf(oNewPTL_c.Horaires_possible_Vendredi__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_possible_Vendredi__c == oNewPTL_c.Horaires_possible_Vendredi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Vendredi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Vendredi__c != oOldPTL_c.Horaires_possible_Vendredi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Vendredi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_possible_Vendredi__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Vendredi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_possible_Samedi__c != oNewPTL_c.Horaires_possible_Samedi__c) && ((oOpportunity_PTL_c.Samedi__c == oOldPTL_c.Horaires_possible_Samedi__c) || (oOpportunity_PTL_c.Samedi__c == oNewPTL_c.Horaires_possible_Samedi__c))){
                    status = true;
                    oOpportunity_PTL_c.Samedi__c = oNewPTL_c.Horaires_possible_Samedi__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Samedi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Samedi__c] to [' + String.valueOf(oNewPTL_c.Horaires_possible_Samedi__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_possible_Samedi__c == oNewPTL_c.Horaires_possible_Samedi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Samedi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Samedi__c != oOldPTL_c.Horaires_possible_Samedi__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Samedi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_possible_Samedi__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Samedi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_preferees_Lundi_txt__c != oNewPTL_c.Horaires_preferees_Lundi_txt__c) && ((oOpportunity_PTL_c.Horaires_preferees_Lundi__c == oOldPTL_c.Horaires_preferees_Lundi_txt__c) || (oOpportunity_PTL_c.Horaires_preferees_Lundi__c == oNewPTL_c.Horaires_preferees_Lundi_txt__c))){
                    status = true;
                    oOpportunity_PTL_c.Horaires_preferees_Lundi__c = oNewPTL_c.Horaires_preferees_Lundi_txt__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Horaires_preferees_Lundi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Horaires_preferees_Lundi__c] to [' + String.valueOf(oNewPTL_c.Horaires_preferees_Lundi_txt__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_preferees_Lundi_txt__c == oNewPTL_c.Horaires_preferees_Lundi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Lundi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Horaires_preferees_Lundi__c != oOldPTL_c.Horaires_preferees_Lundi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Lundi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_preferees_Lundi_txt__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Horaires_preferees_Lundi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_preferees_Mardi_txt__c != oNewPTL_c.Horaires_preferees_Mardi_txt__c) && ((oOpportunity_PTL_c.Horaires_preferees_Mardi__c == oOldPTL_c.Horaires_preferees_Mardi_txt__c) || (oOpportunity_PTL_c.Horaires_preferees_Mardi__c == oNewPTL_c.Horaires_preferees_Mardi_txt__c))){
                    status = true;
                    oOpportunity_PTL_c.Horaires_preferees_Mardi__c = oNewPTL_c.Horaires_preferees_Mardi_txt__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Horaires_preferees_Mardi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Horaires_preferees_Mardi__c] to [' + String.valueOf(oNewPTL_c.Horaires_preferees_Mardi_txt__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_preferees_Mardi_txt__c == oNewPTL_c.Horaires_preferees_Mardi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Mardi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Horaires_preferees_Mardi__c != oOldPTL_c.Horaires_preferees_Mardi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Mardi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_preferees_Mardi_txt__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Horaires_preferees_Mardi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_preferees_Mercredi_txt__c != oNewPTL_c.Horaires_preferees_Mercredi_txt__c) && ((oOpportunity_PTL_c.Horaires_preferees_Mercredi__c == oOldPTL_c.Horaires_preferees_Mercredi_txt__c) || (oOpportunity_PTL_c.Horaires_preferees_Mercredi__c == oNewPTL_c.Horaires_preferees_Mercredi_txt__c))){
                    status = true;
                    oOpportunity_PTL_c.Horaires_preferees_Mercredi__c = oNewPTL_c.Horaires_preferees_Mercredi_txt__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Horaires_preferees_Mercredi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Horaires_preferees_Mercredi__c] to [' + String.valueOf(oNewPTL_c.Horaires_preferees_Mercredi_txt__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_preferees_Mercredi_txt__c == oNewPTL_c.Horaires_preferees_Mercredi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Mercredi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Horaires_preferees_Mercredi__c != oOldPTL_c.Horaires_preferees_Mercredi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Mercredi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_preferees_Mercredi_txt__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Horaires_preferees_Mercredi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_preferees_Jeudi_txt__c != oNewPTL_c.Horaires_preferees_Jeudi_txt__c) && ((oOpportunity_PTL_c.Horaires_preferees_Jeudi__c == oOldPTL_c.Horaires_preferees_Jeudi_txt__c) || (oOpportunity_PTL_c.Horaires_preferees_Jeudi__c == oNewPTL_c.Horaires_preferees_Jeudi_txt__c))){
                    status = true;
                    oOpportunity_PTL_c.Horaires_preferees_Jeudi__c = oNewPTL_c.Horaires_preferees_Jeudi_txt__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Horaires_preferees_Jeudi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Horaires_preferees_Jeudi__c] to [' + String.valueOf(oNewPTL_c.Horaires_preferees_Jeudi_txt__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_preferees_Jeudi_txt__c == oNewPTL_c.Horaires_preferees_Jeudi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Jeudi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Horaires_preferees_Jeudi__c != oOldPTL_c.Horaires_preferees_Jeudi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Jeudi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_preferees_Jeudi_txt__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Horaires_preferees_Jeudi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_preferees_Vendredi_txt__c != oNewPTL_c.Horaires_preferees_Vendredi_txt__c) && ((oOpportunity_PTL_c.Horaires_preferees_Vendredi__c == oOldPTL_c.Horaires_preferees_Vendredi_txt__c) || (oOpportunity_PTL_c.Horaires_preferees_Vendredi__c == oNewPTL_c.Horaires_preferees_Vendredi_txt__c))){
                    status = true;
                    oOpportunity_PTL_c.Horaires_preferees_Vendredi__c = oNewPTL_c.Horaires_preferees_Vendredi_txt__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Horaires_preferees_Vendredi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Horaires_preferees_Vendredi__c] to [' + String.valueOf(oNewPTL_c.Horaires_preferees_Vendredi_txt__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_preferees_Vendredi_txt__c == oNewPTL_c.Horaires_preferees_Vendredi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Vendredi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Horaires_preferees_Vendredi__c != oOldPTL_c.Horaires_preferees_Vendredi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Vendredi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_preferees_Vendredi_txt__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Horaires_preferees_Vendredi__c) + '])');
                    }
            }
            if ((oOldPTL_c.Horaires_preferees_Samedi_txt__c != oNewPTL_c.Horaires_preferees_Samedi_txt__c) && ((oOpportunity_PTL_c.Horaires_preferees_Samedi__c == oOldPTL_c.Horaires_preferees_Samedi_txt__c) || (oOpportunity_PTL_c.Horaires_preferees_Samedi__c == oNewPTL_c.Horaires_preferees_Samedi_txt__c))){
                    status = true;
                    oOpportunity_PTL_c.Horaires_preferees_Samedi__c = oNewPTL_c.Horaires_preferees_Samedi_txt__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Horaires_preferees_Samedi__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Horaires_preferees_Samedi__c] to [' + String.valueOf(oNewPTL_c.Horaires_preferees_Samedi_txt__c) + ']');
                } else {
                    if (oOldPTL_c.Horaires_preferees_Samedi_txt__c == oNewPTL_c.Horaires_preferees_Samedi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Samedi__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Horaires_preferees_Samedi__c != oOldPTL_c.Horaires_preferees_Samedi_txt__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Horaires_preferees_Samedi__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Horaires_preferees_Samedi_txt__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Horaires_preferees_Samedi__c) + '])');
                    }
            }
           if ((oOldPTL_c.Service_de_Drive__c != oNewPTL_c.Service_de_Drive__c) && ((oOpportunity_PTL_c.Service_de_Drive__c == oOldPTL_c.Service_de_Drive__c) || (oOpportunity_PTL_c.Service_de_Drive__c == oNewPTL_c.Service_de_Drive__c))){
                    status = true;
                    oOpportunity_PTL_c.Service_de_Drive__c = oNewPTL_c.Service_de_Drive__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Service_de_Drive__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Service_de_Drive__c] to [' + String.valueOf(oNewPTL_c.Service_de_Drive__c) + ']');
                } else {
                    if (oOldPTL_c.Service_de_Drive__c == oNewPTL_c.Service_de_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Service_de_Drive__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Service_de_Drive__c != oOldPTL_c.Service_de_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Service_de_Drive__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Service_de_Drive__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Service_de_Drive__c) + '])');
                    }
            }
            if ((oOldPTL_c.Vente_de_Gaz_dans_ce_Drive__c != oNewPTL_c.Vente_de_Gaz_dans_ce_Drive__c) && ((oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c == oOldPTL_c.Vente_de_Gaz_dans_ce_Drive__c) || (oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c == oNewPTL_c.Vente_de_Gaz_dans_ce_Drive__c))){
                    status = true;
                    oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c = oNewPTL_c.Vente_de_Gaz_dans_ce_Drive__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Vente_de_Gaz_dans_ce_Drive__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c] to [' + String.valueOf(oNewPTL_c.Vente_de_Gaz_dans_ce_Drive__c) + ']');
                } else {
                    if (oOldPTL_c.Vente_de_Gaz_dans_ce_Drive__c == oNewPTL_c.Vente_de_Gaz_dans_ce_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c != oOldPTL_c.Vente_de_Gaz_dans_ce_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Vente_de_Gaz_dans_ce_Drive__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Vente_de_Gaz_dans_ce_Drive__c) + '])');
                    }
            }
            if ((oOldPTL_c.Marques_de_Gaz_vendues__c != oNewPTL_c.Marques_de_Gaz_vendues__c) && ((oOpportunity_PTL_c.Marques_de_Gaz_vendues__c == oOldPTL_c.Marques_de_Gaz_vendues__c) || (oOpportunity_PTL_c.Marques_de_Gaz_vendues__c == oNewPTL_c.Marques_de_Gaz_vendues__c))){
                    status = true;
                    oOpportunity_PTL_c.Marques_de_Gaz_vendues__c = oNewPTL_c.Marques_de_Gaz_vendues__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Marques_de_Gaz_vendues__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Marques_de_Gaz_vendues__c] to [' + String.valueOf(oNewPTL_c.Marques_de_Gaz_vendues__c) + ']');
                } else {
                    if (oOldPTL_c.Marques_de_Gaz_vendues__c == oNewPTL_c.Marques_de_Gaz_vendues__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Marques_de_Gaz_vendues__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Marques_de_Gaz_vendues__c != oOldPTL_c.Marques_de_Gaz_vendues__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Marques_de_Gaz_vendues__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Marques_de_Gaz_vendues__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Marques_de_Gaz_vendues__c) + '])');
                    }
            }
            if ((oOldPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c != oNewPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c) && ((oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c == oOldPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c) || (oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c == oNewPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c))){
                    status = true;
                    oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c = oNewPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Canal_d_achat_de_la_Bouteille_Butagaz__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c] to [' + String.valueOf(oNewPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c) + ']');
                } else {
                    if (oOldPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c == oNewPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c != oOldPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Canal_d_achat_de_la_Bouteille_Butagaz__c) + '])');
                    }
            }
            if ((oOldPTL_c.Informations_sur_le_Drive__c != oNewPTL_c.Informations_sur_le_Drive__c) && ((oOpportunity_PTL_c.Informations_sur_le_Drive__c == oOldPTL_c.Informations_sur_le_Drive__c) || (oOpportunity_PTL_c.Informations_sur_le_Drive__c == oNewPTL_c.Informations_sur_le_Drive__c))){
                    status = true;
                    oOpportunity_PTL_c.Informations_sur_le_Drive__c = oNewPTL_c.Informations_sur_le_Drive__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Informations_sur_le_Drive__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Informations_sur_le_Drive__c] to [' + String.valueOf(oNewPTL_c.Informations_sur_le_Drive__c) + ']');
                } else {
                    if (oOldPTL_c.Informations_sur_le_Drive__c == oNewPTL_c.Informations_sur_le_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Informations_sur_le_Drive__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Informations_sur_le_Drive__c != oOldPTL_c.Informations_sur_le_Drive__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Informations_sur_le_Drive__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Informations_sur_le_Drive__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Informations_sur_le_Drive__c) + '])');
                    }
            }
            if ((oOldPTL_c.Segmentation__c != oNewPTL_c.Segmentation__c) && ((oOpportunity_PTL_c.Segmentation__c == oOldPTL_c.Segmentation__c) || (oOpportunity_PTL_c.Segmentation__c == oNewPTL_c.Segmentation__c))){
                    status = true;
                    oOpportunity_PTL_c.Segmentation__c = oNewPTL_c.Segmentation__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Segmentation__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Segmentation__c] to [' + String.valueOf(oNewPTL_c.Segmentation__c) + ']');
                } else {
                    if (oOldPTL_c.Segmentation__c == oNewPTL_c.Segmentation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Segmentation__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Segmentation__c != oOldPTL_c.Segmentation__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Segmentation__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Segmentation__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Segmentation__c) + '])');
                    }
            }
            if ((oOldPTL_c.Description__c != oNewPTL_c.Description__c) && ((oOpportunity_PTL_c.Description__c == oOldPTL_c.Description__c) || (oOpportunity_PTL_c.Description__c == oNewPTL_c.Description__c))){
                    status = true;
                    oOpportunity_PTL_c.Description__c = oNewPTL_c.Description__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Description__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Description__c] to [' + String.valueOf(oNewPTL_c.Description__c) + ']');
                } else {
                    if (oOldPTL_c.Description__c == oNewPTL_c.Description__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Description__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Description__c != oOldPTL_c.Description__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Description__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Description__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Description__c) + '])');
                    }
            }
            if ((oOldPTL_c.Nombre_bouteilles_distributeur_cles__c != oNewPTL_c.Nombre_bouteilles_distributeur_cles__c) && ((oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c == oOldPTL_c.Nombre_bouteilles_distributeur_cles__c) || (oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c == oNewPTL_c.Nombre_bouteilles_distributeur_cles__c))){
                    status = true;
                    oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c = oNewPTL_c.Nombre_bouteilles_distributeur_cles__c;
                    oOpportunity_PTL_c.T_PTL_cFieldsToChange__c += '___Nombre_bouteilles_distributeur_cles__c___';
                    System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Synced field [oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c] to [' + String.valueOf(oNewPTL_c.Nombre_bouteilles_distributeur_cles__c) + ']');
                } else {
                    if (oOldPTL_c.Nombre_bouteilles_distributeur_cles__c == oNewPTL_c.Nombre_bouteilles_distributeur_cles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c] :: Field was not changed.');
                    }
                    if (oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c != oOldPTL_c.Nombre_bouteilles_distributeur_cles__c) {
                        System.debug('[AP_SyncOpportunity_PTL_cFromPTL_c_01.propagatePTL_Fields] Skipped field [oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c] :: No sync, fields have changed (source:[' + String.valueOf(oOldPTL_c.Nombre_bouteilles_distributeur_cles__c) + '] != synced:[' + String.valueOf(oOpportunity_PTL_c.Nombre_bouteilles_distributeur_cles__c) + '])');
                    }
            }
            
            
            // END_AUTO_PROPAGATE_PTL__r
        }
        return status;
    }
    
}