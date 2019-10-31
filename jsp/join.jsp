<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import = "java.sql.*" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs = null;

String uid = request.getParameter("id");
String uname = request.getParameter("name");
String upw = request.getParameter("password");//클라이언트에서 파라미터 받음
/*
회원가입
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


  stmt = conn.createStatement();
  
  
  if(uid != null)
  {
	//account 테이블에 정보 저장
	  stmt = conn.createStatement();
	  stmt.executeUpdate( "insert into account values ( \'" + uid + "\' , \'" + upw + "\', \'" + uname + "\',NULL)" );
      
	//accountbox 테이블에 정보 저장
	//  stmt = conn.createStatement();
	//  stmt.executeUpdate( "insert into accountbox values ( null" + " , \'" + uid + "\', null)");
      
	  out.print("ok");
  }  
  
  session.setAttribute("id",uid); //세션 설정
 
}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}

%>