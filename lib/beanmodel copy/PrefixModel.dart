class PrefixModel {
  dynamic status;
  dynamic message;
  PrefixModelData data;

  PrefixModel(this.status, this.message, this.data);

  factory PrefixModel.fromJsom(dynamic json) {
    PrefixModelData d = PrefixModelData.fromJson(json['data']);
    return PrefixModel(json['status'], json['message'], d);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class PrefixModelData {
  dynamic prefix_code;

  PrefixModelData(this.prefix_code);

  factory PrefixModelData.fromJson(dynamic json) {
    return PrefixModelData(json['prefix_code']);
  }

  @override
  String toString() {
    return '{countryCode: $prefix_code}';
  }
}
