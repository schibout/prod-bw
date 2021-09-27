/*
*
*  We have to launch the import files 
*
*
*  for running by hand : 
 VISchedImportAchat v = new VISchedImportAchat();
 v.execute(null);
*
*  for running every hour at xx:16
     VISchedImportAchat m = new VISchedImportAchat();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VISchedImportAchat', sch, m);
*
*
*/
global class VISchedImportAchat implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global id PaysFr = null ; 
    Global Map<string, VICentre_Section__c>MapCentre = new Map<string, VICentre_Section__c>();
    Global Map<string, VIType_de_depense__c>MapDepense = new Map<string, VIType_de_depense__c>();
    
    Global VICentre_section__c CS800;
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean toute ;
    
     public VISchedImportAchat(String Param1,Boolean Param2,Boolean Param3 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
        toute = Param3;                         
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportAchat','4 Running','','Start ');

        for(VIType_de_depense__c td : [Select name, id from VIType_de_depense__c]) {
            MapDepense.put(td.name.Left(3), td);
        }
        for(VICentre_Section__c cs : [Select name, id from VICentre_Section__c]) {
            MapCentre.put(cs.name.Left(3), cs);
        }
        
        
        PaysFr = [SELECT id from VIpays__c where name='FR'].id; 
                                         
        string query = 'SELECT id,codeAffaire__c, codecentre__c,codechapitre__c, codesousChapitre__c,Name_ref_achat__c ,date_de_commande__c, ';
        query = query+'        Date__c, Mtcommande__c ,MtCompatabilise__c , Import_Status__c, typededepense__c,num_cde__c,num_frn__c,lib_frn__c, libelle__c, typeODA__c,   ';
        query = query+'        Mnt_frg__c ,Mnt_frk__c ,origine__c, name, CompteGeneral__c,num_fac__c    ';        
        query = query+'   FROM Int_achat__c ';
        query = query+'   WHERE codeaffaire__c!=null ';

        if(!toute)
            query = query+'     AND (Import_Status__c =\'1\' or Import_Status__c =null) ';

        query = query+'     AND (codeAffaire__c Like \''+AffaireAGenerer+'%\')  ';
        //query = query+'     AND Origine__c =\'SQL-SERVER-Facture-Fournisseur\'  ';
        //query = query+'     AND Date__c>=2021-04-01  ';
       // query = query+'     AND (not codeAffaire__c Like \'8%\')  ';        
       // query = query+'     AND ( codecentre__c not in (\'94O\',\'94Y\',\'430\',\'331\',\'94R\',\'C92\',\'99O\'))  '; 
                      
        query = query+'   Order by codeaffaire__c,date__c desc  ';        
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Int_achat__c> scope){
        num_record = 0;
        Map<string, VIAffaire__c>MapAffaire  = new Map<string, VIAffaire__c>();
        Map<string, VIAchat__c>MapAchat  = new Map<string, VIAchat__c>();
        
        List<string>ListIDAffaire = new List<string>();
        date date_min ; 
        date date_max ;
        
        for(Int_achat__c ac:scope) {
            num_record = num_record+1;
            ListIDAffaire.add(ac.codeAffaire__c);
            if(date_max==null || date_max<ac.date__c)
                date_max=ac.date__c; 
            
            if(date_min==null || date_min>ac.date__c)
                date_min=ac.date__c; 
            
        }       
        system.debug('Dates '+date_min+' '+date_max);

        for(VIAffaire__c aff : [SELECT id,name,date_max_mouvement__c
                                  FROM VIAffaire__c 
                                 WHERE name in :ListIDAffaire]) {
            MapAffaire.put(aff.name, aff);
        }
        system.debug('Affaire '+MapAffaire);
        

        for(VIAchat__c ac : [SELECT id,name,Num_cde__c,affaire__r.name,Num_frn__c
                               FROM VIAchat__c 
                              WHERE affaire__r.name in :ListIDAffaire
                                AND date__c>=:date_min
                                AND date__c<=:date_max]) {
            MapAchat.put(ac.name, ac);
        }

        list<VIAchat__c>listInsertAchat = new List<VIAchat__c>();
        for(Int_achat__c ac:scope) {
            String num_cde='';
            if(ac.origine__c=='SQL-SERVER-Facture-Fournisseur') {
                num_cde='F'+'-'+ac.Name_ref_achat__c.toplainstring();
            } else if(ac.origine__c=='reprise' || ac.origine__c=='stock' || ac.origine__c=='Mvt_stock'  ) {
                num_cde='M-'+ac.Name.removestart(ac.codeaffaire__c+'-');
            } else {
                if(ac.num_cde__c==null && ac.num_frn__c==null) {
                    num_cde=ac.name.replace('-null','');
                } else {
                    if(ac.Name_ref_achat__c!=null) {
                        num_cde = ac.Name_ref_achat__c.toPlainString() +'-';
                    } else {
                        num_cde = ac.num_cde__c+'-'+ac.num_frn__c;
                    }
                } 
                if(ac.origine__c!='SQL-SERVER-ISA_V2' ) { 
                    num_cde='S'+'-'+num_cde;
                } else {
                    num_cde='M'+'-'+num_cde+'-'+ac.date_de_commande__c;
                }
             

            }
            num_cde=num_cde.left(80);
            
            if(MapAchat.containskey(ac.codeAffaire__c+'-'+num_cde)) {
                ac.Import_Status__c='2';
                continue ; 
            }
            
            if(ac.Mtcommande__c==0 && ac.MtCompatabilise__c==0 ) {
                ac.Import_Status__c='2';
                continue ; 
            }

            VIAchat__c Achat = new VIAchat__c();
            
            system.debug(ac.codeaffaire__c+'-'+num_cde);
            
            if(MapAffaire.containskey(ac.codeAffaire__c)) {
                VIAffaire__c Affaire=MapAffaire.get(ac.codeAffaire__c);
                Achat.affaire__c=Affaire.id;
                Achat.name = ac.codeAffaire__c+'-'+num_cde;
                
                if(affaire.date_max_mouvement__c==null || affaire.date_max_mouvement__c<ac.date__c)
                    affaire.date_max_mouvement__c=ac.date__c;

                
                if(!MapCentre.containskey(ac.codecentre__c)) {
                    VIUtils.LogWrite('VISchedImportAchat','3 Error','','code centre inconnu '+ac.codecentre__c+' '+ac.id);
                    continue ; 
                }
                if(!MapDepense.containskey((ac.typedeDepense__c+' ').left(3))) {
                    VIUtils.LogWrite('VISchedImportAchat','3 Error','','code depense inconnu '+ac.typedeDepense__c+' '+ac.id);
                    continue ; 
                }
                
                Achat.Centre_Section__c =MapCentre.get(ac.codecentre__c).id;
                Achat.type_depense__c= MapDepense.get( (ac.typedeDepense__c+' ').left(3)).id;
       
                Achat.Sous_chapitre__c =('0'+ac.Codechapitre__c).right(2)+'-'+('0'+ac.Codesouschapitre__c).right(2);
                if(ac.origine__c=='reprise') {
                    achat.origine__c='SQL-SERVER-Facture-Fournisseur';
                } else if (ac.origine__c=='stock') {
                    achat.origine__c='Mvt_stock';
                } else {
                    Achat.Origine__c = ac.origine__c;
                }

                Achat.CommandeD__c =(ac.Mtcommande__c==null ? 0 :ac.Mtcommande__c);
                Achat.ComptabiliseD__c =(ac.Mtcompatabilise__c==null ? 0 :ac.Mtcompatabilise__c);

                Achat.Date__c =ac.date__c;

                if(Achat.ComptabiliseD__c!=0)
                    Achat.Date_de_comptabilisation__c =ac.date__c;
                
                Achat.CommandeI__c =Achat.CommandeD__c +(ac.mnt_frg__c==null ? 0 : ac.mnt_frg__c) ;            
                Achat.CommandeC__c =Achat.CommandeI__c +(ac.mnt_frk__c==null ? 0 : ac.mnt_frk__c) ;                        
                Achat.Num_cde__c  = ac.Num_cde__c ;

                if(ac.num_frn__c!=null)
                    Achat.num_frn__c  = ac.num_frn__c ;
                
                Achat.Nom_du_fournisseur__c          = ac.lib_frn__c ; 
                Achat.Description_de_la_commande__c  = ac.libelle__c ;                                
                Achat.TypeOda__c = ac.TypeOda__c;  
                Achat.num_fac__c = ac.num_fac__c;
                Achat.CompteGeneral__c  = ac.CompteGeneral__c ;
                MapAchat.put(ac.codeAffaire__c+'-'+num_cde, achat);

                listInsertAchat.add(Achat);
            } else {
                VIUtils.LogWrite('VISchedImportAchat','3 Error','','code affaire inconnue '+ac.codeaffaire__c+' '+ac.id);
                continue ;
            }
            ac.Import_Status__c='2';

        }
        update scope ; 
        update MapAffaire.values();
        insert listInsertAchat;        

    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportAchat','1 Normal',IDLog,'End '+num_record);
        if(enchaine)
            Database.executeBatch(new VISchedImportPointage(AffaireAGenerer, enchaine,toute),VISchedImportPointage.NBR_LOT());
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedImportAchat(AffaireAGenerer, enchaine, toute),VISchedImportAchat.NBR_LOT());

    }

    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=80 ;  // ça plantait à 100
         } else {
             i=10;    
         }
         i=80;
         return i;
    }
    
}