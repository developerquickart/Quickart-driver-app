class CountryCodeList {
    int? country_code;

    CountryCodeList({this.country_code});

    factory CountryCodeList.fromJson(Map<String, dynamic> json) {
        return CountryCodeList(
            country_code: json['country_code'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['country_code'] = this.country_code;
        return data;
    }
}