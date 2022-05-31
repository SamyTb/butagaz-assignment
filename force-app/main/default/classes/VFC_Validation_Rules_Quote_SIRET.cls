public class VFC_Validation_Rules_Quote_SIRET {

        Quote current;
        
        ApexPages.StandardController stdController;
        
    public VFC_Validation_Rules_Quote_SIRET(ApexPages.StandardController controller) {
                this.stdController = controller;
        current = (Quote) stdController.getRecord();
    }
    
    private Opportunity getOpty(Quote current) {
        Quote devis = [select OpportunityId from Quote where Id = :current.Id];
        
        Opportunity opty = [SELECT DO_Code_SIRET__c, DO_En_cours_d_immatriculation__c, Project_Type__c, Account.RecordType.Name FROM Opportunity WHERE Id = :devis.OpportunityID];
        return opty;
    }
    
    public Boolean isSiretEnCoursDImmatOrFill(Opportunity opty) {
        Boolean isCorrect;
        
        String codeSiret = opty.DO_Code_SIRET__c;
        String projectType = opty.Project_Type__c;
        String recordType = opty.Account.RecordType.Name;
        Boolean enCoursDImmat = opty.DO_En_cours_d_immatriculation__c;
        
        if(recordType == 'Pro' && (projectType == 'CREA' || projectType == 'FIDE') && ((String.IsBlank(codeSiret) && enCoursDImmat == false) || (String.IsNotBlank(codeSiret) && enCoursDImmat == true))) {
                isCorrect = false;
        } else {
                isCorrect = true;
        }
        
        return isCorrect;
    }
    
    public pageReference back() {
        return new PageReference('/' + current.Id);
    }
    
    public pageReference launchVerifSiretToCreateContractPdf() {
        
        Boolean siretEnCoursDImmatOrFill = isSiretEnCoursDImmatOrFill(getOpty(current));
        
        if(siretEnCoursDImmatOrFill) {
                ApexPages.Pagereference pageRef = Page.VFP_ContractPDF;
                pageRef.getParameters().put('id', current.Id);
                return pageRef;
        } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Un et un seul des deux champs \"Code SIRET\" et \"En cours d\'immatriculation\", au niveau du Compte, doit être renseigné.');
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}