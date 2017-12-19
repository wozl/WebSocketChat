<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<html>
  <head>
    <title>WebSocket聊天室示例</title>
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="description" content="This is my page">
  </head>
  
  <body>
     <h1>简易聊天室</h1>

<div style="width:400px;height:260px; overflow:scroll; border:3px solid; " id="output"> </div>  <br>    
    <div style="text-align:left;">
        <form action="">
            <input id="in" name="message" value="" type="text" style="width:400px;height:60px;  border:3px solid; " >
            <br><br>

            <input onclick="button()" value="发送" type="button"/>
            发送对象：
            <input id="towho" name="towho" value="all">
            <br>
        </form>
    </div>
  </body>
  	<script type="text/javascript">
  		var ws;//建立通信管道
  		var target="ws://127.0.0.1:8080/websocket/chat";//目的地
  		ws=new WebSocket(target);
  			ws.onopen=function(){//开启连接时
  				var n=prompt("请给自己取一个昵称：");
  				n=n.substr(0,16);
  				ws.send(n);//服务端响应方法为@onmessage注释的方法
  			};
  			//接受来自服务器的信息
  			ws.onmessage=function(event){
  				writeToScreen(event.data);
  			};
  			
  	
  		//单击发送按钮后的执行事件
  		function button(){
  			var message=document.getElementById("in").value.trim();
  			var towho=document.getElementById("towho").value+"@";
  			ws.send(towho+message);
  		}
  		
  		//发生错误是，处理错误
  		ws.onerror= function(evt){
  			writeToScreen('<span style="color:red">出错了</span>'+evt.data);
  			ws.close();
  		}
  		
  		//把信息显示在页面上
  		function writeToScreen(message){
  			var pre=document.createElement("p");
  			pre.style.wordWrap="break-word";
  			pre.innerHTML=message;
  			output.appendChild(pre);
  		}
  		
  		//页面关闭时执行
  		window.onbeforeunload=function(){
  			ws.close();
  		}
  	</script>
  
</html>