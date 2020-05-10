class Topic {
  final String name;
  final String displayName;
  final bool subscribed;

  Topic(this.name, this.displayName, this.subscribed);

  Topic.fromJSON(Map<String, dynamic> json)
      : name = json['name'],
        displayName = json['displayName'],
        subscribed = json['subscribed'];
}
