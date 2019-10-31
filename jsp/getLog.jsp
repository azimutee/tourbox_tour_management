<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%
Connection conn = null;
PreparedStatement pstmt = null; 

Statement stmt = null;
Statement stmt1 = null;

ResultSet rs = null;
ResultSet rs1 = null;

/*
로그를 가져옴
*/

try{
      
	/*
	디비와 연동
	*/
    String DB_SERVER = "localhost:3306"; //호스트 포트
    String DB_USERNAME = "root";//mysql 아이디
    String DB_PASSWORD = "0000"; //mysql 비밀번호
    String DB_DATABASE = "mydb"; //에러나면   "" 이걸로 바꾸세요!!

    String url = "jdbc:mysql://" + DB_SERVER + "/" + DB_DATABASE;
    Class.forName("com.mysql.jdbc.Driver");                       // 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
    conn=DriverManager.getConnection(url,DB_USERNAME, DB_PASSWORD);              // DriverManager 객체로부터 Connection 객체를 얻어온다.
 
    /*클라이언트에서 파라미터 받아옴*/

    String lastlog = request.getParameter("lastLogNum");
    String boxNum = request.getParameter("tourBoxId");

    /*
    전송할 tourblock의 내용을 저장할 클래스
    */
    class BLOCK 
    {
  	  int num; //블록 번호
  	  String title;//블록 제목
  	  String date;//블록 날짜
  	  String startTime;//블록 시작 시간
  	  String endTime;//블록 종료 시간
  	  
  	  String cost;//블록 비용
  	  int placeNum;//블록 place번호
  	  String path;//블록 사진 url
  	  String memo;//블록 메모
  	  
  	  int sort;//날짜 순으로 정렬할 index 
  	 
    }
   
   
   /*
   전송할 log내용을 담을 클래스
   */
    class LOG
    {
    	int logNum; //로그 번호
    	String type; //수행한 내용 타입
    	String id; //사용자 아이디
    	int blockNum;
    	BLOCK block; //바뀐 블록 내용
    }
    
	ArrayList<LOG> logs = new ArrayList<LOG>();
    
	stmt = conn.createStatement();
    rs = stmt.executeQuery("select * from log"); //log를 다 가져옴
    int total = rs.getRow();

    
	stmt = conn.createStatement();
    //rs = stmt.executeQuery("select * from log where num > "+ lastlog ); //log를 다 가져
    rs = stmt.executeQuery("select * from log where num >"+lastlog +" and boxNum = "+boxNum  ); //log를 다 가져
    
    while(rs.next()) //로그를 돌면서
    {
    	
    		LOG log = new LOG();
    		
    		if(!rs.getString("type").equals("delete"))
    		{		
    			stmt1 = conn.createStatement();	    		
	    		rs1 = stmt1.executeQuery("select * from tourblock where num = " + rs.getInt("blockNum"));
	    		//블록 내용 저장
	    		
	    	    while(rs1.next())
	    	    {
	    	    	
	    	    	BLOCK block = new BLOCK();
	    	    	block.num = rs1.getInt("num");
					block.cost = rs1.getString("cost");	
					block.placeNum = rs1.getInt("placeNum");
					block.path = rs1.getString("path");
					block.memo = rs1.getString("memo");
	
					block.date = rs1.getString("date");
					block.startTime = rs1.getString("stime");
					block.endTime = rs1.getString("etime");
						
					log.block = block;
	    	    }
    		}	
    	    //로그에 추가
    	    log.blockNum = rs.getInt("blockNum");
    	    log.logNum =  rs.getInt("num");
    	    log.type = rs.getString("type");
    	    log.id = rs.getString("id");
    	    logs.add(log);
    		
    	}
    	

	   JSONArray ary = new JSONArray();//배열이 필요할때
	   
	   for (int i = 0; i < logs.size(); i++)//배열  
	   {
	    		JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
	    		JSONArray jArray = new JSONArray();//배열이 필요할때
	    		JSONObject obj = new JSONObject();

	            obj.put("logNum", logs.get(i).logNum);
		    	obj.put("type", logs.get(i).type);
		    	obj.put("id", logs.get(i).id);
		    	
		    	if(logs.get(i).type.equals("delete"))
		    		obj.put("num", logs.get(i).blockNum);
		    	
		    	if(!logs.get(i).type.equals("delete"))
			    {
		    		sObject.put("stime", logs.get(i).block.startTime);
			  	    sObject.put("etime", logs.get(i).block.endTime);
			    	sObject.put("cost", logs.get(i).block.cost);
			  	    sObject.put("date", logs.get(i).block.date);
			  	    sObject.put("memo", logs.get(i).block.memo);
			  	    sObject.put("num", logs.get(i).block.num);
			  	    sObject.put("placeNum", logs.get(i).block.placeNum);
			  	       
			  	    jArray.add(sObject); 			      
			    }
		  	    obj.put("content",jArray);
		  	    ary.add(obj);
		  	    
	    }
		    
	   out.print(ary.toString()); 	
	

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