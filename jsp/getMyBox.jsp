<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.sql.*" %><%@ page import = "java.util.*" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
/*
사용자 별로 박스를 가져옴
*/
try
{
	
	/*
	db와 연동
	*/
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.

  String uid = (String)session.getAttribute("id");//사용자 아이디 받음

  /*
  사용자가 가진 투어박스를 찾음
  */
  stmt = conn.createStatement();
  rs = stmt.executeQuery("select * from accountbox where userID=" + "\'" + uid + "\'" );
  
  class BLOCK
  {
	  int boxNum;//박스 번호
  }
  ArrayList<BLOCK> ls = new ArrayList<BLOCK>();
  
  if(rs != null) //클라이언트에 보낼 블록 채우기: 사용자의 가입박스와 그 블록들
  {
	  while(rs.next())
      {
    	BLOCK b = new BLOCK();
    	b.boxNum = rs.getInt("boxNum");
    	
    	 stmt = conn.createStatement();//1. 사용자의 투어박스 번호를 찾고
    	rs1 = stmt.executeQuery("select * from tourbox where num=" + "\'" + b.boxNum + "\'" );


    	stmt = conn.createStatement();//2. 투어박스에 있는 블록 번호를 찾고
    	rs2 = stmt.executeQuery("select * from boxblock where boxNum=" + "\'" + b.boxNum + "\'" );
    	
    	while(rs2.next())
    	{	
    		stmt = conn.createStatement(); //3. 투어블록의 번호를 가져온다.
    		rs3 = stmt.executeQuery("select * from tourblock where num = "+rs2.getInt("blockNum"));
    	}
    	

    	ls.add(b);
        
      }
  }
 
  /*
	클라이언트에 전송할 json 생성
	*/
  JSONObject obj = new JSONObject();
  JSONArray jArray = new JSONArray();//배열이 필요할때
  for (int i = 0; i < ls.size(); i++)//배열
  {
          JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
  
          sObject.put("num", ls.get(i).boxNum);
          
          jArray.add(sObject);
         
   }  
 
  out.print(jArray.toString());
 
}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}

%>