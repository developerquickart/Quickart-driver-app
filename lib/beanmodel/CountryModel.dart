class CountryModel {
  dynamic status;
  dynamic message;
  CountryModelData data;

  CountryModel(this.status, this.message, this.data);

  factory CountryModel.fromJsom(dynamic json) {
    CountryModelData d = CountryModelData.fromJson(json['data']);
    return CountryModel(json['status'], json['message'], d);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class CountryModelData {
  dynamic country_code;

  CountryModelData(this.country_code);

  factory CountryModelData.fromJson(dynamic json) {
    return CountryModelData(json['country_code']);
  }

  @override
  String toString() {
    return '{countryCode: $country_code}';
  }
}
