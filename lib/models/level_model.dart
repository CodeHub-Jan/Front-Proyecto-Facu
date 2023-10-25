class LevelOne {
  String name;
  List<LevelTwo> list;

  LevelOne({
    required this.name,
    required this.list,
  });

  factory LevelOne.fromJson(Map<String, dynamic> json) => LevelOne(
    name: json["name"],
    list: List<LevelTwo>.from(json["list"].map((x) => LevelTwo.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class LevelTwo {
  String name;
  List<LevelThree> list;

  LevelTwo({
    required this.name,
    required this.list,
  });

  factory LevelTwo.fromJson(Map<String, dynamic> json) => LevelTwo(
    name: json["name"],
    list: List<LevelThree>.from(json["list"].map((x) => LevelThree.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class LevelThree {
  String name;
  List<LevelFour> list;

  LevelThree({
    required this.name,
    required this.list,
  });

  factory LevelThree.fromJson(Map<String, dynamic> json) => LevelThree(
    name: json["name"],
    list: List<LevelFour>.from(json["list"].map((x) => LevelFour.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class LevelFour {
  String name;

  LevelFour({
    required this.name,
  });

  factory LevelFour.fromJson(Map<String, dynamic> json) => LevelFour(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}