public without sharing class VFC_Announcement {

    /* INSTANCE VARIABLES */
    private Announcement__c currentAnnouncement = null;
    private ApexPages.StandardController stdController = null;
    private Id currentUserId = null; //The ID of the current Id (Mostly useful for Debug)
    
    
    /* USER PART */
    public ID getCurrentUserID(){
        if (this.currentUserId == null){
            this.currentUserId = UserInfo.getUserId();
        }
        return this.currentUserId;
    }
    
    /* EXTENSION CONSTRUCTOR */
    public VFC_Announcement(ApexPages.StandardController stdController) {
        this.stdController = stdController;
    }
    
    /* UTILITY METHOD: ANNOUNCEMENT EXISTS */
    
    public Boolean getAnnouncementExists() {
        return this.getCurrentAnnouncement().Id != null;
    }
    
    /* MARK THE ANNOUNCEMENT AS SEEN BY THE USER */
    public void recordAnnouncementSeen() {
        if (this.getAnnouncementExists()){
            System.Debug('[recordAnnouncementSeen] Announcement exists with ID ' + String.valueOf(this.getCurrentAnnouncement().Id));
            if (Announcements_Utilities.recordExists(this.getCurrentAnnouncement().Id, this.getCurrentUserID())){
                System.Debug('[recordAnnouncementSeen] User has already seen record - passing.');
            } else {
                System.Debug('[recordAnnouncementSeen] Creating new Announcement_Seen record');
                Announcement_Seen__c announcementSeenRecord = new Announcement_Seen__c (
                    announcement__c = this.getCurrentAnnouncement().Id,
                    user__c = this.getCurrentUserID()
                );
                
                System.debug('ToInsert:' + announcementSeenRecord);
                insert announcementSeenRecord;
                System.Debug('[recordAnnouncementSeen] Inserted record with Id ' + String.valueOf(announcementSeenRecord.Id));
            }
        } else {
            System.Debug('[recordAnnouncementSeen] Announcement does not exist');
        }
    }
    
    /* ANNOUNCEMENT GETTER */
    public Announcement__c getCurrentAnnouncement() {
        if (this.currentAnnouncement == null) {
            this.currentAnnouncement = (Announcement__c)this.stdController.getRecord();
        }
        return this.currentAnnouncement;
    }
}