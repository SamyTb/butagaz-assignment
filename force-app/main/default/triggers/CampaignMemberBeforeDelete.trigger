trigger CampaignMemberBeforeDelete on CampaignMember (before delete) {
    if (Trigger.IsBefore && Trigger.IsDelete) {
        System.Debug('##>>> CampaignMember.BeforeDelete : BEGIN <<< run by ' + UserInfo.getName());
        List<CampaignMember> lCampaignMembers = Trigger.old;
        
        if (PAD.canTrigger('CampaignMember.checkDeleteRight')){
            AP_CampaignMember_01.checkDeleteRight(lCampaignMembers);
        } 
        else{
            System.Debug('##>>> CampaignMember.BeforeDelete : BYPASS checkDeleteRight <<< run by ' + UserInfo.getName());
        }
        System.Debug('##>>> CampaignMember.BeforeDelete : END <<<');
    } 
    else{
        System.Debug('##>>> CampaignMember.BeforeDelete : FALSE TRIGGER <<<');
    }

}