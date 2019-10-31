<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt,pstmt1,pstmt2 = null; 

String box = request.getParameter("tourBoxId");


/*
여행 상자 공유상자로 저장
*/

Statement stmt = null;
Statement stmt1 = null;
Statement stmt2 = null;

ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;

try
{   /*
	디비 연동
	*/
    String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //에러나면   "" 이걸로 바꾸세요!!
    int sbox_num = -1 ;
    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.
    
    stmt = conn.createStatement();
    rs = stmt.executeQuery("select * from boxblock where boxNum=" + box  );

    
    if(box != null)
    {
    	
    	/*
    	  sharedbox insert
    	*/
    	String sql = "insert into sharedbox values(?,?,?)";//n번째 공유상자, 공유된 상자의 투어박스 아이디, 이름
        pstmt=conn.prepareStatement(sql);
        pstmt.setString(1, null);
        pstmt.setInt(2, Integer.valueOf(box));
        
        stmt = conn.createStatement();
        rs = stmt.executeQuery("select * from tourbox where num=" + box  );
       
        while(rs.next())
        	pstmt.setString(3,rs.getString("name"));
        
        pstmt.executeUpdate();
  
        /*
  	     sharedblock insert
  	    */
  	  //가장 최근에 생성된 sharedBox 를 찾음
        stmt1 = conn.createStatement();
        rs1 = stmt1.executeQuery("SELECT * FROM sharedbox ORDER BY num DESC LIMIT 1");
       
        
        while(rs1.next())
        {	
        	sbox_num = rs1.getInt("num");//가장 최근에 생긴 공유 상자 아이디
        }

        /*        
       tourbox,tourblock,boxblock를 
       sharedtourbox,sharedtourblock,sharedboxblock에 복사 
        */
        stmt = conn.createStatement();
        //박스의 블록 찾음
        rs = stmt.executeQuery("select * from boxblock where boxNum=" + box );
           
        while(rs.next())
        {
        	
            stmt1 = conn.createStatement();
            //투어블록 찾음
            rs1 = stmt1.executeQuery("select * from tourblock where num=" + rs.getInt("blockNum")  );
        	
        	while(rs1.next())//투어블록 내용 복사
        	{
        		//sharedblock에 저장
        		pstmt=conn.prepareStatement( "insert into sharedblock values(?,?,?,?,?,?,?,?,?)");
        		pstmt.setString(1, null);
        		pstmt.setString(2, rs1.getString("title"));
                pstmt.setString(3, rs1.getString("date"));
                pstmt.setString(4, rs1.getString("stime"));
                pstmt.setString(5, rs1.getString("etime"));
                pstmt.setString(6, rs1.getString("cost"));
                pstmt.setString(7, rs1.getString("placeNum"));
                pstmt.setString(8, rs1.getString("path"));
                pstmt.setString(9, rs1.getString("memo"));
                
                pstmt.executeUpdate();
                //sharedboxblock에 저장
                String sql2 = "insert into sharedboxblock values(?,?,?)";
                pstmt1=conn.prepareStatement(sql2);

                pstmt1.setString(1,null );
                pstmt1.setInt(2,sbox_num);
        
                //sharedblock에 가장 최근에 저장된 번호 가져옴
                stmt1 = conn.createStatement();
                rs2 = stmt1.executeQuery("SELECT * FROM sharedblock ORDER BY num DESC LIMIT 1");
                while(rs2.next())
                     pstmt1.setInt(3,rs2.getInt("num") );
                
                pstmt1.executeUpdate();
            }

    }
        	
        out.print(sbox_num);//공유상자 번호 클라이언트에 출력
         
  }
       

   
} 


catch (Exception e) {
       e.printStackTrace();
    // try, catch 문 실행 완료 후 실행되는 데 사용객체들을 닫아준다.
} finally {
       if (conn != null) conn.close();
    }
    
 %>