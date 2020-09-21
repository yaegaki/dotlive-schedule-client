package jp.yaegaki.dotlive_schedule

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import androidx.annotation.NonNull
import com.google.android.gms.oss.licenses.OssLicensesMenuActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val LICENSE_CHANNEL = "jp.yaegaki.dotlive-schedule/license"
    private val WIDGET_CHANNEL = "jp.yaegaki.dotlive-schedule/widget"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LICENSE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showLicense") {
                val intent = Intent(this, OssLicensesMenuActivity::class.java)
                startActivity(intent)
                result.success(0)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "forceUpdateWidgets") {
                val intent = Intent(this, AwaiSenseiWidget::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    val ids = AppWidgetManager.getInstance(application)
                            .getAppWidgetIds(ComponentName(application, AwaiSenseiWidget::class.java))
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }

                sendBroadcast(intent)
                result.success(0)
            } else {
                result.notImplemented()
            }
        }
    }
}