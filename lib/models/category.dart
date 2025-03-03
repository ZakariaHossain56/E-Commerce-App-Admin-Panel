class Category {
  String? sId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;

  Category({this.sId, this.name, this.image, this.createdAt, this.updatedAt});

//A factory constructor used to create a Category object from a JSON map.
  Category.fromJson(Map<String, dynamic> json) {  
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

//method to convert a Category object back into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}