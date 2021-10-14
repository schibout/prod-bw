/**
 * @description       : 
 * @author            : SCHIBOUT
 * @group             : 
 * @last modified on  : 14-10-2021
 * @last modified by  : SCHIBOUT
**/
global class  INT_BatchOrderFromGPICFile  implements Database.Batchable<sObject>,  Database.Stateful, Schedulable{

    //List<BwTranscodification__c> transcoList = [SELECT Id FROM BwTranscodification__c];
    
    global Database.QueryLocator start(Database.BatchableContext info){
        
        
        UpdateInfosQuote();
        updateOrderInfo();
        return Database.getQueryLocator([SELECT Id,Quote__c, ReferenceClient__c, Numero__c, Account__c
                                        , clientlivre__c ,TotalAPayer__c, Etat__c, Quote__r.DEV_EntiteBW__c
                                        , SousDomaine__c,Opportunity__r.OPP_CompteClientFinal__c,Affaire__c
                                        , DateDerMaj__c, DerDateBL__c, VolumeHeure__c, DateLivDem__c, TotalHorsTaxeDevise__c
                                        , Quote__r.BillingAddress, Quote__r.BillingStreet, Quote__r.BillingCity, Quote__r.BillingCountryCode,Quote__r.ShippingStreet,Quote__r.ShippingStateCode
                                        , Quote__r.BillingPostalCode, Quote__r.ShippingCity,  Quote__r.ShippingCountryCode, Quote__r.ShippingPostalCode,Quote__r.BillingStateCode
                                        , Order__r.PoNumber,Order__r.ORD_ReferenceCommande__c,Order__r.ORD_clientlivre__c,Order__r.ORD_MontantERP__c,NoAvenantCde__c,order__c  
                                        FROM HeaderGpicFile__c WHERE integratedInSf__c = false]);
    }
    /**
    * @description 
    * @author SCHIBOUT | 27-09-2021 
    * @param BC 
    * @param fileDataList 
    **/
    global void execute(Database.BatchableContext BC, List<SObject> fileDataList){

        List<Order> orderList = new List<Order>();
        List<AvenantCommand__c> avenantListCreate = new List<AvenantCommand__c>();
        List<AvenantCommand__c> avenantListUpdate = new List<AvenantCommand__c>();
        for (HeaderGpicFile__c data :(List<HeaderGpicFile__c>) fileDataList) {
            if ((data.NoAvenantCde__c=='000')&&(data.order__c ==null)) {
                orderList.add(createOrder(data));
              }else {
                avenantListCreate.add(createAvenant(data));
              }  
           /* }/*else {

                if (data.Order__r.ORD_MontantERP__c != data.TotalHorsTaxeDevise__c)  {
                    avenantListCreate.add(createAvenant(data))
                }*//*else {

                }       
                
            }*/
            
        }
        
        /*insert(orderList);
        List<Order> ordList = [SELECT Id FROM Order WHERE Id IN :orderList];
        System.debug('ordList = '+ ordList);*/
        System.debug('avenantListCreate = '+ avenantListCreate);
        insert(avenantListCreate);
        List<AvenantCommand__c> avnList = [SELECT Id FROM AvenantCommand__c WHERE Id IN :avenantListCreate];
        System.debug('ordList = '+ avnList);
        //Database.insert(avenantListCreate,false);
    }

    /**
    * @description 
    * @author SCHIBOUT | 27-09-2021 
    * @param BC 
    **/
    global void finish(Database.BatchableContext BC){
    
    }
    
    
    
    /**
    * @description 
    * @author SCHIBOUT | 06-10-2021 
    **/
    public static void UpdateInfosQuote() {
        List<HeaderGpicFile__c> gpicHeaderList = [SELECT Id,NumeroDevis__c,Quote__c, Opportunity__c, Account__c FROM HeaderGpicFile__c WHERE integratedInSf__c = false];
        if (gpicHeaderList.size()==0) return ;
        List<String> externalIdsList = new List<String>();
        
        for (HeaderGpicFile__c var : gpicHeaderList) {
            if (var.NumeroDevis__c != null) externalIdsList.add(var.NumeroDevis__c );
        }
       
        List<Quote> quoteListInterface = [SELECT Id, AccountId, OpportunityId,DEV_Tech_QuoteNumber_ExternalId__c FROM Quote WHERE DEV_Tech_QuoteNumber_ExternalId__c IN :externalIdsList];
       
        
        for (HeaderGpicFile__c var : gpicHeaderList) {
            for (Quote qt : quoteListInterface) {
                if (var.NumeroDevis__c != qt.DEV_Tech_QuoteNumber_ExternalId__c) continue ;
                if (var.quote__c==null && var.quote__c!= qt.Id ) var.quote__c= qt.Id;
                if (var.opportunity__c != qt.OpportunityId && var.opportunity__c == null)var.opportunity__c = qt.OpportunityId;
                if (var.account__c != qt.AccountId && var.account__c == null) var.account__c = qt.AccountId ;
                
            }
           
        }
        Database.update(gpicHeaderList, true) ;
        System.debug('gpicHeaderList = '+gpicHeaderList);
        
    }

    /**
    * @description 
    * @author SCHIBOUT | 12-10-2021 
    * @param gpicHeaderList 
    **/
    public static void updateOrderInfo() {
      List<HeaderGpicFile__c> gpicHeaderList = [SELECT Id,Quote__c, Order__c FROM HeaderGpicFile__c WHERE integratedInSf__c = false];
      System.debug('gpicHeaderList = '+gpicHeaderList);
      List<Id> quoteIds = new List<Id>();
        for (HeaderGpicFile__c var : gpicHeaderList) {
            if (var.quote__c != null) quoteIds.add(var.quote__c );
        }
        List<Order> ordList = [SELECT Id,PoNumber,quoteId FROM Order WHERE quoteId IN :quoteIds] ;
        System.debug('updateOrderInfo ordList = '+ordList);
        for (HeaderGpicFile__c var : gpicHeaderList) {
          for (Order ord : ordList) {
            if ((var.quote__c == ord.quoteId) &&(var.order__c!= ord.Id) ) var.order__c= ord.Id;
         }   
        }
        Database.update(gpicHeaderList, false) ;
        System.debug('updateOrderInfo gpicHeaderList = '+gpicHeaderList);
    }

    /**
    * @description 
    * @author SCHIBOUT | 12-10-2021 
    * @param gpicData 
    * @return AvenantCommand__c 
    **/
    public static AvenantCommand__c createAvenant(HeaderGpicFile__c gpicData) {
        AvenantCommand__c avcmd = new AvenantCommand__c();
        avcmd.Quote__c = gpicData.Quote__c;
        avcmd.PoNumber__c = gpicData.ReferenceClient__c;
        avcmd.ReferenceCommande__c = gpicData.Numero__c;
        //avcmd.AccountId__c = gpicData.Account__c;
        avcmd.ClientLivre__c = gpicData.clientlivre__c;
        avcmd.MontantERP__c = StringUtils.getDecimal(gpicData.TotalAPayer__c);
        avcmd.order__c = gpicData.order__c;
        return avcmd;
    }
    
    
    /**
    * @description 
    * @author SCHIBOUT | 06-10-2021 
    * @param gpicData 
    * @return Order 
    **/

    
    public Order createOrder(HeaderGpicFile__c gpicData) {
        Date effectiveDate = Date.today();
        Order newOrder = new Order();
        newOrder.QuoteId = gpicData.Quote__c;
        newOrder.EffectiveDate = effectiveDate;//date.parse(gpicData.DateDerMaj__c);
        newOrder.PoNumber = gpicData.ReferenceClient__c;
        newOrder.ORD_ReferenceCommande__c = gpicData.Numero__c;
        newOrder.AccountId = gpicData.Account__c;
        newOrder.ORD_ClientLivre__c = gpicData.clientlivre__c;
        newOrder.ORD_MontantERP__c = StringUtils.getDecimal(gpicData.TotalAPayer__c);
        newOrder.Status = '2' ;//gpicData.Etat__c;
        newOrder.ORD_BusinessUnit__c = gpicData.Quote__r.DEV_EntiteBW__c;
        newOrder.ORD_SousDomaine__c ='1';// gpicData.SousDomaine__c;
        newOrder.ORD_CompteFacture__c = gpicData.Opportunity__r.OPP_CompteClientFinal__c;
        newOrder.ORD_DonneesDAffaire__c = gpicData.Affaire__c;
        //newOrder.EffectiveDate = StringUtils.getDate(gpicData.DateDerMaj__c);
        newOrder.ORD_DateReelleExecutionLivraison__c = StringUtils.getDate(gpicData.DerDateBL__c);
        //newOrder.ORD_DateDeFermetureDeLAffaire__c =  gpicData.;
        newOrder.ORD_VolumeDHeuresDIntervention__c = StringUtils.getDecimal(gpicData.VolumeHeure__c);
        newOrder.ORD_DateDInterventionPlanifiee__c= StringUtils.getDate(gpicData.DateLivDem__c);
        newOrder.ORD_MontantHT_ERP__c= StringUtils.getDecimal(gpicData.TotalHorsTaxeDevise__c);
        //newOrder.ORD_DateDeFacturation__c= gpicData.;
        newOrder.ShippingCity= gpicData.Quote__r.ShippingCity;
        newOrder.BillingStreet= gpicData.Quote__r.BillingStreet;
        newOrder.BillingPostalCode= gpicData.Quote__r.BillingPostalCode;
        newOrder.BillingCity= gpicData.Quote__r.BillingCity;
        newOrder.BillingStateCode= gpicData.Quote__r.BillingStateCode;
        newOrder.BillingCountryCode= gpicData.Quote__r.BillingCountryCode;
        newOrder.ShippingStreet= gpicData.Quote__r.ShippingStreet;
        newOrder.ShippingPostalCode= gpicData.Quote__r.ShippingPostalCode;
        newOrder.ShippingStateCode= gpicData.Quote__r.ShippingStateCode;
        newOrder.ShippingCountryCode= gpicData.Quote__r.ShippingCountryCode;
        return newOrder ;

    }

    public static void checkOrderOrAvenant() {

    }
    /**
    * @description 
    * @author SCHIBOUT | 27-09-2021 
    * @param sc 
    **/
    global void execute(SchedulableContext sc) {
        INT_BatchOrderFromGPICFile batch = new INT_BatchOrderFromGPICFile();
        Database.executeBatch(batch);
    }
    
    /**
    * @description 
    * @author SCHIBOUT | 27-09-2021 
    **/
    global static void run(){
        INT_BatchOrderFromGPICFile batch = new INT_BatchOrderFromGPICFile();
        Database.executeBatch(batch);
    }
}
