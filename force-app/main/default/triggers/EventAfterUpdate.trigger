trigger EventAfterUpdate on Event (after update) {
    if (Trigger.IsAfter && Trigger.IsUpdate) {
        System.Debug('##>>> Event.AfterUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Event> lEvents = Trigger.new;
        
        if (PAD.canTrigger('Event.putAcCodeInEvent')){
            if(!AP_Event.hasAlreadyUpdatedEvent()){
                AP_Event.setAlreadyUpdatedEvent(true);
                AP_Event.putAcCodeInEvent(lEvents);
                AP_Event.setAlreadyUpdatedEvent(false);
            }           
        } 
        else{
            System.Debug('##>>> AP_Event.putAcCodeInEvent : BYPASS putAcCodeInEvent <<< run by ' + UserInfo.getName());
        }  
               
        if (PAD.canTrigger('Event.putSegmentationScoringInEvent')){
            if(!AP_Event.hasAlreadyUpdatedEvent()){
                AP_Event.setAlreadyUpdatedEvent(true);
                AP_Event.putSegmentationScoringInEvent(lEvents);
                AP_Event.setAlreadyUpdatedEvent(false);
                
            }            
        } 
        else{
            System.Debug('##>>> AP_Event.putSegmentationScoringInEvent : BYPASS putSegmentationScoringInEvent <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('Event.putSObjectInfoInEvent')){
            //if(!AP_Event.hasAlreadyUpdatedEvent()){
            if(!System.isFuture() && !System.isBatch()){
            	
            	List<Id> lEventIds = new list<Id>();
            	for(Event oEvent:lEvents){
            		lEventIds.add(oEvent.Id);
            	}
            	
                //AP_Event.setAlreadyUpdatedEvent(true);
                //AP_Event.putSObjectInfoInEvent(lEvents);
                AP_Event.putSObjectInfoInEvent(lEventIds);
                //AP_Event.setAlreadyUpdatedEvent(false);
                
            }            
        } 
        else{
            System.Debug('##>>> AP_Event.putSObjectInfoInEvent : BYPASS putSObjectInfoInEvent <<< run by ' + UserInfo.getName());
        }
        
        
     /*   if (PAD.canTrigger('Event.putSObjectInfoPTLGEBInEvent')){
          if(!AP_Event.hasAlreadyUpdatedEvent()){
            AP_Event.setAlreadyUpdatedEvent(true);
            AP_Event.putSObjectInfoPTLGEBInEvent(lEvents);
            AP_Event.setAlreadyUpdatedEvent(false);
            
          }            
        } 
        else{
            System.Debug('##>>> AP_Event.putSObjectInfoPTLGEBInEvent : BYPASS putSObjectInfoPTLGEBInEvent <<< run by ' + UserInfo.getName());
        }*/
        
         
    } 
    else{
        System.Debug('##>>> Event.AfterUpdate : FALSE TRIGGER <<<');
    }
    
}