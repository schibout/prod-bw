@isTest
public class StringUtilsTest {

    @IsTest
    static void methodName(){
        
        Test.startTest();
        
        System.assertEquals(true, StringUtils.isEmpty(null),'Null Value');
        System.assertEquals(true, StringUtils.isEmpty(''),'Null Value');
        System.assertEquals(true, StringUtils.isNotEmpty('1'),'Null Value');
        System.assertEquals('1', StringUtils.trim('1   '),'Null Value');
        System.assertEquals(true, StringUtils.equalsIgnoreCase('1','1'),'Null Value');

        Test.stopTest();
        
    }
}