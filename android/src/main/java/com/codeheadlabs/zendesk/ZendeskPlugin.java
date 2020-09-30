package com.codeheadlabs.zendesk;

import android.app.Activity;
import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ZendeskPlugin
 */
public class ZendeskPlugin implements FlutterPlugin, ActivityAware {
    private MethodChannel channel;
    private EventChannel chatStateEventChannel;
    private EventChannel accountStateEventChannel;

    private MethodCallHandlerImpl methodCallHandler;
    private ChatStateStreamHandler chatStateStreamHandler;

    private AccountStateStreamHandler accountStateStreamHandler;

    public ZendeskPlugin() {
    }

    public static void registerWith(Registrar registrar) {
        ZendeskPlugin plugin = new ZendeskPlugin();
        plugin.startListening(registrar.messenger(), registrar.context(), registrar.activity());
    }

    private void startListening(BinaryMessenger messenger, Context context, Activity activity) {
        channel = new MethodChannel(messenger, "com.codeheadlabs.zendesk");
        chatStateEventChannel = new EventChannel(messenger, "com.codeheadlabs.zendesk_chatStateChannel");
        accountStateEventChannel = new EventChannel(messenger, "com.codeheadlabs.zendesk_accountStateChannel");

        methodCallHandler = new MethodCallHandlerImpl(context);
        methodCallHandler.setActivity(activity);

        chatStateStreamHandler = new ChatStateStreamHandler();
        accountStateStreamHandler = new AccountStateStreamHandler();

        chatStateEventChannel.setStreamHandler(chatStateStreamHandler);
        accountStateEventChannel.setStreamHandler(accountStateStreamHandler);
        channel.setMethodCallHandler(methodCallHandler);
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        startListening(binding.getBinaryMessenger(), binding.getApplicationContext(), null);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        channel = null;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        methodCallHandler.setActivity(binding.getActivity());
        channel.setMethodCallHandler(methodCallHandler);
        chatStateEventChannel.setStreamHandler(chatStateStreamHandler);
        accountStateEventChannel.setStreamHandler(accountStateStreamHandler);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        methodCallHandler.setActivity(null);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        methodCallHandler.setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivity() {
        methodCallHandler.setActivity(null);
        channel.setMethodCallHandler(null);
        chatStateEventChannel.setStreamHandler(null);
        accountStateEventChannel.setStreamHandler(null);
    }
}
