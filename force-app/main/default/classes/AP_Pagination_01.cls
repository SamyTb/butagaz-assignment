public class AP_Pagination_01 {
    public class Paginator {
        // A Class for paginating results
        private Integer nRecords;
        private Integer perPage;

        public Paginator(Integer nRecords, Integer perPage){
            this.nRecords = nRecords;
            this.perPage  = perPage;
        }

        public Integer getNumPages(){
            if (this.nRecords == 0){
                return 1;
            } else {
                return Integer.valueOf(Math.ceil(Double.valueOf(this.nRecords) / Double.valueOf(this.perPage))); 
                //Validate perPage != 0?
            }
        }
    
        public Boolean pageExists(Integer pageIndex){ // 0-Indexed
            return (pageIndex >= 0) && (pageIndex < this.getNumPages());
        }

        public Integer getPageStartIndex(Integer pageIndex){ // 0-Based for 0-Indexed pages
            return (this.perPage * pageIndex);
        }
    }
}