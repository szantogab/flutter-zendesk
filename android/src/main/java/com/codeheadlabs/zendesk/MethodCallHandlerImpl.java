package com.codeheadlabs.zendesk;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.zendesk.service.ErrorResponse;
import com.zendesk.service.ZendeskCallback;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import zendesk.chat.*;
import zendesk.chat.VisitorInfo.Builder;
import zendesk.messaging.MessagingActivity;

public class MethodCallHandlerImpl implements MethodCallHandler {

  public MethodCallHandlerImpl(Context context) {
    this.context = context;
  }

  private final Context context;

  @Nullable
  private Activity activity;

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "init":
        handleInit(call, result);
        break;
      case "setVisitorInfo":
        handleSetVisitorInfo(call, result);
        break;
      case "startChat":
        handleStartChat(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleInit(MethodCall call, final Result result) {
    Chat.INSTANCE.init(context, (String) call.argument("accountKey"));
    ChatProvider chatProvider = Chat.INSTANCE.providers().chatProvider();
    if (call.hasArgument("department")) {
      chatProvider.setDepartment((String) call.argument("department"), null);
    }

    if (call.hasArgument("appName")) {
      //zopimConfig.visitorPathOne((String) call.argument("appName"));
    }

    result.success(true);
  }

  private void handleSetVisitorInfo(MethodCall call, final Result result) {
    ProfileProvider profileProvider = Chat.INSTANCE.providers().profileProvider();

    Builder builder = VisitorInfo.builder();
    if (call.hasArgument("name")) {
      builder = builder.withName((String) call.argument("name"));
    }
    if (call.hasArgument("email")) {
      builder = builder.withEmail((String) call.argument("email"));
    }
    if (call.hasArgument("phoneNumber")) {
      builder = builder.withPhoneNumber((String) call.argument("phoneNumber"));
    }

    profileProvider.setVisitorInfo(builder.build(), new ZendeskCallback<Void>() {
      @Override
      public void onSuccess(Void aVoid) {
        result.success(null);
      }

      @Override
      public void onError(ErrorResponse errorResponse) {
        result.error(errorResponse.getReason(), errorResponse.getResponseBody(), null);
      }
    });
  }

  private void handleStartChat(MethodCall call, Result result) {
    //if (activity != null) {
      MessagingActivity.builder().withEngines(ChatEngine.engine()).show(context);
    //}

    result.success(true);
  }
}
