/*CP3 P0605
c0842810, Yuting Sha
2022-03-30*/

--STEP1:

CREATE OR REPLACE VIEW P0605V AS
    SELECT 
        school_code,
        program_code,
        course_code,
        credit_hours,
        section_id,
        semester_year,
        semester_term,
        student_no,
        last_name ||', '||first_name  AS student_name,
        letter_grade 
    FROM gl_programs
        JOIN gl_courses     USING(program_code)
        JOIN gl_sections    USING(course_code)
        JOIN gl_semesters   USING(semester_id)
        JOIN gl_enrollments USING(section_id)
        JOIN gl_students    USING(student_no);

SELECT * FROM P0605V;

--step02
CREATE OR REPLACE PROCEDURE P0605 
    (p_school_code  IN P0605V.school_code%TYPE,
    p_semester_year IN P0605V.semester_year%TYPE,
    p_semester_term IN P0605V.semester_term%TYPE )
IS
    PROCEDURE L1_Break; -- (forward declaration)
    PROCEDURE L2_Break;
    PROCEDURE L3_Break;
    PROCEDURE get_school_name;
    PROCEDURE get_program_name;
    PROCEDURE get_course_title;
    CURSOR grade_report_cursor IS
        SELECT * FROM P0605V
        WHERE school_code = p_school_code 
            AND semester_year = p_semester_year 
            AND semester_term = p_semester_term
        ORDER BY program_code, course_code,section_id,student_no;
    grade_report_rec            grade_report_cursor%ROWTYPE;
    prt_school_name             gl_schools.school_name%TYPE;
    hold_program_code           P0605V.program_code%TYPE;
    prt_program_code            P0605V.program_code%TYPE;
    prt_program_name            gl_programs.program_name%TYPE;
    hold_course_code            P0605V.course_code%TYPE;
    prt_course_code             hold_course_code%TYPE;
    hold_course_title            gl_courses.course_title%TYPE;
    prt_course_title            hold_course_title%TYPE;
    hold_section_id             P0605V.section_id%TYPE;
    prt_section_id              VARCHAR(5);
    v_school_count              NUMBER(7)   := 0;
    v_program_count             v_school_count%TYPE := 0;
    v_course_count              v_school_count%TYPE := 0;
    v_section_count             v_school_count%TYPE := 0;
    ZEROS CONSTANT              NUMBER      := 0;
    SPACES CONSTANT             VARCHAR2(5) := ' ';
    e_table_is_empty_exception  EXCEPTION;
    v_head1  VARCHAR2(90)  := 'Grades for School of';
    v_head2  VARCHAR2(90);
    v_head3  VARCHAR2(90)  := LPAD('Course', 10) || LPAD('Section', 40) || LPAD('Student', 10) || LPAD('Grade', 30) ;                    
    v_head4  VARCHAR2(90)  := LPAD('------', 10) || LPAD('-------', 40) || LPAD('-------', 10) || LPAD('-----', 30) ;
----------------- Initialization Sub-Procedure ------------
PROCEDURE initialization IS
BEGIN
    OPEN grade_report_cursor;
    FETCH grade_report_cursor INTO grade_report_rec;
    IF grade_report_cursor%NOTFOUND THEN
        RAISE e_table_is_empty_exception;
    END IF;
    hold_program_code       := grade_report_rec.program_code;
    hold_course_code        := grade_report_rec.course_code;
    hold_section_id         := grade_report_rec.section_id;
    prt_program_code        := hold_program_code;
    prt_course_code         := hold_course_code;
    get_course_title;
    -- prt_course_title        := hold_course_title;
    hold_course_title       := prt_course_title;
    prt_section_id          := grade_report_rec.section_id;
    get_school_name;
    v_head1 := v_head1 || prt_school_name || LPAD(p_semester_term||p_semester_year,10);
    DBMS_OUTPUT.PUT_LINE(LPAD(v_head1,57));
    v_head2 := LPAD('-', LENGTH(v_head1),'-');
    DBMS_OUTPUT.PUT_LINE(LPAD(v_head2,57));
    DBMS_OUTPUT.NEW_LINE;
    get_program_name;
    DBMS_OUTPUT.PUT_LINE (LPAD('Program: ', 10) || prt_program_code ||' - '||prt_program_name);
    DBMS_OUTPUT.PUT_LINE (v_head3);
    DBMS_OUTPUT.PUT_LINE (v_head4);
END initialization;
----------------- Detail Processing Sub-Procedure ---------
PROCEDURE detail_processing IS
    BEGIN
     DBMS_OUTPUT.PUT_LINE(
            LPAD(prt_course_code, 15)  || ' ' ||
            RPAD(prt_course_title, 26) ||
            LPAD(prt_section_id, 10)   ||
            LPAD(grade_report_rec.student_no, 10)   ||
            LPAD(grade_report_rec.student_name, 20) ||
            LPAD(COALESCE(TO_CHAR(grade_report_rec.letter_grade),'N/G'), 10));
    v_section_count := v_section_count + 1;
    prt_course_code := SPACES;
    prt_course_title := SPACES;
    prt_section_id  := SPACES;
    END detail_processing;
----------------- Check_Control_Breaks Sub-Procedure ---------
PROCEDURE check_control_breaks IS
BEGIN
    CASE
        WHEN grade_report_rec.program_code <> hold_program_code THEN
            L1_Break;
            L2_Break;
            L3_Break;
        WHEN grade_report_rec.course_code <> hold_course_code THEN
            L1_Break;
            L2_Break;
        WHEN grade_report_rec.section_id <> hold_section_id THEN
            L1_Break;
        ELSE NULL; --No control break
    END CASE;
END check_control_breaks;
-----------------  L1_Break Sub-Procedure -----------section break
PROCEDURE L1_Break IS  
    BEGIN
        DBMS_OUTPUT.PUT_LINE(LPAD('* Section '||hold_section_id ||' count: '||v_section_count,52));
        DBMS_OUTPUT.NEW_LINE;
        v_course_count  := v_course_count + v_section_count;
        v_section_count := ZEROS;
        hold_section_id := grade_report_rec.section_id;
        prt_section_id  := grade_report_rec.section_id;
    END L1_Break;
-----------------  L2_Break Sub-Procedure -----------course break
PROCEDURE L2_Break IS  
BEGIN
    DBMS_OUTPUT.PUT_LINE(LPAD('** Course '||hold_course_code ||' '||hold_course_title||' count: '||v_course_count,53));
    DBMS_OUTPUT.NEW_LINE;
    v_program_count     := v_program_count + v_course_count;
    v_course_count      := ZEROS;
    hold_course_code    := grade_report_rec.course_code;
    prt_course_code     := grade_report_rec.course_code;
    get_course_title;
    hold_course_title := prt_course_title ;
END L2_Break;
-----------------  L3_Break Sub-Procedure -----------program break
PROCEDURE L3_Break IS  
BEGIN
    DBMS_OUTPUT.PUT_LINE(LPAD('*** Program '||prt_program_name ||' count: '||v_program_count,54));
    v_school_count := v_school_count + v_program_count ;
    DBMS_OUTPUT.NEW_LINE;
    IF NOT grade_report_cursor%NOTFOUND THEN
        hold_program_code := grade_report_rec.program_code;
        get_program_name;
        DBMS_OUTPUT.PUT_LINE(LPAD('-',90,'-'));
        DBMS_OUTPUT.PUT_LINE (LPAD('Program: ', 10) || hold_program_code ||' - '||LPAD(prt_program_name, 10));
        DBMS_OUTPUT.PUT_LINE (v_head3);
        DBMS_OUTPUT.PUT_LINE (v_head4);
        v_program_count := ZEROS;
    END IF;
END L3_Break;
----------------- get_school_name Procedure ---------
PROCEDURE get_school_name IS
    BEGIN
        SELECT school_name INTO prt_school_name
        FROM gl_schools
        WHERE school_code = p_school_code;
END get_school_name;
----------------- get_program_name Procedure ---------
PROCEDURE get_program_name IS
    BEGIN
        SELECT program_name INTO prt_program_name
        FROM gl_programs
        WHERE program_code = grade_report_rec.program_code;
END get_program_name;
----------------- get_course_title Procedure ---------
PROCEDURE get_course_title IS
    BEGIN
        SELECT course_title INTO prt_course_title
        FROM gl_courses
        WHERE course_code = grade_report_rec.course_code;
END get_course_title;
----------------- Termination Sub-Procedure ---------
PROCEDURE termination IS
    BEGIN
        L1_Break;
        L2_Break;
        L3_Break;
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE('**** Total students in School of '||prt_school_name||' : '||v_school_count);
        CLOSE grade_report_cursor;
    END termination;
---------------- Main Module (Execution Section) -----
BEGIN
    initialization;
    LOOP
        check_control_breaks;
        detail_processing;
        FETCH grade_report_cursor INTO grade_report_rec;
        EXIT WHEN grade_report_cursor%NOTFOUND;
    END LOOP;
    termination;
EXCEPTION
    WHEN e_table_is_empty_exception THEN
    DBMS_OUTPUT.PUT_LINE('Table is empty.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('    SQL Error Code: '|| SQLCODE);
    DBMS_OUTPUT.PUT_LINE('SQL Error Message: '|| SQLERRM);
END P0605;

--STEP03
DECLARE
    v_school_code P0605V.school_code%TYPE := UPPER(:ENTER_SCHOOL_CODE);
    v_semester_year P0605V.semester_year%TYPE := :ENTER_YEAR;
    v_semester_term P0605V.semester_term%TYPE := UPPER(:ENTER_TERM_F_W_S);
BEGIN
    P0605(v_school_code,v_semester_year,v_semester_term);
END;
