/**
* Class used for the implementation of the PAD methodology
* @version 1.00 02/08/2019
* @author TMA EI JSA 
* @Trigger ALL
* @CodeCoverage 100% 
*/
public class PAD {
    public static final string bypassTrigger; //List of bypassed triggers 
    public static final User user; 
    static { 
        user = [Select BypassApexTriggers__c from User where Id=:UserInfo.getUserId() limit 1];
        bypassTrigger = ';'+ user.BypassApexTriggers__c + ';';   
    }
     public static boolean canTrigger(string Name){
            return (bypassTrigger.indexof(';' + Name + ';') == -1);

         }
}