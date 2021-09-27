@isTest
public class BatchOrderVisionSynchroTest {

    @testSetup static void setup() {
        //
        user API=[SELECT USER_ByPassRegleValidation__c, USER_ByPassProcessBuilder__c
        FROM user 
        WHERE lastName=:label.API
        LIMIT 1];

        API.USER_ByPassRegleValidation__c=true;
        API.USER_ByPassProcessBuilder__c = true;

        update API;
        Test.startTest();
        //
       System.runAs(API){

             
            List<BwTranscodification__c> transcoList = new List<BwTranscodification__c>();
            transcoList.add(new BwTranscodification__c(DataType__c='Sous domaine',MbApi__c='24',VsApi__c='LOC'));
            transcoList.add(new BwTranscodification__c(DataType__c='BU',MbApi__c='4',VsApi__c='LOC'));
            transcoList.add(new BwTranscodification__c(DataType__c='Agence Régionale',MbApi__c='1',VsApi__c='LOC'));
            transcoList.add(new BwTranscodification__c(DataType__c='Secteur',MbApi__c='39',VsApi__c='LOC'));
            Database.insert(transcoList,false);
            System.assertEquals(4, transcoList.size() , 'BwTranscodification__c Not Good' );
        
            Account newAccount=new Account(Name='TestOrder',
            ShippingCity='Lebanon',
            ShippingPostalCode='123',
            RecordTypeId = '0120O000000kqhw',
            ACC_SIREN__c='123456789');
            insert newAccount;
			
            
            list<order> listNewOrders=new list<order>();
            
            order newOrder1=new Order();
            newOrder1.AccountId=newAccount.Id;
            newOrder1.EffectiveDate=Date.today() + 10;
            newOrder1.ORD_SousDomaine__c = '19';
            newOrder1.ORD_BusinessUnit__c ='4';
            newOrder1.status='3';
            newOrder1.ORD_MontantHT_ERP__c =50 ;
            listNewOrders.add(newOrder1);
			//
            //
            order newOrder2=new Order();
            newOrder2.AccountId=newAccount.Id;
            newOrder2.EffectiveDate=Date.today() + 10;
            newOrder2.ORD_SousDomaine__c = '19';
            newOrder2.ORD_BusinessUnit__c ='4';
            newOrder2.ORD_MontantHT_ERP__c =100 ;
            newOrder2.status='3';
            listNewOrders.add(newOrder2);
            //----------------
            //
            order newOrder2_1=new Order();
            newOrder2_1.AccountId=newAccount.Id;
            newOrder2_1.EffectiveDate=Date.today() + 10;
            newOrder2_1.ORD_SousDomaine__c = '19';
            newOrder2_1.ORD_BusinessUnit__c ='4';
            newOrder2_1.ORD_MontantHT_ERP__c =100 ;
            newOrder2_1.status='3';
            listNewOrders.add(newOrder2_1);
            //Assert current revenu = 250
            //
            order newOrder3=new Order();
            newOrder3.AccountId=newAccount.Id;
            newOrder3.EffectiveDate=Date.today() -365;
            newOrder3.status='3';
            newOrder3.ORD_SousDomaine__c = '19';
            newOrder3.ORD_BusinessUnit__c ='4';
            newOrder3.ORD_MontantHT_ERP__c =75 ;
            listNewOrders.add(newOrder3);
            
            order newOrder4=new Order();
            newOrder4.AccountId=newAccount.Id;
            newOrder4.EffectiveDate=Date.today()  -365;
            newOrder4.ORD_MontantHT_ERP__c =200 ;
            newOrder4.ORD_SousDomaine__c = '19';
            newOrder4.ORD_BusinessUnit__c ='4';
            newOrder4.status='3';
            listNewOrders.add(newOrder4);
            //Revenu - 1 = 275
            
            order newOrder1_1=new Order();
            newOrder1_1.AccountId=newAccount.Id;
            newOrder1_1.EffectiveDate=Date.today() + 10;
            newOrder1_1.status='3';
            newOrder1_1.ORD_MontantHT_ERP__c =125 ;
            newOrder1_1.ORD_SousDomaine__c = '19';
            newOrder1_1.ORD_BusinessUnit__c ='4';
            listNewOrders.add(newOrder1_1);
           
            System.debug('newOrder1_1 '+newOrder1_1);
            order newOrder1_2=new Order();
            newOrder1_2.AccountId=newAccount.Id;
            newOrder1_2.EffectiveDate=Date.today() -365;
            newOrder1_2.status='3';
            newOrder1_2.ORD_SousDomaine__c = '19';
            newOrder1_2.ORD_BusinessUnit__c ='4';
            newOrder1_2.ORD_MontantHT_ERP__c =145 ;
            listNewOrders.add(newOrder1_2);
            
            
            insert listNewOrders;
        }
    }
    
    @isTest static void testMethod1() {
        Account acct =  [SELECT Id FROM Account WHERE NAME ='TestOrder' LIMIT 1];
        List<Order> orderList =[SELECT Id,ord_visSousDomain__c,Ord_Domaine__c,ORD_SousDomaine__c ,ORD_BusinessUnit__c FROM Order WHERE AccountId  = :acct.Id];
        system.assertEquals (orderList.size() , 7,'Not Equals Test Methode');
        BatchOrderVisionSynchro.run();

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
        ord.AccountId=AccountId;
        ord.EffectiveDate=closeDate;
        ord.status='3';
        ord.Description=Name;
        ord.ORD_MontantHT_ERP__c =145 ;
        return ord;
    }
}