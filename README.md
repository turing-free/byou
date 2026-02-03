# byou

macOS 工具 - 通过快捷键捕获网页选中内容、模拟鼠标双击，并使用腾讯云机器翻译API进行语句翻译。

## 功能

- 全局快捷键 Alt+S 捕获选中内容
- 全局快捷键 Alt+X 模拟鼠标双击并自动捕获选中内容
- 使用**腾讯云机器翻译API**进行在线翻译
- 自动将选中的网页内容复制到剪切板
- 将内容和翻译结果记录到日志文件: `/Users/turing/opencode/byou.log`
- 在弹出窗口中显示内容和翻译
- 捕获后自动清空剪切板
- 状态栏菜单：打开配置界面

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

## 配置

### 腾讯云机器翻译API配置

1. 点击状态栏菜单选择"Settings..."（或按快捷键 Cmd+,）
2. 填入腾讯云凭证：
   - **Secret ID**: 在腾讯云控制台的[访问管理 > API密钥管理](https://console.cloud.tencent.com/cam/capi)获取
   - **Secret Key**: 同上
   - **Region**: 选择最近的区域（默认ap-guangzhou）
3. 点击"Save Configuration"保存
4. 点击"Test Connection"测试连接

### 获取腾讯云凭证

1. 访问[腾讯云控制台](https://console.cloud.tencent.com/)
2. 注册或登录账号
3. 进入"访问管理 > API密钥管理"
4. 点击"新建密钥"获取Secret ID和Secret Key
5. **免费额度：每月500万字符**

## 翻译特性

- **支持语言**: 19种语言，包括中文（简体/繁体）、英语、日语、韩语等
- **翻译质量**: 使用腾讯混元MT1.5模型，WMT25比赛中超越Google Translate 30/31语言对
- **响应速度**: 平均0.18-0.45秒
- **文本限制**: 每次请求最多2000字符
- **速率限制**: 5次/秒

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
6. 查看 `/Users/turing/opencode/byou.log` 获取完整记录

### Alt+X - 模拟鼠标双击并翻译

1. 运行应用
2. 配置腾讯云凭证（首次使用需要）
3. 将鼠标移动到需要双击的文本位置
4. 按 Alt+X 模拟双击操作
5. 应用会自动捕获双击后选中的文本并进行翻译
6. 查看弹出窗口中的内容和翻译结果
7. 查看 `/Users/turing/opencode/byou.log` 获取完整记录

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

3. **免费额度**
   - 每月500万字符免费
   - 超出后按量付费（约¥58/百万字符）

4. **翻译质量**
   - 使用腾讯混元MT1.5模型
   - 在WMT25比赛中超越Google Translate 30/31语言对
   - 特别适合中文到英文翻译

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

## 项目结构

```
Sources/byou/
├── AppDelegate.swift              # 主应用逻辑
├── ConfigManager.swift           # 配置管理（凭证存储）
├── TencentTranslationManager.swift # 腾讯云API集成
├── SettingsViewController.swift   # 配置界面
├── PopoverViewController.swift   # 翻译结果弹出窗口
├── HotkeyManager.swift          # 全局快捷键管理
├── ClipboardManager.swift        # 剪切板操作
└── MouseManager.swift           # 鼠标双击模拟
```

## 相关资源

- **腾讯云机器翻译文档**: https://www.tencentcloud.com/document/product/1161
- **腾讯云控制台**: https://console.cloud.tencent.com/
- **API密钥管理**: https://console.cloud.tencent.com/cam/capi
