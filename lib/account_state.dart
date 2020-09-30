class AccountState {
  final bool online;
  final List<Department> departments;

  const AccountState(this.online, this.departments);

  factory AccountState.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) return null;
    final departmentList = map["departments"] as List<dynamic>;
    return AccountState(map["online"] == true, departmentList.map((a) => Department.fromMap(a as Map<dynamic, dynamic>)).toList(growable: false));
  }
}

class Department {
  final String id;
  final String name;
  final DepartmentStatus status;

  const Department(this.id, this.name, this.status);

  factory Department.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) return null;
    return Department(map["id"], map["name"], _fromStatus(map["status"]));
  }

  static DepartmentStatus _fromStatus(String status) {
    if (status == "Online") return DepartmentStatus.ONLINE;
    if (status == "Offline") return DepartmentStatus.OFFLINE;
    if (status == "Away") return DepartmentStatus.AWAY;
    return null;
  }
}

enum DepartmentStatus { AWAY, OFFLINE, ONLINE }
