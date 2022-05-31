public class GDB_CreateDeptPrices {

    /**
     * Create prices from json
     * @param  codePal15      codePal15 Code palette 15kg
     * @param  codePal8       codePal8 Code palette 8kg
     * @param  code2sacs      code2sacs Code pack 2 sacs
     * @param  codeGranulebox codeGranulebox Code granulebox
     * @param  codeDemiPal15 codeDemiPal15 Code demi palette 15kg
     */
    public static void createPrices(String codePal15, String codePal8, String code2sacs, String codeGranulebox, String codeDemiPal15) {
        String jsonString = '[{"department": "01", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "02", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "03", "pal15": 290, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "04", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "05", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "06", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "07", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "08", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "09", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "10", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "11", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "12", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "13", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "14", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "15", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "16", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "17", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "18", "pal15": 290, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "19", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "21", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "22", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "23", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "24", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "25", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "26", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "27", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "28", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "29", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "30", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "31", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "32", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "33", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "34", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "35", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "36", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "37", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "38", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "39", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "40", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "41", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "42", "pal15": 290, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "43", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "44", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "45", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "46", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "47", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "48", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "49", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "50", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "51", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "52", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "53", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "54", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "55", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "56", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "57", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "58", "pal15": 290, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "59", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "60", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "61", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "62", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "63", "pal15": 290, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "64", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "65", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "66", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "67", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "68", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "69", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "70", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "71", "pal15": 290, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "72", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "73", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "74", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "75", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "76", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "77", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "78", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "79", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "80", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "81", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "82", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "83", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "84", "pal15": 305, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "85", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "86", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "87", "pal15": 299, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "88", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "89", "pal15": 300, "pal8": 360, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "90", "pal15": 294, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "91", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "92", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "93", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "94", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199},'
                            + '{"department": "95", "pal15": 304, "pal8": 350, "2sacs": 9.9, "granulebox": 249, "demipal15": 199}]';
        
        List<GDB_Department_Has_WarehouseProd__c> dhwList  = new List<GDB_Department_Has_WarehouseProd__c>();
        List<GDB_Warehouse_Has_Product__c> whpList = [
            SELECT id,gdb_Warehouse__r.gdb_codes__c, gdb_Article__r.Code_Article__c 
            FROM GDB_Warehouse_Has_Product__c 
            ORDER BY gdb_Article__r.Code_Article__c
        ];

        List<Object> priceList = (List<Object>) JSON.deserializeUntyped(jsonString);
        for(Object price : priceList) {
            Map<String, Object> p = (Map<String, Object>)price;
            String dept = String.valueOf(p.get('department'));
            Map<String, Decimal> prices = new Map<String, Decimal>{
                'PAL15' => Decimal.valueOf(String.valueOf(p.get('pal15'))),
                'PAL8' => Decimal.valueOf(String.valueOf(p.get('pal8'))),
                '2SACS' => Decimal.valueOf(String.valueOf(p.get('2sacs'))),
                'GRANULEBOX' => Decimal.valueOf(String.valueOf(p.get('granulebox'))),
                'DEMIPAL15' => Decimal.valueOf(String.valueOf(p.get('demipal15')))
            };

            for(String key : prices.keySet()) {
                Decimal cPrice = prices.get(key);
                Decimal cTax = 'GRANULEBOX'.equals(key) ? cPrice - (cPrice / 1.2) : cPrice - (cPrice / 1.1);
                Decimal cPrice2 = '2SACS'.equals(key) ? cPrice / 2 : cPrice;
                Decimal cTax2 = '2SACS'.equals(key) ? cPrice2 - (cPrice2 / 1.1) : cTax;

                String codeArt;
                if('PAL15'.equals(key)) {
                    codeArt = codePal15; //'GDB_P15_1';
                } else if('PAL8'.equals(key)) {
                    codeArt = codePal8; //'GDB_P8_1';
                } else if('2SACS'.equals(key)) {
                    codeArt = code2sacs; //'GDB_P55';
                } else if('GRANULEBOX'.equals(key)) {
                    codeArt = codeGranulebox; //'GDB_BOX_1';
                } else if('DEMIPAL15'.equals(key)) {
                    codeArt = codeDemiPal15; //'GDB_P15_DE';
                }

                Id whId = getWarehouseHasProdByDeptAndArt(whpList, dept, codeArt);
                if(whId != null) {
                    GDB_Department_Has_WarehouseProd__c dhw = new GDB_Department_Has_WarehouseProd__c(
                        Name = 'DEPT' + dept + '_' + key,
                        gdb_department__c = dept,
                        gdb_price__c = cPrice.setScale(2),
                        gdb_tax__c = cTax.setScale(2),
                        gdb_unit_price_warehouse__c = cPrice2.setScale(2),
                        gdb_unit_tax_warehouse__c = cTax2.setScale(2),
                        gdb_warehouseproduct__c = whId
                    );
                    dhwList.add(dhw);
                }
            }
        }

        insert dhwList;
    }

    /**
     * Get the warehouse_has_product ID from department and code article
     * @param  whpList     whpList List of GDB_Warehouse_Has_Product__c
     * @param  department  department Department code
     * @param  codeArticle codeArticle Item code
     * @return Id
     */
    private static Id getWarehouseHasProdByDeptAndArt(List<GDB_Warehouse_Has_Product__c> whpList, String department, String codeArticle) {
        for(GDB_Warehouse_Has_Product__c whp : whpList) {
            if(whp.gdb_Warehouse__c != null
            && whp.gdb_Warehouse__r.gdb_codes__c != null
            && department != null
            && whp.gdb_Warehouse__r.gdb_codes__c.indexOf(department) != -1
            && whp.gdb_Article__r != null
            && whp.gdb_Article__r.Code_Article__c != null
            && codeArticle != null
            && whp.gdb_Article__r.Code_Article__c.equals(codeArticle)) {
                return whp.Id;
            }
        }

        return null;
    }
    
    /**
     * Delete matrix price.
     * 
     */
    public static void deletePrices() {        
        List<GDB_Department_Has_WarehouseProd__c> lstPrices = [SELECT ID FROM GDB_Department_Has_WarehouseProd__c];
        delete lstPrices;
    }
}