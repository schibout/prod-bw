@isTest
public class VIGenereLigne1_test {
 
    static testmethod void VIGenereLigne_type1_test() {
    
        VIInsertDataTest.VIInsertData_EUR_affaire();
        //VIInsertDataTest.VIInsertData_Achat();
        //VIInsertDataTest.VIInsertData_Pointage();
        //VIInsertDataTest.VIInsertData_Facture();
        

        VIType_de_depense__c tdMat=[select id from VIType_de_depense__c where name like 'MAT%' ];
        VIType_de_depense__c tdMo=[select id from VIType_de_depense__c where name like 'MO%' ];
        VIType_de_depense__c tdGAR=[select id from VIType_de_depense__c where name like 'GAR%' ];
        VIType_de_depense__c tdPFG=[select id from VIType_de_depense__c where name like 'PFG%' ];
        
        VIcentre_section__c cs=[select id from VIcentre_section__c LIMIT 1 ];
       
        list<VICompte_general__c>ListCG = new list<VICompte_general__c>();
        listCG.add(new  VICompte_general__c  (name='7'));
        listCG.add(new  VICompte_general__c  (name='920100'));
        listCG.add(new  VICompte_general__c  (name='930100'));
        listCG.add(new  VICompte_general__c  (name='940100'));
        listCG.add(new  VICompte_general__c  (name='606000'));        
        listCG.add(new  VICompte_general__c  (name='903000'));        

        insert ListCG ; 
        VICompte_general__c cg = [select id from VICompte_general__c LIMIT 1];

        VIperiode__c per_ouverte =[SELECT id,name
                                     FROM VIperiode__c 
                                    WHERE statut__c=:VIConstant.PERIODE_OUVERTE ];

        VIperiode__c per_derniere =[SELECT id,name
                                     FROM VIperiode__c 
                                    WHERE statut__c=:VIConstant.PERIODE_DERNIERE ];

        VIAffaire__c aff= [select id, Produit_SousDomaine__c, Entite_BW__c   from VIAffaire__c];

            
        VISousDomaine__c sousdomaine = [select id, Type_d_imputation__c,Mode_de_calcul_de_l_avancement__c  from VISousDomaine__c ];
        sousdomaine.Type_d_imputation__c ='1';
        sousdomaine.Mode_de_calcul_de_l_avancement__c='2';
        update sousdomaine ; 

        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_pointage();

        VIAchat__c ac = [SELECT id, origine__c 
                           FROM VIAchat__c] ;
        ac.origine__c='SQL-SERVER-Facture-Fournisseur';
        update ac;

        VILigne_comptable__c lc = new VILigne_comptable__c(affaire_de_rattachement__c=aff.id, 
                                                           Periode_comptable__c=per_ouverte.id,
                                                           statut_ecriture_comptable__c='40',
                                                           sens__c='D',
                                                           montant__c=1,
                                                           CompteComptable_local__c=cg.id,
                                                           sous_chapitre__c='00-00',
                                                           libelle__c='ll');
        insert lc;
        
        VIGenereLigne1 v = new VIGenereLigne1('','1');
        v.execute(null);

        
    }
   
    static testmethod void VIGenereLigne_type4_test() {
    
        VIInsertDataTest.VIInsertData_EUR_affaire();
        

        VIType_de_depense__c tdMat=[select id from VIType_de_depense__c where name like 'MAT%' ];
        VIType_de_depense__c tdMo=[select id from VIType_de_depense__c where name like 'MO%' ];
        VIType_de_depense__c tdGAR=[select id from VIType_de_depense__c where name like 'GAR%' ];
        VIType_de_depense__c tdPFG=[select id from VIType_de_depense__c where name like 'PFG%' ];
        
        VIcentre_section__c cs=[select id from VIcentre_section__c LIMIT 1 ];
       
        list<VICompte_general__c>ListCG = new list<VICompte_general__c>();
        listCG.add(new  VICompte_general__c  (name='7'));
        listCG.add(new  VICompte_general__c  (name='920100'));
        listCG.add(new  VICompte_general__c  (name='930100'));
        listCG.add(new  VICompte_general__c  (name='940100'));
        listCG.add(new  VICompte_general__c  (name='606000'));        
        listCG.add(new  VICompte_general__c  (name='903000'));        

        insert ListCG ; 
        VICompte_general__c cg = [select id,name from VICompte_general__c LIMIT 1];
        

        VIperiode__c per_ouverte =[SELECT id,name
                                     FROM VIperiode__c 
                                    WHERE statut__c=:VIConstant.PERIODE_OUVERTE ];

        VIperiode__c per_derniere =[SELECT id,name
                                     FROM VIperiode__c 
                                    WHERE statut__c=:VIConstant.PERIODE_DERNIERE ];

        VIAffaire__c aff= [select id, Produit_SousDomaine__c, Entite_BW__c   from VIAffaire__c];

            
        VISousDomaine__c sousdomaine = [select id, Type_d_imputation__c,Mode_de_calcul_de_l_avancement__c  from VISousDomaine__c ];
        sousdomaine.Type_d_imputation__c ='4';
        sousdomaine.Mode_de_calcul_de_l_avancement__c='2';
        update sousdomaine ; 

        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_pointage();

        VIAchat__c ac = [SELECT id, origine__c ,CompteGeneral__c,type_depense__c, affaire__c,Centre_Section__c,
                                Sous_chapitre__c,Periode_comptable__c
                           FROM VIAchat__c] ;
        ac.origine__c='SQL-SERVER-Facture-Fournisseur';  
        ac.CompteGeneral__c=cg.name;
        ac.type_depense__c=tdMAT.id;
        update ac;
        
        VIAchat__c ac1 = new VIAchat__c() ; 
        ac1.origine__c='Mvt_stock';
        ac1.CompteGeneral__c=ac.CompteGeneral__c;
        ac1.type_depense__c=tdPFG.id; 
        ac1.affaire__c = ac.affaire__c;
        ac1.Centre_Section__c = ac.Centre_Section__c;
        ac1.Sous_chapitre__c = ac.Sous_chapitre__c;     
        ac1.Periode_comptable__c = ac.Periode_comptable__c;
        ac1.date__c=system.today();
        ac1.ComptabiliseD__c=1;
        insert ac1 ; 
        
        VIAchat__c ac2 = new VIAchat__c() ; 
        ac2.origine__c='Mvt_stock';
        ac2.CompteGeneral__c=ac.CompteGeneral__c;
        ac2.type_depense__c=ac.type_depense__c; 
        ac2.affaire__c = ac.affaire__c;
        ac2.Centre_Section__c = ac.Centre_Section__c;
        ac2.Sous_chapitre__c = ac.Sous_chapitre__c;     
        ac2.Periode_comptable__c = ac.Periode_comptable__c;
        ac2.date__c=system.today();
        ac2.ComptabiliseD__c=1;
        insert ac2 ; 
        
            
        VIGenereLigne1 v = new VIGenereLigne1('','1');
        v.execute(null);

        
        
        
/*      henri
        list<VILigne_Affaire__c>ListLa= [SELECT id, Cout_terminaison_MontantD__c, Engage_brut_arrete_MontantD__c,Ecart_C_A_F_MontantD__c   
                                           FROM VILigne_Affaire__c ] ;

        ListLa[0].Ecart_C_A_F_MontantD__c=1;
        update ListLa ; 
        System.assertEquals(2, listLa.size());
        System.assertEquals(101, listLa[0].Engage_brut_arrete_MontantD__c);
*/
        
    }   
    static testmethod void VIGenereLigne_type8_test() {
    
        VIInsertDataTest.VIInsertData_EUR_affaire();
        //VIInsertDataTest.VIInsertData_Achat();
        //VIInsertDataTest.VIInsertData_Pointage();
        //VIInsertDataTest.VIInsertData_Facture();
        

        VIType_de_depense__c tdMat=[select id from VIType_de_depense__c where name like 'MAT%' ];
        VIType_de_depense__c tdMo=[select id from VIType_de_depense__c where name like 'MO%' ];
        VIType_de_depense__c tdGAR=[select id from VIType_de_depense__c where name like 'GAR%' ];
        VIType_de_depense__c tdPFG=[select id from VIType_de_depense__c where name like 'PFG%' ];
        
        VIcentre_section__c cs=[select id from VIcentre_section__c LIMIT 1 ];
       
        list<VICompte_general__c>ListCG = new list<VICompte_general__c>();
        listCG.add(new  VICompte_general__c  (name='7'));
        listCG.add(new  VICompte_general__c  (name='920100'));
        listCG.add(new  VICompte_general__c  (name='930100'));
        listCG.add(new  VICompte_general__c  (name='940100'));
        listCG.add(new  VICompte_general__c  (name='606000'));        
        listCG.add(new  VICompte_general__c  (name='903000'));        

        insert ListCG ; 

        VIperiode__c per_ouverte =[SELECT id,name
                                     FROM VIperiode__c 
                                    WHERE statut__c=:VIConstant.PERIODE_OUVERTE ];

        VIperiode__c per_derniere =[SELECT id,name
                                     FROM VIperiode__c 
                                    WHERE statut__c=:VIConstant.PERIODE_DERNIERE ];

        VIAffaire__c aff= [select id, Produit_SousDomaine__c, Entite_BW__c   from VIAffaire__c];

            
        VISousDomaine__c sousdomaine = [select id, Type_d_imputation__c,Mode_de_calcul_de_l_avancement__c  from VISousDomaine__c ];
        sousdomaine.Type_d_imputation__c ='8';
        sousdomaine.Mode_de_calcul_de_l_avancement__c='2';
        update sousdomaine ; 

        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_pointage();

        VIAchat__c ac = [SELECT id, origine__c ,type_depense__c, affaire__c,Centre_Section__c,CompteGeneral__c,
                                Sous_chapitre__c,Periode_comptable__c
                           FROM VIAchat__c] ;
        ac.origine__c='SQL-SERVER-Facture-Fournisseur';
        ac.type_depense__c=tdMAT.id;        
        update ac;
        
        VIAchat__c ac1 = new VIAchat__c() ; 
        ac1.origine__c='Mvt_stock';
        ac1.CompteGeneral__c=ac.CompteGeneral__c;
        ac1.type_depense__c=tdPFG.id; 
        ac1.affaire__c = ac.affaire__c;
        ac1.Centre_Section__c = ac.Centre_Section__c;
        ac1.Sous_chapitre__c = ac.Sous_chapitre__c;     
        ac1.Periode_comptable__c = ac.Periode_comptable__c;
        ac1.date__c=system.today();
        ac1.ComptabiliseD__c=1;
        insert ac1 ; 
        
        
        VIAchat__c ac2 = new VIAchat__c() ; 
        ac2.origine__c='Mvt_stock';
        ac2.CompteGeneral__c=ac.CompteGeneral__c;
        ac2.type_depense__c=tdMAT.id; 
        ac2.affaire__c = ac.affaire__c;
        ac2.Centre_Section__c = ac.Centre_Section__c;
        ac2.Sous_chapitre__c = ac.Sous_chapitre__c;     
        ac2.Periode_comptable__c = ac.Periode_comptable__c;
        ac2.date__c=system.today();
        ac2.ComptabiliseD__c=1;
        insert ac2 ; 
        
            
        VIGenereLigne1 v = new VIGenereLigne1('','1');
        v.execute(null);

        
        
        
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