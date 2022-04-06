-- view P0404V -- 
CREATE OR REPLACE VIEW P0404V AS 
    SELECT semester_year, semester_term, section_id,student_no, enroll_date
        FROM gl_enrollments
            JOIN gl_sections USING (section_id)
            JOIN gl_semesters USING (semester_id)
            JOIN gl_students USING (student_no)
        WHERE numeric_grade IS NULL AND letter_grade IS NULL;

-- 6. P0404e --
DECLARE
    H1 VARCHAR2(80) := 'Enrollment Missing Grade Verification';
    H2 VARCHAR2(80) := LPAD('_',LENGTH(H1),' _');
    H3 VARCHAR2(80) := 'Section    Student No    Enroll Date';
    H4 VARCHAR2(80) := '-------    ----------    -----------';
    E_NO_DATA_FOUND EXCEPTION;
    v_isNoRowFound Number(1,0) := 0;
    
    CURSOR no_enroll_cursor (p_semester_year gl_semesters.semester_year%TYPE, 
                            p_semester_term gl_semesters.semester_term%TYPE) IS
        SELECT * FROM P0404V
            WHERE semester_year = p_semester_year AND 
                    semester_term = p_semester_term
            ORDER BY section_id, student_no;
    
    v_cursor_rec     no_enroll_cursor%ROWTYPE;
    v_semester_year  gl_semesters.semester_year%TYPE := :ENTER_SEMESTER_YEAR;
    v_semester_term  gl_semesters.semester_term%TYPE := UPPER(:ENTER_SEMESTER_TERM);
    v_semester_month VARCHAR2(80);
BEGIN
    IF v_semester_year IS NULL OR v_semester_term IS NULL THEN
        DBMS_OUTPUT.PUT_LINE
        ('** Either year or term were not entered. The listing shows missing grades for the current term. **');
        DBMS_OUTPUT.NEW_LINE;
    END IF;
    IF v_semester_year IS NULL THEN
        v_semester_year := TO_CHAR(SYSDATE,'YYYY');
    END IF;
    IF v_semester_term IS NULL THEN
        v_semester_month := TO_CHAR(SYSDATE,'MM');
        CASE 
            WHEN v_semester_month >= '09' THEN
            v_semester_term := 'F';
            WHEN v_semester_month >= '05' THEN
            v_semester_term := 'S';
            WHEN v_semester_month >= '01' THEN
            v_semester_term := 'W';
        END CASE;
    END IF;
    DBMS_OUTPUT.PUT_LINE(H1);
    DBMS_OUTPUT.PUT_LINE(H2);
    DBMS_OUTPUT.PUT_LINE('Year: '||v_semester_year || '    Term:'||v_semester_term);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE(H3);
    DBMS_OUTPUT.PUT_LINE(H4);
    OPEN no_enroll_cursor(v_semester_year,v_semester_term);
    LOOP
        FETCH no_enroll_cursor INTO v_cursor_rec;
        EXIT WHEN no_enroll_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_cursor_rec.section_id             ||'    '||
                            LPAD(v_cursor_rec.student_no,10)     ||'    '||
                            LPAD(v_cursor_rec.enroll_date,12));
        v_isNoRowFound := 1;
    END LOOP;
    CLOSE no_enroll_cursor;
    IF v_isNoRowFound = 0 THEN
        RAISE E_NO_DATA_FOUND;
    END IF;
EXCEPTION
    WHEN E_NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('** There are no missing grades for ' ||v_semester_year||v_semester_term||' **');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('** The following undetermined error occured. Contact software support. **');
        DBMS_OUTPUT.PUT_LINE('** Error Code: '|| SQLCODE ||' **');
        DBMS_OUTPUT.PUT_LINE('** Error message '|| SQLERRM ||' **');
END;