class CancellationReasons {
  String? status;
  String? message;
  List<CancelReason>? cancelReason;

  CancellationReasons({this.status, this.message, this.cancelReason});

  CancellationReasons.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['cancel_reason'] != null) {
      cancelReason = <CancelReason>[];
      json['cancel_reason'].forEach((v) {
        cancelReason!.add(new CancelReason.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.cancelReason != null) {
      data['cancel_reason'] =
          this.cancelReason!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CancelReason {
  int? resId;
  String? reason;

  CancelReason({this.resId, this.reason});

  CancelReason.fromJson(Map<String, dynamic> json) {
    resId = json['res_id'];
    reason = json['reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['res_id'] = this.resId;
    data['reason'] = this.reason;
    return data;
  }
}