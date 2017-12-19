package com.cn.websocket;

import java.util.HashMap;

import javax.websocket.CloseReason;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import sun.print.resources.serviceui;

/**
 * 简单websocktchat聊天室类
 * **/
@ServerEndpoint(value="/chat")
public class WebSocketChat {

	private boolean first=true;
	private String name;//用户自定义昵称
	//key为session 的id value为这个session对象
	private static final HashMap<String, Object> connect = new HashMap<String,Object>();
	//key为session的id  value为这个用户自定义的昵称
	private static final HashMap<String, String> userMap=new HashMap<String,String>();
	
	private Session session;
	
	/**
	 * 
	 * 客户端建立连接时调用方法
	 * **/
	@OnOpen
	public void clientopen(Session session){
		this.session=session;
		connect.put(session.getId(), this);
	}
	
	
	/**
	 * 客户端断开连接时
	 * **/
	@OnClose
	public void clientclose(Session session){
		//当有用户退出时对其它用户进行广播
		String message="系统："+userMap.get(session.getId())+"退出聊天";
		userMap.remove(session.getId());
		connect.remove(session.getId());
		for(String key:connect.keySet()){
			WebSocketChat client=null;
			try {
				client=(WebSocketChat) connect.get(key);
				synchronized (client) {
					client.session.getBasicRemote().sendText(message);
				}
			} catch (Exception e) {
				connect.remove(client);
				try {
					client.session.close();
				} catch (Exception e2) {
					e.printStackTrace();
				}
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * 对所有人进行广播
	 * **/
	public static void sendAll(String mess,Session session){
		String who=null;
		for(String key:connect.keySet()){
			WebSocketChat client=null;
			try {
				client=(WebSocketChat) connect.get(key);
				if(key.equalsIgnoreCase(session.getId())){
					who="我对大家说：";
				}else{
					who=userMap.get(session.getId())+"对大家说：";
				}
				synchronized (client) {
					client.session.getBasicRemote().sendText(who+mess);
				}
			} catch (Exception e) {
				connect.remove(client);
				try {
					client.session.close();
				} catch (Exception e2) {
					e.printStackTrace();
				}
				e.printStackTrace();
			}
		}
	}
	
	public String getName(){
		return this.name;
	}
	
	/**
	 * 接受处理客户端的值
	 * **/
	@OnMessage
	public void echo(String message,Session session){
		System.out.println(message);
		WebSocketChat client=null;
		//判断值是否是第一次传的值,由webonopen传入
		if(first){
			this.name=message;
			String mes="系统：欢迎"+name;
			//将昵称和对应的session存入hashmap
			userMap.put(session.getId(), name);
			//将信息广播给所有的用户
			for(String key :connect.keySet()){
				try {
					client=(WebSocketChat) connect.get(key);
					synchronized(client){
						//给客户端广播系统信息
						client.session.getBasicRemote().sendText(mes);
					}
				} catch (Exception e) {
					//如果发生错误就将该对象移除
					connect.remove(client);
					try {
						//并关闭session
						client.session.close();
					} catch (Exception e2) {
						e.printStackTrace();
					}
				}
			}
			first=false;//再之后传的值都不再是第一次
		}else{
			/**
			 * message的值为xxx@xxxx的形式为要发给的用户昵称，all代表发送给所有的人
			 * message.split("@",2);以@为分割符把字符串分xxx和xxxx两部分
			 * **/
			String [] list=message.split("@",2);
			if(list[0].equalsIgnoreCase("all")){//all发送给所有人
				sendAll(list[1],session);
			}else{
				boolean you=false;//标记是否找到发送的用户
				for(String key: userMap.keySet()){
					if(list[0].equalsIgnoreCase(userMap.get(key))){
						client=(WebSocketChat) connect.get(key);
						synchronized (client) {
							try {
								//发送信息给指定的用户
								client.session.getBasicRemote().sendText(userMap.get(session.getId())+"对你说："+list[1]);
							} catch (Exception e) {
								e.printStackTrace();
						}
					}
					you=true;//标记为找到该用户了
					break;
				}
			}
				if(you){//为true是页面显示自己对xx说,否则就显示暂无此用户
					try {
						session.getBasicRemote().sendText("我对"+list[0]+"说："+list[1]);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}else{
					try {
						session.getBasicRemote().sendText("系统说：暂无此用户");
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
		}
	}
	
	
	
	
	/**
	 * 客户端错误监听
	 * **/
	@OnError
	public void error(Session session,Throwable error){
	
	}
}
