#更新：

###Version 1.0.1       2014-07-29

1.增加对 dSYM 文件的支持，直接将 xcarchive 或 dSYM 文件拖入窗口中即可。

2.增加项目编译时自动将 dSYM 文件保存到项目目录下的脚本(如果选中 Run script only when installing 则只会在每次 Archive 的时候保存 dSYM 文件到根目录)，并将 dSYM 路径写入应用的数据库中，下次打开软件时，自动导入保存的 dSYM 文件路径。（脚本：`/usr/bin/python /Applications/dSYM.app/Contents/Resources/RunScript.py`）

![runScript][8]


3.修复 dSYM 根据和版本管理软件冲突的 bug。


###Version 1.0.0       2014-06-26


1.软件基本功能完成（仅支持 xcarchive 文件）。


#项目简介

来到新公司后，前段时间就一直在忙，前不久  [项目][1] 终于成功发布上线了，最近就在给项目做优化，并排除一些线上软件的 bug，因为项目中使用了友盟统计，所以在友盟给出的错误信息统计中能比较方便的找出客户端异常的信息，可是很多像数组越界却只给出了 `*** -[__NSArrayM objectAtIndex:]: index 50 beyond bounds [0 .. 39]'` 这类错误信息，如下图所示：

![errorInfo][2]

遇到这种问题如果通过 `objectAtIndex` 去检索错误的地方那将会是一个巨大的工作量。

#dSYM 文件

###什么是 dSYM 文件
Xcode编译项目后，我们会看到一个同名的 dSYM 文件，dSYM 是保存 16 进制函数地址映射信息的中转文件，我们调试的 symbols 都会包含在这个文件中，并且每次编译项目的时候都会生成一个新的 dSYM 文件，位于 `/Users/<用户名>/Library/Developer/Xcode/Archives` 目录下，对于每一个发布版本我们都很有必要保存对应的 Archives 文件 ( [AUTOMATICALLY SAVE THE DSYM FILES][5] 这篇文章介绍了通过脚本每次编译后都自动保存 dSYM 文件)。


###dSYM 文件有什么作用
当我们软件 release 模式打包或上线后，不会像我们在 Xcode 中那样直观的看到用崩溃的错误，这个时候我们就需要分析 crash report 文件了，iOS 设备中会有日志文件保存我们每个应用出错的函数内存地址，通过 Xcode 的 Organizer 可以将 iOS 设备中的 DeviceLog 导出成 crash 文件，这个时候我们就可以通过出错的函数地址去查询 dSYM 文件中程序对应的函数名和文件名。大前提是我们需要有软件版本对应的 dSYM 文件，这也是为什么我们很有必要保存每个发布版本的 Archives 文件了。

###如何将文件一一对应
每一个 xx.app 和 xx.app.dSYM 文件都有对应的 UUID，crash 文件也有自己的 UUID，只要这三个文件的 UUID 一致，我们就可以通过他们解析出正确的错误函数信息了。

    1.查看 xx.app 文件的 UUID，terminal 中输入命令 ：

    dwarfdump --uuid xx.app/xx (xx代表你的项目名)

    2.查看 xx.app.dSYM 文件的 UUID ，在 terminal 中输入命令：
    dwarfdump --uuid xx.app.dSYM 

    3.crash 文件内第一行 Incident Identifier 就是该 crash 文件的 UUID。


#dSYM工具
于是我抽了几个小时的时间将这些命令封装到一个应用中，也为以后解决bug提供了便利。

使用步骤:

1.将打包发布软件时的xcarchive文件拖入软件窗口内的任意位置(支持多个文件同时拖入，注意：`文件名不要包含空格`)

2.选中任意一个版本的xcarchive文件，右边会列出该xcarchive文件支持的CPU类型，选中错误对应的CPU类型。

3.对比错误给出的UUID和工具界面中给出的UUID是否一致。

4.将错误地址输入工具的文本框中，点击分析。

![dSYMToos][3]

[Mac app下载地址][6]

[项目源码地址][7]
[1]: https://itunes.apple.com/cn/app/kang-da-yu-zhen-nu-ren-bao/id707364888?l=en&mt=8
[2]: http://bcs.duapp.com/answerhuang/blog/errorInfo.png
[3]: http://bcs.duapp.com/answerhuang/blog/dsymTool.png
[4]: http://bcs.duapp.com/answerhuang/blog/crashUUID.png
[5]: http://www.cimgf.com/2009/12/23/automatically-save-the-dsym-files/
[6]: http://pan.baidu.com/s/1o65gV4Q
[7]: https://github.com/answer-huang/dSYMTools
[8]: http://bcs.duapp.com/answerhuang/blog/runScript.png
