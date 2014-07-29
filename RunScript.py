#coding=utf-8

"""
   * User:  answer.huang
   * Email: aihoo91@gmail.com
   * Date:  14-7-28
   * Time:  23:36
   * Blog:  answerhuang.duapp.com
 """
 
 
import os
import sys
import time
import shutil
import sqlite3

print os.environ["EFFECTIVE_PLATFORM_NAME"]
print os.environ["DWARF_DSYM_FOLDER_PATH"]

if os.environ["BUILD_STYLE"] == "Debug":
    print "跳过debug模式"
    sys.exit()

if os.environ["EFFECTIVE_PLATFORM_NAME"] == "-iphonesimulator":
    print "跳过模拟器编译情况"
    sys.exit()

dsym_folder_path = os.environ["DWARF_DSYM_FOLDER_PATH"]
dsym_file_name = os.environ["DWARF_DSYM_FILE_NAME"]
src_path = os.path.join(dsym_folder_path, dsym_file_name)



executable_name = os.environ["EXECUTABLE_NAME"]
relative_dest_path = "dSYM/%s.%s.app.dSYM" % (executable_name, time.strftime('%Y%m%d%H%M%S', time.localtime(time.time())))
dest_path = os.path.join(os.environ["PROJECT_DIR"], relative_dest_path)

print "moving %s to %s" % (src_path, dest_path)
shutil.move(src_path, dest_path)

if os.path.exists(dest_path):
    sqlitedb = "/Applications/dSYM.app/Contents/Resources/dsym.db"
    cx = sqlite3.connect(sqlitedb)
    cu = cx.cursor()
    cu.execute("""create table if not exists archives (file_path varchar(10) unique)""")
    cu.execute("insert into archives values (?)", (dest_path, ))
    cx.commit()