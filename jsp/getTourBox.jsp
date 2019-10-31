<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
ResultSet rs4 = null;
ResultSet block = null;
ResultSet place = null;
ResultSet pnames = null;

/*
모든 여행 상자 리스트를 가져옴
*/

try
{
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.

  int  blockCnt = 0;
  /*
  클라이언트에 보낼 박스블록 클래스
  */
  class BLOCK
  {
	  int boxNum;//박스 번호
	  String boxName;//박스 이름
	  String path;//박스 이미지 url
  }

  ArrayList<BLOCK> ls = new ArrayList<BLOCK>();
  ArrayList<String> locs = new ArrayList<String>();
  ArrayList<ArrayList<String>> locList = new ArrayList<ArrayList<String>>();
  
  stmt = conn.createStatement();
  rs = stmt.executeQuery("select distinct boxNum from boxblock " );//중복없이 박스 번호 가져옴

  ArrayList<BLOCK> block_ls = new ArrayList<BLOCK>();

  while(rs.next())//클라이언트에 보낼 블록 클래스 인스턴스 채우기: 각 박스들과 그안의 블록들
  {
	 BLOCK b = new BLOCK();
	 
	 b.boxNum = rs.getInt("boxNum");
	 
	 stmt = conn.createStatement();
	 /*
	 box를 찾음
	 */
     rs2 = stmt.executeQuery("select * from tourbox where num ="+ b.boxNum );
     while(rs2.next())
    	 b.boxName = rs2.getString("name");
	
     stmt = conn.createStatement();
     rs2 = stmt.executeQuery("select * from boxblock where boxNum ="+  rs.getInt("boxNum") +" and blockNum <> 0" );

     while(rs2.next())
     {
    	  stmt = conn.createStatement();
    	  rs3 = stmt.executeQuery("SELECT * FROM tourblock where num = "+rs2.getInt("blockNum") );
    	  while(rs3.next())
    		  b.path = rs3.getString("path");
    	  
    	  blockCnt++;
     }	 

     block_ls.add(b);
  }

  if(blockCnt!=0)
  for(int i=0;i<block_ls.size();i++)//클라이언트에 보낼 로그 클래스 인스턴스 채우기
  {    
	  stmt = conn.createStatement();
	  //박스 찾음
	  block = stmt.executeQuery("select * from boxblock where boxNum ="+ block_ls.get(i).boxNum );
	  while(block.next())//박스 안의 블록 찾음
	  {
		  stmt = conn.createStatement();
		  rs4 = stmt.executeQuery("select * from tourblock where num ="+ block.getInt("blockNum") );
	  }
	  
	  while(rs4.next())//블록의 place찾음
	  {
		  stmt = conn.createStatement();
		  place = stmt.executeQuery("select * from place where num ="+ rs4.getInt("placeNum") );
	  }
	  
	  while(place.next())//place 제목 저장
	  {
		  stmt = conn.createStatement();
		  locs.add(place.getString("name"));
		  
	  }
	  
	// HashSet 데이터 형태로 생성되면서 중복 제거됨
	  HashSet hs = new HashSet(locs);

	  // ArrayList 형태로 다시 생성
	  ArrayList<String> newLocs = new ArrayList<String>(hs);
	  
	  locList.add(newLocs);
	 
  }
  
//  클라이언트에 보낼 json 생성 및 출력
  
  JSONObject obj = new JSONObject();
  JSONArray jArray = new JSONArray();//배열이 필요할때
  for (int i = 0; i < block_ls.size(); i++)//배열
  {
          JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
  
          sObject.put("num", block_ls.get(i).boxNum);
          sObject.put("name", block_ls.get(i).boxName);
          sObject.put("path", block_ls.get(i).path);
        
          for (int j = 0; j < locList.size(); j++)//배열
          {
        	  for (int k = 0; k < locList.get(j).size(); k++)//배열
              {    
        		  sObject.put("loc", locList.get(j)); 
              } 
           }

    	  jArray.add(sObject); 	
    	  
   }  
  
  out.print(jArray.toString());
   

} 
catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}
%>