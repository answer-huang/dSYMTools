#coding=utf-8

#打包命令 : python setup.py py2app

__author__ = 'answer-huang'

import sys
reload(sys)
sys.setdefaultencoding('utf8')


from setuptools import setup

APP = ['dSYM.py']
OPTIONS = {
    #'includes': ['about.png'],
    'iconfile': 'dSYMIcns.icns',
    'plist': {'CFBundleShortVersionString': '1.0.1', }
}
DATA_FILES = ['about.png', 'avatar.jpg', 'dsym.db', 'RunScript.py']

setup(
    app = APP,
    name= 'dSYM',
    data_files = DATA_FILES,
    options = {'py2app' : OPTIONS},
    setup_requires=['py2app']
)