---
title: "Android BLE"
date: 2024-09-18T13:20:37+08:00
draft: true
tags: ["Android","BLE"]
categories: ["Android"]
---

[Android BLE](https://developer.android.com/develop/connectivity/bluetooth/ble/ble-overview?hl=zh-cn)

<!--more-->

## 写在开头

角色:中心设备(如手机,平板)作为客户端,外围设备(如手环,手表)作为服务端
流程:申请权限,判断是否支持ble,打开蓝牙,扫描设备(得到外围设备uuid),通过connectGatt连接,用discoverServices发现服务,从gatt服务拿到特征去读或者写(读写有回调),关闭连接

### 服务端
外围设备侧通常包含两块能力：广播(Advertising) + GATT Server。手机也能当外围设备，但很多设备/ROM会限制后台广播与连接数量，实际更多见的是手环/传感器当服务端。

#### 1) 广播(Advertising)
- 目标：让中心设备扫描到你，并拿到用于过滤/识别的信息(服务 UUID、厂商数据、设备名等)
- 关键类：BluetoothLeAdvertiser / AdvertiseSettings / AdvertiseData / AdvertiseCallback
- 常见放法：
  - 在 AdvertiseData 里塞 Service UUID：方便客户端用 `setServiceUuid()` 直接过滤
  - 需要更强识别能力时用 Manufacturer Data(厂商数据)：放协议版本/产品型号/短标识等
- 注意点：
  - 广播包很小，字段会互相挤占；尽量只放“让人找到你”的最小信息
  - 广播间隔越低越耗电；连接型设备一般不需要一直高频广播

#### 2) GATT Server
- 目标：对外暴露 Service / Characteristic / Descriptor，让客户端来读、写、订阅通知
- 关键类：BluetoothGattServer / BluetoothGattServerCallback / BluetoothGattService / BluetoothGattCharacteristic / BluetoothGattDescriptor
- 搭建步骤：
  1. `BluetoothManager.openGattServer()` 创建 server，注册回调
  2. 创建 `BluetoothGattService`，添加 characteristic/descriptor，然后 `addService()`
  3. 等待客户端 connect -> discover services -> read/write/subscribe

#### 3) 回调与典型逻辑
- 连接：
  - `onConnectionStateChange(device, status, newState)`：管理连接列表、清理状态
- 服务添加：
  - `onServiceAdded(status, service)`：确认服务已注册成功再开始广播/对外服务
- 读请求：
  - `onCharacteristicReadRequest(...)`：取出当前值，调用 `sendResponse()`
- 写请求：
  - `onCharacteristicWriteRequest(...)`：校验/解析入参，更新内部状态；需要响应时 `sendResponse()`
- 订阅通知：
  - `onDescriptorWriteRequest(...)`：通常处理 CCCD(0x2902)，记录该 device 是否订阅
  - 主动推送：`notifyCharacteristicChanged(device, characteristic, confirm)` 通知客户端

#### 4) 特征与描述符设计建议
- 写入型特征：
  - 如果写入数据可能被分包，定义明确的应用层 framing(长度/序号/校验)
  - 区分 Write With Response / Write Without Response 的语义(可靠性 vs 吞吐)
- 通知型特征：
  - 通知频率与 payload 直接决定耗电与链路占用，尽量“事件驱动”
  - 客户端订阅成功后再开始推送；断开/取消订阅要停止推送
- 描述符：
  - 客户端订阅通知时写 CCCD 是常规流程；服务端要正确处理并维护订阅状态

#### 5) 权限与版本差异(服务端侧)
- Android 12+：一般需要 `BLUETOOTH_ADVERTISE` 才能广播；连接/通信需要 `BLUETOOTH_CONNECT`
- Android 11 及以下：很多扫描/发现流程和定位权限绑定(更偏客户端侧)，但服务端发布广播通常仍需按系统要求声明权限
- 不同厂商对后台广播/长连接策略差异很大，建议把“持续广播/后台常驻”当成高风险点做降级策略

#### Demo：手机当外围设备(服务端)
下面 Demo 目标：A 手机开启广播 + GATT Server；B 手机作为客户端连接后，向 RX 写入字符串，A 手机把内容通过 TX 通知回传。

把这几段代码放进同一个 Android App 里即可运行(两台手机安装同一个 App，一台点 Peripheral，一台点 Central)。

**AndroidManifest.xml**

```xml
<manifest ...>
    <uses-feature
        android:name="android.hardware.bluetooth_le"
        android:required="true" />

    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />

    <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />

    <application ... />
</manifest>
```

**BleUuids.kt**

```kotlin
object BleUuids {
    val SERVICE_UUID: UUID = UUID.fromString("0000aaaa-0000-1000-8000-00805f9b34fb")
    val RX_UUID: UUID = UUID.fromString("0000aaab-0000-1000-8000-00805f9b34fb")
    val TX_UUID: UUID = UUID.fromString("0000aaac-0000-1000-8000-00805f9b34fb")
    val CCCD_UUID: UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")
}
```

**MainActivity.kt**

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val peripheral = Button(this).apply { text = "Peripheral" }
        val central = Button(this).apply { text = "Central" }

        peripheral.setOnClickListener { startActivity(Intent(this, PeripheralActivity::class.java)) }
        central.setOnClickListener { startActivity(Intent(this, CentralActivity::class.java)) }

        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                addView(peripheral)
                addView(central)
            }
        )
    }
}
```

**PeripheralActivity.kt**

```kotlin
class PeripheralActivity : AppCompatActivity() {
    private val permissionsRequestCode = 1001

    private val bluetoothManager by lazy { getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager }
    private val bluetoothAdapter by lazy { bluetoothManager.adapter }
    private val advertiser by lazy { bluetoothAdapter.bluetoothLeAdvertiser }

    private var gattServer: BluetoothGattServer? = null
    private var txCharacteristic: BluetoothGattCharacteristic? = null
    private val subscribedDevices = linkedSetOf<BluetoothDevice>()

    private lateinit var logView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val start = Button(this).apply { text = "Start" }
        val stop = Button(this).apply { text = "Stop" }
        logView = TextView(this)

        start.setOnClickListener { ensureReadyAndStart() }
        stop.setOnClickListener { stopAll() }

        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                addView(start)
                addView(stop)
                addView(logView)
            }
        )
    }

    private fun ensureReadyAndStart() {
        val missing = requiredPermissions().filter {
            ActivityCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, missing.toTypedArray(), permissionsRequestCode)
            return
        }
        if (!bluetoothAdapter.isEnabled) {
            startActivity(android.content.Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE))
            return
        }
        startAll()
    }

    private fun requiredPermissions(): List<String> {
        val list = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            list += Manifest.permission.BLUETOOTH_ADVERTISE
            list += Manifest.permission.BLUETOOTH_CONNECT
        } else {
            list += Manifest.permission.ACCESS_FINE_LOCATION
        }
        return list
    }

    @SuppressLint("MissingPermission")
    private fun startAll() {
        log("starting...")
        startGattServer()
        startAdvertising()
    }

    @SuppressLint("MissingPermission")
    private fun startGattServer() {
        val service = BluetoothGattService(BleUuids.SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)

        val rx = BluetoothGattCharacteristic(
            BleUuids.RX_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )

        val tx = BluetoothGattCharacteristic(
            BleUuids.TX_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        val cccd = BluetoothGattDescriptor(
            BleUuids.CCCD_UUID,
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
        )
        tx.addDescriptor(cccd)

        service.addCharacteristic(rx)
        service.addCharacteristic(tx)

        txCharacteristic = tx
        gattServer = bluetoothManager.openGattServer(this, gattServerCallback).also {
            it.addService(service)
        }
    }

    @SuppressLint("MissingPermission")
    private fun startAdvertising() {
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(ParcelUuid(BleUuids.SERVICE_UUID))
            .build()

        advertiser.startAdvertising(settings, data, advertiseCallback)
        log("advertising started")
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartFailure(errorCode: Int) {
            log("advertising failed: $errorCode")
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            log("conn: ${device.address}, status=$status, newState=$newState")
            if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                subscribedDevices.remove(device)
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            if (characteristic.uuid == BleUuids.RX_UUID) {
                val text = String(value, StandardCharsets.UTF_8)
                log("rx from ${device.address}: $text")
                notifyToAll("echo: $text")
            }

            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
            }
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            descriptor: BluetoothGattDescriptor,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            if (descriptor.uuid == BleUuids.CCCD_UUID) {
                val enabled = value.contentEquals(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE) ||
                    value.contentEquals(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE)
                if (enabled) subscribedDevices += device else subscribedDevices -= device
                log("cccd ${device.address}: enabled=$enabled")
            }

            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun notifyToAll(text: String) {
        val tx = txCharacteristic ?: return
        val bytes = text.toByteArray(StandardCharsets.UTF_8)
        tx.value = bytes
        val server = gattServer ?: return
        for (device in subscribedDevices) {
            server.notifyCharacteristicChanged(device, tx, false)
        }
    }

    @SuppressLint("MissingPermission")
    private fun stopAll() {
        runCatching { advertiser.stopAdvertising(advertiseCallback) }
        subscribedDevices.clear()
        gattServer?.close()
        gattServer = null
        txCharacteristic = null
        log("stopped")
    }

    private fun log(msg: String) {
        runOnUiThread { logView.append(msg + "\n") }
    }

    override fun onDestroy() {
        stopAll()
        super.onDestroy()
    }
}
```

### 客户端
中心设备侧一般是：扫描 -> 连接 GATT -> 发现服务 -> 读/写/订阅 -> 断开与资源释放。

#### 1) 扫描(Scanning)
- 关键类：BluetoothLeScanner / ScanSettings / ScanFilter / ScanCallback
- 过滤策略：
  - 优先用 Service UUID 过滤：更省电、更少误报
  - 或者用 Manufacturer Data 做二次识别：避免同类设备服务 UUID 相同
- 常见注意点：
  - 扫描是高耗电操作，尽量限定时长(比如 5~15s)并提供停止入口
  - Android 8+ 对后台扫描/频率有更严格限制，别指望后台一直扫

#### 2) 连接与发现服务
- 关键类：BluetoothDevice.connectGatt / BluetoothGatt / BluetoothGattCallback
- 典型顺序：
  1. `connectGatt(...)` 发起连接
  2. `onConnectionStateChange()` -> `BluetoothProfile.STATE_CONNECTED` 后调用 `discoverServices()`
  3. `onServicesDiscovered()` 拿到 service/characteristic，建立读写与订阅
- 常见细节：
  - 连接失败/`status != GATT_SUCCESS` 很常见，务必做重试与超时
  - `autoConnect` 行为在不同版本/厂商差异大，除非你明确需要“系统托管自动重连”，一般用 `false`

#### 3) 读/写/通知订阅
- 读：
  - 旧接口：`gatt.readCharacteristic(characteristic)` + `onCharacteristicRead()`
  - 新接口(Android 13+)：有更明确的重载写法；但工程里通常要兼容旧版本
- 写：
  - 写入前设置 `writeType`：`WRITE_TYPE_DEFAULT`(有响应) 或 `WRITE_TYPE_NO_RESPONSE`(无响应)
  - 写回调：`onCharacteristicWrite()`
- 订阅通知：
  1. `gatt.setCharacteristicNotification(characteristic, true)`
  2. 写 CCCD descriptor 值(0x2902)：enable notification/indication
  3. 服务端推送后，在 `onCharacteristicChanged()` 收到数据
- 顺序非常重要：只 `setCharacteristicNotification()` 不写 CCCD 通常收不到通知

#### 4) MTU、分包与吞吐
- `gatt.requestMtu(mtu)` 可以提高单包有效载荷(仍要考虑 ATT/协议开销)
- 大 payload 通常需要应用层分包协议(长度/序号/CRC)，不要假设一次 write/notify 就能发完
- 吞吐优化一般依赖：
  - 无响应写 + 合理节流
  - 更大的 MTU
  - 减少不必要的服务发现/频繁开关连接

#### 5) 资源释放与稳定性
- 断开流程建议：
  - `gatt.disconnect()` 后在合适时机 `gatt.close()` 释放资源
- 避免并发 GATT 操作：
  - 很多设备栈对“同时发多个 read/write/descriptor write”支持不好，建议串行化请求
- 兼容性经验：
  - 遇到“discoverServices 卡住 / 通知收不到 / 偶现 133”等问题，优先检查：权限、CCCD 写入是否成功、操作是否串行、是否有超时重试

#### 6) 权限与版本差异(客户端侧)
- Android 12+：
  - 扫描：`BLUETOOTH_SCAN`
  - 连接/读写：`BLUETOOTH_CONNECT`
  - 不再强依赖定位权限，但系统仍可能要求打开定位开关才能稳定扫描(取决于 ROM/场景)
- Android 11 及以下：
  - 扫描常需定位权限：`ACCESS_FINE_LOCATION`(以及定位开关)
  - 需要按系统策略处理运行时权限与用户解释

#### Demo：手机当中心设备(客户端)
运行方式：A 手机打开 PeripheralActivity 点 Start；B 手机打开 CentralActivity 点 Start Scan，然后点 Connect，最后点 Write 发送消息，订阅后会在日志里收到 `echo:` 通知。

**CentralActivity.kt**

```kotlin
class CentralActivity : AppCompatActivity() {
    private val permissionsRequestCode = 2001

    private val bluetoothManager by lazy { getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager }
    private val bluetoothAdapter by lazy { bluetoothManager.adapter }
    private val scanner by lazy { bluetoothAdapter.bluetoothLeScanner }

    private lateinit var logView: TextView
    private var lastDevice: BluetoothDevice? = null
    private var gatt: BluetoothGatt? = null

    private var rx: BluetoothGattCharacteristic? = null
    private var tx: BluetoothGattCharacteristic? = null
    private var cccd: BluetoothGattDescriptor? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val startScan = Button(this).apply { text = "Start Scan" }
        val stopScan = Button(this).apply { text = "Stop Scan" }
        val connect = Button(this).apply { text = "Connect" }
        val write = Button(this).apply { text = "Write" }
        val disconnect = Button(this).apply { text = "Disconnect" }
        logView = TextView(this)

        startScan.setOnClickListener { ensureReadyAndStartScan() }
        stopScan.setOnClickListener { stopScan() }
        connect.setOnClickListener { connectLast() }
        write.setOnClickListener { writeHello() }
        disconnect.setOnClickListener { closeGatt() }

        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                addView(startScan)
                addView(stopScan)
                addView(connect)
                addView(write)
                addView(disconnect)
                addView(logView)
            }
        )
    }

    private fun ensureReadyAndStartScan() {
        val missing = requiredPermissions().filter {
            ActivityCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, missing.toTypedArray(), permissionsRequestCode)
            return
        }
        if (!bluetoothAdapter.isEnabled) {
            startActivity(android.content.Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE))
            return
        }
        startScan()
    }

    private fun requiredPermissions(): List<String> {
        val list = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            list += Manifest.permission.BLUETOOTH_SCAN
            list += Manifest.permission.BLUETOOTH_CONNECT
        } else {
            list += Manifest.permission.ACCESS_FINE_LOCATION
        }
        return list
    }

    @SuppressLint("MissingPermission")
    private fun startScan() {
        val filters = listOf(
            ScanFilter.Builder()
                .setServiceUuid(ParcelUuid(BleUuids.SERVICE_UUID))
                .build()
        )
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()
        scanner.startScan(filters, settings, scanCallback)
        log("scan started")
    }

    @SuppressLint("MissingPermission")
    private fun stopScan() {
        runCatching { scanner.stopScan(scanCallback) }
        log("scan stopped")
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            lastDevice = result.device
            log("found: ${result.device.name} ${result.device.address} rssi=${result.rssi}")
        }
    }

    @SuppressLint("MissingPermission")
    private fun connectLast() {
        val device = lastDevice ?: run {
            log("no device yet")
            return
        }
        closeGatt()
        log("connecting: ${device.address}")
        gatt = device.connectGatt(this, false, gattCallback)
    }

    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            log("conn status=$status newState=$newState")
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                gatt.discoverServices()
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                rx = null
                tx = null
                cccd = null
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            log("services status=$status")
            if (status != BluetoothGatt.GATT_SUCCESS) return

            val service: BluetoothGattService = gatt.getService(BleUuids.SERVICE_UUID) ?: return
            rx = service.getCharacteristic(BleUuids.RX_UUID)
            tx = service.getCharacteristic(BleUuids.TX_UUID)
            cccd = tx?.getDescriptor(BleUuids.CCCD_UUID)

            enableNotify()
        }

        override fun onDescriptorWrite(gatt: BluetoothGatt, descriptor: BluetoothGattDescriptor, status: Int) {
            log("cccd write status=$status")
        }

        override fun onCharacteristicWrite(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, status: Int) {
            log("write status=$status")
        }

        override fun onCharacteristicChanged(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic) {
            val bytes = characteristic.value ?: return
            log("notify: " + String(bytes, StandardCharsets.UTF_8))
        }
    }

    @SuppressLint("MissingPermission")
    private fun enableNotify() {
        val g = gatt ?: return
        val t = tx ?: return
        val d = cccd ?: return

        g.setCharacteristicNotification(t, true)
        d.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
        g.writeDescriptor(d)
    }

    @SuppressLint("MissingPermission")
    private fun writeHello() {
        val g = gatt ?: run {
            log("no gatt")
            return
        }
        val r = rx ?: run {
            log("no rx char")
            return
        }
        val payload = ("hi@" + System.currentTimeMillis()).toByteArray(StandardCharsets.UTF_8)
        r.value = payload
        r.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
        val ok = g.writeCharacteristic(r)
        log("write started=$ok")
    }

    @SuppressLint("MissingPermission")
    private fun closeGatt() {
        gatt?.close()
        gatt = null
        rx = null
        tx = null
        cccd = null
        log("gatt closed")
    }

    private fun log(msg: String) {
        runOnUiThread { logView.append(msg + "\n") }
    }

    override fun onDestroy() {
        stopScan()
        closeGatt()
        super.onDestroy()
    }
}
```

### 其他

<!-- 权限 流程 各安卓版本 -->
