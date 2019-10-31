<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import = "java.sql.*" %><%@ page import = "java.util.*" %><%@ page import="org.json.simple.*"%><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs = null;
/*
모든 장소 리스트를 가져옴
*/
try
{
	/*
	디비 연동
	*/
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.
  //out.println("연결됨");      // 커넥션이 제대로 연결되면 수행된다.

  stmt = conn.createStatement();
  rs = stmt.executeQuery("select * from place" );

  class PLACE //클라이언트에 보낼 place객체
  {
	  int num;//번호
	  int recNum;//추천 횟수
	  String name;//이름
	  String longtitude;//위도
	  String latitude;//경도
	  String addr;//주소
	  String category;//카테고리
	  String locName;//지역명
	  String path;//place image url
  }
  
  ArrayList<PLACE> ls = new ArrayList<PLACE>();
  //클라이언트에 보낼 객체 채움: place table의 내용
  if(rs != null) 
  {
	  while(rs.next())
      {
		 PLACE p = new PLACE();
		 p.num = rs.getInt("num");
		 p.recNum = rs.getInt("recNum");
		 p.name = rs.getString("name");
		 p.longtitude = rs.getString("longtitude");
		 p.latitude = rs.getString("latitude");
		 p.addr = rs.getString("address");
		 p.category = rs.getString("category");
		 p.locName = rs.getString("locName");
		 p.path = rs.getString("path");
		 ls.add(p);
      }
	  
  }
  
  /*
  
  클라이언트에 보낼 json 생성 및 출력
  
  */
  
  
  JSONObject obj = new JSONObject();
  JSONArray jArray = new JSONArray();//배열이 필요할때
  for (int i = 0; i < ls.size(); i++)//배열
  {
          JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
          sObject.put("num", ls.get(i).num);
          sObject.put("recNum", ls.get(i).recNum);
          sObject.put("name", ls.get(i).name);
          sObject.put("longtitude", ls.get(i).longtitude);
          sObject.put("latitude", ls.get(i).latitude);
          sObject.put("category", ls.get(i).category);
          sObject.put("addr", ls.get(i).addr);
          sObject.put("locName", ls.get(i).locName);
          sObject.put("path", ls.get(i).path);

    	  jArray.add(sObject); 	
   }
  
  //http://humble.tistory.com/20
   out.print(jArray.toString());
  
}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}

%>