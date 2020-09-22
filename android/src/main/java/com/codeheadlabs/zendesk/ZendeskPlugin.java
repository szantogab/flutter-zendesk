package com.codeheadlabs.zendesk;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ZendeskPlugin
 */
public class ZendeskPlugin implements FlutterPlugin, ActivityAware {

  private MethodChannel channel;
  private MethodCallHandlerImpl methodCallHandler;

  public ZendeskPlugin() {
  }

  public static void registerWith(Registrar registrar) {
    ZendeskPlugin plugin = new ZendeskPlugin();
    plugin.channel = new MethodChannel(registrar.messenger(), "com.codeheadlabs.zendesk");
    plugin.methodCallHandler = new MethodCallHandlerImpl(registrar.context());
    plugin.methodCallHandler.setActivity(registrar.activity());
    plugin.channel.setMethodCallHandler(plugin.methodCallHandler);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), "com.codeheadlabs.zendesk");
    methodCallHandler = new MethodCallHandlerImpl(binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    methodCallHandler.setActivity(binding.getActivity());
    channel.setMethodCallHandler(methodCallHandler);
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
  }
}
