public class soqlInFlow {
    /* Class definition for throwing custom exceptions */
    public class FlowApexActionException extends Exception{}
    
    @InvocableMethod(label='Query N records' description='Returns a list of N records, where is N specified by a user as a flow input.')
    public static list<QueryResults> getNrecords(QueryParameters[] queryParams){
        
        if(queryParams[0].numberOfRecords >= 50000)
            throw new FlowApexActionException('You cannot query more than 50000 records.');
        
        if(queryParams[0].whereClause == null)
        	queryParams[0].whereClause = '';
            
        list<QueryResults> result = new list<QueryResults>();
        string query = 'Select '+ queryParams[0].fieldsToQuery + ' FROM ' +  queryParams[0].objectApiName + queryParams[0].whereClause + ' LIMIT ' + queryParams[0].numberOfRecords;
        try{
            sObject[] recordList = database.query(query);
            //system.debug(recordList);
            QueryResults qr = new QueryResults();
            qr.records = recordList;
            result.add(qr);
        }catch(Exception e){
            throw e;
        }
        return result;
    }
    
    /* Input parameters for the Apex action */
    public class QueryParameters{
        @InvocableVariable(label='Api name of the Object' required = true )
        public string objectApiName;

        @InvocableVariable(label='!SPACE MUST BE BEFORE \'WHERE\'! sample: WHERE ContentDocumentId IN (\'697Z000001a8jyQAA\',\'0697Z000001a8lLQAQ\') ' required = false )
        public string whereClause;
        
        @InvocableVariable(label='API names of the fields to query(Comma separated)' required = true)
        public string fieldsToQuery;
        
        @InvocableVariable(label='Number of records to query' required = true)
        public integer numberOfRecords;
    }
    
    /* Output parameters of the Apex action */
    public class QueryResults{
        @InvocableVariable(label='List of records')
	public sObject[] records;        
    }
}