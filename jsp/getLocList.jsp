<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.sql.*" %><%@ page import = "java.util.*" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;

String boxNum = request.getParameter("boxNum");

try
{
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.
  //out.println("연결됨");      // 커넥션이 제대로 연결되면 수행된다.


  
}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}

%>