#coding=utf-8
__author__ = 'answer-huang'

import  sys
reload(sys)
sys.setdefaultencoding('utf8')

import wx
from MyInfo import AboutMe
from AHDropTarget import AHDropTarget
import os
import subprocess
import sqlite3

class AHFrame(wx.Frame):
    def __init__(self, parent, title):
        wx.Frame.__init__(self,
                          parent,
                          -1,
                          title,
                          wx.DefaultPosition,
                          wx.Size(500, 500)
                          #style=wx.DEFAULT_FRAME_STYLE
                          #style=wx.DEFAULT_FRAME_STYLE ^ (wx.RESIZE_BORDER | wx.MAXIMIZE_BOX)
        )
                          #style=wx.SYSTEM_MENU | wx.CAPTION | wx.CLOSE_BOX | wx.MINIMIZE_BOX)
        #拖进到窗口中的文件列表
        self.filesList = []

        #创建状态栏
        self.statusbar = self.CreateStatusBar()
        self.statusbar.SetForegroundColour('red')
        self.statusbar.SetFieldsCount(2)
        self.statusbar.SetStatusWidths([-2, -1]) #大小比例2:1

        #创建工具栏
        toolbar = self.CreateToolBar()
        toolbar.AddSimpleTool(1, wx.Image('./about.png', wx.BITMAP_TYPE_PNG).ConvertToBitmap(), "关于我", "")
        toolbar.AddSeparator()
        toolbar.Realize()  #准备显示工具栏
        wx.EVT_TOOL(self, 1, self.OnAboutMe)

        #创建panel
        self.panel = wx.Panel(self)
        self.panel.SetDropTarget(AHDropTarget(self))

        #self.font = wx.Font(18, wx.SCRIPT, wx.BOLD, wx.LIGHT)
        #self.selectedPath = wx.StaticText(self.panel, -1, u'请将xcarchive文件拖拽到窗口中！', pos=(138, 300))
        #self.selectedPath.SetFont(self.font)

        self.vbox = wx.BoxSizer(wx.VERTICAL)


        self.description = wx.StaticText(self.panel, -1, u'请将dSYM文件拖拽到窗口中并选中任意一个版本进行分析',  style=wx.TE_WORDWRAP | wx.TE_MULTILINE)
        self.fileTypeLB = wx.ListBox(self.panel, -1,  style = wx.LB_EXTENDED)
        self.fileTypeLB.SetBackgroundColour(wx.Colour(232, 232, 232, 255))
        #TODO: 从sqlite中读取文件路径
        self.getdSYMFileFromSqlite()
        self.Bind(wx.EVT_LISTBOX, self.ListBoxClick, self.fileTypeLB)
        self.Bind(wx.EVT_LISTBOX_DCLICK, self.ListBoxClick, self.fileTypeLB)

        self.fileTypeLBhbox = wx.BoxSizer(wx.HORIZONTAL)
        self.fileTypeLBhbox.Add(self.fileTypeLB, 1, wx.EXPAND)
        self.vbox.Add(self.description, 0, wx.EXPAND | wx.ALL, 5)
        self.vbox.Add(self.fileTypeLBhbox, 1, wx.EXPAND | wx.ALL, 5)
        self.vbox.SetItemMinSize(self.fileTypeLBhbox, (200, 100))
        self.vbox.Add((-1, 10))

        self.UUIDString = wx.StaticText(self.panel, -1, u'选中dSYM文件的UUID:')
        self.vbox.Add(self.UUIDString, 0, wx.EXPAND | wx.ALL, 5)

        self.UUIDStringText = wx.TextCtrl(self.panel, -1)
        hbox2 = wx.BoxSizer(wx.HORIZONTAL)
        hbox2.Add(self.UUIDStringText, 1, wx.EXPAND)
        self.vbox.Add(hbox2, 0, wx.EXPAND | wx.ALL, 5)

        self.vbox.Add((-1, 10))

        self.memAddressStr = wx.StaticText(self.panel, -1, u'请输入错误信息的内存地址:')
        self.vbox.Add(self.memAddressStr, 0, wx.ALL, 5)

        self.memAddress = wx.TextCtrl(self.panel, -1)
        hbox3 = wx.BoxSizer(wx.HORIZONTAL)
        hbox3.Add(self.memAddress, 1, wx.EXPAND)
        self.vbox.Add(hbox3, 0, wx.EXPAND | wx.ALL, 5)

        self.fileBtn = wx.Button(self.panel, -1, u'分析')
        self.fileBtn.Bind(wx.EVT_BUTTON, self.startCalc)
        hbox4 = wx.BoxSizer(wx.HORIZONTAL)
        hbox4.Add(self.fileBtn, 1, wx.EXPAND)
        self.vbox.Add(hbox4, 0, wx.EXPAND | wx.ALL, 5)


        self.vbox.Add((-1, 10))

        self.maybeReason = wx.StaticText(self.panel, -1, u'有可能错误的地方:', style=wx.TE_WORDWRAP|wx.TE_MULTILINE)#size=(170, 30), pos=(5, 250),
        self.vbox.Add(self.maybeReason, 0, wx.EXPAND | wx.ALL, 5)
        self.maybeReasonContent = wx.TextCtrl(self.panel, -1, u'', style=wx.TE_WORDWRAP|wx.TE_MULTILINE)#size=(500, 60), pos=(5, 270),
        hbox5 = wx.BoxSizer(wx.HORIZONTAL)
        hbox5.Add(self.maybeReasonContent, 1, wx.EXPAND)

        self.vbox.Add(hbox5, 1, wx.EXPAND | wx.ALL, 5)
        self.vbox.SetItemMinSize(hbox5, (200, 100))

        self.panel.Bind(wx.EVT_ENTER_WINDOW, self.OnEnterWindow)
        self.panel.Bind(wx.EVT_LEAVE_WINDOW, self.OnLeaveWindow)
        self.panel.Bind(wx.EVT_MOTION, self.OnMotion)
        self.panel.SetSizer(self.vbox)

    #文件列表单击事件
    def ListBoxClick(self, event):
        self.selectedArchiveFilePath = self.filesList[event.GetSelection()]
        self.getFilePath(self.selectedArchiveFilePath)
        self.getArchiveUUID()

    #获取文件UUID
    def getArchiveUUID(self):
        comString = 'dwarfdump --uuid ' + self.dsymFilePath
        lines = os.popen(comString).readlines()
        self.archiveUUIDDic = {}
        for line in lines:
            uuidString = line.split(' ')[1]
            archiveType = line.split(' ')[2][1:-1]
            self.archiveUUIDDic[archiveType] = uuidString
        if hasattr(self, 'archiveType'):
            self.fileTypeLBhbox.Remove(self.fileTypeLBhbox.GetItemIndex(self.archivebox))
            self.archiveType.Destroy()
        self.archiveType = wx.RadioBox(self.panel, -1, "请选择该archive文件对应的编译类型", choices=self.archiveUUIDDic.keys(), majorDimension=1)
        self.archivebox = wx.BoxSizer(wx.HORIZONTAL)
        self.archivebox.Add(self.archiveType, 0, wx.ALL, 5)
        self.fileTypeLBhbox.Add(self.archivebox, 0, wx.ALL, 5)
        self.fileTypeLBhbox.Layout()
        self.Bind(wx.EVT_RADIOBOX, self.EvtRadioBox, self.archiveType)
        self.UUIDStringText.SetValue(self.archiveUUIDDic[self.archiveType.GetStringSelection()])
        self.selectedArchiveType = self.archiveType.GetStringSelection()


    #选择编译器事件
    def EvtRadioBox(self, event):
        self.selectedArchiveType = event.GetString()
        self.UUIDStringText.SetValue(self.archiveUUIDDic[self.selectedArchiveType])


    def startCalc(self, event):
        if self.memAddress.GetValue():
            comString = 'xcrun atos -arch ' + self.selectedArchiveType + ' -o ' + str(self.appFilePath) + ' ' + self.memAddress.GetValue()
            tmp = os.popen(comString).readlines()
            self.maybeReasonContent.SetValue(tmp[0])

    def OnEnterWindow(self, event):
        event.Skip()

    def OnLeaveWindow(self, event):
        event.Skip()

    def OnMotion(self, event):
        if event.Dragging() and event.LeftIsDown():
            print '按住了鼠标移动'
        event.Skip()

    def ShowFileType(self):
        self.fileTypeLB.Set(list([os.path.basename(filepath) for filepath in self.filesList]))

    def getdSYMFileFromSqlite(self):
        if os.path.exists('dsym.db'):
            cx = sqlite3.connect('dsym.db')
            cu = cx.cursor()
            ##查询
            cu.execute("select * from archives")
            self.filesList = [dsym[0] for dsym in cu.fetchall()]
            self.ShowFileType()

    #获取最后需要的文件地址
    def getFilePath(self, rootPath):
        if rootPath.endswith("dSYM"):
            self.dsymFilePath = rootPath
            fileName = os.path.basename(rootPath)
        else:
            dsymsPath = os.path.join(rootPath,'dSYMs')
            listFiles = os.listdir(dsymsPath)
            for fileName in listFiles:
                if fileName.endswith('dSYM'):
                    #dsym文件路径
                    self.dsymFilePath = os.path.join(dsymsPath, fileName)

        appPath = os.path.join(self.dsymFilePath,'Contents/Resources/DWARF')
        if os.path.isdir(appPath):
            if len(os.listdir(appPath)) is not 0:
                #命令行中需要的文件路径
                self.appFilePath = os.path.join(appPath,fileName.split(".")[0])

    #显示关于我的界面
    def OnAboutMe(self, event):
        aboutMe = AboutMe(self)
        aboutMe.ShowModal()
        aboutMe.Destroy()

versions = '1.0.1'
if __name__ == '__main__':
    app = wx.App(redirect=False)
    frame = AHFrame(None, 'dSYM文件分析工具' + versions)
    frame.ShowWithEffect(True)
    app.MainLoop()
