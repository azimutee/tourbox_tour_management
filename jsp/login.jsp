<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%

Connection conn = null; //초기화
Statement stmt = null;//클라이언트에서 파라미터 받음
ResultSet rs0 = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
/*
로그인
*/

try
{
	
	/*
	디비 연동
	*/
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.
  //out.println("연결됨");      // 커넥션이 제대로 연결되면 수행된다.

  String uid = request.getParameter("id");

  String upw = request.getParameter("password");

  class BLOCK
  {
	  int boxNum;
  }
  ArrayList<BLOCK> ls = new ArrayList<BLOCK>();

 
 /*아이디와 비밀번호가 동일한 account 찾음*/
  stmt = conn.createStatement();

  rs0 = stmt.executeQuery("select * from account where id=" + "\'" + uid + "\'" + "and pw="+ "\'"+upw+ "\'"  );
  
  while(rs0.next()) 
  {
	  session.setAttribute("id",uid);//세션 생성
	  
	  stmt = conn.createStatement();
	  /*아이디와 동일한 accountbox 찾음*/
	  rs = stmt.executeQuery("select * from accountbox where userID=" + "\'" + uid + "\'" );
	  

	  /*
	  클라이언트에 보낼 박스 인스턴스 채움: 사용자가 가입한 투어박스와 그 블록들  
	  */
	  if(rs != null) 
	  {
		  while(rs.next())
	      {
	    	BLOCK b = new BLOCK();
	    	b.boxNum = rs.getInt("boxNum");
	    	
	    	 stmt = conn.createStatement();
	    	 //박스 찾음
	    	rs1 = stmt.executeQuery("select * from tourbox where num=" + "\'" + b.boxNum + "\'" );


	    	stmt = conn.createStatement();
	    	//박스의 블록 찾음
	    	rs2 = stmt.executeQuery("select * from boxblock where boxNum=" + "\'" + b.boxNum + "\'" );
	    	
	    	while(rs2.next())
	    	{	
	    		stmt = conn.createStatement();
	    		//투어 블록 찾음
	    		rs3 = stmt.executeQuery("select * from tourblock where num = "+rs2.getInt("blockNum"));
	    	}
	    	

	    	ls.add(b);
	 
	      }
		  
			

	  }
  }
  
 
  
 
 
 	/*
	클라이언트에 보낼 json생성
	*/

	
  JSONObject obj = new JSONObject();
  JSONArray jArray = new JSONArray();//배열이 필요할때
  for (int i = 0; i < ls.size(); i++)//배열
  {
          JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
  
          sObject.put("num", ls.get(i).boxNum);
          
          jArray.add(sObject);
         
   }  
  if(session.getAttribute("id")!= null)
	  obj.put("id", session.getAttribute("id"));
  else
	  obj.put("id", "");
  obj.put("box", jArray);//배열을 넣음

  out.print(obj.toString());
   
}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}

%>