package com.codeheadlabs.zendesk;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
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

    private MethodCallHandlerImpl methodCallHandler;
    private ChatStateStreamHandler chatStateStreamHandler;

    public ZendeskPlugin() {
    }

    public static void registerWith(Registrar registrar) {
        ZendeskPlugin plugin = new ZendeskPlugin();
        plugin.startListening(registrar.messenger(), registrar.context(), registrar.activity());
    }

    private void startListening(BinaryMessenger messenger, Context context, Activity activity) {
        channel = new MethodChannel(messenger, "com.codeheadlabs.zendesk");
        chatStateEventChannel = new EventChannel(messenger, "com.codeheadlabs.zendesk_chatStateChannel");

        methodCallHandler = new MethodCallHandlerImpl(context);
        methodCallHandler.setActivity(activity);

        chatStateStreamHandler = new ChatStateStreamHandler();

        chatStateEventChannel.setStreamHandler(chatStateStreamHandler);
        channel.setMethodCallHandler(methodCallHandler);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        startListening(binding.getBinaryMessenger(), binding.getApplicationContext(), null);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        methodCallHandler.setActivity(binding.getActivity());
        channel.setMethodCallHandler(methodCallHandler);
        chatStateEventChannel.setStreamHandler(chatStateStreamHandler);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        methodCallHandler.setActivity(null);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        methodCallHandler.setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivity() {
        methodCallHandler.setActivity(null);
        channel.setMethodCallHandler(null);
        chatStateEventChannel.setStreamHandler(null);
    }
}
