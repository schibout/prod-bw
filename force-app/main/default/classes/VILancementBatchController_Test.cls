@isTest
public class VILancementBatchController_Test {

    static testmethod void VILancementBatchController_Test() {
    
        VIInsertDataTest.VIInsertData_EUR_affaire();
        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_Pointage();
        VIInsertDataTest.VIInsertData_Facture();

        VILancementBatchController testlb = new VILancementBatchController ();  

        list<VIperiode__c>ListPeriode=[SELECT id,date_de_fin__c 
                                         FROM VIperiode__c 
                                       WHERE Statut__c =:VIConstant.PERIODE_OUVERTE
                                     ORDER BY NAME LIMIT 1];
        
        PageReference pageRef = Page.VILancementBatch; 
        
        testlb.getEntite_bwOptions();
        testlb.Entite_bw=[SELECT entite_bw__c FROM VIEntiteBW__c LIMIT 1].entite_bw__c;
        
        VIAffaire__c aff = [select id,Date_de_SAV_reelle__c,Type_Imputation__c  from VIAffaire__c LIMIT 1] ;
       // aff.Date_de_SAV_reelle__c = ListPeriode[0].date_de_fin__c;
       // update aff; 

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
                                 WHERE entite_bw__c='1'  ]) {
             MapEntite_bwPeriode.put(per.name,per);
             if(per.statut__c==VIConstant.PERIODE_OUVERTE)  {
                 periode_ouverte=per; 
             }
                                     
         }

        VIUtils.recalc(aff.id,true, true, tdMO,tdGAR, tdEMM, tdAMP, tdFOl, cs801, MapEntite_bwPeriode,periode_ouverte.date_de_debut__c );



        testlb.Entite_bw1='1';
        testlb.callBatchGenerate(); 
        testlb.callBatchGenereAutorisation(); 
        
        
        
/*        
        list<VILigne_Affaire__c>ListLa= [SELECT id, Cout_terminaison_MontantD__c, Engage_brut_arrete_MontantD__c,Ecart_C_A_F_MontantD__c   
                                           FROM VILigne_Affaire__c ] ;
        
        ListLa[0].Ecart_C_A_F_MontantD__c=1;
        update ListLa ; 
        System.assertEquals(10, listLa.size());
        System.assertEquals(0, listLa[0].Engage_brut_arrete_MontantD__c);

        delete listLa ; 
*/        
    }
    
    static testmethod void VILancementBatchController1_Test() {
        VIInsertDataTest.VIInsertData_EUR_affaire();

        VISchedCreatePeriode v = new VISchedCreatePeriode();
        v.execute(null);
        
        VILancementBatchController testlb = new VILancementBatchController (); 
        PageReference pageRef = Page.VILancementBatch;
        testlb.getPeriodeEntite_bwOptions();
        
    }    
    
    static testmethod void VILancementBatchController2_Test() {
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        
        VILancementBatchController testlb = new VILancementBatchController (); 
        PageReference pageRef = Page.VILancementBatch;

        testlb.Entite_bw=[SELECT entite_bw__c FROM VIEntiteBW__c LIMIT 1].entite_bw__c;
        
        testlb.getPeriodeEntite_bwOptions();

        list<VIperiode__c>ListPeriode=[SELECT id,date_de_fin__c 
                                         FROM VIperiode__c 
                                       WHERE Statut__c =:VIConstant.PERIODE_OUVERTE
                                     ORDER BY NAME LIMIT 1];
        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_Pointage();
        //VIInsertDataTest.VIInsertData_Avenant();
        VIInsertDataTest.VIInsertData_facture();        

        //VIAffaire__c aff = [SELECT Date_de_SAV_reelle__c from VIAffaire__c];
        //aff.Date_de_SAV_reelle__c = ListPeriode[0].date_de_fin__c;
        //update aff ; 
        
        testlb.CallBatchCalcTDBGazelle();        
    }    
    
    static testmethod void VILancementBatchController3_Test() {
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        
        VILancementBatchController testlb = new VILancementBatchController (); 
        PageReference pageRef = Page.VILancementBatch;
        
        VICompte_general__c cc = new  VICompte_general__c  (name='7');
        insert cc ; 

        list<VIperiode__c>ListPeriode=[SELECT id,date_de_fin__c 
                                         FROM VIperiode__c 
                                       WHERE Statut__c =:VIConstant.PERIODE_OUVERTE
                                     ORDER BY NAME LIMIT 1];
        VIAffaire__c aff = [select id,Date_de_SAV_reelle__c from VIAffaire__c LIMIT 1] ;        
        VILigne_comptable__c Lc = new VILigne_comptable__c(Statut_ecriture_comptable__c=VIConstant.EC_BROUILLON,
                                                           CompteComptable_local__c = cc.id,
                                                           libelle__c=VIConstant.EC_CA_AVENCEMENT,
                                                           periode_comptable__c=ListPeriode[0].id,
                                                           affaire__c=aff.id);
        insert lc;
        testlb.EcrituresAEnvoyer='Avancement';
        testlb.Entite_bw=[SELECT entite_bw__c FROM VIEntiteBW__c LIMIT 1].entite_bw__c;
        
        testlb.callBatchEnvoiEcriture();        
    }    

    static testmethod void VILancementBatchController_batchCloture_Test() {
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        
        VILancementBatchController testlb = new VILancementBatchController (); 
        PageReference pageRef = Page.VILancementBatch;

        testlb.Entite_bw=[SELECT entite_bw__c FROM VIEntiteBW__c LIMIT 1].entite_bw__c;
        
        testlb.getPeriodeEntite_bwOptions();
        testlb.entite_bw='1';
        testlb.callBatchCloture() ;
    }    

    static testmethod void VILancementBatchController_batchenvoiecriture_Test() {
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        
        VILancementBatchController testlb = new VILancementBatchController (); 
        PageReference pageRef = Page.VILancementBatch;

        testlb.Entite_bw=[SELECT entite_bw__c FROM VIEntiteBW__c LIMIT 1].entite_bw__c;

        VIAffaire__c aff = [select id,entite_bw__c from VIAffaire__c limit 1];
        aff.entite_bw__c = '1';
        update aff; 
        
        VIperiode__c per_ouverte =[SELECT id,name
                                     FROM VIperiode__c 
                                    WHERE statut__c=:VIConstant.PERIODE_OUVERTE ];
       
        list<VICompte_general__c>ListCG = new list<VICompte_general__c>();
        listCG.add(new  VICompte_general__c  (name='903000'));        
        insert ListCG ; 
        
        VICompte_general__c cg = [select id from VICompte_general__c LIMIT 1];
        
        
        VILigne_comptable__c lc = new VILigne_comptable__c(affaire_de_rattachement__c=aff.id, 
                                                           Periode_comptable__c=per_ouverte.id,
                                                           statut_ecriture_comptable__c='20',
                                                           sens__c='D',
                                                           montant__c=1,
                                                           CompteComptable_local__c=cg.id,
                                                           libelle__c=VIConstant.EC_CA_AVENCEMENT, 
                                                           sous_chapitre__c='00-00');
        insert lc;
        
        testlb.getPeriodeEntite_bwOptions();
        testlb.EcrituresAEnvoyer='Avancement';
        testlb.entite_bw='1';
        testlb.callBatchEnvoiEcriture() ;
    }    

    static testmethod void VILancementBatchController_batchImportAffaire_Test() {
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        
        VILancementBatchController testlb = new VILancementBatchController (); 
        PageReference pageRef = Page.VILancementBatch;

        testlb.Entite_bw=[SELECT entite_bw__c FROM VIEntiteBW__c LIMIT 1].entite_bw__c;
        
        testlb.getPeriodeEntite_bwOptions();
        testlb.entite_bw='1';
        testlb.callImportAffaire(); 
    }    


    static testmethod void VILancementBatchController_recalcul_Test() {
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Pointage();
       
        VILancementBatchController testlb = new VILancementBatchController (); 
        PageReference pageRef = Page.VILancementBatch;

        testlb.Entite_bw=[SELECT entite_bw__c FROM VIEntiteBW__c LIMIT 1].entite_bw__c;
        
        testlb.getPeriodeEntite_bwOptions();
        testlb.entite_bw='1';
        testlb.date_minimum=system.today();
        testlb.date_maximum=system.today();
        
        testlb.callRecalcul();

    }    

    
}