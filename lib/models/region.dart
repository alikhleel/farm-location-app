class Region {
  final String _id;
  final String _name;
  final int? _cmtNum;

  Region({required String id, required String name, required int? cmtNum})
      : _id = id,
        _name = name,
        _cmtNum = cmtNum;
  Region.fromNetwork(Map<String, dynamic> data)
      : _id = data['id'],
        _name = data['name'],
        _cmtNum = data['cmt_number'];

  Region.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _name = json['name'],
        _cmtNum = json['cmt_number'];

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': _name,
        'cmt_number': _cmtNum,
      };

  String get getId => _id;
  String get getName => _name;
  int? get cmtNumber => _cmtNum;
}
