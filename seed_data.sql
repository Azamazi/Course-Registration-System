-- =========================================================
-- Sample data for demo / screenshots
-- =========================================================

INSERT INTO Departments (dept_code, dept_name, building) VALUES
('CS', 'Computer Science', 'Tech Block A'),
('MATH', 'Mathematics', 'Science Block'),
('ENG', 'English & Humanities', 'Arts Block'),
('EE', 'Electrical Engineering', 'Tech Block B');

INSERT INTO Instructors (first_name, last_name, email, dept_id, title) VALUES
('Ahmed', 'Raza', 'ahmed.raza@uni.edu', 1, 'Associate Professor'),
('Sara', 'Khan', 'sara.khan@uni.edu', 1, 'Lecturer'),
('Bilal', 'Hussain', 'bilal.hussain@uni.edu', 2, 'Professor'),
('Ayesha', 'Malik', 'ayesha.malik@uni.edu', 3, 'Lecturer'),
('Usman', 'Tariq', 'usman.tariq@uni.edu', 4, 'Assistant Professor');

INSERT INTO Students (roll_no, first_name, last_name, email, major_dept_id, enrollment_year, gpa) VALUES
('F23-BSCS-001', 'Hassan', 'Iqbal', 'hassan.iqbal@student.uni.edu', 1, 2023, 3.4),
('F23-BSCS-002', 'Mahnoor', 'Fatima', 'mahnoor.fatima@student.uni.edu', 1, 2023, 3.8),
('F23-BSCS-003', 'Ali', 'Ahmed', 'ali.ahmed@student.uni.edu', 1, 2023, 2.9),
('F22-BSEE-010', 'Zainab', 'Sheikh', 'zainab.sheikh@student.uni.edu', 4, 2022, 3.6),
('F22-BSEE-011', 'Omar', 'Farooq', 'omar.farooq@student.uni.edu', 4, 2022, 3.1),
('F24-BSCS-020', 'Fatima', 'Noor', 'fatima.noor@student.uni.edu', 1, 2024, 3.9),
('F24-BSMA-005', 'Hamza', 'Shah', 'hamza.shah@student.uni.edu', 2, 2024, 3.3);

INSERT INTO Courses (course_code, course_name, credits, dept_id, description) VALUES
('CS101', 'Introduction to Programming', 3, 1, 'Fundamentals of programming using C++.'),
('CS201', 'Data Structures', 3, 1, 'Linear and non-linear data structures.'),
('CS301', 'Database Systems', 3, 1, 'Relational model, SQL, normalization, transactions.'),
('CS310', 'Web Development', 3, 1, 'HTML, CSS, JavaScript and server-side basics.'),
('MATH101', 'Calculus I', 3, 2, 'Limits, derivatives, integrals.'),
('MATH201', 'Linear Algebra', 3, 2, 'Vector spaces, matrices, eigenvalues.'),
('ENG105', 'Academic Writing', 2, 3, 'Composition and communication skills.'),
('EE150', 'Circuit Analysis', 3, 4, 'DC/AC circuit theory and analysis.');

-- Prerequisites: CS201 needs CS101, CS301 needs CS201
INSERT INTO Prerequisites (course_id, prereq_course_id) VALUES
(2, 1),
(3, 2);

INSERT INTO Sections (course_id, instructor_id, semester, year, room, schedule, capacity) VALUES
(1, 2, 'Fall', 2026, 'A-101', 'Mon/Wed 09:00-10:20', 3),
(2, 1, 'Fall', 2026, 'A-102', 'Tue/Thu 10:30-11:50', 2),
(3, 1, 'Fall', 2026, 'A-103', 'Mon/Wed 11:00-12:20', 2),
(4, 2, 'Fall', 2026, 'A-104', 'Tue/Thu 13:00-14:20', 3),
(5, 3, 'Fall', 2026, 'S-201', 'Mon/Wed/Fri 08:00-08:50', 4),
(6, 3, 'Fall', 2026, 'S-202', 'Tue/Thu 09:00-10:20', 3),
(7, 4, 'Fall', 2026, 'H-101', 'Wed 14:00-15:50', 3),
(8, 5, 'Fall', 2026, 'B-101', 'Mon/Wed 10:30-11:50', 3);

-- Sample completed history (Fall 2025) so prerequisite triggers have something to check
INSERT INTO Sections (course_id, instructor_id, semester, year, room, schedule, capacity) VALUES
(1, 2, 'Fall', 2025, 'A-101', 'Mon/Wed 09:00-10:20', 40); -- section_id 9, CS101 last year
INSERT INTO Sections (course_id, instructor_id, semester, year, room, schedule, capacity) VALUES
(2, 1, 'Fall', 2025, 'A-102', 'Tue/Thu 10:30-11:50', 40); -- section_id 10, CS201 last year

INSERT INTO Enrollments (student_id, section_id, enrollment_date, status, grade) VALUES
(1, 9, '2025-09-01', 'Completed', 'A'),      -- Hassan completed CS101
(1, 10, '2025-09-01', 'Completed', 'B+'),    -- Hassan completed CS201 -> eligible for CS301
(2, 9, '2025-09-01', 'Completed', 'A-'),     -- Mahnoor completed CS101 -> eligible for CS201
(3, 9, '2025-09-01', 'Completed', 'B');      -- Ali completed CS101

-- Current-term registrations
INSERT INTO Enrollments (student_id, section_id, status) VALUES
(1, 3, 'Registered'),   -- Hassan -> CS301 (allowed, has CS201)
(2, 2, 'Registered'),   -- Mahnoor -> CS201 (allowed, has CS101)
(3, 4, 'Registered'),   -- Ali -> Web Dev
(4, 8, 'Registered'),   -- Zainab -> Circuit Analysis
(4, 6, 'Registered'),   -- Zainab -> Linear Algebra
(5, 5, 'Registered'),   -- Omar -> Calculus I
(6, 1, 'Registered'),   -- Fatima Noor -> CS101
(7, 5, 'Registered');   -- Hamza -> Calculus I
