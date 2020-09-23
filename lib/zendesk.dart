import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'chat_state.dart';

class Zendesk {
  static const MethodChannel _channel = const MethodChannel('com.codeheadlabs.zendesk');
  static const EventChannel _chatStateEventChannel = const EventChannel('com.codeheadlabs.zendesk_chatStateChannel');

  Future<void> init(String accountKey, {String department, String appName}) async {
    await _channel.invokeMethod<void>('init', <String, String>{'accountKey': accountKey, 'department': department, 'appName': appName});
  }

  Stream<ChatState> observeChatState() => _chatStateEventChannel.receiveBroadcastStream().map((e) => ChatState.fromMap(e));

  Future<void> setVisitorInfo({String name, String email, String phoneNumber, String department}) async {
    await _channel.invokeMethod<void>('setVisitorInfo', <String, String>{'name': name, 'email': email, 'phoneNumber': phoneNumber, 'department': department});
  }

  Future<void> registerPushToken(String token) async {
    await _channel.invokeMethod<void>('registerPushToken', <String, String>{'token': token});
  }

  Future<void> unregisterPushToken() async {
    await _channel.invokeMethod<void>('unregisterPushToken');
  }

  Future<void> processPush(Map<String, String> remoteMessageData) async {
    await _channel.invokeMethod<void>('processPush', <String, Map<String, String>>{'remoteMessageData': remoteMessageData});
  }

  Future<String> appendNote(String note) async {
    return await _channel.invokeMethod<String>('appendNote', <String, String>{'note': note});
  }

  Future<String> setNote(String note) async {
    return await _channel.invokeMethod<String>('setNote', <String, String>{'note': note});
  }

  Future<List<String>> addTags(List<String> tags) async {
    return await _channel.invokeListMethod<String>('addTags', <String, dynamic>{'tags': tags});
  }

  Future<List<String>> removeTags(List<String> tags) async {
    return await _channel.invokeListMethod<String>('removeTags', <String, dynamic>{'tags': tags});
  }

  Future<void> startChat({
    bool isPreChatFormEnabled,
    bool isOfflineFormEnabled,
    bool isAgentAvailabilityEnabled,
    bool isChatTranscriptPromptEnabled,
    String messagingName,
    String iosBackButtonTitle,
    Color iosNavigationBarColor,
    Color iosNavigationTitleColor,
  }) async {
    await _channel.invokeMethod<void>('startChat', {
      'isPreChatFormEnabled': isPreChatFormEnabled,
      'isOfflineFormEnabled': isOfflineFormEnabled,
      'isAgentAvailabilityEnabled': isAgentAvailabilityEnabled,
      'isChatTranscriptPromptEnabled': isChatTranscriptPromptEnabled,
      'messagingName': messagingName,
      'iosBackButtonTitle': iosBackButtonTitle,
      'iosNavigationBarColor': iosNavigationBarColor?.value,
      'iosNavigationTitleColor': iosNavigationTitleColor?.value,
    });
  }
}
