#!/usr/bin/python
# -*- coding: UTF-8 -*-

import pymssql
import time
import os	


def connectandgetrow(server,user,passwd,database,sql):

	connect = pymssql.connect(server,user,passwd,database, charset = 'utf8')

	cursor = connect.cursor()

	#time.sleep(15)
	os.system("echo 'server:%s' >> /home/dbfw/sql.txt"%server)	
	os.system("echo 'user:%s' >> /home/dbfw/sql.txt"%user)	
	os.system("echo 'passwd:%s' >> /home/dbfw/sql.txt"%passwd)	
	os.system("echo 'database:%s' >> /home/dbfw/sql.txt"%database)	
	os.system("""echo "sql:%s" >> /home/dbfw/sql.txt"""%sql)	
	try:
		cursor.execute(sql)
	except Exception:
		print "error"
		count = 0
	else:	
		print "ok"
		row = cursor.fetchone()
		count = row[0]
		os.system("echo 'row:%s' >> /home/dbfw/sql.txt"%row)	

	connect.close()
	print count
	#print str(count)
	return count

def main():
	
	#server = "192.168.111.160:1434"
	#user = "sa"
	#passwd = "schina1234"
	#database = "master"
	#sql = "select count(1) from dbm_888"

	server = "192.168.0.110:1433"
	user = "sa"
	passwd = "schina1234"
	database = "test"
	sql = "select count(1) from (select * from  student08  where sname='ttt' ) dbfw_alias"

	connectandgetrow(server,user,passwd,database,sql)

#main()
