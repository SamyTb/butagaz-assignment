public class ProjectMgr {
    
    
    /*
        Used to create Project__c records based on leads
    */
    //@future 
    public static void createProjectFromLead(List<Id> leadRecordIds){
        
        List<Project__c> projectsToInsert = new List<Project__c>();
        
        Id leadIsolationRT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Service_Isolation_Combles_Perdus').getRecordTypeId();
        Id leadCuveFioulRT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Service_Recyclage_Cuve_Fioul').getRecordTypeId();
        Id leadSolaireRT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Service_Solaire').getRecordTypeId();
        Id leadChauffageInstallationMaterielRT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Service_Chauffage_Installation_Materiel').getRecordTypeId();
        
        Id projectIsolationRT = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Isolation').getRecordTypeId();
        Id projectCuveFioulRT = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Recyclage_Cuve_Fioul').getRecordTypeId();
        Id projectSolaireRT = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Solaire').getRecordTypeId();
        Id projectChauffageInstallationMaterielRT = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Chauffage_Installation_de_materiel').getRecordTypeId();
        
        /*List<Lead> lLeadsTest = [SELECT Id, ConvertedAccountId, LeadSource, RecordTypeId, RecordType.DeveloperName, Project_Departement__c, Housing_Type__c, Lost_Roofs__c, Heated_Housing__c, Housing_Over_2_Years__c, Lost_Roofs_Accessibility__c, Lost_Roofs_Surface__c
                            FROM Lead 
                            WHERE Id IN :leadRecordIds];
                            
        if(lLeadsTest.size() > 0){
            for(Lead oLead : lLeadsTest){
                System.debug('##### oLead.Info : ' + oLead.ConvertedAccountId + ' - ' + oLead.RecordTypeId + ' - ' + oLead.RecordType.DeveloperName + ' - ');
            }
        }*/


        List<Lead> lLeads = [SELECT Id, ConvertedAccountId, ExternalID__c, LeadSource, RecordTypeId, Project_Departement__c, Housing_Type__c, Lost_Roofs__c, Heated_Housing__c, Housing_Over_2_Years__c, Lost_Roofs_Accessibility__c, Lost_Roofs_Surface__c,
                                /*Offer__c, Housing_Data__c,*/ Equipments__c, Roof_Angle__c, Roof_Orientation__c, Installation_Efficiency__c, Roof_Surface__c, Estimated_Annual_Consumption__c,
                                Amount_Saved_On_The_Invoice__c, Percentage_Of_Invoice_Reduction__c, Recovery_Period__c, Refined_Recovery_Period__c, Profit_Over_20_Years__c, Profit_Excluding_Installation_Costs__c,
                                Gross_Annual_Energy_Production__c, Self_Consumption_Rate_Estimate__c, Amount_Of_The_Investment_Bonus__c, Amount_Of_Tax_Credit__c, Annual_Production__c, Investment_Cost_Per_WC__c,
                                Installation_Power__c, Max_Installation_Power__c, Maximum_Number_Of_Solar_Panels__c, Pre_Tax_Investment_Amount__c, Investment_Amount_With_Tax_With_Aid__c, Investment_Amount_With_Tax_Without_Aid__c,
                                Sunshine_Rate__c, Project_Location__Latitude__s, Project_Location__Longitude__s, Installer__c, Installer_Comments__c
                            FROM Lead 
                            WHERE Id IN :leadRecordIds
                            AND RecordType.DeveloperName IN ('Service_Isolation_Combles_Perdus', 'Service_Recyclage_Cuve_Fioul', 'Service_Solaire', 'Service_Chauffage_Installation_Materiel')];
                            //AND LeadSource IN ('Isolation Combles Perdus', 'Recyclage Cuve Fioul')];
        
        if(lLeads.size() > 0){
            
            List<Project_Subcontractor__c> lSubContractors = [SELECT Id, Name, Project_Type__c, Group__c, Department__c FROM Project_Subcontractor__c];
            Set<String> subContractorDepartments = new Set<String>();
            System.debug('### lSubContractors : ' + lSubContractors);
            
            for(Lead oLead : lLeads){
                
                // Get the project type based on the lead source
                String sProjectType = '';
                if(oLead.RecordTypeId == leadIsolationRT){
                    sProjectType = 'Isolation Combles Perdus';
                }else if (oLead.RecordTypeId == leadCuveFioulRT){
                    sProjectType = 'Recyclage cuve fioul';
                }else if (oLead.RecordTypeId == leadSolaireRT){
                    sProjectType = 'Solaire';
                }else if (oLead.RecordTypeId == leadChauffageInstallationMaterielRT){
                    sProjectType = 'Chauffage Installation Materiel';
                }
                
                Id subContractorId = null;
                if(lSubContractors.size() > 0){
                    for(Project_Subcontractor__c oSubContractor : lSubContractors){
                        if( !String.isBlank(oSubContractor.Department__c) ){
                            subContractorDepartments.clear();
                            subContractorDepartments.addAll(oSubContractor.Department__c.split(';'));
                            if( oSubContractor.Project_Type__c == sProjectType /*&& oSubContractor.Group__c == oLead.Group__c*/ && subContractorDepartments.size() > 0 && subContractorDepartments.contains(oLead.Project_Departement__c) ){
                                subContractorId = oSubContractor.Id;
                                System.debug('### subContractorId : ' + subContractorId);
                                break;
                            }
                        }
                    }
                }
                
                
                Project__c oProject = new Project__c();
                
                oProject.Project_Type__c = sProjectType;
                oProject.Customer_Account__c = oLead.ConvertedAccountId;
                oProject.Same_Address__c = true;
                
                if(oLead.RecordTypeId == leadIsolationRT){
                    oProject.RecordTypeId = projectIsolationRT;
                    oProject.Housing_Type__c = oLead.Housing_Type__c;
                    oProject.Lost_Roofs__c = oLead.Lost_Roofs__c;
                    oProject.Heated_Housing__c = oLead.Heated_Housing__c;
                    oProject.Housing_Over_2_Years__c = oLead.Housing_Over_2_Years__c;
                    oProject.Lost_Roofs_Accessibility__c = oLead.Lost_Roofs_Accessibility__c;
                    oProject.Lost_Roofs_Surface__c = oLead.Lost_Roofs_Surface__c;
                    oProject.Subcontractor__c = subContractorId;
                }else if (oLead.RecordTypeId == leadCuveFioulRT){
                    oProject.RecordTypeId = projectCuveFioulRT;
                    oProject.Subcontractor__c = subContractorId;
                }else if (oLead.RecordTypeId == leadSolaireRT){
                    oProject.RecordTypeId = projectSolaireRT;
                    oProject.Subcontractor__c = subContractorId;
                    oProject.Lead_External_Id__c = oLead.ExternalID__c;

                    //oProject.Offer__c = oLead.Offer__c;
                    //oProject.Housing_Data__c = oLead.Offer__c;
                    oProject.Equipments__c = oLead.Equipments__c;
                    oProject.Roof_Angle__c = oLead.Roof_Angle__c;
                    oProject.Roof_Orientation__c = oLead.Roof_Orientation__c;
                    oProject.Installation_Efficiency__c = oLead.Installation_Efficiency__c;
                    oProject.Roof_Surface__c = oLead.Roof_Surface__c;
                    oProject.Estimated_Annual_Consumption__c = oLead.Estimated_Annual_Consumption__c;
                    oProject.Amount_Saved_On_The_Invoice__c = oLead.Amount_Saved_On_The_Invoice__c;
                    oProject.Percentage_Of_Invoice_Reduction__c = oLead.Percentage_Of_Invoice_Reduction__c;
                    oProject.Recovery_Period__c = oLead.Recovery_Period__c;
                    oProject.Refined_Recovery_Period__c = oLead.Refined_Recovery_Period__c;
                    oProject.Profit_Over_20_Years__c = oLead.Profit_Over_20_Years__c;
                    oProject.Profit_Excluding_Installation_Costs__c = oLead.Profit_Excluding_Installation_Costs__c;
                    oProject.Gross_Annual_Energy_Production__c = oLead.Gross_Annual_Energy_Production__c;
                    oProject.Self_Consumption_Rate_Estimate__c = oLead.Self_Consumption_Rate_Estimate__c;
                    oProject.Amount_Of_The_Investment_Bonus__c = oLead.Amount_Of_The_Investment_Bonus__c;
                    oProject.Amount_Of_Tax_Credit__c = oLead.Amount_Of_Tax_Credit__c;
                    oProject.Annual_Production__c = oLead.Annual_Production__c;
                    oProject.Investment_Cost_Per_WC__c = oLead.Investment_Cost_Per_WC__c;
                    oProject.Installation_Power__c = oLead.Installation_Power__c;
                    oProject.Max_Installation_Power__c = oLead.Max_Installation_Power__c;
                    oProject.Maximum_Number_Of_Solar_Panels__c = oLead.Maximum_Number_Of_Solar_Panels__c;
                    oProject.Pre_Tax_Investment_Amount__c = oLead.Pre_Tax_Investment_Amount__c;
                    oProject.Investment_Amount_With_Tax_With_Aid__c = oLead.Investment_Amount_With_Tax_With_Aid__c;
                    oProject.Investment_Amount_With_Tax_Without_Aid__c = oLead.Investment_Amount_With_Tax_Without_Aid__c;
                    oProject.Sunshine_Rate__c = oLead.Sunshine_Rate__c;
                    oProject.Project_Location__Latitude__s = oLead.Project_Location__Latitude__s;
                    oProject.Project_Location__Longitude__s = oLead.Project_Location__Longitude__s;
                    oProject.Installer__c = oLead.Installer__c;
                    oProject.Installer_Comments__c = oLead.Installer_Comments__c;
                }if(oLead.RecordTypeId == leadChauffageInstallationMaterielRT){
                    oProject.RecordTypeId = projectChauffageInstallationMaterielRT;
                    //oProject.Subcontractor__c = subContractorId;    Decision : No automatic determination of the subcontractor because there is a lot of overlaps on same departments managed by different subcontractors
                }
                
                projectsToInsert.add(oProject);
            }
        }
        
        if(projectsToInsert.size() > 0){
            try {
                insert projectsToInsert;
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        
    }
    

    public static Project_Subcontractor__c getSubcontractor(String pProjectType, String pDepartment) {

        List<Project_Subcontractor__c> lSubContractors = [SELECT Id, Name, Project_Type__c, Group__c, Department__c FROM Project_Subcontractor__c];
        Set<String> subContractorDepartments = new Set<String>();
        System.debug('### lSubContractors : ' + lSubContractors);
        
        Project_Subcontractor__c subContractorToReturn = new Project_Subcontractor__c();
        //Id subContractorId = null;
        if(lSubContractors.size() > 0){
            for(Project_Subcontractor__c oSubContractor : lSubContractors){
                subContractorDepartments.clear();
                subContractorDepartments.addAll(oSubContractor.Department__c.split(';'));
                if( oSubContractor.Project_Type__c == pProjectType /*&& oSubContractor.Group__c == oLead.Group__c*/ && subContractorDepartments.size() > 0 && subContractorDepartments.contains(pDepartment) ){
                    //subContractorId = oSubContractor.Id;
                    subContractorToReturn = oSubContractor;
                    System.debug('### subContractorId : ' + subContractorToReturn.Id);
                    System.debug('### subContractorName : ' + subContractorToReturn.Name);
                    break;
                }
            }
        }
        
        return subContractorToReturn;
    }

}