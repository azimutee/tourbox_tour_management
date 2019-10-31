<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="java.math.BigInteger"%><%@ page import="org.json.simple.*"%><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs0 = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;

/*
여행상자에 참가함
*/

try
{
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.
  //out.println("연결됨");      // 커넥션이 제대로 연결되면 수행된다.

  String uid = (String)session.getAttribute("id"); //세션에서 아이디 가져옴
//클라이언트에서 파라미터 받음
  String boxNum = request.getParameter("tourBoxId");
  String boxPW = request.getParameter("tourBoxPw");
 
  class BLOCK//클라이언트에 보내줄 클래스
  {
	  int num; //블록 번호
	  String title;//블록 제목
	  String date;//블록 날짜
	  String startTime;//블록 시작시간
	  String endTime;//블록 종료 시간
	  
	  String cost;//블록 비용
	  int placeNum;//블록 place번호
	  String path;//블록 이미지url
	  String memo;//블록 메모
	  
	  int sort;//날짜별로 정렬할 index
	 
  }
  
  
  ArrayList<BLOCK> blocks = new ArrayList<BLOCK>();
  	  
 
  if(boxPW != "") //비밀번호 있을 때: 가입하지않은 상자일때 
  {	
	  stmt = conn.createStatement(); //비밀 번호 확인 필요	 
	  rs = stmt.executeQuery("select * from tourbox where num=" + "\'" + boxNum + "\'" + "and pw="+ "\'"+boxPW+ "\'"  ); //박스 번호와 비밀번호 같은 박스 찾음
	  
	  stmt = conn.createStatement(); //비밀 번호 확인 필요
	  stmt.executeUpdate("insert into accountbox values(null," + "\'" + uid + "\'" + ","+ boxNum +")" ); //박스 번호와 비밀번호 같은 박스 찾음
	  
	  
  }
  else //비밀번호 없을 때: 이미 가입한 상자일때 
  {   stmt = conn.createStatement();
      //박스 번호같은 박스 찾음
	  rs = stmt.executeQuery("select * from tourbox where num=" + boxNum );
  }
  
  while(rs.next()) //클라이언트에 보낼 박스 인스턴스 채우기: 선택한 박스의 블록들
  {		 

	  stmt = conn.createStatement();
	  //박스의 블록 찾음
	  rs1 = stmt.executeQuery("select * from boxblock where boxNum=" +  boxNum );
	  {
	
		  while(rs1.next())
		  {
			  stmt = conn.createStatement();
			  //박스의 블록의 내용 찾음
			  rs2 = stmt.executeQuery("select * from tourblock where num=" + rs1.getString("blockNum") );
				  
			  while(rs2.next())//블록 내용 저장
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
					  
					  
					  String parse = block.startTime.split(" ")[0];
				  
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

	  Collections.sort(blocks, new Comparator<BLOCK>(){ //sort을 index로 정렬
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

		  
	      stmt = conn.createStatement();
	      //가장 최근에 생긴 log번호 찾기위해 가장 최근에 생성된 log column가==찾음
	      rs = stmt.executeQuery("SELECT * FROM log ORDER BY num DESC LIMIT 1" );
		  int lastLogNum = -1;
		  
		  while(rs.next())
		  {
			  lastLogNum = rs.getInt("num");
		  }
	      
		  /*
		  클라이언트에 보낼 json 채우고 출력
		  */
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
		  obj.put("lastLogNum", lastLogNum);
		  obj.put("blocks", jArray);//배열을 넣음

		  out.print(obj.toString());

	  }
	  
	
	  
}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
   /* int year = Integer.valueOf(block.date.substring(0, 4)) * 100000000;
	  int month = Integer.valueOf(block.date.substring(5, 7)) * 1000000;
	  int day = Integer.valueOf(block.date.substring(8, 10)) * 10000;
	  
	  int time = Integer.valueOf(block.startTime.substring(0, 2)) * 100;
	  int minute = Integer.valueOf(block.startTime.substring(3, 5));
	  */
}

%>