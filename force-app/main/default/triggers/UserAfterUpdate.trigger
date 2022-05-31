trigger UserAfterUpdate on User (after update) {

	if (Trigger.IsAfter && Trigger.IsUpdate) {

		if (PAD.canTrigger('User.revokePackageLicenseFromUser')){
            List<User> userToUpdateList = new List<User>();
            
            for(User usr : Trigger.new)
            {
            	// if user goes inactive, we want to process it
                if( !usr.IsActive && System.Trigger.OldMap.get(usr.Id).IsActive )
                {
                    userToUpdateList.add(usr);
                }
            }
            if(userToUpdateList.size() > 0){
        		VFC_User.revokePackageLicenseFromUser(userToUpdateList);
            }
        } 
        else{
            System.Debug('##>>> User.AfterUpdate : BYPASS revokePackageLicenseFromUser <<< run by ' + UserInfo.getName());
        }

	}

}