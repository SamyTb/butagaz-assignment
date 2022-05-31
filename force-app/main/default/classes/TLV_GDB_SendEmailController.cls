global class TLV_GDB_SendEmailController {
    
    private static Lead oLead;
    
    WebService static string sendEmailFromLead(string leadId){
        
        System.Debug('Start method TLV_GDB_SendEmailController.sendEmailFromLead');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
        
        String outcomeMessage;
        String templateName;
        Id templateId;
        String orgWideEmailAddressName;
        Id orgWideEmailAddressId;
        
        
        // Get Lead
        List<Lead> lLead = [select Id, Name, Suspect_Number__c, Company from Lead where Id =:leadId limit 1];
        if(!lLead.isEmpty()){
            oLead = lLead[0];
        }else{
            return 'KO-Suspect non trouvé.';
        }
        
        // Get static documents Ids from the library / custom setting
        List<Id> lGDBContentVersionIdsToSendAsAttachment = getTeleventeSettingsValue('GDBContentVersionIdsToSendAsAttachment').split(';');

        List<ContentVersion> lContentVersion = [SELECT Id, VersionData, FileType, ContentDocumentId, Title
                FROM ContentVersion 
                WHERE IsLatest = True
                AND ContentDocumentId =:lGDBContentVersionIdsToSendAsAttachment];  //IN ('0699E000000LbDd','0699E000000LbDs')];   // =:mDocIds.keySet()];  // '0699E000000LbDY',    // , '0699E000000Twtq'
        
        System.debug(logginglevel.WARN,'### [TLV_GDB_SendEmailController.sendEmailFromLead] lContentVersion.size() = ' + lContentVersion.size());
        
        // Copy Document from Libraries to Documents
        List<String> contentList = new List<String>();
        if (!lContentVersion.IsEmpty()){
        	for (ContentVersion oContentVersion : lContentVersion){
        		Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        		
        		attachment.setFileName(oContentVersion.Title + '.' + oContentVersion.FileType);
        	    attachment.setBody(oContentVersion.VersionData);
        	    attachment.setInline(false);
        	    
        	    attachmentList.add(attachment);
        	}
        }
        
        
        // Save dynamic PDFs to the lead attachments
        generateGDBQuotePDF();
        
        
        // Create email
        List<String> sendTo = new List<String>();
        sendTo.add(UserInfo.getUserEmail());
        mail.setToAddresses(sendTo);
        //mail.setCcAddresses(ccAddresses);
        //mail.setOptOutPolicy(emailOptOutPolicy) // SEND, FILTER, REJECT
        orgWideEmailAddressName = getTeleventeSettingsValue('GDBOrgWideEmailAddressToUse');
        orgWideEmailAddressId = getOrgWideEmailAddressId(orgWideEmailAddressName);
        //mail.setReplyTo('erwan.lecaer@butagaz.com');
        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        //mail.setSenderDisplayName('Relation Client Granulés Butagaz');
        //mail.setSubject('Email Subject');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        //mail.setPlainTextBody('Email Plain Text Body');
        mail.setTargetObjectId(oLead.Id);
        mail.setWhatId(oLead.Id);
        mail.setSaveAsActivity(false);
        /*List<String> entityAtt = new List<String>();
        entityAtt.add('0699E000000LbDY;0699E000000LbDd;0699E000000LbDs');*/
        /*List<String> entityAtt = new List<String>{'0699E000000LbDY','0699E000000LbDd','0699E000000LbDs'};
        mail.setEntityAttachments(entityAtt);*/
        //mail.setEntityAttachments(contentList);
        
        // Get Template
        templateName = getTeleventeSettingsValue('GDBEmailTemplateToUseApiName');
        templateId = getTemplateId(templateName);
        mail.setTemplateId(templateId);
        
        // Create attachments
        for (Attachment att : [select Name, Body, BodyLength, ContentType from Attachment where ParentId = :oLead.Id]){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            efa.setContentType(att.ContentType);
            System.debug(logginglevel.WARN,'### [TLV_GDB_SendEmailController.sendEmailFromLead] att.ContentType = ' + att.ContentType);
            attachmentList.add(efa);
        }
        mail.setFileAttachments(attachmentList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
        outcomeMessage = 'OK-Email correctement envoyé.';
        System.Debug('End method TLV_GDB_SendEmailController.sendEmailFromLead');
        
        return outcomeMessage;
    }
    
    
    /** Generate GDB Quote PDF **/ 
    public static void generateGDBQuotePDF() {
        
        //oPECToSign = getPECToSign();
        if(oLead!=null){
            System.debug(logginglevel.WARN,'### [TLV_GDB_SendEmailController.generateGDBQuotePDF] oLead.Id = ' + oLead.Id);
            PageReference pdfPage = Page.GDB_TLV_Offer;
            pdfPage.getParameters().put('id', oLead.Id);
            /*pdfPage.getParameters().put('isSE', isSE);
            pdfPage.getParameters().put('displayCGUSE', 'true');
            pdfPage.getParameters().put('withdrawalText', 'false');
            pdfPage.getParameters().put('nbSig', '3');*/
            
            // getContent not supported in Test Methods, so we need to handle it
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent() : Blob.ValueOf('Some Text');
            
            // Insert attachment
            Attachment oAtt = new Attachment();
            oAtt.parentId = oLead.Id;
            oAtt.Name = 'Devis Granulés Butagaz - ' + oLead.Suspect_Number__c + '.pdf';
            oAtt.Body = pdfBlob;
            insert oAtt;            
        }

    }
    
    
    /** Getting Custom Settings methods **/
    public static String getTeleventeSettingsValue(String name){
        try{
            String res = TeleventeSettings__c.getInstance(name).value__c;
            if(res != null && !res.equals('')){
                return res;
            }else{
            	// BFI request to not throw error anymore but continue the process if Custom Setting is empty or doesn't exist
                //throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'No value specified for Custom Setting DocumentsIds__c : (' + name +').'});
                return '';
            }            
        }catch(System.NullPointerException e){
        	// BFI request to not throw error anymore but continue the process if Custom Setting is empty or doesn't exist
            //throw new AP_CRMException(new List<String>{System.Label.crm_message + ' : ' + 'Set the DocumentsIds__c named (' + name +'). [ '+ e.getMessage() + ' ]'});
            return '';
        }
    }
    
    
    /** Get Template Id **/
    public static Id getTemplateId(String templateName){	    
	    Id templateId = [select Id from EmailTemplate where DeveloperName like :templateName+'%' limit 1].Id;
        System.debug(logginglevel.WARN,'### [TLV_GDB_SendEmailController.sendEmailFromLead] templateId = ' + templateId);
        return templateId;
    }
    
    /** Get Org Wide Address Id **/
    public static Id getOrgWideEmailAddressId(String orgWideEmailAddress){	    
    	Id oweaId = [select Id from OrgWideEmailAddress where Address =:orgWideEmailAddress].Id;
    	System.debug(logginglevel.WARN,'### [TLV_GDB_SendEmailController.sendEmailFromLead] oweaId = ' + oweaId);
        return oweaId;
    }



}