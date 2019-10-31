<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import = "java.text.SimpleDateFormat" %><%@ page import = "java.util.Date" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 

String content = request.getParameter("content");
String placeNum = request.getParameter("placeId");
/*
코멘트 저장
*/
Statement stmt,stmt1 = null;
ResultSet rs,rs1 = null;
try
{
     /*
     디비 연동
     */
    String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //에러나면   "" 이걸로 바꾸세요!!

    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.
    String uid = (String)session.getAttribute("id");
    
    
    /*
    comment에 정보 저장
    */
    if(content != null)
    {
    	String sql = "insert into comment values(?,?,?,?,?)";
        pstmt=conn.prepareStatement(sql);
        pstmt.setString(1, null);
        pstmt.setString(2, content);
        pstmt.setString(3, placeNum);
        pstmt.setString(4, uid);
        Date d = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        pstmt.setString(5, sdf.format(d));
        pstmt.executeUpdate();

        out.print("ok");
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