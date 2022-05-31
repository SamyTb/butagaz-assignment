public class Announcements_Utilities {
    public static Boolean recordExists(Id announcementId, Id userId) {
        Integer nRecords = [
            SELECT COUNT() 
            FROM Announcement_Seen__c
            WHERE Announcement__c=:announcementId AND User__c=:userId
            ];
        return nRecords > 0;
    }
}