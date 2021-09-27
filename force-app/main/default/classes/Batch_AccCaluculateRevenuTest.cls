@isTest
public class Batch_AccCaluculateRevenuTest {
    @IsTest
    static void methodName(){
        user API=[SELECT USER_ByPassRegleValidation__c, USER_ByPassProcessBuilder__c
        FROM user 
        WHERE lastName=:label.API
        LIMIT 1];

        API.USER_ByPassRegleValidation__c=true;
        API.USER_ByPassProcessBuilder__c = true;

        update API;
        Test.startTest();
        System.runAs(API){

            Account newAccount=new Account(Name='Test Account For Update Quote',
            ShippingCity='Lebanon',
            ShippingPostalCode='123',
            RecordTypeId = '0120O000000kqhw',
            ACC_SIREN__c='123456789');
            insert newAccount;
			Account newAccount_1=new Account(Name='Test1',
            ShippingCity='France',
            ShippingPostalCode='1123',
            RecordTypeId = '0120O000000kqhw',
            ACC_SIREN__c='123467811');
            insert newAccount_1;
            VISousDomaine__c vis= new VISousDomaine__c(Name='BRU',Code_API_Sous_domaine__c='1',Mode_de_calcul_de_l_avancement__c='1',use_cutomer_segment__c=true);
            insert vis ;
            list<order> listNewOrders=new list<order>();
            
            order newOrder1=new Order();
            newOrder1.AccountId=newAccount.Id;
            newOrder1.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder1.EffectiveDate=Date.today() + 10;
            newOrder1.status='3';
            newOrder1.ORD_MontantHT_ERP__c =50 ;
            listNewOrders.add(newOrder1);
			//
            //
            order newOrder2=new Order();
            newOrder2.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder2.AccountId=newAccount.Id;
            newOrder2.EffectiveDate=Date.today() + 10;
            newOrder2.ORD_MontantHT_ERP__c =100 ;
            newOrder2.status='3';
            listNewOrders.add(newOrder2);
            //----------------
            //
            order newOrder2_1=new Order();
            newOrder2_1.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder2_1.AccountId=newAccount.Id;
            newOrder2_1.EffectiveDate=Date.today() + 10;
            newOrder2_1.ORD_MontantHT_ERP__c =100 ;
            newOrder2_1.status='3';
            listNewOrders.add(newOrder2_1);
            //Assert current revenu = 250
            //
            order newOrder3=new Order();
            newOrder3.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder3.AccountId=newAccount.Id;
            newOrder3.EffectiveDate=Date.today() -365;
            newOrder3.status='3';
            newOrder3.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder3.ORD_MontantHT_ERP__c =75 ;
            listNewOrders.add(newOrder3);
            
            order newOrder4=new Order();
            newOrder4.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder4.AccountId=newAccount.Id;
            newOrder4.EffectiveDate=Date.today()  -365;
            newOrder4.ORD_MontantHT_ERP__c =200 ;
            newOrder4.status='3';
            listNewOrders.add(newOrder4);
            //Revenu - 1 = 275
            
            order newOrder1_1=new Order();
            newOrder1_1.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder1_1.AccountId=newAccount_1.Id;
            newOrder1_1.EffectiveDate=Date.today() + 10;
            newOrder1_1.status='3';
            newOrder1_1.ORD_MontantHT_ERP__c =125 ;
            listNewOrders.add(newOrder1_1);
            System.debug('newOrder1_1 '+newOrder1_1);
            order newOrder1_2=new Order();
            newOrder1_2.ORD_SousDomaine__c=vis.Code_API_Sous_domaine__c;
            newOrder1_2.AccountId=newAccount_1.Id;
            newOrder1_2.EffectiveDate=Date.today() -365;
            newOrder1_2.status='3';
            newOrder1_2.ORD_MontantHT_ERP__c =145 ;
            listNewOrders.add(newOrder1_2);
            
            
            insert listNewOrders;
            Batch_AccCaluculateRevenu.run();
        
        Test.stopTest();
        Account act = [SELECT  Id, ACC_Revenu_n__c, ACC_revenu_n_1__c,ACC_revenu_n_2__c FROM Account WHERE Name='Test Account For Update Quote' LIMIT 1];
        System.debug('act ='+act);
        System.assertEquals(act.ACC_Revenu_n__c, 250.0,'First Assertion');
        System.assertEquals(act.ACC_revenu_n_1__c, 275.0,'second Assertion');    
        Account acct1 = [SELECT  Id, ACC_Revenu_n__c, ACC_revenu_n_1__c,ACC_revenu_n_2__c FROM Account WHERE Name='Test1' LIMIT 1];
        System.debug('acct1 ='+acct1);
        System.assertEquals(acct1.ACC_Revenu_n__c, 125.0,'Third Assertion');
        System.assertEquals(acct1.ACC_revenu_n_1__c, 145.0,'Forth Assertion');    
    }
    }
    Public static Opportunity createOppy(Id AccountId,Date closeDate,String stageName, String entryName){
        return (new opportunity(AccountId = AccountId,
                                closedate=closeDate,
                                stageName=stageName,
                                Name = entryName));
    }
    
    Public static Id getPricebookId(){
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true );
        	update standardPricebook;
            Id StandardPricebookID = Test.getStandardPricebookId();
 			return StandardPricebookID ;       
    }
    Public static Order createOrder(String Name,Id AccountId,Date closeDate,String stageName, String entryName ){
        Opportunity oppy = createOppy(AccountId,closeDate,stageName, entryName);
        insert oppy ;
        Id standardPricebookId = getPricebookId();
        
        Order ord = New Order();
        return ord;
    }
}