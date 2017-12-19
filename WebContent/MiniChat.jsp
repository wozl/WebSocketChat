<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
		<title>websocket聊天室</title>
		<link rel="stylesheet" href="<%=request.getContextPath() %>/assets/css/amazeui.css" />
		<link rel="stylesheet" href="<%=request.getContextPath() %>/assets/css/app.css">
		<script type="text/javascript" src="<%=request.getContextPath() %>/assets/js/jquery.min.js" ></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/assets/js/amazeui.min.js" ></script>
	</head>
	<body>
		  	<header data-am-widget="header" class="am-header am-header-default">
		      	<h1 class="am-header-title">
		          	<a href="#title-link" class="">
		            	websocket聊天室
		          	</a>
		      	</h1>
  			</header>
		
			
			
			<div data-am-widget="titlebar" class="am-titlebar am-titlebar-default" >
				    <h2 class="am-titlebar-title ">
				        系统通知区
				    </h2>
			</div>
			<div style="width:100%;height:260px; overflow:scroll;" id="output">
				
				
			</div>
			<div data-am-widget="titlebar" class="am-titlebar am-titlebar-default" >
				    <h2 class="am-titlebar-title ">
				        聊天内容区
				    </h2>
			</div>
			<div style="width:100%;height:260px; overflow:scroll;" id="outputchat">
				
				
			</div>
			<!--
            	作者：LQ
            	时间：2017-12-13
            	描述：内容提交区
            -->
			<form action="" class="am-form"  id="form">
				<fieldset>
					<legend></legend>
					<div class="am-form-group">
						<input type="text" id="chatmsg" minlength="3" placeholder="请输入聊天内容（最少三个字符）"  required/>
					</div>
				</fieldset>	
			</form>
			<!--
            	作者：LQ
            	时间：2017-12-13
            	描述：操作区
            -->
			<div>
				<button class="am-btn am-btn-primary" style="float: left; margin-bottom: 10px;" onclick="SendMsgToServer();"><span class="am-icon-paper-plane"></span>发送</button>	
				<span style="float: left; margin-left: 30px; margin-right: 30px;padding-top: 5px;">对象：</span>	
				<select style="width: 160px; float: left;margin-top: 5px;" id="chooseFriend">
					<option name="select">all</option>
				</select>
				<!-- <button onclick="test()">测试</button> -->
			</div>
			
			<!--
            	作者：模拟弹窗
            	时间：2017-12-14
            	描述：
            -->
            <div class="am-modal am-modal-prompt" tabindex="-1" id="prompt">
            	<div class="am-modal-dialog">
            		<div class="am-modal-hd">昵称</div>
            		<div class="am-modal-bd">
            			快来创建你的昵称和小伙伴畅聊吧！
            			<input type="text" class="am-modal-prompt-input" />
            		</div>
            		<div class="am-modal-footer">
            			<span class="am-modal-btn" data-am-modal-cancel>取消</span>
            			<span class="am-modal-btn" data-am-modal-confirm>确定</span>
            		</div>
            	</div>
            </div>   
            
            <!--
            	作者：LQ
            	时间：2017-12-17
            	描述：提示音
            -->
            <div style="display: none;">
            	<audio autoplay="autoplay" id="TipMusic" src=""></audio>
            	
            </div>
	</body>
	<script type="text/javascript">
			var ws;//定义通道
			//创建websocket
			 var target="ws://127.0.0.1:8080/websocket/chat";//目的地
			 ws=new WebSocket(target);
			 var name;//昵称
			$(function() {
				  $('#form').validator({
				    onValid: function(validity) {
				      $(validity.field).closest('.am-form-group').find('.am-alert').hide();
				    },
				
				    onInValid: function(validity) {
				      var $field = $(validity.field);
				      var $group = $field.closest('.am-form-group');
				      var $alert = $group.find('.am-alert');
				      // 使用自定义的提示信息 或 插件内置的提示信息
				      var msg = $field.data('validationMessage') || this.getValidationMessage(validity);
				
				      if (!$alert.length) {
				        $alert = $('<div class="am-alert am-alert-danger"></div>').hide().
				          appendTo($group);
				      }
				
				      $alert.html(msg).show();
				    }
				  });
				  //console.log(nowTime());
				}); 
		
			
			//弹出要求用户创建昵称方法
			function Create_a_nickname(){
				
				var Random_nickname=["a","b","c","d","e","f","g","h","i","j","k"];//随机昵称
				var index=0;
				$("#prompt").modal({
					relatedTarget:this,
					onConfirm:function(e){//用户点击确定时
						if(e.data.length==0){//如果用户什么都没输入就取随机昵称
							name=Random_nickname[Math.floor((Math.random()*Random_nickname.length))];//取随机昵称
						}else{
							name=e.data;
						}
						
						
					},
					onCancel:function(e){//用户点击取消时
						name=Random_nickname[Math.floor((Math.random()*Random_nickname.length))];//取随机昵称
						
					}
				});
				return name;
			};
			//发送信息给服务器
			ws.onopen=function(){
				var n=prompt("请给自己取一个昵称：");
  				n=n.substr(0,16);
				ws.send(n);
			}
			
			//接收来自服务器的信息
			ws.onmessage=function(event){
				//alert(event.data);
				//console.log(event.data);
				showMsg(event.data);
			}
			
			//发送消息给服务器
			function SendMsgToServer(){
				var message=document.getElementById("chatmsg").value.trim();
	  			var towho=$("#chooseFriend option:selected").val()+"@";
	  			ws.send(towho+message);
			}
			
			//发生错误是，处理错误
	  		ws.onerror= function(evt){
	  			alert("出错了"+evt.data);
	  			ws.close();
	  		}
			
	  	//页面关闭时执行
	  		window.onbeforeunload=function(){
	  			ws.close();
	  		}
			
			
			
	//显示消息
	function showMsg(obj){
		var friends=[];//定义可选用户数组
		//alert(obj.indexOf("系统"));
		if((obj.indexOf("系统"))!=-1){//表示这个是系统消息
			if((obj.indexOf("欢迎"))!=-1){//表示这个是欢迎信息
				document.getElementById("output").innerHTML+='<article class="am-comment">'+
				'<a href="###"><img src="image/fg.jpg" alt="" class="am-comment-avatar" width="48" height="48"/></a>'+
				'<div class="am-comment-main">'+
				'<header class="am-comment-hd">'+
				'<div class="am-comment-meata">'+
				'<a href="###" class="am-comment-author" >系统消息:</a>发表于'+
				'<time>'+nowTime()+'</time>'
				+'</div>'
				+'</header>'+
				'<div class="am-comment-bd">'+obj.substring(obj.indexOf("：")+1,obj.length)+''//截取用户名 obj.substring(obj.indexOf("欢迎")+2,str.obj)
				+'</div>'
				+'<div>'
				+'</article>';
				//添加到选项卡中
				$("#chooseFriend").append('<option name="select">'+obj.substring(obj.indexOf("欢迎")+2,obj.obj)+'</option>');
				//将用户添加到数组中进行保存
				$("#chooseFriend option").map(function(){friends.push($(this).val());});
				//消息提示音
				document.getElementById("TipMusic").src="http://fjlt.sc.chinaz.com/files/download/sound1/201208/1852.wav";
			}
			if(obj.indexOf("退出")!=-1){//表示有用户退出了聊天室
				document.getElementById("output").innerHTML+='<article class="am-comment">'+
				'<a href="###"><img src="image/fg.jpg" alt="" class="am-comment-avatar" width="48" height="48"/></a>'+
				'<div class="am-comment-main">'+
				'<header class="am-comment-hd">'+
				'<div class="am-comment-meta">'+
				'<a href="###" class="am-comment-author" >系统消息:</a>发表于'+
				'<time>'+nowTime()+'</time>'
				+'</div>'
				+'</header>'+
				'<div class="am-comment-bd">'+obj.substring(obj.indexOf("：")+1,obj.length)+'' //截取用户名 obj.substring(obj.indexOf("：")+1,obj.indexOf("退"))
				+'</div>'
				+'<div>'
				+'</article>';
				//消息提示音
				document.getElementById("TipMusic").src="http://fjlt.sc.chinaz.com/files/download/sound1/201208/1852.wav";
				if(friends.indexOf(obj.substring(obj.indexOf("：")+1,obj.length))!=-1){//代表找到这个对象
					document.getElementById("chooseFriend").options.remove(friends.indexOf(obj.substring(obj.indexOf("：")+1,obj.length)));//将退出用户从选项卡中移除
				}
				//无论是否找到该用户都重新初始化
				//初始化数组
				friends=[];
				$("#chooseFriend option").map(function(){friends.push($(this).val());});
			}
		}else{//非系统消息
			if(obj.indexOf("我对")!=-1){//表示当前是我在和某一个对象说话
				document.getElementById("outputchat").innerHTML+='<article class="am-comment">'+
				'<a href="###"><img src="image/fg.jpg" alt="" class="am-comment-avatar" width="48" height="48"/></a>'+
				'<div class="am-comment-main">'+
				'<header class="am-comment-hd">'+
				'<div class="am-comment-meta">'+
				'<a href="###" class="am-comment-author" >'+obj.substring(obj.indexOf("：")+1,-1)+'</a>&nbsp;&nbsp;&nbsp;'+
				'<time>'+nowTime()+'</time>'
				+'</div>'
				+'</header>'+
				'<div class="am-comment-bd">'+obj.substring(obj.indexOf("：")+1,obj.length)+''
				+'</div>'
				+'<div>'
				+'</article>';
				//消息提示音
				document.getElementById("TipMusic").src="http://fjdx.sc.chinaz.com/Files/DownLoad/sound1/201706/8868.wav";
			}
			if(obj.indexOf("对大家说:")!=-1){//表示当前有人在说话
				document.getElementById("outputchat").innerHTML+='<article class="am-comment">'+
				'<a href="###"><img src="image/fg.jpg" alt="" class="am-comment-avatar" width="48" height="48"/></a>'+
				'<div class="am-comment-main">'+
				'<header class="am-comment-hd">'+
				'<div class="am-comment-meta">'+
				'<a href="###" class="am-comment-author" >'+obj.substring(obj.indexOf("：")+1,-1)+'</a>&nbsp;&nbsp;&nbsp;'+
				'<time>'+nowTime()+'</time>'
				+'</div>'
				+'</header>'+
				'<div class="am-comment-bd">'+obj.substring(obj.indexOf("：")+1,obj.length)+''
				+'</div>'
				+'<div>'
				+'</article>';
				//消息提示音
				document.getElementById("TipMusic").src="http://fjdx.sc.chinaz.com/Files/DownLoad/sound1/201706/8868.wav";
			}
			if(obj.indexOf("对你说：")!=-1){//表示当前有人在对我说话
				document.getElementById("outputchat").innerHTML+='<article class="am-comment">'+
				'<a href="###"><img src="image/fg.jpg" alt="" class="am-comment-avatar" width="48" height="48"/></a>'+
				'<div class="am-comment-main">'+
				'<header class="am-comment-hd">'+
				'<div class="am-comment-meta">'+
				'<a href="###" class="am-comment-author" >'+obj.substring(obj.indexOf("：")+1,-1)+'</a>&nbsp;&nbsp;&nbsp;'+
				'<time>'+nowTime()+'</time>'
				+'</div>'
				+'</header>'+
				'<div class="am-comment-bd">'+obj.substring(obj.indexOf("：")+1,obj.length)+''
				+'</div>'
				+'<div>'
				+'</article>';
				//消息提示音
				document.getElementById("TipMusic").src="http://fjdx.sc.chinaz.com/Files/DownLoad/sound1/201706/8868.wav";
			}
		}
	
	};
	
	//显示时间
	
 	function nowTime(){
 		var times=new Date();
 		var y,m,date,day,hs,ms,ss,theDateStr;
 		y=times.getFullYear();//四位年例如2017
 		m=times.getMonth()+1;//月
 		date=times.getDate();//天
 		day=times.getDay();//星期
 		hs=times.getHours();//时
 		ms=times.getMinutes();//分
 		ss=times.getSeconds();//秒
 		if(ms<10){
 			ms="0"+ms;
 		}
 		if(ss<10){
 			ss="0"+ss;
 		}
 		if(date<10){
 			date="0"+date;
 		}
 		//theDateStr="现在是："+"<strong>"+y+"</strong>"+"年"+"<strong>"+m+"</strong>"+"月"+"<strong>"+date+"</strong>"+"日"+"星期："+"<strong>"+days[day]+"</strong>"+"  "+"<strong>"+hs+"</strong>"+"："+"<strong>"+ms+"</strong>"+"："+"<strong>"+ss+"</strong>";
 		//document.getElementById("time").innerHTML=theDateStr;
 		theDateStr=y+'-'+m+'-'+date+' '+hs+':'+ms+':'+ss;
 		return theDateStr;
 	};
	
	
/* 	//模拟测试
	function test(){
		//$("#chooseFriend").append('<option name="select">aaa</option>');
		/*var str=[];//定义数组用来存放
		$("#chooseFriend option").map(function(){str.push($(this).val());});
		//alert(str.indexOf("aaa"));
		if(str.indexOf("aaa")>0){//代表找到这个对象
			document.getElementById("chooseFriend").options.remove(str.indexOf("aaa"));
		}*/
		//重新初始化数组
		/*str=[];
		$("#chooseFriend option").map(function(){str.push($(this).val());});*/
		//console.log(str);
		
		/*var str="系统：bb退出聊天";
		alert(str.substring(str.indexOf("：")+1,str.length));*/
		//document.getElementById("TipMusic").src="http://fjdx.sc.chinaz.com/Files/DownLoad/sound1/201706/8868.wav";
		
	//};
	 
	
	
	
	
	
	</script>
</html>
