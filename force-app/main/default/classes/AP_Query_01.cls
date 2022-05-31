public class AP_Query_01 {

    public static List<String> lIdsTolStrs(List<Id> lIds){
        // Utility method -- this can't be done in a constructed because call to alternate 
        // constructor must always be first
        List<String> lStrs = new List<String>();
        for (Id i : lIds){ lStrs.add(i); }
        return lStrs;
    }

    public virtual class QuerySetClause {
        // A base clause with a key and an associated value
        public String getClause(){ 
            return '(' + this.getInnerClause() + ')';
        } 

        private virtual String getInnerClause(){
            return '1=1';
        }
    }

    public virtual class QuerySetKeyValueClause extends QuerySetClause {
        private String key; 
        private String value;
        public QuerySetKeyValueClause(String key, String value){ this.key = key; this.value = value; }
    }

    public class QuerySetEqualsClause extends QuerySetKeyValueClause {
        // A WHERE clause.
        Boolean quotesRequired;

        public QuerySetEqualsClause(String key, String value){ 
            super(key, value); 
            this.quotesRequired = true; 
        }
        public QuerySetEqualsClause(String key, Decimal value){ 
            super(key, String.valueOf(value)); 
            this.quotesRequired = false; 
        }
        public QuerySetEqualsClause(String key, Long value){ 
            this(key, Decimal.valueOf(value));
        }
        public QuerySetEqualsClause(String key, Double value){ 
            this(key, Decimal.valueOf(value));
        }
        public QuerySetEqualsClause(String key, Boolean value){
            this(key, value ? 'true' : 'false');
            this.quotesRequired = false;
        }

        public override string getInnerClause(){
            String clause = String.valueOf(this.key) + ' = ';
            if (this.quotesRequired){ return clause + '\'' + this.value + '\''; }
            else { return clause + this.value; }
        }
    }

    public class QuerySetLikeClause extends QuerySetKeyValueClause {
        // A LIKE clause
        public QuerySetLikeClause(String key, String value){ super(key, value); }

        public override string getInnerClause(){
            return String.valueOf(this.key) + ' LIKE \'%' + String.valueOf(value) + '%\'';
        }
    }

    public class QuerySetOrClause extends QuerySetClause {
        private List<QuerySetClause> lClauses; 

        public QuerySetOrClause(List<QuerySetClause> lClauses){
            this.lClauses = lClauses;
        }

        public override string getInnerClause(){
            List<String> clauses = new List<String>();
            for (QuerySetClause oClause : this.lClauses){
                clauses.add(oClause.getClause());
            }
            return String.join(clauses, ' OR ');
        }
    }

    public class QuerySetNotClause extends QuerySetClause {
        private QuerySetClause innerClause;

        public QuerySetNotClause(QuerySetClause innerClause){
            this.innerClause = innerClause;
        }

        public override string getInnerClause(){
            return 'NOT ' + this.innerClause.getClause();
        }
    }

    public class QuerySetInClause extends QuerySetClause {
        // An IN clause
        String key;
        List<String> values;

        public QuerySetInClause(String key, List<String> values){
            this.key = key;
            this.values = values;
        }
        public QuerySetInClause(String key, Set<String> values){
            this(key, new List<String>(values));
        }

        public QuerySetInClause(String key, List<Id> values){
            this(key, AP_Query_01.lIdsTolStrs(values));
        }

        public QuerySetInClause(String key, Set<Id> values){
            this(key, new List<Id>(values));
        }

        public override string getInnerClause(){
            return key + ' IN ( \'' + String.join(this.values, '\', \'') + '\' )';
        }
    }

    public class QuerySet {
        private String SObjectType;
        private List<String> fields;
        private List<QuerySetClause> filters;

        public QuerySet(String SObjectType, List<String> fields, List<QuerySetClause> filters){
            this.SObjectType = SObjectType;
            this.fields  = fields;
            this.filters = filters;
        }

        public QuerySet(String SObjectType, Set<String> fields, List<QuerySetClause> filters){
            this(SObjectType, new List<String>(fields), filters);
        }

        private String getFieldsClause(){
            return String.join(this.fields, ', ');
        }

        private String getObjectClause(){
            return this.SObjectType;
        }

        private String getWhereClause(){
            if (this.filters.size() > 0) {
                List<String> clauses = new List<String>();
                for (QuerySetClause filter : this.filters){ 
                    clauses.add(filter.getClause());
                }
                return 'WHERE ' + String.join(clauses, ' AND ');
            } else {
                return '';
            }
        }

        private String getOrderClause(){
            return 'ORDER BY Name';
        }

        private String getLocateClause(Integer lim, Integer offset) {
            List<String> clauses = new List<String>{ 'LIMIT', String.valueOf(lim), 'OFFSET', String.valueOf(offset)};
            return String.join(clauses, ' ');
        }

        public List<String> getBaseQueryClauses(){
            return new List<String>{
                'SELECT',
                this.getFieldsClause(),
                'FROM',
                this.getObjectClause(),
                this.getWhereClause()
            };
        }

        private List<SObject> runQuery(List<String> clauses){
            String query = String.join(clauses, ' ');
            System.debug('Execute Query: ' + query);
            return Database.query(query);
        }

        public List<SObject> getRecords(Integer lim, Integer offset){
            List<String> clauses = this.getBaseQueryClauses();
            clauses.add(this.getOrderClause());
            clauses.add(this.getLocateClause(lim, offset));
            return this.runQuery(clauses);
        }

        public List<SObject> getRecords(){
            List<String> clauses = this.getBaseQueryClauses();
            return this.runQuery(clauses);
        }

        public Integer getCount(){
            List<String> clauses = new List<String>{
                'SELECT',
                'COUNT()',
                'FROM',
                this.getObjectClause(),
                this.getWhereClause()
            };
            return Database.countQuery(String.join(clauses, ' '));
        }
    }
}