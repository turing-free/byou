# byou

macOS 工具 - 通过快捷键捕获网页选中内容、模拟鼠标双击，并使用腾讯云机器翻译API进行语句翻译。

## 功能

- 全局快捷键 Alt+S 捕获选中内容
- 全局快捷键 Alt+X 模拟鼠标双击并自动捕获选中内容
- 使用**腾讯云机器翻译API**进行在线翻译
- 自动将选中的网页内容复制到剪切板
- 在弹出窗口中显示内容和翻译

## 构建

```bash
./build.sh
```

或手动构建:

```bash
swift build
```

## 系统要求

- **macOS 12.0+**
- 网络连接（腾讯云API需要在线访问）
- 腾讯云账号和API凭证

## 运行

```bash
./run.sh
```

## 使用方法

### Alt+S - 捕获并翻译选中内容

1. 运行应用
2. 配置腾讯云凭证（首次使用需要）
3. 在任意应用中选中文字（中文或英文）
4. 按 Alt+S 捕获并翻译
5. 查看弹出窗口中的内容和翻译结果

### Alt+X - 模拟鼠标双击并翻译

1. 运行应用
2. 配置腾讯云凭证（首次使用需要）
3. 将鼠标移动到需要双击的文本位置
4. 按 Alt+X 模拟双击操作
5. 应用会自动捕获双击后选中的文本并进行翻译
6. 查看弹出窗口中的内容和翻译结果

### 状态栏菜单

- **Settings...**: 打开配置界面
- **Quit**: 退出应用

## 技术栈

- Swift 5.5+
- Swift Package Manager
- AppKit / Carbon (快捷键)
- CGEvent (剪切板操作和鼠标事件)
- Tencent Cloud TMT API (腾讯云机器翻译，TC3-HMAC-SHA256签名认证)
- CryptoKit / CommonCrypto (签名算法)

## 注意事项

### 腾讯云机器翻译API

1. **需要网络连接**
   - 翻译请求发送到腾讯云服务器
   - 依赖网络质量

2. **需要配置凭证**
   - 必须先配置Secret ID和Secret Key
   - 凭证存储在本地UserDefaults中

## 故障排除

### 翻译失败

1. **检查网络连接**：确保网络正常
2. **检查腾讯云凭证**：
   - 确认Secret ID和Secret Key正确
   - 使用"Test Connection"按钮测试连接
3. **检查配额**：确认腾讯云免费额度未用完

### 捕获失败

1. **检查快捷键冲突**：确认Alt+S和Alt+X未被其他应用占用
2. **检查应用权限**：确保应用有辅助功能权限（macOS设置 > 隐私与安全 > 辅助功能）


## 相关资源

- **腾讯云机器翻译文档**: https://www.tencentcloud.com/document/product/1161
- **腾讯云控制台**: https://console.cloud.tencent.com/
- **API密钥管理**: https://console.cloud.tencent.com/cam/capi
