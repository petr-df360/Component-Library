public class SharepointResponses {
    
    public class tokenResponse {
        
        public String token_type;
        public String expires_in;
        public String not_before;
        public String expires_on;
        public String resource;
        public String access_token;
    }
    
    public class simpleUploadResponse {
        
        public String odata_metadata;
        public String odata_type;
        public String odata_id;
        public String odata_editLink;
        public String CheckInComment;
        public Integer CheckOutType;
        public String ContentTag;
        public Integer CustomizedPageStatus;
        public String ETag;
        public Boolean Exists;
        public Boolean IrmEnabled;
        public String Length;
        public Integer Level;
        //public Object LinkingUri; //is object because null was returned
        public String LinkingUrl;
        public Integer MajorVersion;
        public Integer MinorVersion;
        public String Name;
        public String ServerRelativeUrl;
        public String TimeCreated;
        public String TimeLastModified;
        //public Object Title; //is object because null was returned
        public Integer UIVersion;
        public String UIVersionLabel;
        public String UniqueId;
    }
    
    public class createFolderResponse {
        
        public String odata_metadata;
        public String odata_type;
        public String odata_id;
        public String odata_editLink;
        public Boolean Exists;
        public Boolean IsWOPIEnabled;
        public Integer ItemCount;
        public String Name;
        //public Object ProgID;//object because response was null 
        public String ServerRelativeUrl;
        public String TimeCreated;
        public String TimeLastModified;
        public String UniqueId;
        public String WelcomePage;
    }
    
    //same for start upload and continue upload
    public class chunkUploadResponse{
        
        public String odata_metadata;
        public String value;
    }
    
    public class finishUploadResponse {
        public String odata_metadata {get;set;} // in json: odata.metadata
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public String CheckInComment {get;set;} 
        public Integer CheckOutType {get;set;} 
        public String ContentTag {get;set;} 
        public Integer CustomizedPageStatus {get;set;} 
        public String ETag {get;set;} 
        public Boolean Exists {get;set;} 
        public Boolean IrmEnabled {get;set;} 
        public String Length {get;set;} 
        public Integer Level {get;set;} 
        //public Object LinkingUri {get;set;} 
        public String LinkingUrl {get;set;} 
        public Integer MajorVersion {get;set;} 
        public Integer MinorVersion {get;set;} 
        public String Name {get;set;}
        @AuraEnabled
        public String ServerRelativeUrl {get;set;} 
        public String TimeCreated {get;set;} 
        public String TimeLastModified {get;set;} 
        public String Title {get;set;} 
        public Integer UIVersion {get;set;} 
        public String UIVersionLabel {get;set;} 
        public String UniqueId {get;set;} 
    }
    
    public class SharepointUser {
        public String odata_metadata {get;set;} // in json: odata.metadata
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public Integer Id {get;set;} 
        public Boolean IsHiddenInUI {get;set;} 
        public String LoginName {get;set;} 
        public String Title {get;set;} 
        public Integer PrincipalType {get;set;} 
        public String Email {get;set;} 
        public Boolean IsEmailAuthenticationGuestUser {get;set;} 
        public Boolean IsShareByEmailGuestUser {get;set;} 
        public Boolean IsSiteAdmin {get;set;} 
        public UserId UserId {get;set;} 
    }
    
    public class UserId {
        public String NameId {get;set;} 
        public String NameIdIssuer {get;set;}   
    }
    
    public class SharepointGroup {
        
        public String odata_metadata {get;set;} // in json: odata.metadata
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public Integer Id {get;set;} 
        public Boolean IsHiddenInUI {get;set;} 
        public String LoginName {get;set;} 
        public String Title {get;set;} 
        public Integer PrincipalType {get;set;} 
        public Boolean AllowMembersEditMembership {get;set;} 
        public Boolean AllowRequestToJoinLeave {get;set;} 
        public Boolean AutoAcceptRequestToJoinLeave {get;set;} 
        public String Description {get;set;} 
        public Boolean OnlyAllowMembersViewMembership {get;set;} 
        public String OwnerTitle {get;set;} 
    }
    
    public class RoleAssignments {
        public List<RoleAssignment> value {get;set;} 
        
    }
    public class RoleAssignment {
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public Integer PrincipalId {get;set;} 
    }
    
    public class RoleAssignmentMember {
        
        public String odata_metadata {get;set;} // in json: odata.metadata
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public Integer Id {get;set;} 
        public Boolean IsHiddenInUI {get;set;} 
        public String LoginName {get;set;} 
        public String Title {get;set;} 
        public Integer PrincipalType {get;set;} 
        public String Email {get;set;} 
        public Boolean IsEmailAuthenticationGuestUser {get;set;} 
        public Boolean IsShareByEmailGuestUser {get;set;} 
        public Boolean IsSiteAdmin {get;set;} 
        public UserId UserId {get;set;} 
    }
    
    public class RoleAssignmentGroup {
        
        public String odata_metadata {get;set;} // in json: odata.metadata
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public Integer Id {get;set;} 
        public Boolean IsHiddenInUI {get;set;} 
        public String LoginName {get;set;} 
        public String Title {get;set;} 
        public Integer PrincipalType {get;set;} 
        public Boolean AllowMembersEditMembership {get;set;} 
        public Boolean AllowRequestToJoinLeave {get;set;} 
        public Boolean AutoAcceptRequestToJoinLeave {get;set;} 
        public String Description {get;set;} 
        public Boolean OnlyAllowMembersViewMembership {get;set;} 
        public String OwnerTitle {get;set;} 
        public Object RequestToJoinLeaveEmailSetting {get;set;} 
        
    }
    
    public class SiteGroups {
        public SiteGroup value;
    }
    
    public class SiteGroup {
        public String odata_type {get;set;} // in json: odata.type
        public String odata_id {get;set;} // in json: odata.id
        public String odata_editLink {get;set;} // in json: odata.editLink
        public Integer Id {get;set;} 
        public Boolean IsHiddenInUI {get;set;} 
        public String LoginName {get;set;} 
        public String Title {get;set;} 
        public Integer PrincipalType {get;set;} 
        public Boolean AllowMembersEditMembership {get;set;} 
        public Boolean AllowRequestToJoinLeave {get;set;} 
        public Boolean AutoAcceptRequestToJoinLeave {get;set;} 
        public String Description {get;set;} 
        public Boolean OnlyAllowMembersViewMembership {get;set;} 
        public String OwnerTitle {get;set;} 
        public Object RequestToJoinLeaveEmailSetting {get;set;} }
    
}