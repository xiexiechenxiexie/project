#coding=UTF-8

import os
import json
import re
RESOURCE_PATH = "src"
VERSION_INFO_NAME = "ResPath.json"
XXTEA_KEY = "YangeIt"
XXTEA_SIGN = "HsGame"

# 获取文件列表
def getFileList(rootDir):
	dirList = []
	def getDir(path):
		for lists in os.listdir(path): 
			filePath = os.path.join(path, lists)
			print(filePath)
			if os.path.isdir(filePath):
				getDir(filePath)
			else:
				list.append(dirList, filePath)
		return
	getDir(rootDir)
	return dirList

# xxtea加密
def encryptFileXXTEA(file, key, sign=""):
	with open(file, "rb+") as f:
		ciphertext = xxtea.encrypt(f.read(), key)
		f.seek(0, 0)
		f.write(sign+ciphertext)
		f.truncate()
		f.close()
	return

TRIM_PATTERN = re.compile(r"\\+|/+")
# 删除路径前的/或\
def trimHeadSeparator(path):
	name = path
	if TRIM_PATTERN.match(name):
		name = TRIM_PATTERN.sub("", name, 1)
	return name


def buildVersionJson(resource_path):
	infoList = {'files':{}}
	print("ceshi")
	i = 0

	# 文件列表
	for filePath in getFileList(resource_path):
		i=i+1
		name = filePath.replace(resource_path, "")
		name = trimHeadSeparator(name)
		name = name.replace(os.path.sep, "/")
		if name.find("framework/") >= 0:
			continue
		else:
			if not os.path.isdir(filePath):
				infoList['files'][i] = {'name':name}

	# 写入json
	with open(os.path.join(resource_path, VERSION_INFO_NAME), "wb") as f:
		f.write(json.dumps(infoList))
		f.close()
	# 加密

	return

buildVersionJson(RESOURCE_PATH)