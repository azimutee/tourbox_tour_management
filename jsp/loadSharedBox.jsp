<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="java.math.BigInteger"%><%@ page import="org.json.simple.*"%><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs0 = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
/*
원하는 공유 상자 내용 로드
*/

try
{
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.
  //out.println("연결됨");      // 커넥션이 제대로 연결되면 수행된다.

  String uid = (String)session.getAttribute("id");

  String boxNum = request.getParameter("sharedBoxId");//클라이언트에서 파라미터 받음
   //String boxNum = "1";
 		
  //out.print("updat5");
  
  //클라이언트에 보낼 블록 클래스
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
	  String memo;//블록 메모
	  
	  long sort;//날짜별로 정렬할 index
	 
  }
  

  ArrayList<BLOCK> blocks = new ArrayList<BLOCK>();
  	  
  
  // 클라이언트에 보낼 클래스 채우기: 각 공유 박스와 그 블록의 내용들
  
  if(boxNum != null)
  {
	  stmt = conn.createStatement();
	  //공유박스 찾음
	  rs = stmt.executeQuery("select * from sharedbox where num=" + boxNum );
	  
	  
	  while(rs.next())
	  {		 

		  stmt = conn.createStatement();
		  rs1 = stmt.executeQuery("select * from sharedboxblock where boxNum=" +  boxNum );
		  
			  while(rs1.next())
			  {
				  stmt = conn.createStatement();
				  rs2 = stmt.executeQuery("select * from sharedblock where num=" + rs1.getString("blockNum") );
				  
				  while(rs2.next())
				  {
						  //2016-11-27    18:15
						  BLOCK block = new BLOCK();
						  block.num = rs2.getInt("num");
						  block.title = rs2.getString("title");
						  block.cost = rs2.getString("cost");

						  block.placeNum = rs2.getInt("placeNum");
						  block.path = rs2.getString("path");
						  block.memo = rs2.getString("memo");
						  
						  block.date = rs2.getString("date");
						  block.startTime = rs2.getString("stime");
						  block.endTime = rs2.getString("etime");
					

						  int year = -1;
						  int month = -1;
						  int day = -1;
						  						
						  StringTokenizer sdate = new StringTokenizer(block.date);
						  int dcnt = 0;
						  while(sdate.hasMoreTokens()) 
						  {
									if(dcnt == 0)
										year = Integer.valueOf(sdate.nextToken("/"));
									else if(dcnt == 1)
										month = Integer.valueOf(sdate.nextToken("/"));
									else if(dcnt == 2)
										day = Integer.valueOf(sdate.nextToken("/"));
									
									dcnt++;
						  }
						  
						  
						  //String parse = block.startTime.replace("am", " ");
				String parse = block.startTime.split(" ")[0];
						  
						 // parse = parse.trim();
					  //분이랑 초를 나눠야한다능아됐다아니아니
					  						  
						  int time = -1;
						  int minute = -1;
						  
						  StringTokenizer stime = new StringTokenizer(parse);
						  int tcnt = 0;
						  while(stime.hasMoreTokens()) 
						  {
									if(tcnt == 0)
										time = Integer.valueOf(stime.nextToken(":"));
									else if(tcnt == 1)
										minute = Integer.valueOf(stime.nextToken(":"));
									
									tcnt++;
						  }
						  //2013/03/12,11:12 date type
						  //2147/48/36/47 int
						  //9223/37/20/36:85:4775807 long
						  block.sort = (100000000*year) + (1000000*month) + (10000*day) + (100*time) + minute;
						
						  
						  blocks.add(block);
				  }
				  
			   
			  }
			  

		  }
  }    
  

	  Collections.sort(blocks, new Comparator<BLOCK>(){//sort를 인덱스로 정렬
	    public int compare(BLOCK obj1, BLOCK obj2)
	    {
	    	if(obj1.sort < obj2.sort)
	    		return -1;
	    	else if(obj1.sort == obj2.sort)
	    		return 0;
	    	else
	    		return 1;
	    }
	  });


	  //클라이언트에 보낼 json 생성 및 출력

	  JSONObject obj = new JSONObject();
	  JSONArray jArray = new JSONArray();//배열이 필요할때
	  for (int i = 0; i < blocks.size(); i++)//배열
	  {
	          JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
	  
	          sObject.put("cost", blocks.get(i).cost);
	          sObject.put("date", blocks.get(i).date);
	          sObject.put("etime", blocks.get(i).endTime);
	          sObject.put("memo", blocks.get(i).memo);
	          sObject.put("num", blocks.get(i).num);
	        	          
	          sObject.put("path", blocks.get(i).path);
	          sObject.put("placeNum", blocks.get(i).placeNum);
	          sObject.put("stime", blocks.get(i).startTime);
	          sObject.put("title", blocks.get(i).title);
	          	         
	          jArray.add(sObject);       
	   }  

	  obj.put("box", boxNum);
	  obj.put("blocks", jArray);//배열을 넣음

	  out.print(obj.toString());
}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}

%>