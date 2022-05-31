public class VFC_Announcements_Latest {

    /* INSTANCE VARIABLES */
    private List<Announcement__c> lAnnouncements = null; //The list of active Announcements
    private Boolean displayPopUp = null; //Whether or not we should display the PopUp
    private Id currentUserId = null; //The ID of the current Id (Mostly useful for Debug)
    
    
    /* USER PART */
    public ID getCurrentUserID(){
        if (this.currentUserId == null){
            this.currentUserId = UserInfo.getUserId();
        }
        return this.currentUserId;
    }
    
    /* DISPLAY EVALUATION PART */
    public Boolean evalDisplay(){
        if (this.getNoAnnouncements()){
                // Fail gracefully when we have no accouncement.
                return false;
        }
        Id latestAnnouncementId = this.getLatestAnnouncement().Id;
        Id userId = this.getCurrentUserID();
        System.Debug('[evalDisplay] Searching for record for announcement ' + String.valueOf(latestAnnouncementId) + 'and user ' + String.valueOf(userId));
        
        if (AP_Announcements_Utilities.recordExists(latestAnnouncementId, userId)){
            System.Debug('[evalDisplay] User already saw the announcement');
            return false;
        } else {
            System.Debug('[evalDisplay] User didn\'t see the announcement');
            return true;
        }
    }

    /* POPUP PART */
    
    public Boolean getDisplayPopUp(){
        if (this.displayPopUp == null) {
            System.Debug('[getDisplayPopUp] displayPopUp value unavailable, calculating');
            this.displayPopUp = this.evalDisplay();
        }
        System.Debug('[getDisplayPopUp] displayPopUp value is ' + String.valueOf(this.displayPopUp));
        return this.displayPopUp;
    }

    /* ANNOUNCEMENTS PART */
    public list<Announcement__c> getLAnnouncements() {
        if (this.lAnnouncements == null) {
            this.lAnnouncements = [
                SELECT ID, Name, Body__c, CreatedDate 
                FROM Announcement__c 
                WHERE  Active__c=true
                ORDER BY Sequence_Number__c
                DESC
            ];
        }
        System.debug(LoggingLevel.ERROR, this.lAnnouncements == null);
        return this.lAnnouncements;
    }
    
    public Announcement__c getLatestAnnouncement() {
        list<Announcement__c> lAnnouncements = this.getLAnnouncements();
        if (!(lAnnouncements.isEmpty())){
            return lAnnouncements[0];
        }
        return null;
    }
    
    /* TEMPLATE UTILITY FUNCTIONS */
    
    public Boolean getNoAnnouncements() {
        return this.getLAnnouncements().isEmpty();
    }
 }