public class AP04LeadAutoConvert {
    /**
     * convertLeads converts leads provided in input list param
     *
     * @param {List<ID>} leadIds
     *
     * @return {void}
     */
    @InvocableMethod(label='Convert leads' description='Converts list of leads provided.')
    public static void convertLeads(List<Id> leadIds){
        LeadStatus oLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for (id currentlead: leadIds) {
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(currentlead);                
            Leadconvert.setConvertedStatus(oLeadStatus.MasterLabel);
            Leadconvert.setDoNotCreateOpportunity(true); //Remove this line if you want to create an opportunity from Lead Conversion 
            MassLeadconvert.add(Leadconvert);
        }
        
        if (!MassLeadconvert.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
        }
    }

}