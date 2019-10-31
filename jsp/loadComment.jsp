<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.util.Date" %><%@ page import = "java.text.SimpleDateFormat" %><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 

String placeNum = request.getParameter("placeId");//클라이언트에서 파라미터 받음
Statement stmt,stmt1 = null;
ResultSet rs,rs1 = null;

/*
장소 별 코멘트 로드
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
    
    클라이언트에 보낼 PLACE,COMMENT 클래스
    
    */
    class PLACE
    {
  	  int recNum;//추천한 횟수
  	  int count;//여행한 횟수
    }
    
    class COMMENT
    {
    	String id;//사용자 아이디
    	String date;//적은 날짜
    	String content;//코멘트 내욘
    }
    ArrayList<COMMENT> ls = new  ArrayList<COMMENT>();
	PLACE p = new PLACE();
    if( placeNum !=null) //클라이언트에 보낼 클래스 내용 추가 : 각 place별로 코멘트의 내용과 추천 저장
    {
    	stmt = conn.createStatement();
    	//place 찾음
        rs = stmt.executeQuery("select * from place where num=" +  placeNum  );
        
        while(rs.next())
        	tmp = rs.getInt("recNum");//place의 추천횟수 찾음
   
        p.recNum = tmp;
        String rec= String.valueOf(tmp);

        stmt = conn.createStatement();
        //place를 가진 tourblock찾음
        rs = stmt.executeQuery("select * from tourblock where placeNum=" +  placeNum  );

        while(rs.next())
        p.count = rs.getRow(); //몇개인지 찾아서 여행한 횟수에 저장

        stmt = conn.createStatement();
        //place에 있는 comment찾음
        rs = stmt.executeQuery("select * from comment where placeNum=" +  placeNum  );
        while(rs.next())
        {
        	COMMENT c = new COMMENT();
        	c.id = rs.getString("id");
        	c.content = rs.getString("content");
        	
        	Date d = new Date();
        	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        	c.date = sdf.format(d);
        	
        	ls.add(c);
        }
        
        /*
        클라이언트에 보낼 json생성 및 출력
        */
        JSONObject obj = new JSONObject();
        JSONArray jArray = new JSONArray();//배열이 필요할때
        for (int i = 0; i < ls.size(); i++)//배열
        {
                JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
        
                sObject.put("id", ls.get(i).id);
                sObject.put("content", ls.get(i).content);
                sObject.put("date", ls.get(i).date);
                jArray.add(sObject);
               
         }  
        
        obj.put("place_rec", p.recNum);
        obj.put("place_cnt", p.count);
        obj.put("comment", jArray);//배열을 넣음

        out.print(obj.toString());
        
        
    }		
    // try 문 내에서 예외상황이 발생 했을 시 실행
} catch (Exception e) {
       e.printStackTrace();
    // try, catch 문 실행 완료 후 실행되는 데 사용객체들을 닫아준다.
} finally {
       if (pstmt != null) 
    	   pstmt.close();
       
       if (conn != null) 
    	   conn.close();
    }
    
 %>