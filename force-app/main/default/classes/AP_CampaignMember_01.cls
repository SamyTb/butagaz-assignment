public class AP_CampaignMember_01 {
	public static void checkDeleteRight(List<CampaignMember> lCampaignMembers){
        
		System.debug('START method AP_CampaignMember_01.checkDeleteRight');   
		
		User oUser=[select Id, UserPermissionsMarketingUser from User where Id=:UserInfo.getUserId()];
		
		if(!oUser.UserPermissionsMarketingUser){    
	    	for(CampaignMember oCampaignMember:lCampaignMembers){ 
	            oCampaignMember.addError(System.Label.cannot_Delete_CampaignMember);
	        }
		}
        		
		System.debug('END method AP_CampaignMember_01.checkDeleteRight');        		
	}
}