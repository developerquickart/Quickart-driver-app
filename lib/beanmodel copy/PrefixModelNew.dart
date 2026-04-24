import 'package:driver/beanmodel/PrefixCodeList.dart';

class PrefixModelNew {
    List<PrefixCodeList>? data;
    String? message;
    String? status;

    PrefixModelNew({this.data, this.message, this.status});

    factory PrefixModelNew.fromJson(Map<String, dynamic> json) {
        return PrefixModelNew(
            data: json['data'] != null ? (json['data'] as List).map((i) => PrefixCodeList.fromJson(i)).toList() : null,
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