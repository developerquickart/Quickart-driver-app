import 'package:driver/baseurl/baseurlg.dart';

class OrderHistory {
  dynamic cartId;
  dynamic paymentMethod;
  dynamic paymentStatus;
  dynamic userAddress;
  dynamic building_villa;
  dynamic orderStatus;
  dynamic storeName;
  dynamic storeLat;
  dynamic storeLng;
  dynamic storeAddress;
  dynamic userLat;
  dynamic userLng;
  dynamic dboyLat;
  dynamic dboyLng;
  dynamic userName;
  dynamic userPhone;
  double? remainingPrice;
  dynamic deliveryBoyName;
  dynamic deliveryBoyPhone;
  dynamic deliveryDate;
  dynamic timeSlot;
  dynamic totalItems;
  dynamic subsciption_id;
  dynamic delivery_unique_code;
  dynamic del_partner_instruction;
  dynamic cancel_reason;
  dynamic doorImage;
  dynamic specialInstruction;

  List<ItemsDetails>? items;
  dynamic orderDetails;
  bool? isChecked;

  OrderHistory(
      {this.cartId,
      this.paymentMethod,
      this.paymentStatus,
      this.userAddress,
      this.orderStatus,
      this.storeName,
      this.storeLat,
      this.storeLng,
      this.storeAddress,
      this.userLat,
      this.userLng,
      this.dboyLat,
      this.dboyLng,
      this.userName,
      this.userPhone,
      this.remainingPrice,
      this.deliveryBoyName,
      this.deliveryBoyPhone,
      this.deliveryDate,
      this.timeSlot,
      this.totalItems,
      this.items,
      this.subsciption_id,
      this.orderDetails,
      this.isChecked,
      this.delivery_unique_code,
      this.building_villa,
      this.del_partner_instruction,
      this.cancel_reason,
      this.doorImage,
      this.specialInstruction});

  OrderHistory.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    userAddress = json['user_address'];
    orderStatus = '${json['order_status']}'.replaceAll('_', ' ');
    storeName = json['store_name'];
    storeLat = json['store_lat'];
    storeLng = json['store_lng'];
    storeAddress = json['store_address'];
    userLat = json['user_lat'];
    userLng = json['user_lng'];
    dboyLat = json['dboy_lat'];
    dboyLng = json['dboy_lng'];
    userName = json['user_name'];
    userPhone = json['user_phone'];
    delivery_unique_code = json['delivery_unique_code'];
    del_partner_instruction = json['del_partner_instruction'];
    cancel_reason = json['cancel_reason'];

    isChecked = false;
    remainingPrice =
        json['remaining_price'] != null && json['remaining_price'] != ''
            ? double.parse('${json['remaining_price']}')
            : 0;
    deliveryBoyName = json['delivery_boy_name'];
    deliveryBoyPhone = json['delivery_boy_phone'];
    deliveryDate = json['delivery_date'];
    timeSlot = json['time_slot'];
    subsciption_id = json['subsciption_id'];

    totalItems = json['total_items'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(new ItemsDetails.fromJson(v));
      });
    }
    orderDetails = json['order_details'] != null ? json['order_details'] : null;
    building_villa =
        json["building_villa"] != null ? json["building_villa"] : "";
    doorImage = json['doorimage'];
    specialInstruction = json['special_instruction'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cart_id'] = this.cartId;
    data['payment_method'] = this.paymentMethod;
    data['payment_status'] = this.paymentStatus;
    data['user_address'] = this.userAddress;
    data['order_status'] = this.orderStatus;
    data['store_name'] = this.storeName;
    data['store_lat'] = this.storeLat;
    data['store_lng'] = this.storeLng;
    data['store_address'] = this.storeAddress;
    data['user_lat'] = this.userLat;
    data['user_lng'] = this.userLng;
    data['dboy_lat'] = this.dboyLat;
    data['dboy_lng'] = this.dboyLng;
    data['user_name'] = this.userName;
    data['user_phone'] = this.userPhone;
    data['remaining_price'] = this.remainingPrice;
    data['delivery_boy_name'] = this.deliveryBoyName;
    data['delivery_boy_phone'] = this.deliveryBoyPhone;
    data['delivery_date'] = this.deliveryDate;
    data['time_slot'] = this.timeSlot;
    data['subsciption_id'] = this.subsciption_id;
    data['delivery_unique_code'] = this.delivery_unique_code;
    data['del_partner_instruction'] = this.del_partner_instruction;
    data['building_villa'] = this.building_villa;
    data['cancel_reason'] = this.cancel_reason;
    data['doorimage'] = this.doorImage;
    data['special_instruction'] = this.specialInstruction;

    data['total_items'] = this.totalItems;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemsDetails {
  dynamic storeOrderId;
  dynamic productName;
  dynamic varientImage;
  dynamic quantity;
  dynamic unit;
  dynamic varientId;
  dynamic qty;
  dynamic totalMrp;
  dynamic orderCartId;
  dynamic orderDate;
  dynamic storeApproval;
  dynamic storeId;
  dynamic description;
  double? price;
  dynamic payment_method;
  bool? isChecked;

  ItemsDetails(
      {this.storeOrderId,
      this.productName,
      this.varientImage,
      this.quantity,
      this.unit,
      this.varientId,
      this.qty,
      this.price,
      this.totalMrp,
      this.orderCartId,
      this.orderDate,
      this.storeApproval,
      this.storeId,
      this.description,
      this.payment_method,
      this.isChecked});

  ItemsDetails.fromJson(Map<String, dynamic> json) {
    storeOrderId = json['store_order_id'];
    productName = json['product_name'];
    // varientImage = '$imagebaseUrl1${json['varient_image']}';
    varientImage = '${json['varient_image']}';
    quantity = json['quantity'];
    unit = json['unit'];
    varientId = json['varient_id'];
    qty = json['qty'];
    price = json['price'] != null && json['price'] != ''
        ? double.parse(json['price'].toString())
        : 0;
    totalMrp = json['total_mrp'];
    orderCartId = json['order_cart_id'];
    orderDate = json['order_date'];
    storeApproval = json['store_approval'];
    storeId = json['store_id'];
    description = json['description'];
    payment_method = json['payment_method'];
    isChecked = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['store_order_id'] = this.storeOrderId;
    data['product_name'] = this.productName;
    data['varient_image'] = this.varientImage;
    data['quantity'] = this.quantity;
    data['unit'] = this.unit;
    data['varient_id'] = this.varientId;
    data['qty'] = this.qty;
    data['price'] = this.price;
    data['total_mrp'] = this.totalMrp;
    data['order_cart_id'] = this.orderCartId;
    data['order_date'] = this.orderDate;
    data['store_approval'] = this.storeApproval;
    data['store_id'] = this.storeId;
    data['description'] = this.description;
    data['payment_method'] = this.payment_method;
    return data;
  }
}
