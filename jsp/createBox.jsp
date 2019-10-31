<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 
String boxname = request.getParameter("boxName");
String boxpw = request.getParameter("boxPassword");//클라이언트에서 파라미터 받음

Statement stmt,stmt1 = null;
ResultSet rs,rs1 = null;

/*
처음 투어 박스를 생성함
*/

try{
    /*
        디비 연동
    */  
    String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //schema

    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.
 
  
    int box = 1;
    if(boxname != null && boxpw != null)
    {
    	/*
                  투어 박스에 자료 저장
        */
    	String sql = "insert into tourbox values(?,?,?,?)";
        pstmt=conn.prepareStatement(sql);
        pstmt.setString(1, null);
        pstmt.setString(2, boxname);
        pstmt.setString(3, boxpw);
        pstmt.setString(4, null);
        pstmt.executeUpdate();

        
        /*
                  새로 만들어진 투어박스의 이름 찾음
        */
        String sql2 = "select * from tourbox where name = "+"\'"+boxname+"\'"; 
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql2);
        
        while(rs.next())
        {	
        	box = rs.getInt("num");
        }
        
        String uid = (String)session.getAttribute("id"); //사용자 아이디 찾음
        
        
        /*
        accountbox에 내용 추가
        */
        String sql3 = "insert into accountbox values(?,?,?)";
        
        pstmt=conn.prepareStatement(sql3);
        pstmt.setString(1, null);
        pstmt.setString(2, uid);
        pstmt.setInt(3, box);
        
        pstmt.executeUpdate();

        /*
        boxblock에 내용 추가
        */
        pstmt=conn.prepareStatement("insert into boxblock values(?,?,?)");
        pstmt.setString(1, null);
        pstmt.setInt(2, box);
        pstmt.setString(3, null);
        
        pstmt.executeUpdate();
        
        out.print(box);
    }
    
    // try 문 내에서 예외상황이 발생 했을 시 실행
} catch (Exception e) {
       e.printStackTrace();
    // try, catch 문 실행 완료 후 실행되는 데 사용객체들을 닫아준다.
} finally {
       if (pstmt != null) pstmt.close();
       if (conn != null) conn.close();
    }
    
 %>