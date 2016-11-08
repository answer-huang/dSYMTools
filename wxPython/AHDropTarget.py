#coding=utf-8
__author__ = 'answer-huang'

import wx
import os


class AHDropTarget(wx.FileDropTarget):
    def __init__(self, window):
        wx.FileDropTarget.__init__(self)
        self.window = window

    def OnDropFiles(self, x, y, filenames):
        self.fileList = []
        for filename in filenames:
            print os.path.basename(filename)
            #TODO: 增加对dSYM文件的支持
            if filename.endswith(('xcarchive', 'dSYM')):
                self.fileList.append(filename)

        self.window.filesList = self.fileList
        self.window.ShowFileType()

    #def OnEnter(self, x, y, z):
    #    print x, y, z
    #    print 'OnEnter x:%d, y:%d' % (x, y)
    #
    #def OnLeave(self):
    #    print 'leave windows'
    #
    #def OnDrop(self, x, y):
    #    print 'OnDrop x:%d, y:%d' % (x, y)
    #    print x, y
    #
    #def OnData(self, x, y, z):
    #    print 'OnData x:%d, y:%d' % (x, y)