#coding=utf-8
__author__ = 'answer-huang'

import sys
reload(sys)
sys.setdefaultencoding('utf8')


from setuptools import setup

APP = ['dSYM.py']
OPTIONS = {
    'includes': ['about.png'],
    'iconfile': 'dSYMIcns.icns',
    'plist': {'CFBundleShortVersionString': '0.1.0',}
}
DATA_FILES = ['about.png', 'avatar.jpg']

setup(
    app = APP,
    name= 'dSYM',
    data_files = DATA_FILES,
    options = {'py2app' : OPTIONS},
    setup_requires=['py2app']
)