

DECLARE
    loan_rec            gl_loans%ROWTYPE;
    v_loan_id           gl_loans.loan_id%TYPE := :ENTER_LOAN_ID;
    v_interest_discount gl_loans.annual_interest_rate%TYPE;
    v_new_annual_rate   gl_loans.annual_interest_rate%TYPE;
    v_monthly_rate      NUMBER(10,9);
    v_monthly_interest  gl_loans.monthly_payment%TYPE;
    v_balance           gl_loans.monthly_payment%TYPE;
    v_month             NUMBER(3)            := 0;
    v_month_total       NUMBER(3)            := 0;
    v_year              NUMBER(3)            := 0;
    RATE_DISCOUNT1      CONSTANT NUMBER(3,2) := 0.00;
    RATE_DISCOUNT2      CONSTANT NUMBER(3,2) := 0.25;
    RATE_DISCOUNT3      CONSTANT NUMBER(3,2) := 0.50;
    RATE_DISCOUNT4      CONSTANT NUMBER(3,2) := 0.75;
    RATE_DISCOUNT5      CONSTANT NUMBER(3,2) := 1.00;
    H1 VARCHAR2(80)     := 'Payment Schedule';
    H2 VARCHAR2(80)     := LPAD('_',LENGTH(H1),' _');
    H3 VARCHAR2(80)     := 'Month    Interest    Payment    Balance';
    H4 VARCHAR2(80)     := '-----    --------    -------    -------';
BEGIN
    SELECT * 
        INTO loan_rec
    FROM gl_loans
    WHERE loan_id = v_loan_id;
    -- CASE statement --
        CASE 
            WHEN loan_rec.credit_score>= 800    THEN  v_interest_discount := RATE_DISCOUNT5;
            WHEN loan_rec.credit_score>= 740    THEN  v_interest_discount := RATE_DISCOUNT4;
            WHEN loan_rec.credit_score>= 670    THEN  v_interest_discount := RATE_DISCOUNT3;
            WHEN loan_rec.credit_score>= 580    THEN  v_interest_discount := RATE_DISCOUNT2;
            ELSE                                      v_interest_discount := RATE_DISCOUNT1;
        END CASE;
    -- Calculation --
    v_new_annual_rate   := loan_rec.annual_interest_rate - v_interest_discount;
    v_monthly_rate      := v_new_annual_rate / 1200;
    v_balance           := loan_rec.loan_amount;
    --output--
    DBMS_OUTPUT.PUT_LINE(H1);
    DBMS_OUTPUT.PUT_LINE(H2);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Name: '                    || loan_rec.first_name     ||' '|| loan_rec.last_name);
    DBMS_OUTPUT.PUT_LINE('Loan Amount: '             || TO_CHAR(loan_rec.loan_amount,'FM$99,999.00' ));
    DBMS_OUTPUT.PUT_LINE('Annual Interest Rate: '    || TO_CHAR(loan_rec.annual_interest_rate,'FM9.99') || '%');
    DBMS_OUTPUT.PUT_LINE('Credit Score: '            || loan_rec.credit_score   ||' '|| 
                         'Interest Discount: '       || TO_CHAR(v_interest_discount,'FM0.99')           || '%');
    DBMS_OUTPUT.PUT_LINE('New Annual Interest Rate: '|| v_new_annual_rate       || '%');
    DBMS_OUTPUT.PUT_LINE('Monthly Payment: '         ||TO_CHAR(loan_rec.monthly_payment,'FM$99,999.00' ));
    DBMS_OUTPUT.PUT_LINE(H3);
    DBMS_OUTPUT.PUT_LINE(H4);
    -- WHILE loop --
    WHILE v_balance > loan_rec.monthly_payment LOOP
        v_monthly_interest := v_balance  * v_monthly_rate ; --only keep two decimals
        v_balance := v_balance - loan_rec.monthly_payment + v_monthly_interest;
        v_month := v_month + 1;
        --OUTPUT --
        DBMS_OUTPUT.PUT_LINE(v_month ||
                            LPAD(v_monthly_interest,15) || 
                            LPAD(TO_CHAR(loan_rec.monthly_payment,'FM999.00'),15) ||
                            LPAD(TO_CHAR(v_balance,'FM$99,999.00'),15));
    END LOOP;
    -- final payment output --
    v_monthly_interest  := v_balance  * v_monthly_rate ;
    v_balance           := 0.00;
    v_month_total       := v_month + 1;
    DBMS_OUTPUT.PUT_LINE(v_month_total ||
                            LPAD(TO_CHAR(v_monthly_interest,'FM0.00'),15) || 
                            LPAD(TO_CHAR(loan_rec.monthly_payment,'FM999.00'),15) ||
                            LPAD(TO_CHAR(v_balance,'FM$0.00'),15));
    -- Year & Months calculation --
    v_year := FLOOR(v_month_total / 12);
    v_month := v_month_total - v_year * 12;
    DBMS_OUTPUT.PUT_LINE('It takes '||v_year ||' years and '|| v_month ||' month(s) to pay this loan');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('** The following undetermined error occured. Contact software support. **');
        DBMS_OUTPUT.PUT_LINE('** Error Code: '|| SQLCODE ||' PL/SQL: ' || SQLERRM ||' **');
END;
