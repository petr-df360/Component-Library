public class UserTriggerHelper {
    

    public static void assignSharingId(List<User> users) {
        for(User u : users) {
            if(u.UserType != 'AutomatedProcess') {
                String sharingId = GuidUtil.getSharingId();
                System.debug('sharingId '+sharingId);
                u.Sharing_Id__c = sharingId;
            }
        }
    }

}