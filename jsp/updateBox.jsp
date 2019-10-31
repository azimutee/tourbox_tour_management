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
try{
      
    String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //에러나면   "" 이걸로 바꾸세요!!

    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.

    /*
    
    stime:20:17 pm
etime:20:17 pm
cost:10000
memo:study
type:add
date:2016/11/2
tourBlockId:undefined
    */
    
    String blockNum = request.getParameter("tourBlockId");
    String boxNum = request.getParameter("tourBoxId");
    String type = request.getParameter("type");
    String placeNum = request.getParameter("placeNum");

   
    String date = request.getParameter("date");
    String stime = request.getParameter("stime");
    String etime = request.getParameter("etime");
    String cost = request.getParameter("cost");
    String path = request.getParameter("path");
    String memo = request.getParameter("memo");
    
    stmt = conn.createStatement();

    

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
    
    if(boxNum!=null)
 	{
        if(type.equals("add") )//투어 박스에 블록 추가
        {
        	String sql4 = "insert into tourblock values(?,?,?, ?,?,?, ?,?,?)";
            pstmt=conn.prepareStatement(sql4);
            pstmt.setString(1, null);
            pstmt.setString(2, null);
            pstmt.setString(3, date);
            pstmt.setString(4, stime);
            pstmt.setString(5, etime);
            pstmt.setString(6, cost);
            pstmt.setInt(7, Integer.valueOf(placeNum));
           

            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM place where num = "+placeNum );
            while(rs.next())
            	pstmt.setString(8, rs.getString("path"));
           
            pstmt.setString(9, memo);
            pstmt.executeUpdate();
          
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM tourblock ORDER BY num DESC LIMIT 1");
            
            String sql = "insert into log values(?,?,?, ?,?,?)";
            pstmt=conn.prepareStatement(sql);
            pstmt.setString(1, null);
            
            int block = -1; 
            
            
            while(rs.next())
            {
            	pstmt.setInt(2, rs.getInt("num"));
            	block =  rs.getInt("num");
            }
            
            pstmt.setString(3, type);
            pstmt.setInt(4, Integer.valueOf(boxNum));
            pstmt.setInt(5, Integer.valueOf(placeNum));
            pstmt.setString(6, (String)session.getAttribute("id"));     
            pstmt.executeUpdate();
            
            String sql5 = "insert into boxblock values(?,?,?)";
            pstmt=conn.prepareStatement(sql5);
            pstmt.setString(1, null);
            pstmt.setInt(2,Integer.valueOf(boxNum));
            
            pstmt.setInt(3, block);     
            
            pstmt.executeUpdate();
            
            
            out.print("ok");
        	
        }
                
        else if(type.equals("modify")&& blockNum!=null)//투어 박스에 블록 변경
        {
            
        	String sql = "insert into log values(?,?,?, ?,?,?)";
            pstmt=conn.prepareStatement(sql);
            pstmt.setString(1, null);
            pstmt.setInt(2, Integer.valueOf(blockNum));
            pstmt.setString(3, type);
            pstmt.setInt(4, Integer.valueOf(boxNum));

            rs = stmt.executeQuery("SELECT * FROM tourblock where num = "+blockNum );
            while(rs.next())
            {
            	pstmt.setString(5, rs.getString("placeNum"));
            }
            pstmt.setString(6, (String)session.getAttribute("id"));     
            pstmt.executeUpdate();
        	
        	if(date!=null)
        	{
        		stmt = conn.createStatement();    
                stmt.executeUpdate( "update tourblock set stime = \'" + stime + "\' where num="+blockNum );   
                stmt.executeUpdate( "update tourblock set etime = \'" + etime + "\' where num="+blockNum );
                stmt.executeUpdate( "update tourblock set cost = \'" + cost + "\' where num="+blockNum );
                stmt.executeUpdate( "update tourblock set memo = \'" + memo + "\' where num="+blockNum );
                stmt.executeUpdate( "update tourblock set date = \'" + date + "\' where num="+blockNum );   
        	}
        	
        	out.print("ok");
        }
        
       
        else if(type.equals("delete")&& blockNum!=null)//투어 박스에 블록 삭제
        {
        
        	
     	   String sql = "insert into log values(?,?,?, ?,?,?)";
           pstmt=conn.prepareStatement(sql);
           pstmt.setString(1, null);
           pstmt.setInt(2, Integer.valueOf(blockNum));
           pstmt.setString(3, type);
           pstmt.setInt(4, Integer.valueOf(boxNum));


           rs = stmt.executeQuery("SELECT * FROM tourblock where num = "+blockNum );
           while(rs.next())
           {
           	
        	   pstmt.setString(5, rs.getString("placeNum"));
           }
           
           pstmt.setString(6, (String)session.getAttribute("id"));     
           pstmt.executeUpdate();
        	
    	    stmt = conn.createStatement();
        	stmt.executeUpdate( "delete from tourblock where num= "  + blockNum );
        	
        	stmt = conn.createStatement();
        	stmt.executeUpdate( "delete from boxblock where boxNum= " + boxNum + " and blockNum= " + blockNum);   
        
       	
        	out.print("ok");
        }
    }
 
 	/*
    2. tourbox update
    
    delete: block num
    add/modify : column 정보 다 json으로 출력
    register place
 	[{logNum, type, content: {}}, {ddddd}, {ddddd}]
 			
    */
        
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