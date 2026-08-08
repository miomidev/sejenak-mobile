abstract class Users {
  void getPermissions();
}

abstract class Admin {
  void readUser();
  void updateUser();
  void createUser();
  void deleteUser();
}

class RegularUser implements Users {
  @override
  void getPermissions() {
    print("Regular user: Read & Update profile only.");
  }
}

class AdminUser implements Users, Admin {
  @override
  void getPermissions() {
    print("Admin user: CRUD users, but cannot delete Admin or SuperAdmin.");
  }

  @override
  void deleteUser() {
    print("Admin deleted a regular user.");
  }

  @override
  void readUser() {
    print("Admin read a user's profile.");
  }

  @override
  void createUser() {
    print("Admin created a new user.");
  }

  @override
  void updateUser() {
    print("Admin read a user's profile.");
  }
}

class SuperAdminUser implements Users, Admin {
  @override
  void getPermissions() {
    print("SuperAdmin user: CRUD users, including Admin and SuperAdmin.");
  }

  @override
  void deleteUser() {
    print("SuperAdmin deleted a user or admin.");
  }

  @override
  void readUser() {
    print("SuperAdmin read a regular user and admin.");
  }

  @override
  void createUser() {
    print("SuperAdmin created a regular user and admin.");
  }

  @override
  void updateUser() {
    print(" SuperAdmin a regular user and admin.");
  }
}
