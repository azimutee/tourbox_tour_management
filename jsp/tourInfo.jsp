<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.sql.*" %><%@ page import = "java.util.Date" %><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%@ page import = "java.text.SimpleDateFormat" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet block_rs = null;
ResultSet box_rs = null;
ResultSet id_rs = null;
ResultSet member_rs = null;
/*
여행상자 정보 로드
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

  int sum=0;
   
  String name ="";//박스 이름
  String sdate = "";//시작 날짜
  String edate = ""; //종료 날짜
  String cost = "";//비용
  
  ArrayList<String> member = new ArrayList<String>(); //참가자 리스트
  String m = "";//참가자
	
  /*  
  클라이언트에 보낼 박스 인스턴스 채움 : 가장 최근 테이블의 정보 가져옴 
  */
  stmt = conn.createStatement();
  box_rs = stmt.executeQuery("SELECT * FROM tourbox ORDER BY num DESC LIMIT 1");//가장 최근 투어박스 찾음
  
  while(box_rs.next())
  {	  
	  name = box_rs.getString("name");   //아이디와 동일한 참가자 찾음
	  stmt = conn.createStatement();
      member_rs = stmt.executeQuery("select * from accountbox where boxNum=" + box_rs.getString("num") );
      while(member_rs.next())
      {
    	  m = m + member_rs.getString("userID") +"  ";//참가자 이름 저장
  
      }
  }
  
 
	  //날짜 저장
  Date d = new Date();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
   
  sdate = sdf.format(d);
  edate = sdf.format(d);
  cost = "0";
  
  
  /*  
  클라이언트에 보낼 json 생성 및 출력
  */
  
   JSONObject obj = new JSONObject();
   JSONArray jArray = new JSONArray();//배열이 필요할때
   
   obj.put("member",m);
   obj.put("name",name);
   obj.put("sdate",sdate);
   obj.put("edate",edate);
   obj.put("cost", cost);
  
   jArray.add(obj);
   
   
   out.print(jArray.toString());

}

catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
} //http://humble.tistory.com/20

%>