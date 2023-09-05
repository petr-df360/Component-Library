public class BenefitTypes {
    
    public class tokenJSON{
        public String access_token;
        public String token_type;
        public Integer expires_in;
    }
    
    public class AddressJSON {
        public String name1;
        public String name2;
        public String street;
        public String city;
        public String postcode;
        public String state;
        public String contact;
        public String email;
        public String phone;
        public Boolean active;
        public Boolean billing;
        public String ben_partid;
        public Integer ben_padrid;
    }
    
    public class PartnerJSON {
        public String name;
        public String org_id;
        public Decimal maturity;
        public String payment;
        public String comment;
        public Boolean active;
        public Decimal creditLimit;
        public Boolean insurance;
        public String ben_partid;
        public Boolean supplier;
        public String development_status;
        public String region_cycle;
    }
    
    public class PartnerRevenueJSON{
        public Boolean is_valid;
        public String error;
        public List<RevenueJSON> revenues;
    }
    
    public class RevenueJSON{
        public String ben_partid;
        public String ben_padrid;
        public String brand;
        public Decimal revenue_ytd;
        public Decimal revenue_2ytd;
        public Decimal revenue_b2b;
        public Decimal unreleased_preorder;
        public Decimal revenue_ly;
    }
    
    public class PartnerBalanceJSON{
        public Boolean is_valid;
        public String error;
        public List<BalanceJSON> balances;
    }
    
    public class BalanceJSON{
        public String ben_partid;
        public Decimal balance;
        public Decimal balance_after;
    }
    
    public class PartnerPostJSON{
        public Boolean is_valid;
        public String ben_partid;
        public String error;
    }
    
    public class AddressPostJSON{
        public Boolean is_valid;
        public String ben_partid;
        public String ben_padrid;
        public String error;
    }
    
    public class InvoiceJSON{
        //Renamed fields should be handled on response arrival -> responseBody.replace(original, renamed)
        public String ben_partid;
        public String num; //renamed from reserved keyword "number"
        public String variable;
        public String date_issue;
        public String date_vat;
        public String date_due;
        public String date_payed;
        public Double ammount;
        public Double amount_payed;
        public String curr; //renamed from reserved keyword "currency"
        public Decimal days_after;
        public String payment;

    }
    
    public class PartnerInvoicesJSON{
        public Boolean is_valid;
        public String error;
        public List<InvoiceJSON> invoices;
    }
    
    public class blockB2bJSON{
        public string ben_partid;
    }
    
    public class blockB2bResponse{
        public Boolean is_valid;
        public String error;
    }
    
    public class PostInvoiceJSON {
        public String ben_partid;
        public String supplier_number;
        public String variable;
        public Decimal ammount;
        public String curr;//replace pls
        public String date_due;
        public String payment;
        public String comment;
    }
    
    public class PostInvoiceJSON_V2 {
        public String ben_partid;
        public String supplier_number;
        public String variable;
        public Decimal ammount;
        public String curr;
        public String date_due;
        public String date_vat;
        public String date_issue;
        public String payment;
		public String comment;
        public Integer year;
        public Integer month;
        public String type;
        public String ben_typeid;
        public String account_number;
        public String iban;
        public String swift;
    }
    
    public class PostInvoiceResponseJSON {
        public String ben_invyear;
        public String ben_invnumber;
        public String error;
        public Boolean is_valid;
    }
    
    public class InvoicePayJSON {
        public String ben_invyear;
        public String ben_invnumber;
        public Integer ben_accountid;
    }
    
    public class PostInvoicePayJSON {
        public List<InvoicePayJSON> invoices;
    }
    
    public class InvoicePayJSON_V2 {
        public String ben_invyear;
        public String ben_invnumber;
        public Integer ben_accountid;
        public String payment;  
    }
    
    public class PostInvoicePayJSON_V2 {
        public List<InvoicePayJSON_V2> invoices;
    }
    
    public class InvoicePayResponseJSON {
		public String ben_invyear;
        public String ben_invnumber;
        public String error;
        public Boolean is_valid;        
    }
    
    public class PostInvoicePayResponseJSON {
        public Boolean is_valid;
        public String error;
        public List<InvoicePayResponseJSON> res_invoices;  
    }
  
}