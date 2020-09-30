package com.codeheadlabs.zendesk;

import android.util.Log;
import io.flutter.plugin.common.EventChannel;
import zendesk.chat.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AccountStateStreamHandler implements EventChannel.StreamHandler {
    private ObservationScope scope;

    @Override
    public void onListen(Object arguments, final EventChannel.EventSink events) {
        final AccountProvider accountProvider = Chat.INSTANCE.providers().accountProvider();
        scope = new ObservationScope();
        accountProvider.observeAccount(scope, new Observer<Account>() {
            @Override
            public void update(Account accountState) {
                Log.d("Zendesk", "Updated accountState");
                events.success(accountStateToMap(accountState));
            }
        });
    }

    @Override
    public void onCancel(Object arguments) {
    //    if (scope != null && !scope.isCancelled()) scope.cancel();
        Log.d("Zendesk", "AccountState cancel observation.");
    }

    private static Map<String, Object> accountStateToMap(Account accountState) {
        final HashMap<String, Object> map = new HashMap<>();
        map.put("online", accountState.getStatus() == AccountStatus.ONLINE);

        final List<HashMap<String, Object>> departments = new ArrayList<>();
        for (Department department : accountState.getDepartments()) {
            final HashMap<String, Object> departmentMap = new HashMap<>();
            departmentMap.put("id", Long.toString(department.getId()));
            departmentMap.put("name", department.getName());
            departmentMap.put("status", departmentStatusToString(department.getStatus()));
            departments.add(departmentMap);
        }

        map.put("departments", departments);

        return map;
    }

    private static String departmentStatusToString(DepartmentStatus departmentStatus) {
        if (departmentStatus == DepartmentStatus.OFFLINE) return "Offline";
        if (departmentStatus == DepartmentStatus.ONLINE) return "Online";
        return null;
    }
}
