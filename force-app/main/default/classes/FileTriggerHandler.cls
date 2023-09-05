public with sharing class FileTriggerHandler {

    public static void tryInsertLinkToDocument(List<File__c> files) {
        Set<Id> ids = new Set<Id>();

        for (File__c file : files) {
            ids.add(file.Document__c);
        }

        Map<Id, Document__c> documents = new Map<Id, Document__c>([SELECT Id, File1__c, File2__c, File3__c, File4__c,
                File5__c, File6__c, File7__c, File8__c, File9__c, File10__c FROM Document__c WHERE Id = :ids]);

        Map<Id,Document__c> docsToUpdateMap = new Map<Id,Document__c>();
        Set<Document__c> docsToUpdate = new Set<Document__c>();

        for(File__c file : files) {
            Document__c doc = documents.get(file.Document__c);
            if(String.isBlank(doc.File1__c)) {
                doc.File1__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }                
                continue;
            }else if (String.isBlank(doc.File2__c)) {
                doc.File2__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File3__c)) {
                doc.File3__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File4__c)) {
                doc.File4__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File5__c)) {
                doc.File5__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File6__c)) {
                doc.File6__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File7__c)) {
                doc.File7__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File8__c)) {
                doc.File8__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File9__c)) {
                doc.File9__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }else if (String.isBlank(doc.File10__c)) {
                doc.File10__c = file.SP_File_Name__c;
                //docsToUpdate.add(doc);
                if(!docsToUpdateMap.containsKey(doc.Id)){
                    docsToUpdateMap.put(doc.Id, doc);
                }
                continue;
            }
        }

        if(!docsToUpdateMap.values().isEmpty()){
            update docsToUpdateMap.values();
        }

    }


    public static void tryToDeleteLinkToDocument(List<File__c> files) {
        Set<Id> ids = new Set<Id>();
        for (File__c file : files) {
            ids.add(file.Document__c);
        }

        Map<Id, Document__c> documents = new Map<Id, Document__c> ([SELECT Id, File1__c, File2__c, File3__c, File4__c,
                File5__c, File6__c, File7__c, File8__c, File9__c, File10__c FROM Document__c WHERE Id = :ids]);

        List<File__c> allFiles = [SELECT Id, File_Name__c, Document__c,SP_File_Name__c FROM File__c WHERE Document__c = :ids ORDER BY CreatedDate ASC];

        Map<Document__c, List<File__c>> documentFiles = new Map<Document__c, List<File__c>>();
        for(Document__c document : documents.values()) {
            for(File__c file : allFiles) {
                if(documentFiles.get(document) == null) {
                    documentFiles.put(document, new List<File__c>{file});
                }else{
                    if(file.Document__c == document.Id) {
                        documentFiles.get(document).add(file);
                    }
                }
            }

        }

        //use Set; because if deleting files belonging to single Document -> duplicate error
        Set<Document__c> documentsToUpdate = new Set<Document__c>();

        for(File__c file : files) {
            Document__c doc = documents.get(file.Document__c);
            List<File__c> listFiles = documentFiles.get(doc);
            if(file.SP_File_Name__c == doc.File1__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File2__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File3__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            } else if (file.SP_File_Name__c == doc.File4__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File5__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File6__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File7__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File8__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File9__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }else if (file.SP_File_Name__c == doc.File10__c) {
                Document__c docToUpdate = fillFirstTen(doc, listFiles);
                documentsToUpdate.add(docToUpdate);
                continue;
            }

        }
        if(!documentsToUpdate.isEmpty()) {
            update new List<Document__c>(documentsToUpdate);
        }

    }

    private static Document__c fillFirstTen(Document__c document, List<File__c> files) {
        //List<File__c> files = [SELECT Id, File_Name__c FROM File__c WHERE Document__c =:document.Id ORDER BY CreatedDate ASC LIMIT 11];
        System.debug('document : ' +document);
        System.debug('all files: ' + files);
        if(files == null) {
            document.File1__c = '';
            document.File2__c = '';
            document.File3__c = '';
            document.File4__c = '';
            document.File5__c = '';
            document.File6__c = '';
            document.File7__c = '';
            document.File8__c = '';
            document.File9__c = '';
            document.File10__c = '';
        }else{

            if (files.size() >= 1) {
                document.File1__c = files.get(0).SP_File_Name__c;
            }else{
                document.File1__c = '';
            }
            if (files.size() >= 2) {
                document.File2__c = files.get(1).SP_File_Name__c;
            }else{
                document.File2__c = '';
            }
            if (files.size() >= 3) {
                document.File3__c = files.get(2).SP_File_Name__c;
            }else{
                document.File3__c = '';
            }
            if (files.size() >= 4) {
                document.File4__c = files.get(3).SP_File_Name__c;
            }else{
                document.File4__c = '';
            }
            if(files.size() >= 5) {
                document.File5__c = files.get(4).SP_File_Name__c;
            }else{
                document.File5__c = '';
            }
            if(files.size() >= 6) {
                document.File6__c = files.get(5).SP_File_Name__c;
            }else {
                document.File6__c = '';
            }
            if(files.size() >= 7) {
                document.File7__c = files.get(6).SP_File_Name__c;
            }else{
                document.File7__c = '';
            }
            if(files.size() >= 8) {
                document.File8__c = files.get(7).SP_File_Name__c;
            }else{
                document.File8__c = '';
            }
            if(files.size() >= 9) {
                document.File9__c = files.get(8).SP_File_Name__c;
            }else{
                document.File9__c = '';
            }
            if (files.size() >= 10) {
                document.File10__c = files.get(9).SP_File_Name__c;
            }else{
                document.File10__c = '';
            }
        }


        return document;
    }

}