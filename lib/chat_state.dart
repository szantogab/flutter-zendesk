class ChatState {
  final String chatId;
  final String chatComment;
  final String chatSessionStatus;
  final String chatRating;
  final bool isChatting;
  final int queuePosition;
  final List<Agent> agents;

  const ChatState(this.chatId, this.chatComment, this.chatSessionStatus, this.chatRating, this.isChatting, this.queuePosition, this.agents);

  factory ChatState.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) return null;
    final agentMapList = map["agents"] as List<dynamic>;
    return ChatState(map["chatId"], map["chatComment"], map["chatSessionStatus"], map["chatRating"], map["isChatting"], map["queuePosition"], agentMapList.map((a) => Agent.fromMap(a as Map<dynamic, dynamic>)));
  }
}

class Agent {
  final String avatarPath;
  final String displayName;
  final String nick;
  final bool isTyping;

  const Agent(this.avatarPath, this.displayName, this.nick, this.isTyping);

  factory Agent.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) return null;
    return Agent(map["avatarPath"], map["displayName"], map["nick"], map["isTyping"]);
  }
}
