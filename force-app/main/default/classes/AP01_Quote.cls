/* Author: RBC
* Date: 07/12/2020
* Description: Create an attachment from salesforce on the quote based on the language field
* Test Class: AP01_Quote_Test    code coverage: 91%
*/

public class AP01_Quote {
    
    public static void CreateFichier(List<Quote> lstQuote){
        
        
        String FileName='';
        List<ContentDocumentLink> LstCDL = new List<ContentDocumentLink>();
        Map<String,ID> FileNameContentID = new Map<String,ID>();
        
        //get the ContentDocumentID
        List<ContentDocument> conDoc = [SELECT id, Title 
                                        FROM ContentDocument
                                        where title =: label.FileEnglish or title =: label.FileFrench or title =: label.FileItalian ];
        
        For (ContentDocument cd:conDoc ){
            
            FileNameContentID.put(cd.title, cd.id);
            
        }
        
        for (Quote devis:lstQuote){
            if(devis.DEV_Langue_doc_du_compte__c =='1'){                
                FileName= label.FileEnglish; // get the name of the english PDF
            } 
            
            else if(devis.DEV_Langue_doc_du_compte__c =='2'){                
                FileName= label.FileFrench;     // get the name of the french PDF           
            }
            
            else if(devis.DEV_Langue_doc_du_compte__c =='4'){                
                FileName = label.FileItalian;     // get the name of the italian PDF           
            }
            
            
            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = FileNameContentID.get(FileName);
            cDe.LinkedEntityId = devis.Id; // parentid
            cDe.ShareType = 'V'; // Inferred permission
            cDe.Visibility = 'AllUsers';
            LstCDL.add(cDe);           
        }
        
        if(LstCDL.size()>0){
            insert LstCDL;
        }
    }
    
    public static void updateDateLivraisonOppt(List<Quote> lstQuote, Map<Id, Quote> mapOldItems){
        
        Map<Id, List<Quote>> mapQuoteOpp = new Map<Id, List<Quote>>();
        
        for (Quote qt : lstQuote) {
            if(qt.OpportunityId!=null && qt.DEV_EntiteBW__c==Label.BW_ITA && qt.Status != mapOldItems.get(qt.Id).Status && qt.Status==label.Accepte) {
                mapQuoteOpp.put(qt.OpportunityId, new list<Quote>{qt});
            }
        }
        
        List<Opportunity> listOpp = new List<Opportunity>();
        if(mapQuoteOpp.size()>0) {
            listOpp = [SELECT OPP_DateDeLivraisonEnvisagee__c
                       FROM Opportunity
                       WHERE Id in : mapQuoteOpp.keySet()];
        }
        
        List<Opportunity> listOppUpdate = new List<Opportunity> (); 
        for (Opportunity opp: listOpp) {
            Integer delaisLivraison = 0; 
            for(Quote qt : mapQuoteOpp.get(opp.Id))
            {  
                if(opp.OPP_DateDeLivraisonEnvisagee__c==null)
                {
                    Date todayDate = date.today();
                    if(qt.DEV_DelaisLivraison__c!=null)
                    {
                        delaisLivraison = 7 * Integer.valueOf(qt.DEV_DelaisLivraison__c);
                        
                        opp.OPP_DateDeLivraisonEnvisagee__c = todayDate.addDays(delaisLivraison); 
                    }
                }
            }
            
            if(delaisLivraison!=0) {
                
                listOppUpdate.add(opp); 
            }
        }
        
        if(listOppUpdate !=null && listOppUpdate.size()>0) {
            update listOppUpdate;
        }
    }
    
}