#coding=utf-8
__author__ = 'answer-huang'

import wx
import sys
reload(sys)
sys.setdefaultencoding('utf8')

"""
关于我
"""


class AboutMe(wx.Dialog):
    def __init__(self, parent):
        wx.Dialog.__init__(self, parent, -1, '关于我', size=(250, 300))
        bitmap = wx.Image("avatar.jpg", wx.BITMAP_TYPE_JPEG).Rescale(150, 150, quality=wx.IMAGE_QUALITY_HIGH).ConvertToBitmap()
        mask = self._create_round_corner_mask(bitmap.GetSize(), radius=75, border=5)
        bitmap.SetMask(mask)
        wx.StaticBitmap(self, bitmap=bitmap, pos=(50, 10), size=(150, 150))

        wx.StaticText(self, -1, '微博:', pos=(45, 170))
        wx.HyperlinkCtrl(self, -1, 'answer-huang', 'http://weibo.com/u/1623064627', pos=(85, 170))

        # wx.StaticText(self, -1, '邮箱:', pos=(45, 200))
        # wx.HyperlinkCtrl(self, -1, 'aihoo91@gmail.com', 'mailto:aihoo91@gmail.com', pos=(85, 200))

        wx.StaticText(self, -1, '博客:', pos=(45, 200))
        wx.HyperlinkCtrl(self, -1, 'answerhuang.duapp.com', 'http://answerhuang.duapp.com', pos=(85, 200))

        wx.StaticText(self, -1, 'GitHub:', pos=(28, 230))
        wx.HyperlinkCtrl(self, -1, 'dSYMTools', 'https://github.com/answer-huang/dSYMTools', pos=(85, 230))

    def _create_round_corner_mask(self, size, radius, border=0):
        (w, h) = size
        maskBitmap = wx.EmptyBitmap(w, h)
        mdc = wx.MemoryDC()
        mdc.SelectObject(maskBitmap)
        mdc.SetPen(wx.RED_PEN)
        mdc.SetBrush(wx.RED_BRUSH)
        mdc.DrawRoundedRectangle(border, border, w - border*2, h - border*2, radius)
        mdc.SelectObject(wx.NullBitmap)
        return wx.Mask(maskBitmap)