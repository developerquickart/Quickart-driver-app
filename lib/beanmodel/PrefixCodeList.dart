class PrefixCodeList {
    int? prefix_code;

    PrefixCodeList({this.prefix_code});

    factory PrefixCodeList.fromJson(Map<String, dynamic> json) {
        return PrefixCodeList(
            prefix_code: json['prefix_code'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['prefix_code'] = this.prefix_code;
        return data;
    }
}