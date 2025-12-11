class PendingFriendRequest {
  final String friendshipId;
  final String senderId;
  final String senderUsername;
  final String senderEmail;

  PendingFriendRequest({
    required this.friendshipId,
    required this.senderId,
    required this.senderUsername,
    required this.senderEmail,
  });

  factory PendingFriendRequest.fromJson(Map<String, dynamic> json) {
    return PendingFriendRequest(
      friendshipId: json['friendshipId'] as String,
      senderId: json['senderId'] as String,
      senderUsername: json['senderUsername'] as String,
      senderEmail: json['senderEmail'] as String,
    );
  }
}