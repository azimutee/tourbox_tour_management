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

try
{
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.

  class BLOCK
  {
	  int boxNum;
	  String boxName;
	  String path;
  }

  ArrayList<BLOCK> ls = new ArrayList<BLOCK>();
  ArrayList<String> locs = new ArrayList<String>();
  ArrayList<ArrayList<String>> locList = new ArrayList<ArrayList<String>>();
  
  stmt = conn.createStatement();
  rs = stmt.executeQuery("select distinct boxNum from sharedboxblock " );

  ArrayList<BLOCK> block_ls = new ArrayList<BLOCK>();

  while(rs.next())
  {
	 BLOCK b = new BLOCK();
	 b.boxNum = rs.getInt("boxNum");
	 stmt = conn.createStatement();
     rs2 = stmt.executeQuery("select * from sharedbox where num ="+ b.boxNum );
     while(rs2.next())
    	 b.boxName = rs2.getString("name");
	
     stmt = conn.createStatement();
     rs3 = stmt.executeQuery("SELECT * FROM sharedblock ORDER BY num DESC LIMIT 1" );
    
     while(rs3.next())
    	 b.path = rs3.getString("path");
     
     block_ls.add(b);
  }


  for(int i=0;i<block_ls.size();i++)
  {    
	  stmt = conn.createStatement();
	  block = stmt.executeQuery("select * from sharedboxblock where boxNum ="+ block_ls.get(i).boxNum );
	  while(block.next())
	  {
		  stmt = conn.createStatement();
		  rs4 = stmt.executeQuery("select * from sharedblock where num ="+ block.getInt("blockNum") );
	  }
	  
	  while(rs4.next())
	  {
		  stmt = conn.createStatement();
		  place = stmt.executeQuery("select * from place where num ="+ rs4.getInt("placeNum") );
	  }
	  
	  while(place.next())
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
  
  JSONObject obj = new JSONObject();
  JSONArray jArray = new JSONArray();//배열이 필요할때
  for (int i = 0; i < block_ls.size(); i++)//배열
  {
          JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
  
         // out.print("size: "+block_ls.size());
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
  
  //obj.put("box", jArray);//배열을 넣음

  out.print(jArray.toString());
   
  
  
  
} 
catch(Exception e)
{     // 예외 처리
   e.printStackTrace();
}
%>