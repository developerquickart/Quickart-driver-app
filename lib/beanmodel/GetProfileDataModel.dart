import 'package:driver/beanmodel/DriverData.dart';

class GetProfileDataModel {
  String? bank_details;
  DriverData? driverData;
  String? message;
  int? received_incentive;
  int? remaining_incentive;
  String? status;
  int? total_incentive;

  GetProfileDataModel(
      {this.bank_details,
      this.driverData,
      this.message,
      this.received_incentive,
      this.remaining_incentive,
      this.status,
      this.total_incentive});

  factory GetProfileDataModel.fromJson(Map<String, dynamic> json) {
    return GetProfileDataModel(
      bank_details: json['bank_details'],
      driverData: json['driver_data'] != null
          ? DriverData.fromJson(json['driver_data'])
          : null,
      message: json['message'],
      // received_incentive: json['received_incentive'],
      // remaining_incentive: json['remaining_incentive'],
      status: json['status'],
      // total_incentive: json['total_incentive'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['received_incentive'] = this.received_incentive;
    data['remaining_incentive'] = this.remaining_incentive;
    data['status'] = this.status;
    data['total_incentive'] = this.total_incentive;
    if (this.bank_details != null) {
      data['bank_details'] = this.bank_details;
    }
    if (this.driverData != null) {
      data['driver_data'] = this.driverData!.toJson();
    }
    return data;
  }
}
