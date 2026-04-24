class DriverData {
  String? added_by;
  String? boy_city;
  String? boy_loc;
  String? boy_name;
  String? boy_phone;
  int? country_code;
  String? current_lat;
  String? current_lng;
  int? dboy_id;
  String? device_id;
  String? id_name;
  String? id_no;
  String? id_photo;
  String? image;
  String? lat;
  String? lng;
  String? password;
  int? prefix_code;
  int? status;
  int? store_dboy_id;
  int? store_id;

  DriverData(
      {this.added_by,
      this.boy_city,
      this.boy_loc,
      this.boy_name,
      this.boy_phone,
      this.country_code,
      this.current_lat,
      this.current_lng,
      this.dboy_id,
      this.device_id,
      this.id_name,
      this.id_no,
      this.id_photo,
      this.image,
      this.lat,
      this.lng,
      this.password,
      this.prefix_code,
      this.status,
      this.store_dboy_id,
      this.store_id});

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      added_by: json['added_by'],
      boy_city: json['boy_city'],
      boy_loc: json['boy_loc'],
      boy_name: json['boy_name'],
      boy_phone: json['boy_phone'],
      country_code: int.parse(json['country_code']),
      current_lat: json['current_lat'],
      current_lng: json['current_lng'],
      dboy_id: json['dboy_id'],
      device_id: json['device_id'],
      id_name: json['id_name'],
      id_no: json['id_no'],
      id_photo: json['id_photo'],
      image: json['image'],
      lat: json['lat'],
      lng: json['lng'],
      password: json['password'],
      prefix_code: int.parse(json['prefix_code']),
      status: json['status'],
      store_dboy_id: json['store_dboy_id'],
      store_id: json['store_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['added_by'] = this.added_by;
    data['boy_city'] = this.boy_city;
    data['boy_loc'] = this.boy_loc;
    data['boy_name'] = this.boy_name;
    data['boy_phone'] = this.boy_phone;
    data['country_code'] = this.country_code;
    data['dboy_id'] = this.dboy_id;
    data['device_id'] = this.device_id;
    data['id_name'] = this.id_name;
    data['id_no'] = this.id_no;
    data['id_photo'] = this.id_photo;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['password'] = this.password;
    data['prefix_code'] = this.prefix_code;
    data['status'] = this.status;
    data['store_dboy_id'] = this.store_dboy_id;
    data['store_id'] = this.store_id;
    if (this.current_lat != null) {
      data['current_lat'] = this.current_lat;
    }
    if (this.current_lng != null) {
      data['current_lng'] = this.current_lng;
    }
    if (this.image != null) {
      data['image'] = this.image;
    }
    print("G1--->${data['boy_phone']}");
    return data;
  }
}
