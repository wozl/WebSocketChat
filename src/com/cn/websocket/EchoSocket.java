package com.cn.websocket;

import javax.websocket.CloseReason;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

/**
 * 这个类用来处理WebSocket传送过来的数据
 * 重点在于该类有@ServerEndpoint的注解
 * **/
@ServerEndpoint(value="/echo")
public class EchoSocket {

	/**
	 * 客户端建立连接调用方法
	 * */
	@OnOpen
	public void open(Session session, EndpointConfig config){
		System.out.println(session.getId()+"\t客户连接了服务。");
	}
	
	/**
	 * 客户端断开连接调用方法
	 * */
	@OnClose
	public void close(Session session,CloseReason closeReason){
		System.out.println(session.getId()+"\t客户断开了服务。");
	}
	
	/**
	 * 接受客户端信息方法
	 * @param msg
	 * @param last
	 * */
	@OnMessage
	public void message(Session session,boolean last,String msg){
		System.out.println("客户端说："+msg);
		try {
			session.getBasicRemote().sendText("你好！");
			Thread.sleep(3000);//间隔三秒后再发送一个消息
			session.getBasicRemote().sendText("你也好呀！");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 错误监听
	 * 当客户端关闭浏览器窗口时调用
	 * */
	@OnError
	public void error(Session session,Throwable error){
		String id=session.getId();
		System.out.println("客户端"+id+"已关闭连接!");
		
		
	}
	
	public EchoSocket(){
		System.out.println("Socket对象创建");
	}
	
}

