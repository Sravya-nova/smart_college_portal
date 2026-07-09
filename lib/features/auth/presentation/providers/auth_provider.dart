import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { student, admin }

class StudentUser {
  final String id;
  final String name;
  final int age;
  final String semester;
  final String phone;
  final String parentName;
  final String parentPhone;
  final String prevSemMarks;
  final String email;
  final String cgpa;
  final String department;
  final String hostelBlock;
  final String roomNo;
  final String libraryCard;
  final String avatarUrl;

  const StudentUser({
    required this.id,
    required this.name,
    required this.age,
    required this.semester,
    required this.phone,
    required this.parentName,
    required this.parentPhone,
    required this.prevSemMarks,
    required this.email,
    required this.cgpa,
    required this.department,
    required this.hostelBlock,
    required this.roomNo,
    required this.libraryCard,
    required this.avatarUrl,
  });
}

class AdminUser {
  final String id;
  final String name;
  final String dept;
  final String branch;
  final String qualification;
  final String contact;
  final String avatarUrl;

  const AdminUser({
    required this.id,
    required this.name,
    required this.dept,
    required this.branch,
    required this.qualification,
    required this.contact,
    required this.avatarUrl,
  });
}

// Student Mock Database (5 members)
final Map<String, StudentUser> studentDatabase = {
  'ST-202301': const StudentUser(
    id: 'ST-202301',
    name: 'Alex Thompson',
    age: 20,
    semester: '5th Semester',
    phone: '+91 9100 681 777',
    parentName: 'John & Mary Thompson',
    parentPhone: '+91 9100 681 888',
    prevSemMarks: '8.5 GPA',
    email: 'alex.t@becbapatla.ac.in',
    cgpa: '8.8 / 10',
    department: 'CSE (AI & ML), BEC Bapatla',
    hostelBlock: 'Ramanujan Hostel Block (RPL)',
    roomNo: 'Room 302',
    libraryCard: 'LIB-BEC-9482',
    avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop',
  ),
  'ST-202302': const StudentUser(
    id: 'ST-202302',
    name: 'Beatrice Miller',
    age: 21,
    semester: '5th Semester',
    phone: '+91 9100 682 777',
    parentName: 'Robert & Helen Miller',
    parentPhone: '+91 9100 682 888',
    prevSemMarks: '9.2 GPA',
    email: 'beatrice.m@becbapatla.ac.in',
    cgpa: '9.2 / 10',
    department: 'CSE (Data Science), BEC',
    hostelBlock: 'Gargi Girls Hostel Block',
    roomNo: 'Room 104',
    libraryCard: 'LIB-BEC-1085',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop',
  ),
  'ST-202303': const StudentUser(
    id: 'ST-202303',
    name: 'Cassius Gray',
    age: 20,
    semester: '5th Semester',
    phone: '+91 9848 022 338',
    parentName: 'David & Sarah Gray',
    parentPhone: '+91 9848 022 448',
    prevSemMarks: '8.4 GPA',
    email: 'cassius.g@becbapatla.ac.in',
    cgpa: '8.4 / 10',
    department: 'Electronics & Communication, BEC',
    hostelBlock: 'Visvesvaraya Hostel Block',
    roomNo: 'Room 412',
    libraryCard: 'LIB-BEC-3392',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop',
  ),
  'ST-202304': const StudentUser(
    id: 'ST-202304',
    name: 'Diana Prince',
    age: 20,
    semester: '5th Semester',
    phone: '+91 9900 123 456',
    parentName: 'Queen Hippolyta',
    parentPhone: '+91 9900 123 789',
    prevSemMarks: '9.0 GPA',
    email: 'diana.p@becbapatla.ac.in',
    cgpa: '9.0 / 10',
    department: 'Civil Engineering, BEC',
    hostelBlock: 'Gargi Girls Hostel Block',
    roomNo: 'Room 205',
    libraryCard: 'LIB-BEC-4820',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop',
  ),
  'ST-202305': const StudentUser(
    id: 'ST-202305',
    name: 'Ethan Hunt',
    age: 22,
    semester: '5th Semester',
    phone: '+91 9888 777 666',
    parentName: 'William Hunt',
    parentPhone: '+91 9888 777 555',
    prevSemMarks: '8.1 GPA',
    email: 'ethan.h@becbapatla.ac.in',
    cgpa: '8.1 / 10',
    department: 'Mechanical Engineering, BEC',
    hostelBlock: 'Visvesvaraya Hostel Block',
    roomNo: 'Room 102',
    libraryCard: 'LIB-BEC-5561',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop',
  ),
};

// Admin Mock Database (3 members)
final Map<String, AdminUser> adminDatabase = {
  'AD-101': const AdminUser(
    id: 'AD-101',
    name: 'Dr. Michael Chen',
    dept: 'CSE (AI & ML)',
    branch: 'Computer Science',
    qualification: 'Ph.D. in Artificial Intelligence',
    contact: '+91 8643 224 001',
    avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop',
  ),
  'AD-102': const AdminUser(
    id: 'AD-102',
    name: 'Dr. Sarah Jenkins',
    dept: 'Information Technology',
    branch: 'IT & Software Systems',
    qualification: 'Ph.D. in Cyber Networks',
    contact: '+91 8643 224 002',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop',
  ),
  'AD-103': const AdminUser(
    id: 'AD-103',
    name: 'Prof. Rajesh Kumar',
    dept: 'ECE',
    branch: 'Electronics & Communication',
    qualification: 'M.Tech in Microelectronics',
    contact: '+91 8643 224 003',
    avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&auto=format&fit=crop',
  ),
};

class AuthState {
  final bool isLoggedIn;
  final UserRole? role;
  final String? userId;
  final StudentUser? studentUser;
  final AdminUser? adminUser;

  const AuthState({
    this.isLoggedIn = false,
    this.role,
    this.userId,
    this.studentUser,
    this.adminUser,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserRole? role,
    String? userId,
    StudentUser? studentUser,
    AdminUser? adminUser,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      studentUser: clearUser ? null : (studentUser ?? this.studentUser),
      adminUser: clearUser ? null : (adminUser ?? this.adminUser),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  bool login(String id, String password) {
    id = id.trim().toUpperCase();
    if (id.startsWith('ST-')) {
      if (studentDatabase.containsKey(id)) {
        state = AuthState(
          isLoggedIn: true,
          role: UserRole.student,
          userId: id,
          studentUser: studentDatabase[id],
        );
        return true;
      }
    } else if (id.startsWith('AD-')) {
      if (adminDatabase.containsKey(id)) {
        state = AuthState(
          isLoggedIn: true,
          role: UserRole.admin,
          userId: id,
          adminUser: adminDatabase[id],
        );
        return true;
      }
    }
    return false;
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
