/*
*
*  We have to launch the import files 
*
*
*  for running by hand : 
 VISchedImportFacture v = new VISchedImportFacture('B89133',false,true);
 v.execute(null);
*
*  for running every hour at xx:16
     VISchedImportFacture m = new VISchedImportFacture();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VISchedImportFacture', sch, m);
*
*
*/
global class VISchedImportFacture implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global id PaysFr = null ; 
    Global Map<date, VIPeriode__c>MapPeriode = new Map<date, VIPeriode__c>();
    
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean Toute ;    
    
     public VISchedImportFacture(String Param1,Boolean Param2,Boolean Param3 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
        Toute = Param3;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportFacture','4 Running','','Start ');


        for(VIPeriode__c per : [Select name, id,date_de_debut__c from VIPeriode__c where Entite_BW__c='1']) {
            MapPeriode.put(per.date_de_debut__c, per);
        }        
        
        PaysFr = [SELECT id from VIpays__c where name='FR'].id; 
                                         
        string query = 'SELECT codeAffaire__c, compte__c,Date_echeance__c ,date__c,date_de_comptabilisation__c,libelle__c,  ';
        query = query+'        MtHT__c , MtTVA__c   ,MtTTC__c,name,Type__c ,MtEncaisse__c , CodeCentre__c, Type_de_depense__c ,';
        query = query+'        Import_Status__c,Numero_de_facture__c, Type_enregistrement__c, num_reglement__c,Ligne_facture__c,  ';
        query = query+'        chapitre__c,sous_chapitre__c  ';        
        query = query+'   FROM Int_facture__c ';
        query = query+'   WHERE codeaffaire__c!=null ';


        if(!toute)
            query = query+'     AND (Import_Status__c =\'1\' or Import_Status__c =null) ';

        //query = query+'     AND date_de_comptabilisation__c!=null ';        
        query = query+'     AND (codeAffaire__c Like \''+AffaireAGenerer+'%\')  ';
        query = query+'   Order by codeaffaire__c asc ';        

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Int_Facture__c> scope){
        num_record = 0;
        Map<string, VIAffaire__c>MapAffaire  = new Map<string, VIAffaire__c>();
        Map<string, VIFacture__c>MapFacture  = new Map<string, VIFacture__c>();
        Map<string, VIligne_comptable__c>MapLigneComptable  = new Map<string, VIligne_comptable__c>();        
        Map<string, VICompte_general__c >MapCompte  = new Map<string, VICompte_general__c >();

        
        
        List<string>ListIDAffaire = new List<string>();
        List<string>ListIDCompte  = new List<string>();        
        List<string>ListIDLigneFacture  = new List<string>();        
        
        for(Int_facture__c fac:scope) {
            num_record = num_record+1;
            ListIDAffaire.add(fac.codeAffaire__c);
            ListIDCompte.add(fac.compte__c);
            if(fac.date_de_comptabilisation__c==null)
                fac.date_de_comptabilisation__c=fac.date__c;

            if(fac.Type_enregistrement__c=='ECR' ) 
                ListIDLigneFacture.add(Fac.codeAffaire__c+'-'+Fac.Numero_de_facture__c+'-'+fac.type_de_depense__c+'-'+fac.compte__c) ;
        }       

        for(VICompte_general__c com : [SELECT id,name
                                         FROM VICompte_general__c 
                                        WHERE name in :ListIDCompte]) {
            MapCompte.put(com.name, com);
        }

        for(VIAffaire__c aff : [SELECT id,name,date_max_mouvement__c
                                  FROM VIAffaire__c 
                                 WHERE name in :ListIDAffaire]) {
            MapAffaire.put(aff.name, aff);
        }

        for(VIFacture__c fac : [SELECT id, name, affaire__r.name,date_de_comptabilisation__c
                             FROM VIFacture__c
                            WHERE affaire__r.name  in :ListIDAffaire]) {
            MapFacture.put(fac.affaire__r.name+'/'+fac.date_de_comptabilisation__c+'/'+fac.name , fac);
        }
        for(VIligne_comptable__c lc : [SELECT id, name, reference__c, affaire__r.name  
                                         FROM VIligne_comptable__c
                                        WHERE reference__c  in :ListIDLigneFacture or affaire__r.name='9990']) {
            MapLigneComptable.put(lc.reference__c , lc);
        }

        list<VIFacture__c>listInsertFacture = new List<VIFacture__c>();
        list<VIligne_comptable__c>ListInsertLC = new list<VIligne_comptable__c>();
        for(Int_facture__c fac:scope) {
            if(fac.libelle__c!=null) {
                if(fac.libelle__c.contains('|')) {
                     system.debug('présence d un pipe dans le libellé, on ne traite pas');
                     fac.Import_Status__c='2';
                     continue ;     
                }
            }

            
            if( MapAffaire.containskey(fac.codeAffaire__c)) {
                VIAffaire__c aff = MapAffaire.get(fac.codeAffaire__c);
                if(fac.date__c!=null ) {
                    if(aff.date_max_mouvement__c==null || aff.date_max_mouvement__c<fac.date__c)
                        aff.date_max_mouvement__c=fac.date__c;
                }
                if(fac.date_de_comptabilisation__c!=null) {
                    if(aff.date_max_mouvement__c==null || aff.date_max_mouvement__c<fac.date_de_comptabilisation__c)
                        aff.date_max_mouvement__c=fac.date_de_comptabilisation__c;
                }
            }
            
            if(fac.type_enregistrement__c=='ECR' || fac.codeAffaire__c=='9990') {
                 if(!MapLigneComptable.containskey(fac.codeAffaire__c+'-'+fac.Numero_de_facture__c+'-'+fac.type_de_depense__c+'-'+fac.compte__c)) {
                     if(!MapAffaire.containskey(fac.codeAffaire__c)) {
                         fac.Import_Status__c='2';
                         continue ; 
                     }
                     
                     string PeriodeId ;                     
                     if(fac.date_de_comptabilisation__c<date.newinstance(2018,01,01)) {
                         PeriodeId = MapPeriode.get(date.newinstance(2018,01,01)).id ; 
                     } else  {
                         PeriodeId = MapPeriode.get(fac.date_de_comptabilisation__c.tostartofmonth()).id ;
                     }
                     
                     VIligne_comptable__c lc = new VIligne_comptable__c (
                        affaire__c                =MapAffaire.get(fac.codeAffaire__c).id,
                        affaire_de_rattachement__c=MapAffaire.get(fac.codeAffaire__c).id,
                        compte_comptable_groupe__c=fac.compte__c,
                        comptecomptable_local__c  =MapCompte.get(fac.compte__c).id, 
                        Periode_comptable__c      =PeriodeId,
                        date_ecriture__c          =fac.date_de_comptabilisation__c,
                        libelle__c                =fac.libelle__c,
                        sens__c                   =(fac.mtHT__c>0?'C' : 'D'),
                        montant__c                =fac.mtHT__c * (fac.mtHT__c>0?1 : -1),
                        statut_ecriture_comptable__c='40',
                        centre__c                 =fac.CodeCentre__c,
                        chapitre__c               =fac.chapitre__c,
                        sous_chapitre__c          =fac.sous_chapitre__c,
                        type_de_depense__c        =fac.type_de_depense__c,
                        reference__c              =fac.codeAffaire__c+'-'+fac.Numero_de_facture__c+'-'+fac.type_de_depense__c+'-'+fac.compte__c
                      ) ;
                     fac.Import_Status__c='2';       
                     MapLigneComptable.put(lc.reference__c , lc);
                     
                     ListInsertLC.add(lc);
                 }
                 fac.Import_Status__c='2';
                 continue ;     
            }



            string num_facture='';
            if(fac.type_enregistrement__c=='FAC') {
                num_facture=fac.Numero_de_facture__c ;
            } else if(fac.type_enregistrement__c=='RGC') {
                num_facture=fac.Numero_de_facture__c+'-'+fac.Num_reglement__c ;
            }
            system.debug('Facture en cours '+fac.codeaffaire__c+' ' +num_facture);
            
            if(MapFacture.containskey(fac.codeAffaire__c+'/'+fac.date_de_comptabilisation__c+'/'+num_facture)) {
                fac.Import_Status__c='2';       
                continue;
            }

            if(!MapAffaire.containskey(fac.codeAffaire__c)) {
                VIUtils.LogWrite('VISchedImportFacture','3 Error','','code affaire inconnue '+fac.codeAffaire__c);
                continue ; 
            }
            
            VIFacture__c facture = new VIFacture__c();
            VIAffaire__c Affaire=MapAffaire.get(fac.codeAffaire__c);

            if(MapCompte.containskey(fac.compte__c))
                Facture.compte_general__c=MapCompte.get(fac.compte__c).id;
            
            Facture.name=num_facture ;  
            Facture.affaire__c=Affaire.id;
            Facture.Date__c =fac.date__c;
            if(Facture.Date__c<=date.newinstance(2018,01,01) ) {
                 Facture.Date__c=date.newinstance(2018,01,01);
             }
            
            
            if(fac.date_echeance__c!=null)
                Facture.Date_echeance__c =fac.date_echeance__c;
            
            Facture.Type__c  =fac.Type_enregistrement__c;     

            if(fac.date_de_comptabilisation__c!=null)
                Facture.date_de_comptabilisation__c = fac.date_de_comptabilisation__c ; 

            Facture.Libelle__c = fac.Libelle__c ; 
                      
            if(fac.type_enregistrement__c=='FAC') {
                Facture.Montant_HT__c  =fac.MtHT__c;            
                Facture.Montant_TVA__c  =(fac.MtTVA__c==null ? 0 : fac.MtTVA__c);            
                Facture.Montant_TTC__c  =fac.MtTTC__c;                        
            } else if(fac.type_enregistrement__c=='RGC') {
                Facture.Montant_HT__c  =fac.MtHT__c;                            
                Facture.Montant_Paye__c=fac.MtEncaisse__c  ;
            }
                      
            listInsertFacture.add(Facture);
            mapFacture.put(num_facture,facture);
            
            fac.Import_Status__c='2';

            
        }
        update scope ; 
        update MapAffaire.values();
        insert listInsertFacture;    
        insert ListInsertLC ; 

    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportFacture','1 Normal',IDLog,'End '+num_record);
        if(enchaine)
            Database.executeBatch(new VISchedImportAchat(AffaireAGenerer, enchaine,toute),VISchedImportAchat.NBR_LOT());        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedImportFacture(AffaireAGenerer, enchaine, toute),VISchedImportfacture.NBR_LOT());
    }
    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=100 ;
         } else {
             i=10;    
         }
         return i;
    }

    
    
}