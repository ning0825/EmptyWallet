# Intl

## 设置国际化
* 导入flutter_localizations
* 设置localization_delegates和supportedLocales
## 高级区域定义
* 使用Locale.fromSubtags支持香港，台湾的中文
## 跟随系统语言，Locale类和Localization组件
* Locale locale = Localizations.localeOf(context)//查看设备当前区域设置
## 载入和恢复区域化的值
* Localizations.of<MaterialLocalizations>(context, MaterialLocalizations)//载入MaterialLocalizations
## 使用自带的delegates
* GlobalMaterialLocalizations
## 定义多语言化的类
* 使用intl包，编写DemoLocalizations类
## 指定app支持的语言参数
* 使用localeResolutionCallback强制使用系统语言（不支持的语言会导致程序报错）
## 可选的一个多语言化类
* Minimal Demo
## 添加一种新语言支持
## 使用intl库


