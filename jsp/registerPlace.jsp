<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 

//클라이언트에서 파라미터 받음
String name = request.getParameter("placeName");
String longtitude = request.getParameter("longitude");
String latitude = request.getParameter("latitude");
String address = request.getParameter("placeAddress");
String category = request.getParameter("category");
String locName = request.getParameter("localName");
String path = request.getParameter("placeImageUrl");

/*
장소 등록
*/

Statement stmt,stmt1 = null;
ResultSet rs,rs1 = null;
try{
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
    String type = request.getParameter("type");
    
    /*
    place에 정보 저장
    */
    if(name != null)
    {
    	String sql = "insert into place values(?,?,?, ?,?,?, ?,?,?)";
        pstmt=conn.prepareStatement(sql);
        pstmt.setString(1, null);
        pstmt.setInt(2, 0);
        pstmt.setString(3, name);
        pstmt.setString(4, longtitude);
        pstmt.setString(5, latitude);
        pstmt.setString(6, address);
        pstmt.setString(7, category);
        pstmt.setString(8, locName);
        pstmt.setString(9, path);
        pstmt.executeUpdate();

        
        stmt = conn.createStatement();
        
      //가장 최근에 만든 place번호 get
      
        rs = stmt.executeQuery("SELECT * FROM place ORDER BY num DESC LIMIT 1" );  
        int pnum =0;
        while(rs.next())
        	pnum = rs.getInt("num"); 
        
        
        /*
       log에 정보 저장
        */
        String sql1 = "insert into log values(?,?,?, ?,?,?)";
        pstmt=conn.prepareStatement(sql1);
        pstmt.setString(1, null);
        pstmt.setString(2, null);
        pstmt.setString(3, type);
        pstmt.setString(4, null);
        pstmt.setInt(5, pnum);
        pstmt.setString(6, (String)session.getAttribute("id"));     
        pstmt.executeUpdate();
        
        out.print(pnum);
      }
    
    
} 

catch (Exception e) 
{
       e.printStackTrace();
    // try, catch 문 실행 완료 후 실행되는 데 사용객체들을 닫아준다.
} 

finally 
{
       if (pstmt != null) pstmt.close();
       if (conn != null) conn.close();
}
    
 %>