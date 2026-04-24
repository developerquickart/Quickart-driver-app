import 'CountryCodeList.dart';

class CountryModelNew {
    List<CountryCodeList>? data;
    String? message;
    String? status;

    CountryModelNew({this.data, this.message, this.status});

    factory CountryModelNew.fromJson(Map<String, dynamic> json) {
        return CountryModelNew(
            data: json['data'] != null ? (json['data'] as List).map((i) => CountryCodeList.fromJson(i)).toList() : null,
            message: json['message'],
            status: json['status'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['message'] = this.message;
        data['status'] = this.status;
        if (this.data != null) {
            data['data'] = this.data!.map((v) => v.toJson()).toList();
        }
        return data;
    }
}