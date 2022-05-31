public class matriceSAP
{
    public String projetType;
    public String projetSubType;
    public String opportunityReason;
    public String storageModificationReason;
    public String PTL;
    public String sDO;
    public String hierarchie;
    public String remise;
    public String calendrierFacturation;
    public String contrat;
    public String raisonCdeContratCrea;
    public String raisonCdeMvt;
    public String cdeMvtCiterne;
    
    public matriceSAP(String projetType, String projetSubType, String opportunityReason, String storageModificationReason, String PTL, String sDO, String hierarchie,
                      String remise, String calendrierFacturation, String contrat, String raisonCdeContratCrea, String raisonCdeMvt, String cdeMvtCiterne)
    {
            this.projetType = projetType;
            this.projetSubType = projetSubType;
            this.opportunityReason = opportunityReason;
            this.storageModificationReason = storageModificationReason;
            this.PTL = PTL;
            this.sDO = sDO;
            this.hierarchie = hierarchie;
            this.remise = remise;
            this.calendrierFacturation = calendrierFacturation;
            this.contrat = contrat;
            this.raisonCdeContratCrea = raisonCdeContratCrea;
            this.raisonCdeMvt = raisonCdeMvt;
            this.cdeMvtCiterne = cdeMvtCiterne;

    }
}