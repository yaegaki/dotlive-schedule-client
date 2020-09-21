package jp.yaegaki.dotlive_schedule

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import androidx.work.*
import com.github.kittinunf.fuel.Fuel
import com.squareup.picasso.NetworkPolicy
import com.github.kittinunf.result.Result as FuelResult
import com.squareup.picasso.Picasso
import org.json.JSONObject
import java.util.*
import java.util.concurrent.TimeUnit

data class ScheduleInfo(val tweetId: String, val title: String, val imageURL: String, val image: Bitmap)

const val WorkTagName = "fetch_awaisensei"
const val SharedPreferencesName = "ScheduleInfoCaches"

class MyWorker(context: Context, params: WorkerParameters) : Worker(context, params)  {
    override fun doWork(): Result {
        val views = RemoteViews(applicationContext.packageName, R.layout.awai_sensei_widget)
        val info = getScheduleInfo(applicationContext)
        if (info != null) {
            views.setTextViewText(R.id.appwidget_text, info.title)
            views.setImageViewBitmap(R.id.imageView, info.image)
            views.setViewVisibility(R.id.imageView, View.VISIBLE)
            views.setViewVisibility(R.id.reloadButton, View.GONE)

            val pendingIntent = Intent(applicationContext, MainActivity::class.java).let {
                PendingIntent.getActivity(applicationContext, 0, it, 0)
            }
            views.setOnClickPendingIntent(R.id.imageView, pendingIntent)
        } else {
            views.setTextViewText(R.id.appwidget_text, "読み込みに失敗しました")
            views.setViewVisibility(R.id.imageView, View.GONE)
            views.setViewVisibility(R.id.reloadButton, View.VISIBLE)

            val intent = Intent(applicationContext, AwaiSenseiWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                val ids = AppWidgetManager.getInstance(applicationContext)
                        .getAppWidgetIds(ComponentName(applicationContext, AwaiSenseiWidget::class.java))
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            val pendingIntent = PendingIntent.getBroadcast(applicationContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
            views.setOnClickPendingIntent(R.id.reloadButton, pendingIntent)
        }

        AppWidgetManager
                .getInstance(applicationContext)
                .updateAppWidget(ComponentName(applicationContext, AwaiSenseiWidget::class.java), views)

        return Result.success()
    }
}

/**
 * Implementation of App Widget functionality.
 */
class AwaiSenseiWidget : AppWidgetProvider() {
    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            initAppWidget(context, appWidgetManager, appWidgetId)
        }

        val req = PeriodicWorkRequestBuilder<MyWorker>(60, TimeUnit.MINUTES)
                .build()

        WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(WorkTagName, ExistingPeriodicWorkPolicy.REPLACE, req)
    }

    override fun onEnabled(context: Context) {
    }

    override fun onDisabled(context: Context) {
        WorkManager.getInstance(context).cancelUniqueWork(WorkTagName)
    }
}

internal fun getSharedPreferences(context: Context): SharedPreferences {
    return context.getSharedPreferences(SharedPreferencesName, Context.MODE_PRIVATE)
}

internal fun getScheduleInfo(context: Context): ScheduleInfo? {
    val pref = getSharedPreferences(context)
    try {
        val url = "https://dotlive-schedule.appspot.com/api/awaisensei"
        val (_, _, result) = Fuel.get(url).responseString()
        return when (result) {
            is FuelResult.Failure -> {
                getScheduleInfoCache(pref)
            }
            is FuelResult.Success -> {
                val obj = JSONObject(result.get())
                val tweetId = obj.getString("tweetId")
                val title = obj.getString("title")
                val imageURL = obj.getString("imageURL")
                val image = Picasso.get()
                        .load(imageURL)
                        .get()
                val info = ScheduleInfo(tweetId, title, imageURL, image)
                putScheduleInfoCache(pref, info)
                info
            }
        }
    }
    catch (t: Throwable)
    {
        return getScheduleInfoCache(pref)
    }
}

internal fun getScheduleInfoCache(pref: SharedPreferences): ScheduleInfo? {
    val tweetId = pref.getString("tweetId", null) ?: return null
    val title = pref.getString("title", null) ?: return null
    val imageURL = pref.getString("imageURL", null) ?: return null


    return try {
        val image = Picasso.get()
                .load(imageURL)
                .networkPolicy(NetworkPolicy.OFFLINE)
                .get()

        ScheduleInfo(tweetId, title, imageURL, image)
    }
    catch (t: Throwable) {
        null
    }
}

internal fun putScheduleInfoCache(pref: SharedPreferences, info: ScheduleInfo) {
    pref.edit()
            .putString("tweetId", info.tweetId)
            .putString("title", info.title)
            .putString("imageURL", info.imageURL)
            .apply()
}

internal fun initAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.awai_sensei_widget)
    views.setTextViewText(R.id.appwidget_text, "読み込み中")
    views.setViewVisibility(R.id.reloadButton, View.GONE)
    appWidgetManager.updateAppWidget(appWidgetId, views)
}