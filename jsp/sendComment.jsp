<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 
String placeNum = request.getParameter("placeNum");

Statement stmt,stmt1 = null;
ResultSet rs,rs1 = null;
try
{
      
    String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //에러나면   "" 이걸로 바꾸세요!!

    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.
    String uid = (String)session.getAttribute("id");
   
    stmt = conn.createStatement();
    
    if(placeNum != null)
    {
       rs = stmt.executeQuery("select * from comment where placeNum =" + placeNum );
    	  
    }
    
    // try 문 내에서 예외상황이 발생 했을 시 실행
} 
   catch (Exception e) 
   {
       e.printStackTrace();
    // try, catch 문 실행 완료 후 실행되는 데 사용객체들을 닫아준다.
    } 

   finally {
       if (pstmt != null) pstmt.close();
       if (conn != null) conn.close();
    }
    
 %>