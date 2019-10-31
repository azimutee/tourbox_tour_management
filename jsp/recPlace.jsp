<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.util.Date" %><%@ page import = "java.text.SimpleDateFormat" %><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 
String placeNum = request.getParameter("placeNum");////클라이언트에서 파라미터 받음
//String placeNum ="1";
Statement stmt,stmt1 = null;
ResultSet rs,rs1 = null;

/*
장소 추천
*/
try{
      /*
      디비 연동
      */
 String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //에러나면   "" 이걸로 바꾸세요!!
    int tmp  = -1;
    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.
    
    /*
      추천한 place찾아서 추천  숫자 증가시킴
    */
    if( placeNum !=null)
    {
    	stmt = conn.createStatement();
    	//place 찾음
        rs = stmt.executeQuery("select * from place where num=" +  placeNum  );
        
    	/*
    	찾은 place의 recNum 증가시켜 update
    	*/
        while(rs.next())
        	tmp = rs.getInt("recNum");
        ++tmp;
        String rec= String.valueOf(tmp);

        stmt = conn.createStatement();
        stmt.executeUpdate("update place set recNum = "+ rec + " where num= " + placeNum  );
        
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
    
	if (pstmt != null) 
		pstmt.close();
       
	if (conn != null) 
		conn.close();
    }
    
 %>