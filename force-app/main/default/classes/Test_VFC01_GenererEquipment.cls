@isTest
public class Test_VFC01_GenererEquipment {
    public static testmethod void test_insertEquipment(){
        
        Account newAccount=new Account(Name='Test Account',
                                       ShippingCity='Lebanon',
                                       ShippingPostalCode='123',
                                       ACC_SIREN__c='012345678');
        insert newAccount;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        order newOrder=new Order();
        newOrder.AccountId=newAccount.Id;
        newOrder.EffectiveDate=Date.today() + 10;
        newOrder.status='3';
        newOrder.pricebook2Id=pricebookId;
        newOrder.ORD_ReferenceCommande__c='PFITEST01';
        
        
        insert newOrder;
        
        product2 newproduct2=new product2(Name='Test product',IsActive=true);
        insert newproduct2;
        
        PricebookEntry newPricebookEntry=new PricebookEntry(pricebook2Id=pricebookId,
                                                            product2Id=newproduct2.Id,
                                                            unitPrice=200,
                                                            UnitePrixPar__c='Heure',
                                                            IsActive=true);
        insert newPricebookEntry;
        
        OrderItem newOrderItem=new OrderItem();
        newOrderItem.OrderId = newOrder.Id;
        newOrderItem.Product2Id = newproduct2.Id;
        newOrderItem.quantity = 2;
        newOrderItem.UnitPrice = 150;
        newOrderItem.PricebookentryId = newPricebookEntry.Id;

                
        insert newOrderItem;
        
        PageReference pageRef = Page.VFP01_GenererEquipement;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',newOrderItem.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(newOrderItem);
        VFC01_GenereEquipment init =new VFC01_GenereEquipment(sc);
        init.createAsset();
        Asset insertedAsset=[SELECT Name,RecordTypeId,AccountId,Product2Id,ASS_Commande__c,Produit_command__c,ASS_NumeroIdentite__c
                             FROM Asset];
        
        OrderItem infoOrderItem=[SELECT product2.Name,order.AccountId,Product2Id,OrderId,Equipement_cree__c,PC_Numero_de_PFI__c
                                 FROM orderItem];
        
        system.assert(insertedAsset.Name==infoOrderItem.product2.Name);
        system.assert(insertedAsset.RecordTypeId==Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(label.Equipement).getRecordTypeId()); 
        system.assert(insertedAsset.Product2Id==infoOrderItem.Product2Id);
        system.assert(insertedAsset.ASS_Commande__c==infoOrderItem.OrderId);
        system.assert(insertedAsset.Produit_command__c==infoOrderItem.Id); 
        system.assert(insertedAsset.ASS_NumeroIdentite__c==infoOrderItem.PC_Numero_de_PFI__c);
      

        
        PageReference pageRefFail = Page.VFP01_GenererEquipement;
        Test.setCurrentPage(pageRefFail);
        pageRefFail.getParameters().put('id',newOrderItem.Id);
        ApexPages.StandardController scFail = new ApexPages.StandardController(newOrderItem);
        VFC01_GenereEquipment initFail =new VFC01_GenereEquipment(scFail);
        initFail.createAsset();
        
        list<asset> listAssets=[SELECT Id
                                FROM asset]; 
    }
}