public with sharing class GDB_ProductCarouselController {
    /**
    * Get medias
    * @param {String} recordId
    * @return {List<GDB_article_media__c>}
     */
     @AuraEnabled
     public static List<GDB_article_media__c> getMedia(String recordId){
         return GDB_ProductUtils.getMediaByArticleId(recordId);
     }
}