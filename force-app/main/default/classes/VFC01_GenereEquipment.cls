public with sharing class VFC01_GenereEquipment {
    
    Private final orderItem thisOrderItem;
    
    public VFC01_GenereEquipment(ApexPages.StandardController stdcontroller){
        This.thisOrderItem=(orderItem) stdcontroller.getrecord();
    }    
    
    public pageReference createAsset(){
        orderItem orderItemdetails=[SELECT product2.Name, order.AccountId,order.ORD_ClientLivre__c, Product2Id, OrderId, Quantity, Nbre_Equipements__c, Equipement_cree__c, PC_Numero_de_PFI__c 
                                    FROM orderItem
                                    WHERE Id=:thisOrderItem.Id];
        
        //orderItemdetails.Nbre_Equipements__c = 0;
        
        Asset newAsset=new Asset();
        newAsset.Name=orderItemdetails.product2.Name;
        newAsset.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(label.Equipement).getRecordTypeId();
        newAsset.AccountId = orderItemdetails.order.ORD_ClientLivre__c;
        newAsset.Product2Id = orderItemdetails.Product2Id;
        newAsset.ASS_Commande__c = orderItemdetails.OrderId;
        newAsset.Produit_command__c=orderItemdetails.Id;
        newAsset.ASS_NumeroIdentite__c=orderItemdetails.PC_Numero_de_PFI__c;
        
        try{
            
            insert newAsset;
            orderItemdetails.Nbre_Equipements__c = orderItemdetails.Nbre_Equipements__c + 1;
            if (orderItemdetails.Nbre_Equipements__c == orderItemdetails.Quantity) {
            orderItemdetails.Equipement_cree__c=true;
            }
            update orderItemdetails;
            
            PageReference assetView=new PageReference('/'+newAsset.id); 
            assetView.setRedirect(true);
            return assetView;     
            
        } 
        
        
        catch (Exception e){
            string errorMessage=e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringBefore('[]');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,errorMessage));
            return null;
        
        }
        
       
    }  
}