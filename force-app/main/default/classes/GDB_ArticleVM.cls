public with sharing class GDB_ArticleVM {
    @AuraEnabled
    public Id Id {get;set;}
    
    @AuraEnabled
    public String Name {get;set;}
    
    @AuraEnabled
    public Boolean isSample {get;set;}
    
    @AuraEnabled
    public String code {get;set;}
    
    @AuraEnabled
    public String description {get;set;}
    
    @AuraEnabled
    public String technicalCharacteristics {get;set;}
    
    @AuraEnabled
    public Map<String, String> seo {get;set;}
    
    @AuraEnabled
    public String imgUrl {get;set;}
    
    @AuraEnabled
    public Boolean isBadgeDisplayed {get;set;}
    
    @AuraEnabled
    public String pageUrl {get;set;}
    
    @AuraEnabled
    public Boolean isSoldOnB2B {get;set;}
    
    @AuraEnabled
    public Boolean isSoldOnB2C {get;set;}
    
    @AuraEnabled
    public List<String> locationDisplay {get;set;}
    
    @AuraEnabled
    public Double sortNum {get;set;}
    
    @AuraEnabled
    public String bvExternalId {get;set;}
    
    @AuraEnabled
    public Map<String, Double> badgeColor {get;set;}
    
    @AuraEnabled
    public String badgeText {get;set;}
    
    @AuraEnabled
    public Boolean isOnline {get;set;}
    
    @AuraEnabled
    public Integer quantity {get;set;}
    
    @AuraEnabled
    public Double price {get;set;}
    
    @AuraEnabled
    public Double tax {get;set;}
    
    @AuraEnabled
    public Double unit_price {get;set;}
    
    @AuraEnabled
    public Double unit_tax {get;set;}
    
    @AuraEnabled
    public String sku {get;set;}

    @AuraEnabled
    public Boolean purchasable {get;set;}

    @AuraEnabled
    public String promotion {get;set;}

    @AuraEnabled
    public String technicalCharacteristicsText {get;set;}

    @AuraEnabled
    public Double quantityBuyable {get;set;}
    
    @AuraEnabled
    public Boolean displayShippingCostsMessage {get;set;}
    
    private GDB_Department_Has_WarehouseProd__c dhw {get;set;}
    
    /**
    * Create and fill an instance of GDB_ArticleVM from data of GDB_Department_Has_WarehouseProd__c query
    * @param {GDB_Department_Has_WarehouseProd__c} cDHW
    */
    public GDB_ArticleVM(GDB_Department_Has_WarehouseProd__c cDHW) {
        this.dhw = cDHW;
        
        if(cDHW != null) {
            Item__c item = cDHW.gdb_warehouseproduct__r.gdb_article__r;
            
            this.Id = item.Id;
            this.Name = item.Name;
            this.isSample = item.gdb_isSample__c;
            this.code = item.Code_Article__c;
            this.description = item.gdb_delivery_description__c;
            this.technicalCharacteristics = cDHW.gdb_technical_characteristics__c; 
            this.seo = new Map<String, String>{
                'title' => item.gdb_seo_title__c,
                'description' => item.gdb_seo_description__c,
                'keywords' => item.gdb_seo_keywords__c,
                'url' => item.gdb_seo_url__c
            }; 
            this.imgUrl = item.gdb_image_url__c; 
            this.isBadgeDisplayed = item.gdb_display_badge__c; 
            this.pageUrl = item.gdb_page_url__c; 
            this.isSoldOnB2B = item.gdb_canBeSoldOnB2B__c; 
            this.isSoldOnB2C = item.gdb_canBeSoldOnB2C__c; 
            this.locationDisplay = item.gdb_LocationDisplay__c != null ? item.gdb_LocationDisplay__c.split(';') : null; 
            this.sortNum = item.gdb_sort__c; 
            this.bvExternalId = item.gdb_bv_external_id__c; 
            this.badgeColor = new Map<String, Double>{
                'r' => item.gdb_badge_color_red__c,
                'g' => item.gdb_badge_color_green__c,
                'b' => item.gdb_badge_color_blue__c
            }; 
            this.badgeText = item.gdb_badge_text__c; 
            this.isOnline = item.gdb_online__c;
            this.purchasable = item.gdb_purchasable__c;
            this.promotion = item.gdb_promotion_text__c;
            this.technicalCharacteristicsText = item.gdb_technical_characteristics__c;
            this.quantityBuyable = item.gdb_quantity_buyable__c;
            this.displayShippingCostsMessage = cDHW.gdb_warehouseproduct__r.gdb_article__r.GDB_Display_ShippingCosts_Message__c;
        }
        
        // Calcul of values
        this.quantity = this.getQuantity();
        this.price = this.getPrice();
        this.tax = this.getTax();
        this.unit_price = this.getUnitPrice();
        this.unit_tax = this.getUnitTax();
        this.sku = this.getSKU();
    }
    
    /**
    * Return product quantity
    * @return {Integer}
    */
    public Integer getQuantity() {
        if(this.dhw != null
        && this.dhw.gdb_warehouseproduct__r != null) {
            return Integer.valueOf(this.dhw.gdb_warehouseproduct__r.gdb_quantity__c);
        }
        
        return null;
    }
    
    /**
    * Return product quantity warehouse
    * @return {Integer}
    */
    public Integer getWarehouseQuantity() {
        if(this.dhw != null
        && this.dhw.gdb_warehouseproduct__r != null) {
            return Integer.valueOf(this.dhw.gdb_warehouseproduct__r.gdb_quantitywarehouse__c);
        }
        
        return null;
    }
    
    /**
    * Return product price
    * @return {Double}
    */
    public Double getPrice() {
        if(this.dhw != null) {
            return this.dhw.gdb_price__c;
        }
        
        return null;
    }
    
    /**
    * Return product tax
    * @return {Double}
    */
    public Double getTax() {
        if(this.dhw != null) {
            return this.dhw.gdb_tax__c;
        }
        
        return null;
    }
    
    /**
    * Return product price
    * @return {Double}
    */
    public Double getUnitPrice() {
        if(this.dhw != null) {
            return this.dhw.gdb_unit_price_warehouse__c;
        }
        
        return null;
    }
    
    /**
    * Return product tax
    * @return {Double}
    */
    public Double getUnitTax() {
        if(this.dhw != null) {
            return this.dhw.gdb_unit_tax_warehouse__c;
        }
        
        return null;
    }
    
    /**
    * Check if product is displayed on page in params
    * @params {String} name
    * @return {Boolean}
    */
    public Boolean isDisplayedOn(String name) {
        return this.locationDisplay != null 
                && this.locationDisplay.contains(name);
    }
    
    /**
    * Get the warehouse id
    * @params {String} name
    * @return {Id}
    */
    public Id getWarehouseId() {
        if(this.dhw != null
        && this.dhw.gdb_warehouseproduct__r != null) {
            return this.dhw.gdb_warehouseproduct__r.gdb_Warehouse__c;
        }
        
        return null;
    }
    
    /**
    * Get the product SKU
    * @params {String} name
    * @return {String}
    */
    public String getSKU() {
        if(this.dhw != null
        && this.dhw.gdb_warehouseproduct__r != null) {
            return this.dhw.gdb_warehouseproduct__r.gdb_sku__c;
        }
        
        return null;
    }

    /**
     * Bind the current article data to basket product instance passed by param
     * @param {GDB_Basket_Product__c} bp
     */
    public void bind2BasketProduct(GDB_Basket_Product__c bp) {
        if(bp != null) {
            bp.gdb_unit_price__c = this.unit_price;
            bp.gdb_unit_tax__c = this.unit_tax;
            bp.gdb_warehouse__c = this.getWarehouseId();

            bp.gdb_unit_price_warehouse__c = (this.unit_price == null || 
                                            this.unit_price == 0) ? 
                                            this.price : this.unit_price;
                                                                
            bp.gdb_unit_tax_warehouse__c = (this.unit_tax == null || 
                                            this.unit_tax == 0) ? 
                                            this.tax : this.unit_tax;

            bp.gdb_sku__c = this.sku;
            bp.gdb_quantitywarehousecoefficient__c = this.getWarehouseQuantity();
            bp.gdb_total_price__c = this.price * bp.gdb_quantity__c;
            bp.gdb_total_tax__c = this.tax * bp.gdb_quantity__c;
        }
    }
}