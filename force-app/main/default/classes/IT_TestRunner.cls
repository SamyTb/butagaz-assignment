public class IT_TestRunner implements Database.AllowsCallouts
{
    /**
     * Wraps CodeCoverage data
     **/
    public class CodeCoverageWrapper
    {
        public Id      classId    {get; private set;}
        public String  name       {get; set;        }
        public Integer uncovered  {get; private set;}
        public Integer covered    {get; private set;}
        public Decimal percentage {get; private set;}
        public Integer totalLines {get; private set;}

        public CodeCoverageWrapper(ApexCodeCoverageAggregate ag)
        {
            this.name       = ag.ApexClassOrTriggerId;
            this.classId    = ag.ApexClassOrTriggerId;
            this.covered    = ag.numLinesCovered;
            this.uncovered  = ag.numLinesUncovered;
            this.totalLines = this.uncovered + this.covered;
            this.percentage = this.covered > 0 ? (100*this.covered)/(this.totalLines) : 0;
        }
    }

    /**
     * Attributes of ApexCodeCoverageAggregate API response
     **/
    public class ApexCodeCoverageAggregateAttributes
    {
        public String type {get;set;}
        public String url {get;set;}
    }

    /**
     * ApexCodeCoverageAggregate returned by the tooling API
     **/
    public class ApexCodeCoverageAggregate implements Comparable
    {
        public String ApexClassOrTriggerId {get;set;}
        public Integer NumLinesCovered {get;set;}
        public Integer NumLinesUncovered {get;set;}
        public ApexCodeCoverageAggregateAttributes attributes {get;set;}

        public Integer compareTo(Object compareTo)
        {
            Integer result = 0;

            ApexCodeCoverageAggregate compared = (ApexCodeCoverageAggregate)compareTo;

            Integer thisTotalLines = this.NumLinesCovered + this.NumLinesUncovered;
            Integer comparedTotalLines = compared.NumLinesCovered + compared.NumLinesUncovered;

            Decimal thisCoverage = thisTotalLines == 0 ? 0 : this.NumLinesCovered * 100 / thisTotalLines;
            Decimal comparedCoverage = comparedTotalLines == 0 ? 0 : compared.NumLinesCovered * 100 / comparedTotalLines;

            if(thisCoverage > comparedCoverage)
            {
                result = 1;
            }
            else if(thisCoverage < comparedCoverage)
            {
                result = -1;
            }

            return result;
        }
    }

    /**
     * Tooling API response
     **/
    public class ToolingAPIResponse
    {
        public Integer size {get;set;}
        public Integer totalSize {get;set;}
        public Boolean done {get;set;}
        public String queryLocator {get;set;}
        public String entityTypeName {get;set;}

        public List<ApexCodeCoverageAggregate> records {get;set;}
    }

    /**
     * Retrieves code coverage from tooling API
     **/
    private static ToolingAPIResponse GetCoverage()
    {
        if(Test.isRunningTest())
        {
            ToolingAPIResponse apiResponse = new ToolingAPIResponse();
            List<ApexCodeCoverageAggregate> lstAcca = new List<ApexCodeCoverageAggregate>();
            ApexCodeCoverageAggregate acca = new ApexCodeCoverageAggregate();
            for(Integer i = 0; i < 5; i++) {
                acca = new ApexCodeCoverageAggregate();
                acca.NumLinesCovered = 10 + i;
                acca.NumLinesUncovered = 15 + i;
                lstAcca.add(acca);
            }

            lstAcca.sort();

            apiResponse.records = lstAcca;

            return apiResponse;
        }

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); //Get user Session ID
        req.setHeader('Content-Type', 'application/json');

        String domainUrl= URL.getSalesforceBaseUrl().toExternalForm();

        String query = 'Select+ApexClassOrTriggerId,NumLinesCovered,NumLinesUncovered+From+ApexCodeCoverageAggregate+Order+By+NumLinesUncovered+Desc';
        req.setEndpoint(domainUrl+'/services/data/v33.0/tooling/query/?q='+query);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(req);
        String body = response.getBody();

        ToolingAPIResponse apiResponse = (ToolingAPIResponse)JSON.deserialize(body, ToolingAPIResponse.class);

        apiResponse.records.sort();

        return apiResponse;
    }

    // derived from http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_unit_tests_running.htm#APISectionTitle

    public static void Setup(Integer testHour, Integer testMinutes, String testStartDay, String testEndDay, Integer emailHour, Integer emailMinutes, String emailStartDay, String emailEndDay)
    {
        try
        {
            system.schedule('IT_TestRunner', '0 ' + testMinutes + ' ' + testHour +' ? * ' + testStartDay + '-' +  testEndDay, new IT_TestRunner_Scheduler());
            system.schedule('IT_TestRunnerResults', '0 ' + emailMinutes + ' ' + emailHour + ' ? * ' + emailStartDay + '-' + emailEndDay, new IT_TestRunnerResults_Scheduler());
        }
        catch (Asyncexception ex)
        {
            system.debug('Job already scheduled');
        }
    }

    // Enqueue all unit test classes as spec'd by IT_Automated_Test_Run__c record(s)
    public static list<ID> EnqueueTests()
    {
        list<Id> jobIds = new list<Id>();

        for (IT_Automated_Test_Run__c run : [select IT_Query__c, IT_Excluded_Classes__c,
        IT_Email_on_Pass__c, IT_Exclude_Managed_Packages__c
        from IT_Automated_Test_Run__c where IT_Active__c = true]) {
            string whereExcluded = '';
            if (run.IT_Excluded_Classes__c != null) {
                for (string c : run.IT_Excluded_Classes__c.split('[,\\s]+')) {
                    whereExcluded += 'and Name != \'' + c + '\'';
                }
            }
            if (run.IT_Exclude_Managed_Packages__c == True) {
               whereExcluded += ' AND NameSpacePrefix = null';
            }

            string query = 'SELECT Id FROM ApexClass WHERE Name LIKE \'' + run.IT_Query__c + '\' ' + whereExcluded;
            ApexClass[] testClasses = Database.query(query);

            if (testClasses != null && !testClasses.isEmpty()) {

                ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
                for (ApexClass cls : testClasses) {
                    queueItems.add(new ApexTestQueueItem(ApexClassId=cls.Id));
                }

                if (!Test.isRunningTest()) {
                    insert queueItems;

                    // Get the job ID of the first queue item returned.
                    ApexTestQueueItem item =
                       [SELECT ParentJobId FROM ApexTestQueueItem
                        WHERE Id=:queueItems[0].Id LIMIT 1];

                    insert new IT_Test_Runner_Job__c(Name = item.parentjobid, IT_Automated_Test_Run__c = run.Id);

                    jobIds.add(item.parentjobid);
                }
            }
        }

        return jobIds;
    }

    public static List<Messaging.SingleEmailMessage> EmailMethodStatus(List<IT_Test_Runner_Job__c> jobs) {
        Set<string> jobNames = new Set<string>();

        for (IT_Test_Runner_Job__c job : jobs)
        {
            jobNames.add(job.Name);
        }

        ApexTestResult[] results =
        [
             SELECT AsyncApexJobId, Outcome, ApexClass.Name, ApexClassId, MethodName, Message, StackTrace
            FROM ApexTestResult
            WHERE AsyncApexJobId in :jobNames
            ORDER BY ApexClass.Name, MethodName
        ];

        return EmailMethodStatus(jobs, results);
    }

    public static List<Messaging.SingleEmailMessage> EmailMethodStatus(List<IT_Test_Runner_Job__c> jobs, ApexTestResult[] results)
    {
        Long coveredLines = 0;
        Long uncoveredLines = 0;

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Organization org = [SELECT Id, Name FROM Organization];
        String instanceName;
        String host = URL.getSalesforceBaseUrl().getHost();
        String[] hostElement = host.split('\\.');
        if(hostElement != null && !hostElement.isEmpty()) {
            instanceName = hostElement[1];
        }

        ToolingAPIResponse apiResponse = GetCoverage();

        Map<Id,CodeCoverageWrapper> wrapperMap = new Map<Id,CodeCoverageWrapper>();

        for(ApexCodeCoverageAggregate ag : apiResponse.records)
        {
            coveredLines += (ag.numLinesCovered != null) ? ag.numLinesCovered : 0;
            uncoveredLines += (ag.numLinesUncovered !=  null) ? ag.numLinesUncovered : 0;

            CodeCoverageWrapper w = new CodeCoverageWrapper(ag);
            wrapperMap.put(ag.ApexClassOrTriggerId,w);
        }

        for(ApexClass ac : [Select Name From ApexClass Where Id in :wrapperMap.keySet()])
        {
            wrapperMap.get(ac.Id).name=ac.Name;
        }

        for(ApexTrigger at : [Select Name From ApexTrigger Where Id in :wrapperMap.keySet()])
        {
            wrapperMap.get(at.Id).name=at.Name;
        }

        Decimal percentage = (coveredLines > 0) ? ((coveredLines*100) / (coveredLines + uncoveredLines)) : 0;

        for (IT_Test_Runner_Job__c job : jobs)
        {
            Integer passed = 0;
            Integer total = 0;

            String className = '';

            String resultsHtml = '<p style="font-size:15px;font-family:Arial;font-weight:bold;">Results :</p><br/>';
            resultsHtml += '<table style="border:0;border-spacing:0;width:100%;border-collapse:collapse;">';
            resultsHtml += '<thead>';
            resultsHtml += '<tr>';
            resultsHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Class</th>';
            resultsHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Method</th>';
            resultsHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Duration</th>';
            resultsHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Result</th>';
            resultsHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Errors</th>';
            resultsHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Stack Trace</th>';
            resultsHtml += '</tr>';
            resultsHtml += '</thead>';
            resultsHtml += '<tbody>';

            for (ApexTestResult result : results)
            {
                if ((String)result.AsyncApexJobId == job.Name || (Test.isRunningTest() && jobs.size() == 1))
                {
                    String backgroundColor;
                    Boolean currentTestPassed = result.Outcome == 'Pass';

                    total++;

                    if (currentTestPassed)
                    {
                        passed++;
                        backgroundColor = 'c3fcac';
                    }
                    else
                    {
                        backgroundColor = 'fcacac';
                    }

                    String stacktrace = result.StackTrace;

                    if(String.isNotEmpty(stacktrace))
                    {
                        stacktrace = stacktrace.replace('\r\n', '<br />');
                        stacktrace = stacktrace.replace('\r', '<br />');
                        stacktrace = stacktrace.replace('\n', '<br />');
                    }

                    resultsHtml += '<tr>';

                    resultsHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;background-color:#' + backgroundColor + ';padding:5px;">' + result.ApexClass.Name + '</td>';
                    resultsHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;background-color:#' + backgroundColor + ';padding:5px;">' + result.MethodName + '</td>';
                    resultsHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;background-color:#' + backgroundColor + ';padding:5px;white-space: nowrap;">' + 'X' /*result.RunTime*/ + ' seconde(s)</td>';
                    resultsHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;background-color:#' + backgroundColor + ';padding:5px;">' + result.Outcome + '</td>';
                    resultsHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;background-color:#' + backgroundColor + ';padding:5px;">' + (currentTestPassed ? '' : result.Message) + '</td>';
                    resultsHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;background-color:#' + backgroundColor + ';padding:5px;">' + (currentTestPassed ? '' : stacktrace) + '</td>';

                    resultsHtml += '</tr>';
                }
            }

            resultsHtml += '</tbody>';
            resultsHtml += '</table>';

            Boolean allPassed = passed == total;

            if ((allPassed && job.IT_Automated_Test_Run__r.IT_Email_on_Pass__c) || !allPassed) {
                String subject = job.IT_Automated_Test_Run__r.Name + ' Automated Test Results: ' + (passed < total ? 'Fail' : 'Pass');

                String bodyHtml = '<html lang="en" xmlns="http://www.w3.org/1999/xhtml">';
                bodyHtml += '<head>';
                bodyHtml += '<meta charset="utf-8" />';
                bodyHtml += '<title>' + subject + '</title>';
                bodyHtml += '</head>';
                bodyHtml += '<body>';

                bodyHtml += '<table style="border:0;border-spacing:0;border-collapse:collapse;width:100%;" cellspacing="0" cellpadding="0" border="0">';
                bodyHtml += '<tbody>';
                bodyHtml += '<tr>';
                bodyHtml += '<td style="width:50%;">';
                bodyHtml += '<p style="font-size:20px;font-family:Arial;font-weight:bold;">Automated test results for org : </p>';
                bodyHtml += '<table>';
                bodyHtml += '<thead>';
                bodyHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;font-weight:bold;">Org Name</th>';
                bodyHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;font-weight:bold;">Org ID</th>';
                bodyHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;font-weight:bold;">Org instance name</th>';
                bodyHtml += '</thead>';
                bodyHtml += '<tbody>';
                bodyHtml += '<tr>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px 20px 5px 20px;">' + org.Name + '</td>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px 20px 5px 20px;">' + org.Id + '</td>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px 20px 5px 20px;">' + instanceName + '</td>';
                bodyHtml += '</tr>';
                bodyHtml += '</tbody>';
                bodyHtml += '</table>';
                bodyHtml += '</td>';
                bodyHtml += '<td style="width:50%;text-align:right;" align="right" valign="top">';
                bodyHtml += '<table align="right"><tr><td>';
                bodyHtml += '<img alt="Itelios" width="200" height="66" style="float:right;" src="https://nasa.itelios.net/static/logo-itelios-small.jpg"/>';
                bodyHtml += '</td></tr></table>';
                bodyHtml += '</td>';
                bodyHtml += '</tr>';
                bodyHtml += '</tbody>';
                bodyHtml += '</table>';

                bodyHtml += '<br />';
                bodyHtml += '<p style="font-size:15px;font-family:Arial;font-weight:bold;">Summary :</p>';
                bodyHtml += '<br />';
                bodyHtml += '<table style="border:0;border-spacing:0;border-collapse:collapse;">';
                bodyHtml += '<tbody>';
                bodyHtml += '<tr>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;font-weight:bold;">Passed :</td>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px 20px 5px 20px;">' + passed + '</td>';
                bodyHtml += '</tr>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;font-weight:bold;">Failed :</td>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px 20px 5px 20px;">' + (total - passed) + '</td>';
                bodyHtml += '</tr>';
                bodyHtml += '<tr>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;font-weight:bold;">Total :</td>';
                bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px 20px 5px 20px;">' + total + '</td>';
                bodyHtml += '</tr>';
                bodyHtml += '</tbody>';
                bodyHtml += '</table>';

                bodyHtml += '<br />';
                bodyHtml += resultsHtml;

                bodyHtml += '<br />';
                bodyHtml += '<p style="font-size:15px;font-family:Arial;font-weight:bold;">Coverage : <span style="color:#' + (percentage >= 75 ? '00b050' : 'ff1d1d') + ';">' + percentage + '%</span></p>';
                bodyHtml += '<br />';
                bodyHtml += '<table style="border:0;border-spacing:0;border-collapse:collapse;">';
                bodyHtml += '<thead>';
                bodyHtml += '<tr>';
                bodyHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Class</th>';
                bodyHtml += '<th style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#e8e6e6;">Coverage</th>';
                bodyHtml += '</tr>';
                bodyHtml += '</thead>';
                bodyHtml += '<tbody>';

                for(CodeCoverageWrapper codeCoverage : wrapperMap.values())
                {
                    String backgroundColor = codeCoverage.percentage >= 75 ? 'c3fcac' : 'fcacac';

                    bodyHtml += '<tr>';
                    bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;background-color:#' + backgroundColor + ';">' + codeCoverage.name + '</td>';
                    bodyHtml += '<td style="border:1px solid #3d3c3c;font-size:15px;font-family:Arial;padding:5px;text-align:center;background-color:#' + backgroundColor + ';">' + codeCoverage.percentage + '%</td>';
                    bodyHtml += '</tr>';
                }

                bodyHtml += '</tbody>';
                bodyHtml += '</table>';

                bodyHtml += '</body>';
                bodyHtml += '</html>';

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setToAddresses(job.IT_Automated_Test_Run__r.IT_Emails__c.split('[,\\s]+'));
                mail.setSubject(subject);
                mail.setHtmlBody(bodyHtml);

                messages.add(mail);
            }
        }

        if (!Test.isRunningTest())
        {
            Messaging.sendEmail(messages);
        }

        return messages;
    }
 }