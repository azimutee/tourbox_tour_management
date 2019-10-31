<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 

Statement stmt = null;
Statement stmt1 = null;
/*
투어 박스의 블록 추가,삭제,변경
*/
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
try{
      
    String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //에러나면   "" 이걸로 바꾸세요!!

    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.

    String sboxId = request.getParameter("sharedBoxId");
    String tboxId = request.getParameter("tourBoxId");


    class BLOCK
    {
  	  int num;//블록 번호
  	  String title;//블록 제목
  	  String date;//블록 날짜
  	  String startTime;//블록 시작 시간
  	  String endTime;//블록 종료 시간
  	  
  	  String cost;//블록 비용
  	  int placeNum;//블록 place 번호
  	  String path;//블록 이미지 url
  	  String memo; //블록 메모
  	  
  	  int sort;//블록 정렬할 index
  	 
    }
   
    class LOG
    {
    	int logNum;
    	String type;
    	String id;
    	ArrayList<BLOCK> blocks = new ArrayList<BLOCK>();
    }
    
	ArrayList<LOG> logs = new ArrayList<LOG>();
    
    /*
    
    1. log insert
    
    */
    
    stmt = conn.createStatement();

    rs = stmt.executeQuery("select * from sharedboxblock where boxNum=" + sboxId  );
    
    
    while(rs.next())
    {
    	stmt = conn.createStatement();
    	rs1 = stmt.executeQuery("select * from sharedblock where num=" + rs.getInt("blockNum")  );
    	
    	while(rs1.next())
    	{
    		/*
    		1.insert into tourblock
    		*/
    		String sql = "insert into tourblock values(?,?,?, ?,?,?, ?,?,?)";
            pstmt=conn.prepareStatement(sql);
            pstmt.setString(1, null);
            pstmt.setString(2, rs1.getString("title"));
            pstmt.setString(3, rs1.getString("date"));
            pstmt.setString(4, rs1.getString("stime"));
            pstmt.setString(5, rs1.getString("etime"));
            pstmt.setInt(6, rs1.getInt("cost"));
            pstmt.setInt(7, rs1.getInt("placeNum"));
            pstmt.setString(8, rs1.getString("path"));
            pstmt.setString(9, rs1.getString("memo"));
            pstmt.executeUpdate();
    		
            stmt = conn.createStatement();
        	rs2 = stmt.executeQuery("SELECT * FROM tourblock ORDER BY num DESC LIMIT 1" );
        	
        	
        	/*
    		3.insert into accountbox
    		*/
    		String sql3 = "insert into accountbox values(?,?,?)";
            pstmt=conn.prepareStatement(sql3);
            pstmt.setString(1, null);
            pstmt.setString(2, (String)session.getAttribute("id"));
            pstmt.setInt(3,Integer.valueOf(tboxId) );
        	
        	/*
    		3.insert into boxblock,log block
    		*/
        	while(rs2.next())
	        {
        		String sql1 = "insert into boxblock values(?,?,?)";
	            pstmt=conn.prepareStatement(sql1);
	            pstmt.setString(1, null);
	            pstmt.setInt(2, Integer.valueOf(tboxId));
	            pstmt.setInt(3, rs2.getInt("num"));
	            pstmt.executeUpdate();
	            
	            
	            if(sboxId!=null && tboxId!=null)
        	 	{
        	    	String sql2 = "insert into log values(?,?,?, ?,?,?)";
        	        pstmt=conn.prepareStatement(sql2);
        	        pstmt.setString(1, null);
        	        pstmt.setInt(2, rs2.getInt("num"));
        	        pstmt.setString(3, "add");
        	        pstmt.setInt(4,  Integer.valueOf(tboxId));
        	        pstmt.setInt(5, rs2.getInt("placeNum"));
        	        pstmt.setString(6, (String)session.getAttribute("id"));     
        	        pstmt.executeUpdate();
        	    }
	        }
        	
        	 
    		
    	}
    	    
    	
    	
    }
    out.print("ok");
    
  
 	
    
} 

catch (Exception e) 
{
       e.printStackTrace();
    // try, catch 문 실행 완료 후 실행되는 데 사용객체들을 닫아준다.
} 

finally 
{
       if (pstmt != null) 
    	   pstmt.close();
       
       if (conn != null) 
    	   conn.close();
}
    
 %>