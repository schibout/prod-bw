public with sharing class StringUtils {
  /**
     * 
     */
    public static Boolean isEmpty(String str) {
        return str == null || str.length() == 0;
    }
    /**
     * 
     */
    public static boolean isNotEmpty(String str) {	
        return !(isEmpty(str));	
    }	
    /**
     * 
     */
    public static String trim(String str) {	
        return str == null ? null : str.trim();	
    }	
    /**
     * 
     */
    public static boolean equalsIgnoreCase(String str1, String str2) {	
        return str1 == null ? str2 == null : str1.equalsIgnoreCase(str2);	
    }
}