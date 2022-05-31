//Sub Controler of the Case Controler
//This controler aim to check the process after reopen a case

public class CaseReopenControllerExtension 
{

    //private string FCaseId;
    public Case Fcase { get; set; }
   
    public CaseReopenControllerExtension(ApexPages.StandardController stdController) {
        FCase = (Case)stdController.getRecord();
        //FCaseId = ApexPages.currentPage().getParameters().get('idcase');
    } 
    
    public PageReference CancelCase()
    {
        return new PageReference('/' + FCase.id );
    }    
    
    public PageReference SaveCase()
    {
        try {
               
         //update du Record Type
         if (FCase.Claim__c) {
             FCase.recordTypeId = Utils.getCustomSetting('Case_RecordTypeId_Claim');
         } else {
             FCase.recordTypeId = Utils.getCustomSetting('Case_RecordTypeId_Standard_Edit');
         }
         
         if(FCase.reopen_Number__c == null) {
            FCase.reopen_Number__c=1;
         } else {
             FCase.reopen_Number__c++;
         }
         
         // CVER: allow users to add a case comment when closing the case
         FCase.Number_Of_Closed_Comments__c = 0;
         
         FCase.Status = Utils.getCustomSetting('Case_Status_To_Do');
          //update du Case
         update FCase;
         //retrieve the last reason of reopening
         Case currentCase = [select Id, Last_Reason_for_Reopening__c, OwnerId from Case where Id =: FCase.Id];
         //new Task 
         Task reopenCaseTask = new Task();
         reopenCaseTask.Subject = Utils.getCustomSetting('Case_Reopen_Task_Subject');
         reopenCaseTask.WhatId = Fcase.Id;
         reopenCaseTask.ActivityDate = Date.today();
         reopenCaseTask.Status = Utils.getCustomSetting('Case_Reopen_Task_Status');
         if(currentCase != null){
            reopenCaseTask.OwnerId = UserInfo.getUserId();// on affecte la tache à l'utilisateur qui réouvre la demande 
            reopenCaseTask.Reason_for_reopening__c = currentCase.Last_Reason_for_Reopening__c;
         }
         //insert of the task
         insert reopenCaseTask;
           
        }
        catch (DmlException e)
        {
            ApexPages.addMessages(e);
            return null;
        }
        
        return new PageReference('/' + FCase.Id);
    }
}