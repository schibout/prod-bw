@isTest
public class VISchedGenereCentralis_test {

    static testmethod void VISchedGenereCentralis_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_Pointage();
        VIInsertDataTest.VIInsertData_Facture();
        
        
        VISousDomaine__c sd = [select  Mode_de_calcul_de_l_avancement__c from VISousDomaine__c];
        sd.Mode_de_calcul_de_l_avancement__c='2';
        update sd ; 

        VIPeriode__c per_ouverte ; 
        VIPeriode__c per_preouverte ;

        for(VIperiode__c per:[SELECT id,date_de_fin__c ,statut__c
                                FROM VIperiode__c 
                              ORDER BY NAME]) {
           if(per.statut__c==VIConstant.PERIODE_OUVERTE) 
               per_ouverte=per; 
           if(per.statut__c==VIConstant.PERIODE_PREOUVERTE) 
               per_preouverte=per; 
       }
        
        VICompte_general__c cc = new  VICompte_general__c  (name='7');
        VICompte_general__c c706000 = new  VICompte_general__c  (name='706000');
        VICompte_general__c c473000 = new  VICompte_general__c  (name='473000');        
        list<VICompte_general__c>ListCompteGeneral = new list<VICompte_general__c>();
        ListCompteGeneral.add(cc);
        ListCompteGeneral.add(c706000);        
        ListCompteGeneral.add(c473000);        
        
        insert ListCompteGeneral ; 
        
       
        VIAchat__c ac = [SELECT id, CompteGeneral__c , ComptabiliseD__c , periode_comptable__c , affaire__c,
                                Centre_Section__r.id,Type_depense__r.id,
                                CurrencyIsoCode, sous_chapitre__c,
                                num_cde__c,
                                origine__c
                           FROM VIachat__c 
                          WHERE periode_comptable__r.statut__c=:VIConstant.PERIODE_OUVERTE ];

        VIAchat__c newac = new VIAchat__c (name='aaa', CompteGeneral__c=ac.CompteGeneral__c , ComptabiliseD__c=1, affaire__c=ac.affaire__c,
                                           periode_comptable__c=per_preouverte.id,date__c=per_preouverte.date_de_fin__c,
                                           Centre_Section__c=ac.Centre_Section__r.id,Type_depense__c=ac.Type_depense__r.id,
                                           CurrencyIsoCode=ac.CurrencyIsoCode, sous_chapitre__c=ac.sous_chapitre__c,
                                           num_cde__c=ac.num_cde__c,
                                           origine__c=ac.origine__c);
        insert newac ; 
        
                       

        VIpointage__C point = [SELECT id , affaire__c, Centre_Section__c , Complet__c ,CompteGeneral__c ,date__c, Date_comptabilisation__c ,
                                      Debours__c ,Employe__c ,heures__c,Numero_unique__c , Sous_chapitre__c 
                                 FROM VIpointage__C 
                                WHERE periode_comptable__c=:Per_ouverte.id limit 1];
		VIpointage__c newpoint = new VIPointage__c (
                                        affaire__c=point.affaire__c, 
                                        Centre_Section__c=point.Centre_Section__c , 
                                        CompteGeneral__c=point.CompteGeneral__c ,
                                        date__c=per_preouverte.date_de_fin__c, 
                                        Date_comptabilisation__c=per_preouverte.date_de_fin__c ,
                                        Employe__c=point.Employe__c ,
                                        heures__c=point.heures__c,
                                        Numero_unique__c=point.Numero_unique__c+'zz' , 
                                        Sous_chapitre__c=point.Sous_chapitre__c );
        insert newPoint ;         


        VIfacture__C fac = [SELECT id , affaire__c, Compte__c  ,Compte_general__c,date__c, Date_de_comptabilisation__c ,
                                      Montant_HT__c, Periode_comptable__c ,Type__c  
                                 FROM VIfacture__C 
                                WHERE periode_comptable__c=:Per_ouverte.id limit 1];
		VIfacture__C newfac = new VIfacture__C (
                                        affaire__c=fac.affaire__c, 
                                        Compte__c=fac.Compte__c , 
                                        Compte_general__c =fac.Compte_general__c ,
                                        date__c=per_preouverte.date_de_fin__c, 
                                        Date_de_comptabilisation__c=per_preouverte.date_de_fin__c ,
                                        Montant_HT__c=fac.Montant_HT__c,
                                        Type__c=fac.Type__c );
        insert newfac ;         
        
        
        VIInsertDataTest.VIInsertData_ligne_comptable();
        
        list<VILigne_comptable__c>ListLc = [SELECT id,CompteComptable_local__c,Statut_ecriture_comptable__c  FROM VILigne_comptable__c];
        for(VILigne_comptable__c lc : ListLc) {
            lc.CompteComptable_local__c=c706000.id;
            lc.Statut_ecriture_comptable__c='40';
            lc.type_de_depense__c='AVT';
        }
        update listLc ; 
        Database.executeBatch(new VISchedGenereCentralis1(),VISchedGenereCentralis1.NBR_LOT());                
        for(VILigne_comptable__c lc : ListLc) {
            lc.CompteComptable_local__c=c473000.id;
        }
        update listLc ; 

        //VISchedGenereCentralis4 v = new VISchedGenereCentralis4();
        //v.execute(null);

        
/*      henri
        list<VILigne_Affaire__c>ListLa= [SELECT id, Cout_terminaison_MontantD__c, Engage_brut_arrete_MontantD__c,Ecart_C_A_F_MontantD__c   
                                           FROM VILigne_Affaire__c ] ;

        ListLa[0].Ecart_C_A_F_MontantD__c=1;
        update ListLa ; 
        System.assertEquals(2, listLa.size());
        System.assertEquals(101, listLa[0].Engage_brut_arrete_MontantD__c);
*/
        
    }
}