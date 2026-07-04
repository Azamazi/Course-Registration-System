-- =========================================================
-- University Course Registration System
-- Schema: schema.sql
-- Engine target: SQLite (portable to Oracle/MySQL with minor
-- type changes — see NOTES.md for the Oracle equivalents)
-- =========================================================

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------
-- DEPARTMENTS
-- ---------------------------------------------------------
CREATE TABLE Departments (
    dept_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    dept_code    TEXT NOT NULL UNIQUE,      -- e.g. 'CS'
    dept_name    TEXT NOT NULL,             -- e.g. 'Computer Science'
    building     TEXT
);

-- ---------------------------------------------------------
-- INSTRUCTORS
-- ---------------------------------------------------------
CREATE TABLE Instructors (
    instructor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name    TEXT NOT NULL,
    last_name     TEXT NOT NULL,
    email         TEXT NOT NULL UNIQUE,
    dept_id       INTEGER NOT NULL,
    title         TEXT DEFAULT 'Lecturer',  -- Professor / Assoc. Prof / Lecturer
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

-- ---------------------------------------------------------
-- STUDENTS
-- ---------------------------------------------------------
CREATE TABLE Students (
    student_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    roll_no        TEXT NOT NULL UNIQUE,     -- e.g. 'F23-BSCS-045'
    first_name     TEXT NOT NULL,
    last_name      TEXT NOT NULL,
    email          TEXT NOT NULL UNIQUE,
    major_dept_id  INTEGER NOT NULL,
    enrollment_year INTEGER NOT NULL,
    gpa            REAL DEFAULT 0.0 CHECK (gpa >= 0.0 AND gpa <= 4.0),
    FOREIGN KEY (major_dept_id) REFERENCES Departments(dept_id)
);

-- ---------------------------------------------------------
-- COURSES  (the catalog entry, not a specific offering)
-- ---------------------------------------------------------
CREATE TABLE Courses (
    course_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    course_code  TEXT NOT NULL UNIQUE,      -- e.g. 'CS301'
    course_name  TEXT NOT NULL,
    credits      INTEGER NOT NULL CHECK (credits BETWEEN 1 AND 6),
    dept_id      INTEGER NOT NULL,
    description  TEXT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

-- ---------------------------------------------------------
-- PREREQUISITES  (self-referencing many-to-many on Courses)
-- ---------------------------------------------------------
CREATE TABLE Prerequisites (
    course_id       INTEGER NOT NULL,
    prereq_course_id INTEGER NOT NULL,
    PRIMARY KEY (course_id, prereq_course_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (prereq_course_id) REFERENCES Courses(course_id),
    CHECK (course_id <> prereq_course_id)
);

-- ---------------------------------------------------------
-- SECTIONS  (a specific offering of a course in a given term)
-- ---------------------------------------------------------
CREATE TABLE Sections (
    section_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id      INTEGER NOT NULL,
    instructor_id  INTEGER NOT NULL,
    semester       TEXT NOT NULL CHECK (semester IN ('Fall','Spring','Summer')),
    year           INTEGER NOT NULL,
    room           TEXT,
    schedule       TEXT,               -- e.g. 'Mon/Wed 10:00-11:20'
    capacity       INTEGER NOT NULL CHECK (capacity > 0),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id),
    UNIQUE (course_id, semester, year, instructor_id)
);

-- ---------------------------------------------------------
-- ENROLLMENTS  (student <-> section, the registration record)
-- ---------------------------------------------------------
CREATE TABLE Enrollments (
    enrollment_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id      INTEGER NOT NULL,
    section_id      INTEGER NOT NULL,
    enrollment_date TEXT NOT NULL DEFAULT (date('now')),
    status          TEXT NOT NULL DEFAULT 'Registered'
                     CHECK (status IN ('Registered','Dropped','Completed')),
    grade           TEXT CHECK (grade IN ('A','A-','B+','B','B-','C+','C','C-','D','F',NULL)),
    UNIQUE (student_id, section_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (section_id) REFERENCES Sections(section_id)
);

-- ---------------------------------------------------------
-- INDEXES for common lookups
-- ---------------------------------------------------------
CREATE INDEX idx_enrollments_student ON Enrollments(student_id);
CREATE INDEX idx_enrollments_section ON Enrollments(section_id);
CREATE INDEX idx_sections_course ON Sections(course_id);
CREATE INDEX idx_courses_dept ON Courses(dept_id);

-- ---------------------------------------------------------
-- VIEW: seats currently taken/available per section
-- ---------------------------------------------------------
CREATE VIEW v_section_availability AS
SELECT
    s.section_id,
    c.course_code,
    c.course_name,
    s.semester,
    s.year,
    i.first_name || ' ' || i.last_name AS instructor,
    s.capacity,
    COUNT(e.enrollment_id) FILTER (WHERE e.status = 'Registered') AS seats_taken,
    s.capacity - COUNT(e.enrollment_id) FILTER (WHERE e.status = 'Registered') AS seats_available
FROM Sections s
JOIN Courses c ON c.course_id = s.course_id
JOIN Instructors i ON i.instructor_id = s.instructor_id
LEFT JOIN Enrollments e ON e.section_id = s.section_id
GROUP BY s.section_id;

-- ---------------------------------------------------------
-- VIEW: a student's current schedule
-- ---------------------------------------------------------
CREATE VIEW v_student_schedule AS
SELECT
    st.student_id,
    st.roll_no,
    st.first_name || ' ' || st.last_name AS student_name,
    c.course_code,
    c.course_name,
    c.credits,
    s.semester,
    s.year,
    s.schedule,
    e.status,
    e.grade
FROM Enrollments e
JOIN Students st ON st.student_id = e.student_id
JOIN Sections s ON s.section_id = e.section_id
JOIN Courses c ON c.course_id = s.course_id;

-- ---------------------------------------------------------
-- TRIGGER: block registration once a section is full
-- ---------------------------------------------------------
CREATE TRIGGER trg_prevent_overbook
BEFORE INSERT ON Enrollments
WHEN (
    (SELECT COUNT(*) FROM Enrollments
      WHERE section_id = NEW.section_id AND status = 'Registered')
    >=
    (SELECT capacity FROM Sections WHERE section_id = NEW.section_id)
)
BEGIN
    SELECT RAISE(ABORT, 'Section is full: capacity reached');
END;

-- ---------------------------------------------------------
-- TRIGGER: block registration if a prerequisite is not completed
-- ---------------------------------------------------------
CREATE TRIGGER trg_check_prereq
BEFORE INSERT ON Enrollments
WHEN EXISTS (
    SELECT 1 FROM Prerequisites p
    WHERE p.course_id = (SELECT course_id FROM Sections WHERE section_id = NEW.section_id)
      AND p.prereq_course_id NOT IN (
          SELECT s2.course_id
          FROM Enrollments e2
          JOIN Sections s2 ON s2.section_id = e2.section_id
          WHERE e2.student_id = NEW.student_id AND e2.status = 'Completed'
      )
)
BEGIN
    SELECT RAISE(ABORT, 'Prerequisite not completed for this course');
END;
