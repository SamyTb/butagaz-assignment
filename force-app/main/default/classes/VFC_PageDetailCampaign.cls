public class VFC_PageDetailCampaign {

    private List<Campaign> Camp;
    private PTL__c PTL_campmkt;
    Set<String> setIP = new Set<String>();
    List<Id> listUniqueCMId = new list<Id>();
   

    public VFC_PageDetailCampaign(ApexPages.StandardController controller) 
    {
        this.PTL_campmkt= (PTL__c)controller.getRecord();
        system.debug('MLC PTL' + this.PTL_campmkt );
    }
    
  
 	// Selection des campagnes marketing liees au PTL  
    public List<Campaign> getCamp()
    {
        
        if(PTL_campmkt!=null){
        
	     	PTL__c ptl = [Select id, Contact_Marketing__c FROM PTL__c where id = :PTL_campmkt.id];
	     	
			camp = [ SELECT Id, Name, RecordTypeid, IsActive, Alerte_Campagne__c,Status,
			     								Parent.Name,StartDate, Type ,  
			     								(SELECT id,HasResponded,Status,Interested_date__c,ContactId 
			     								 FROM CampaignMembers  
			     								 WHERE ContactId = :ptl.Contact_Marketing__c
			     								 AND ContactId != null
			     								 AND HasResponded=false	  LIMIT 5) CampaignMembersSelect		
			         FROM Campaign 
		             WHERE Id IN 
		                 ( SELECT CampaignID FROM CampaignMember WHERE ContactId =  :ptl.Contact_Marketing__c AND ContactId != null AND HasResponded=false ) 
		             AND Status in ('In progress','Planned')  
		             ORDER BY StartDate LIMIT 5	                    
			       ];  
		
        }
			                    		
        if(camp.size() == 0){
            return null;
        }else{
            return camp ;
        }
        
		
		
    }
    
   
}