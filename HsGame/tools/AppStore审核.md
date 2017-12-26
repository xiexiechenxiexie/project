上架前准备
证书申请  参考地址:https://www.cnblogs.com/sk-fengzi/p/5670087.html  
沙箱测试账号  苹果开发者->iTools Connect-> 用户职能



保证服务器能够美国正常通信
支付采用h5方式，审核期间采用苹果Iap方式  审核之后切换为苹果支付
ipv6正常(3.15是兼容的，忽略)
签名设置自动签名->选择对应的签名证书

1:Archive->export-> 
	AppStore  上架苹果渠道
	Adhoc(内部安装方式，添加uuid到devices)
	Enterprise ->未知
	Development(第三方企业签名)
	


2:xcode->Open Developer Tool ->Application loader->AppleId login ->上传导出ipa包

3：进入苹果开发者后台-> Itool Connect -> 我的App -> /
	在该界面活动tab下面 会看到提交的版本，刚提交的等待处理-》处理完成就可以进行如下操作
	
	ios app ->准备提交
	在准备提交的app中   如果有被拒绝的删除拒绝版本  
						没有被拒绝的直接						选择新提交的版本->存储->提交产品
   