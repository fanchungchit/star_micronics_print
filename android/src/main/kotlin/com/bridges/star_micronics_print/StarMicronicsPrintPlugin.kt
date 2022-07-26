package com.bridges.star_micronics_print

import android.content.Context
import android.graphics.*
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import com.starmicronics.stario10.*
import com.starmicronics.stario10.starxpandcommand.DocumentBuilder
import com.starmicronics.stario10.starxpandcommand.PrinterBuilder
import com.starmicronics.stario10.starxpandcommand.StarXpandCommandBuilder
import com.starmicronics.stario10.starxpandcommand.printer.CutType
import com.starmicronics.stario10.starxpandcommand.printer.ImageParameter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

/** StarMicronicsPrintPlugin */
class StarMicronicsPrintPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "star_micronics_print")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "printBitmap" -> {
                val interfaceType = InterfaceType.valueOf(call.argument<String>("interfaceType")!!)
                val identifier = call.argument<String>("identifier")!!
                val bytes = call.argument<ByteArray>("bitmap")!!
                val copies = call.argument<Int>("copies")!!

                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                printBitmap(interfaceType, identifier, bitmap, copies)

                result.success("")
            }
            "printPath" -> {
                val interfaceType = InterfaceType.valueOf(call.argument<String>("interfaceType")!!)
                val identifier = call.argument<String>("identifier")!!
                val path = call.argument<String>("path")!!
                val copies = call.argument<Int>("copies")!!

                val bytes = BitmapFactory.decodeFile(path)
                printBitmap(interfaceType, identifier, bytes, copies)
                result.success("")
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun printBitmap(
        interfaceType: InterfaceType,
        identifier: String,
        bitmap: Bitmap,
        copies: Int
    ) {
        Log.d("StarMicronicsPrint", "PrintBitmap start.")

        val settings = StarConnectionSettings(interfaceType, identifier)

        val printer = StarPrinter(settings, context)

        val job = SupervisorJob()
        val scope = CoroutineScope(Dispatchers.Default + job)

        scope.launch {
            try {
                printer.openAsync().await()

                val builder = StarXpandCommandBuilder()

                for (i in 1..copies) {
                    builder.addDocument(createDocument(bitmap))
                }
                val commands = builder.getCommands()

                printer.printAsync(commands).await()
            } catch (e: Exception) {
                Log.d("StarMicronicsPrint", "PrintBitmap failed, ${e.message}")
            } finally {
                printer.closeAsync().await()
            }
        }

        Log.d("StarMicronicsPrint", "PrintBitmap finished.")
    }

    private fun createDocument(bitmap: Bitmap): DocumentBuilder {
        val imageWidth = 576

        return DocumentBuilder()
            .addPrinter(
                PrinterBuilder()
                    .actionPrintImage(ImageParameter(bitmap, imageWidth))
                    .actionCut(CutType.Partial)
            )
    }
}


