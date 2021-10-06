/**
 * @description       : 
 * @author            : SCHIBOUT
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : SCHIBOUT
**/
global class  INT_BatchOrderFromGPICFile  implements Database.Batchable<sObject>,  Database.Stateful, Schedulable{

    //List<BwTranscodification__c> transcoList = [SELECT Id FROM BwTranscodification__c];
    
    global Database.QueryLocator start(Database.BatchableContext info){
        /*
            select id, NoOpportuniteSF__c, NumeroDevis__c, ReferenceClient__c,TotalAPayer__c,Etat__c, ClientPayeur__c, Affaire__c, DateDerMaj__c, DerDateBL__c, VolumeHeure__c, DateLivDem__c, TotalHorsTaxeDevise__c,CodePostalLiv__c, VilleLiv__c
            , CodePaysLiv__c,AdresseLiv__c,Numero__c   from HeaderGpicFile__c 
        */
        List<HeaderGpicFile__c> numDevList = [SELECT Id,NumeroDevis__c,Quote__c, Opportunity__c, Account__c,AvenantCommande__c,Order__c FROM HeaderGpicFile__c WHERE integratedInSf__c = false];
        UpdateInfosDevis(numDevList);
        return Database.getQueryLocator([SELECT Id,Quote__c, ReferenceClient__c, Numero__c, Account__c
                                        , clientlivre__c ,TotalAPayer__c, Etat__c, Quote__r.DEV_EntiteBW__c
                                        , SousDomaine__c,Opportunity__r.OPP_CompteClientFinal__c,Affaire__c
                                        , DateDerMaj__c, DerDateBL__c, VolumeHeure__c, DateLivDem__c, TotalHorsTaxeDevise__c
                                        , Quote__r.BillingAddress, Quote__r.BillingStreet, Quote__r.BillingCity, Quote__r.BillingCountryCode
                                        , Quote__r.BillingPostalCode, Quote__r.ShippingCity,  Quote__r.ShippingCountryCode, Quote__r.ShippingPostalCode  
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
        List<AvenantCommand__c> avenantList = new List<AvenantCommand__c>();
        for (HeaderGpicFile__c data :(List<HeaderGpicFile__c>) fileDataList) {
            if (data.NoAvenantCde__c='000') {
                orderList.add(createOrder(data));
            }else {
                orderList.add(createAvenant(data));
            }
            
        }

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
    public static void UpdateInfosDevis(List<HeaderGpicFile__c> gpicHeaderList) {
        if (gpicHeaderList.size()==0) return ;
        List<String> externalIdsList = new List<String>();
        for (HeaderGpicFile__c var : gpicHeaderList) {
            if (var.NumeroDevis__c != null) externalIdsList.add(var.NumeroDevis__c );
        }
        List<Quote> quoteListInterface = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE DEV_Tech_QuoteNumber_ExternalId__c IN :externalIdsList];

        for (HeaderGpicFile__c var : gpicHeaderList) {
            for (Quote qt : quoteListInterface) {
                if (var.NumeroDevis__c == qt.DEV_Tech_QuoteNumber_ExternalId__c) {
                    if (var.quote__c==null && var.quote__c!= qt.Id ) var.quote__c= qt.Id;
                    if (var.opportunity__c != qt.OpportunityId && var.opportunity__c == null)var.opportunity__c = qt.OpportunityId;
                    if (var.account__c != qt.AccountId && var.account__c == null) var.account__c = qt.AccountId ;
                }     
            }
           Database.update(gpicHeaderList, false) ;
            
        }
        /*List<Object> quoteList = [SELECT id,AccountId,ShippingCity,ShippingCountryCode
                                 ,ShippingPostalCode,ShippingStreet,BillingCountryCode,BillingStateCode
                                 ,BillingCity,BillingPostalCode,BillingStreet 
                                FROM Quote WHERE DEV_Tech_QuoteNumber_ExternalId__c='00053781' limit 10 ];*/
    }

    /**
    * @description 
    * @author SCHIBOUT | 06-10-2021 
    * @param gpicData 
    * @return Order 
    **/

    
    public Order createOrder(HeaderGpicFile__c gpicData) {
        Order newOrder = new Order();
        newOrder.QuoteId = gpicData.Quote__c;
        newOrder.PoNumber = gpicData.ReferenceClient__c;
        newOrder.ORD_ReferenceCommande__c = gpicData.Numero__c;
        newOrder.AccountId = gpicData.Account__c;
        newOrder.ORD_ClientLivre__c = gpicData.clientlivre__c;
        newOrder.ORD_MontantERP__c = gpicData.TotalAPayer__c;
        newOrder.Status = gpicData.Etat__c;
        newOrder.ORD_BusinessUnit__c = gpicData.Quote__r.DEV_EntiteBW__c;
        newOrder.ORD_SousDomaine__c = gpicData.SousDomaine__c;
        newOrder.ORD_CompteFacture__c = gpicData.Opportunity__r.OPP_CompteClientFinal__c;
        newOrder.ORD_DonneesDAffaire__c = gpicData.Affaire__c;
        newOrder.EffectiveDate = gpicData.DateDerMaj__c;
        newOrder.ORD_DateReelleExecutionLivraison__c = gpicData.DerDateBL__c;
        newOrder.ORD_DateDeFermetureDeLAffaire__c =  gpicData.;
        newOrder.ORD_VolumeDHeuresDIntervention__c = gpicData.VolumeHeure__c;
        newOrder.ORD_DateDInterventionPlanifiee__c= gpicData.DateLivDem__c;
        newOrder.ORD_MontantHT_ERP__c= gpicData.TotalHorsTaxeDevise__c;
        newOrder.ORD_DateDeFacturation__c= gpicData.;
        newOrder.ShippingStreet= gpicData.Quote__r.ShippingStreet;
        //newOrder.ShippingPostalCode= gpicData.Quote__r.ShippingPostalCode;
        newOrder.ShippingCity= gpicData.Quote__r.ShippingCity;
        newOrder.BillingStreet= gpicData.Quote__r.BillingStreet;
        newOrder.BillingPostalCode= gpicData.BillingPostalCode;
        newOrder.BillingCity= gpicData.Quote__r.BillingCity;
        newOrder.BillingStateCode= gpicData.Quote__r.BillingStateCode;
        newOrder.BillingCountryCode= gpicData.Quote__r.BillingCountryCode;
        newOrder.ShippingStreet= gpicData.Quote__r.;
        newOrder.ShippingPostalCode= gpicData.Quote__r.ShippingPostalCode;
        newOrder.ShippingCity= gpicData.Quote__r.ShippingCity;
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
