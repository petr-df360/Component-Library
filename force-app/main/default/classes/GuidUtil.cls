global class GuidUtil {
    
    private static String kHexChars = '0123456789abcdef';
    
    global static String NewGuid() {
        
        String returnValue = '';
        Integer nextByte = 0;
        
        for (Integer i=0; i<16; i++) {
            
            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';
            
            nextByte = (Math.round(Math.random() * 255)-128) & 255;
            
            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            
            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            
            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }
        
        return returnValue;
    }
    
    global static String getCharAtIndex(String str, Integer index) {
        
        if (str == null) return null;
        
        if (str.length() <= 0) return str;    
        
        if (index == str.length()) return null;    
        
        return str.substring(index, index+1);
    }
    
    global static String getSharingId(){
        Set<String> existingIds = new Set<String>();
        List<User> users = [SELECT Sharing_Id__c FROM User];
        for(User u : users) {
            existingIds.add(u.Sharing_Id__c);
        }
               
        //for each user get sharing id, insert id to list
        //when new id is generated check for uniqueness. Generate new ids until unique is found.
        String characters = 'abcdefghijklmnopqrstuvwxyz1234567890';
        Integer size = characters.length();
        Boolean unique = false;
        String newId;
        
        //Integer counter;
        while(!unique){
            newId = '';
            for(Integer i=0;i<2;i++){
                String randomChars = getCharAtIndex(characters,randomNumber(size));
                newId += randomChars;   
            }
            
            if(!existingIds.contains(newId)){
                unique = true;
            }
        }
        return newId;
    }
    
    
    public static Integer randomNumber(Integer size){
        Integer random = Math.Round(Math.Random() *size ); if(random == size){ random--; } return random; 
    }
}