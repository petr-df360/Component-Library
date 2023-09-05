public without sharing class FavoritesController {
    
    @AuraEnabled
    public static boolean addToFavorites(String documentId) {
        String userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, Sharing_Id__c FROM User WHERE Id = :userId];
        
        List<Document__c> documents = [SELECT Id, User_To_Favorites__c FROM Document__c WHERE Id = :documentId];
        
        if(!documents.isEmpty() && !users.isEmpty()) {
            if(users[0].Sharing_Id__c == null) {
                System.debug('Sharing ID is not defined!');
               	return false;
            }
            documents[0].User_To_Favorites__c = users[0].Sharing_Id__c;
            update documents[0];
            return true;
        }
        
        return false; 
        
    }
    
    @AuraEnabled
    public static Boolean removeFromFavorites(String documentId) {
        String userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, Sharing_Id__c FROM User WHERE Id = :userId];
        
        List<Document__c> documents = [SELECT Id, User_From_Favorites__c FROM Document__c WHERE Id = :documentId];
        
        if(!documents.isEmpty() && !users.isEmpty()) {
            if(users[0].Sharing_Id__c == null) {
                System.debug('Sharing ID is not defined!');
               	return false;
            }
            System.debug('not null!');
            documents[0].User_From_Favorites__c = users[0].Sharing_Id__c;
            update documents[0];
            return true;   
        }
        
       return false;
        
    }

}