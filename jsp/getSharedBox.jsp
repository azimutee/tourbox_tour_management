<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page import="org.json.simple.*"%><%@ page import = "java.util.*" %><%@ page import = "java.sql.*" %><%

Connection conn = null; //초기화
Statement stmt = null;
ResultSet rs = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
ResultSet rs4 = null;
ResultSet rs5 = null;
ResultSet block = null;
ResultSet place = null;
ResultSet pnames = null;

/*
모든 공유 상자 리스트를 가져옴
*/


try
{
   /*
   db와 연동
   */
  String url = "jdbc:mysql://localhost:3306/mydb";      // URL, "jdbc:mysql://localhost:3306/(mySql에서 만든 DB명)" << 입력 이때 3306은 mysql기본 포트
  String ID = "root";         // SQL 사용자 이름
  String PW = "0000";     // SQL 사용자 패스워드
  Class.forName("com.mysql.jdbc.Driver");              // DB와 연동하기 위해 DriverManager에 등록한다.
  conn=DriverManager.getConnection(url,ID,PW);    // DriverManager 객체로부터 Connection 객체를 얻어온다.

  /*
  클라이언트에 전송할 박스블록 클래스
  */
  class BLOCK
  {
     int boxNum; //박스 번호
     String boxName;//박스 이름
     String path;//박스 이미지 url
  }

  ArrayList<BLOCK> ls = new ArrayList<BLOCK>();
  ArrayList<String> locs = new ArrayList<String>();
  ArrayList<ArrayList<String>> locList = new ArrayList<ArrayList<String>>();
  
  stmt = conn.createStatement();
  rs = stmt.executeQuery("select distinct boxNum from sharedboxblock " ); //박스-블록 테이블에서 박스 번호 가져옴

  ArrayList<BLOCK> block_ls = new ArrayList<BLOCK>();

  while(rs.next())//클라이언트에 보낼 블록 클래스 인스턴스 채우기: 각 박스들과 그안의 블록들
  {
    BLOCK b = new BLOCK();
    b.boxNum = rs.getInt("boxNum");
    
    stmt = conn.createStatement();
     rs2 = stmt.executeQuery("select * from sharedbox where num ="+ b.boxNum );
     while(rs2.next())
        b.boxName = rs2.getString("name");

     stmt = conn.createStatement();
     rs3 = stmt.executeQuery("SELECT * FROM sharedboxblock where boxNum = "+b.boxNum );
     
     
     while(rs3.next())
     {
        stmt = conn.createStatement();
         rs5 = stmt.executeQuery("SELECT * FROM sharedblock where num="+rs3.getInt("blockNum") );
    
         while(rs5.next())
              b.path = rs5.getString("path");
     }
     
     block_ls.add(b);
  }


  for(int i=0;i<block_ls.size();i++)//클라이언트에 보낼 로그  클래스 인스턴스 채우기: 공유블록들과 그 place
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
     
   // HashSet 데이터 형태로 생성되면서 중복 데이터 제거됨
     HashSet hs = new HashSet(locs);

     // ArrayList 형태로 다시 생성
     ArrayList<String> newLocs = new ArrayList<String>(hs);
     
     locList.add(newLocs);
    
  }
  /*
  클라이언트에 보낼 json 정보 저장해 보냄
  */
  JSONObject obj = new JSONObject();
  JSONArray jArray = new JSONArray();//배열이 필요할때
  for (int i = 0; i < block_ls.size(); i++)//배열
  {
          JSONObject sObject = new JSONObject();//배열 내에 들어갈 json
  
          sObject.put("num", block_ls.get(i).boxNum);
          sObject.put("name", block_ls.get(i).boxName);
          sObject.put("path", block_ls.get(i).path);
        


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