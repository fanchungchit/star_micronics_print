package com.bridges.star_micronics_print

import android.content.Context
import android.graphics.*
import android.os.Build
import android.os.Environment
import android.text.StaticLayout
import android.text.TextPaint
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
import java.io.File
import java.io.OutputStream

/** StarMicronicsPrintPlugin */
class StarMicronicsPrintPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

//    private var manager: StarDeviceDiscoveryManager? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "star_micronics_print")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
//            "discovery" -> {
//                Log.d("THREAD", Thread.currentThread().name)
//
//                var resultPrinters: List<Map<String, Any>> = listOf()
//
//                runBlocking {
//                    val interfaceTypes: List<InterfaceType> =
//                        call.argument<List<String>>("interfaceTypes")!!
//                            .map { InterfaceType.valueOf(it) }
//
//                    val discoveryTime: Int = call.argument("discoveryTime")!!
//
//                    val printers = discovery(interfaceTypes, discoveryTime)
//
//                    resultPrinters = printers.map {
//                        mapOf(
//                            "identifier" to it.connectionSettings.identifier,
//                            "model" to it.information?.model.toString(),
//                            "interfaceType" to it.connectionSettings.interfaceType.toString()
//                        )
//                    }
//                }
//
//                return result.success(resultPrinters)
//            }
            "printBitmap" -> {
                val bytes: ByteArray = call.argument("bitmap")!!
                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                printBitmap(InterfaceType.Bluetooth, "00:11:62:18:DA:4E", bitmap)

                result.success("")
            }
            "printReceipt" -> {
                printReceipt(InterfaceType.Bluetooth, "00:11:62:18:DA:4E")
                result.success("")
            }
            "printPath" -> {
                val path: String = call.argument("path")!!
                val bitmap = BitmapFactory.decodeFile(path)
                printBitmap(InterfaceType.Bluetooth, "00:11:62:18:DA:4E", bitmap)

            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

//    private suspend fun discovery(
//        interfaceTypes: List<InterfaceType>,
//        discoveryTime: Int
//    ): List<StarPrinter> {
//        Log.d("StarMicronicsPrint", "Discovery start.")
//        return suspendCoroutine { continuation ->
//            try {
//                Log.d("THREAD", Thread.currentThread().name)
//                val printers = mutableListOf<StarPrinter>()
//
//                manager?.stopDiscovery()
//
//                manager = StarDeviceDiscoveryManagerFactory.create(interfaceTypes, context)
//
//                manager?.discoveryTime = discoveryTime
//
//                manager?.callback = object : StarDeviceDiscoveryManager.Callback {
//                    override fun onPrinterFound(printer: StarPrinter) {
//                        Log.d("StarMicronicsPrint", "Discovery printer found, $printer")
//                        printers += printer
//                    }
//
//                    override fun onDiscoveryFinished() {
//                        Log.d("StarMicronicsPrint", "Discovery finished.")
//                        continuation.resume(printers)
//                    }
//                }
//
//                manager?.startDiscovery()
//            } catch (e: Exception) {
//                Log.d("StarMicronicsPrint", "Discovery failed, ${e.message}")
//            }
//        }
//    }

    private fun printBitmap(interfaceType: InterfaceType, identifier: String, bitmap: Bitmap) {
        Log.d("StarMicronicsPrint", "PrintBitmap start.")

        val settings = StarConnectionSettings(interfaceType, identifier)

        val printer = StarPrinter(settings, context)

        val job = SupervisorJob()
        val scope = CoroutineScope(Dispatchers.Default + job)

        scope.launch {
            try {
                printer.openAsync().await()

                val builder = StarXpandCommandBuilder()
                builder.addDocument(createDocument(bitmap))
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

    private fun printReceipt(interfaceType: InterfaceType, identifier: String) {
        val bitmap = createReceipt()
        printBitmap(interfaceType, identifier, bitmap)
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

    private fun createReceipt(): Bitmap {
        val textToPrint = """
　 　　　  　　Star Micronics
----------------------------------------
              電子發票證明聯
              103年01-02月
              EV-99999999
2014/01/15 13:00
隨機碼 : 9999      總計 : 999
賣　方 : 99999999

商品退換請持本聯及銷貨明細表。
9999999-9999999 999999-999999 9999


         銷貨明細表 　(銷售)
                    2014-01-15 13:00:02

烏龍袋茶2g20入　         55 x2    110TX
茉莉烏龍茶2g20入         55 x2    110TX
天仁觀音茶2g*20　        55 x2    110TX
     小　　計 :　　        330
     總　　計 :　　        330
---------------------------------------
現　金　　　               400
     找　　零 :　　         70
 101 發票金額 :　　        330
2014-01-15 13:00

商品退換、贈品及停車兌換請持本聯。
9999999-9999999 999999-999999 9999
"""

        val paint = Paint()
        val bitmap: Bitmap

        val textSize = 24
        val printWidth = 576
        val typeface = Typeface.create(Typeface.MONOSPACE, Typeface.NORMAL)

        paint.textSize = textSize.toFloat()
        paint.typeface = typeface

        paint.getTextBounds(textToPrint, 0, textToPrint.length, Rect())

        val textPaint = TextPaint(paint)

        val layout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            StaticLayout.Builder.obtain(textToPrint, 0, textToPrint.length, textPaint, printWidth)
                .build()
        } else {
            TODO("VERSION.SDK_INT < M")
        }

//        val staticLayout = StaticLayout(
//            textToPrint, textPaint, printWidth, Layout.Alignment.ALIGN_NORMAL,
//            1F, 0F, false
//        )

        bitmap =
            Bitmap.createBitmap(layout.width, layout.height, Bitmap.Config.ARGB_8888)

        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)
        canvas.translate(0F, 0F)
        layout.draw(canvas)

        return bitmap
    }
}


