# 更新：
### Version 1.0.5       2016-11-28
1.支持拖入 dSYM 文件。
### Version 1.0.4       2016-11-08
1.使用 Objective-C 重写应用。
2.建议都使用此版本。
### Version 1.0.3       2015-05-16
1.解决文件路径中不能包含空格的 bug。

### Version 1.0.2       2015-05-05
1.由于在 arm64 上 Slide address 变化，现需要提供 Slide address，不然得不到异常地址。

### Version 1.0.1       2014-07-29

1.增加对 dSYM 文件的支持，直接将 xcarchive 或 dSYM 文件拖入窗口中即可。


2.修复 dSYM 根据和版本管理软件冲突的 bug。


### Version 1.0.0       2014-06-26


1.软件基本功能完成（仅支持 xcarchive 文件）。


# 项目简介

来到新公司后，前段时间就一直在忙，前不久  [项目](https://itunes.apple.com/cn/app/kang-da-yu-zhen-nu-ren-bao/id707364888?l=en&mt=8) 终于成功发布上线了，最近就在给项目做优化，并排除一些线上软件的 bug，因为项目中使用了友盟统计，所以在友盟给出的错误信息统计中能比较方便的找出客户端异常的信息，可是很多像数组越界却只给出了 `*** -[__NSArrayM objectAtIndex:]: index 50 beyond bounds [0 .. 39]'` 这类错误信息，如下图所示：

![errorInfo](http://answerhuang.bj.bcebos.com/blog/errorInfo.png)

遇到这种问题如果通过 `objectAtIndex` 去检索错误的地方那将会是一个巨大的工作量。

# dSYM 文件

### 什么是 dSYM 文件
Xcode编译项目后，我们会看到一个同名的 dSYM 文件，dSYM 是保存 16 进制函数地址映射信息的中转文件，我们调试的 symbols 都会包含在这个文件中，并且每次编译项目的时候都会生成一个新的 dSYM 文件，位于 `/Users/<用户名>/Library/Developer/Xcode/Archives` 目录下，对于每一个发布版本我们都很有必要保存对应的 Archives 文件 ( [AUTOMATICALLY SAVE THE DSYM FILES](http://www.cimgf.com/2009/12/23/automatically-save-the-dsym-files/) 这篇文章介绍了通过脚本每次编译后都自动保存 dSYM 文件)。


### dSYM 文件有什么作用
当我们软件 release 模式打包或上线后，不会像我们在 Xcode 中那样直观的看到用崩溃的错误，这个时候我们就需要分析 crash report 文件了，iOS 设备中会有日志文件保存我们每个应用出错的函数内存地址，通过 Xcode 的 Organizer 可以将 iOS 设备中的 DeviceLog 导出成 crash 文件，这个时候我们就可以通过出错的函数地址去查询 dSYM 文件中程序对应的函数名和文件名。大前提是我们需要有软件版本对应的 dSYM 文件，这也是为什么我们很有必要保存每个发布版本的 Archives 文件了。

### 如何将文件一一对应
每一个 xx.app 和 xx.app.dSYM 文件都有对应的 UUID，crash 文件也有自己的 UUID，只要这三个文件的 UUID 一致，我们就可以通过他们解析出正确的错误函数信息了。

    1.查看 xx.app 文件的 UUID，terminal 中输入命令 ：

    dwarfdump --uuid xx.app/xx (xx代表你的项目名)

    2.查看 xx.app.dSYM 文件的 UUID ，在 terminal 中输入命令：
    dwarfdump --uuid xx.app.dSYM 

    3.crash 文件内 Binary Images: 下面一行中 <> 内的 e86bcc8875b230279c962186b80b466d  就是该 crash 文件的 UUID，而第一个地址 0x1000ac000 便是 slide address:
    Binary Images:
    0x1000ac000 - 0x100c13fff Example arm64  <e86bcc8875b230279c962186b80b466d> /var/containers/Bundle/Application/99EE6ECE-4CEA-4ADD-AE8D-C4B498886D22/Example.app/Example


# dSYM工具
于是我抽了几个小时的时间将这些命令封装到一个应用中，也为以后解决bug提供了便利。

使用步骤:

1.将打包发布软件时的xcarchive文件拖入软件窗口内的任意位置(支持多个文件同时拖入，注意：`文件名不要包含空格`)

2.选中任意一个版本的xcarchive文件，右边会列出该xcarchive文件支持的CPU类型，选中错误对应的CPU类型。

3.对比错误给出的UUID和工具界面中给出的UUID是否一致。

4.将错误地址以及 Slide Address 输入工具的文本框中，点击分析。

![dSYMToos](http://answerhuang.bj.bcebos.com/blog/dsymTool.png)


[项目源码地址](https://github.com/answer-huang/dSYMTools)

[1]: https://itunes.apple.com/cn/app/kang-da-yu-zhen-nu-ren-bao/id707364888?l=en&mt=8
[2]: http://answerhuang.bj.bcebos.com/blog/errorInfo.png
[3]: http://answerhuang.bj.bcebos.com/blog/dsymTool.png
[4]: http://answerhuang.bj.bcebos.com/blog/crashUUID.png
[5]: http://www.cimgf.com/2009/12/23/automatically-save-the-dsym-files/
[6]: https://github.com/answer-huang/dSYMTools


