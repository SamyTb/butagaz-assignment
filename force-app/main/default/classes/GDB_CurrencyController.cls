public with sharing class GDB_CurrencyController {
    public GDB_CurrencyController() {
    }

    public String currencyISOCode {
        get;
        set {
            if (value != null) {
                currencyISOCode = value;
            } else {
               currencyISOCode = GDB_Constants.currencySymbol.get('EUR');
            }
        }
    }

    public Decimal amountValue {
        get;
        set {
            if (value != null) {
                amountValue = value;
            }
        }
    }

    public String formattedAmountValue {
            get{
                if(formattedAmountValue == null){
                    formattedAmountValue = this.amountValue == null ? '' : this.amountValue.format();
                    if(formattedAmountValue.substringAfterLast(',').length() == 1)
                        formattedAmountValue += '0';
                    else if(String.isNotBlank(formattedAmountValue) && !formattedAmountValue.contains(','))
                        formattedAmountValue += ',00';
                }
                return formattedAmountValue;
            }
            set;
    }
}