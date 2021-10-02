--Task #1

SELECT course_id, title
FROM course
WHERE credits > 3;

SELECT room_number
FROM classroom
WHERE building = 'Packard' or building = 'Watson';

SELECT course_id, title
FROM course
WHERE dept_name = 'Comp. Sci.';

SELECT course_id
FROM section
WHERE semester = 'Fall';

SELECT id, name
FROM student
WHERE tot_cred > 45 and tot_cred < 90;

SELECT id, name
FROM student
WHERE name similar to '%[aeiou]';

SELECT course_id
FROM prereq
WHERE prereq_id = 'CS-101';

--Task #2

SELECT dept_name, avg(salary) as avg_salary
FROM instructor
GROUP BY dept_name
ORDER BY avg_salary;

SELECT building, count(building) as num_of_courses
        from section
        GROUP BY building
LIMIT 1;

WITH min_courses(min_courses) as (select min(num_of_courses) from (
SELECT dept_name, count(dept_name) as num_of_courses
        from course
        GROUP BY dept_name) as f),
dep_table(dept_name, num_of_courses) as (
SELECT dept_name, count(dept_name) as num_of_courses
        from course
        GROUP BY dept_name)
SELECT dept_name from dep_table, min_courses WHERE dep_table.num_of_courses = min_courses;


WITH student_id AS (SELECT student_id FROM (
    SELECT y.id AS student_id, count(y.course_id) AS taken_subjects FROM (
        SELECT id, course_id FROM takes WHERE course_id IN(
            SELECT course_id FROM course WHERE dept_name = 'Comp. Sci.')) AS y GROUP BY y.id) AS temporary
WHERE taken_subjects > 3)
SELECT id, name FROM student, student_id
WHERE id = student_id;

SELECT id, name
FROM instructor
WHERE dept_name in ('Biology', 'Philosophy', 'Music');

SELECT id
FROM teaches
WHERE year = 2018
EXCEPT SELECT id FROM teaches WHERE year = 2017;

--Task #3

SELECT name FROM student WHERE id in(
SELECT distinct id FROM takes WHERE course_id in (
    SELECT course_id FROM course WHERE dept_name = 'Comp. Sci.')
                                  and id in (SELECT id from takes WHERE grade = 'A' or grade = 'A-'))
ORDER BY name;

SELECT name, id FROM instructor WHERE id in(
SELECT i_id FROM advisor WHERE s_id in
(SELECT id from takes WHERE grade not in ('A', 'A-')));

SELECT dept_name FROM student EXCEPT (
SELECT distinct dept_name FROM student WHERE id in
(SELECT id from takes WHERE grade in ('F', 'C')));

SELECT name, id FROM instructor WHERE id in(
SELECT id FROM teaches EXCEPT
(SELECT distinct id from teaches WHERE course_id in (
SELECT course_id from takes WHERE grade = 'A')));

SELECT distinct course_id, semester, year FROM section WHERE time_slot_id in ('A', 'B', 'C', 'E', 'H');