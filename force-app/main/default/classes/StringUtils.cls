/**
 * @description       : 
 * @author            : SCHIBOUT
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : SCHIBOUT
**/
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

    public static Integer getInt(String valueToConvert) {
        Integer x ;
        try
        {
            x = Integer.valueOf(valueToConvert.trim());
            
        }
        catch (exception e)
        {
            System.debug('Convertion error '+e.getMessage());
        }
        return x;
    }
 
    /**
    * @description 
    * @author SCHIBOUT | 06-10-2021 
    * @param valueToConvert 
    * @return Decimal 
    **/
    public static Decimal getDecimal(String valueToConvert) {
        Decimal x ;
        try
        {
             x = Decimal.valueOf(valueToConvert.trim());
            
        }
        catch (exception e)
        {
            System.debug('Convertion error '+e.getMessage());
        }
        return x;
    }

    public static Date getDate(String valueToConvert) {
        Date x ;
        /*try
        {
             x = Decimal.valueOf(valueToConvert.trim());
            
        }
        catch (exception e)
        {
            System.debug('Convertion error '+e.getMessage());
        }*/
        return x;
    }

    
    
}