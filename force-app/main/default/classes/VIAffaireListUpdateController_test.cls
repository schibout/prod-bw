@isTest
public class VIAffaireListUpdateController_test {


    static testmethod void VIAffaireListUpdateController_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Achat();        

        VIAffaire__c aff = [select id,Date_de_sav_reelle__c from VIAffaire__c LIMIT 1];
        VItype_de_depense__c tdMO  = new VItype_de_depense__c();
        VItype_de_depense__c tdGAR = new VItype_de_depense__c();
        VItype_de_depense__c tdEMM = new VItype_de_depense__c();
        VItype_de_depense__c tdAMP = new VItype_de_depense__c();
        VItype_de_depense__c tdFOL = new VItype_de_depense__c();     
        VICentre_section__c CS801= new VICentre_section__c();
    
        Map<string,VIperiode__c>MapEntite_bwPeriode = new Map<string,VIperiode__c>();
        

        for(VIType_de_depense__c td : [SELECT ID,name from VIType_de_depense__c where name like 'MO %' or name like 'GAR%' or name like 'EMM%' or name like 'AMP%' or name like 'FOL%']) {
            if(td.name.startswith('MO '))
                 tdMO=td ; 

            if(td.name.startswith('GAR'))
                 tdGAR=td ; 

            if(td.name.startswith('EMM'))
                 tdEMM=td ; 

            if(td.name.startswith('AMP'))
                 tdAMP=td ; 

            if(td.name.startswith('FOL'))
                 tdFOL=td ; 
        }
        CS801 = [select id from VICentre_section__c where name like '801%' ];        

        VIPeriode__c periode_ouverte  ;              
        for(VIPeriode__c per : [SELECT ID,name, entite_bw__c, date_de_debut__c, date_de_fin__c ,statut__c
                                  FROM VIPeriode__c
                                 WHERE entite_bw__c='1' 
                              ORDER BY date_de_debut__c]) {
             MapEntite_bwPeriode.put(per.name,per);
             if(per.statut__c==VIConstant.PERIODE_OUVERTE)  {
                 periode_ouverte=per; 
             }                                  
         }


        
        
        
        VIUtils.recalc(aff.id,true, true, tdMO,tdGAR, tdEMM, tdAMP, tdFOl, cs801, MapEntite_bwPeriode,periode_ouverte.date_de_debut__c );
        

        VILigne_affaire__c la=[SELECT type_depense__c, Ecart_C_A_F_MontantD__c  FROM VILigne_affaire__c limit 1];
        la.Ecart_C_A_F_MontantD__c =1;
        update la;
        la.type_depense__c=tdMo.id;
        la.Ecart_C_A_F_MontantD__c =2;
        update la;
       
        ApexPages.StandardController sc = new ApexPages.StandardController(aff);
        VIAffaireListUpdateController testaff = new VIAffaireListUpdateController (sc);  
        
        PageReference pageRef = Page.VIAffaireListUpdate; 
        pageRef.getParameters().put('id',aff.Id);

        testaff.testcoverage();

        
        VISchedBatchDeleteLA v = new VISchedBatchDeleteLA('',false);
        v.execute(null);

        
        
    }

   
    
}