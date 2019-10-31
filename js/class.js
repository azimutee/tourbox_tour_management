class UI{
	constructor(){
		this.showLoading();
		this.initGoogleMap();
		this.setLoginStatus(0);
		this.currentTourBoxId = 0;
		this.selectedBlock = 0;
		this.lastLogNum = 0;
		this.updateLogNum = [];
		this.updater = setInterval(function(){
			ui.updateLog();
		}, 3000);
		
		//여행지 설정
		this.local = ["전체", "서울", "인천", "부산", "대구", "전주", "울산", "광주", "통영", "경주", "부여", "속초", "강릉", "제주", "기타"];
		this.placeType = ["관광", "숙소", "식사", "오락"];
		
		//각종 리스트, 목록 값 설정
		this.setLocal(this.local, "destination");
		this.setLocal(this.local, "allTourBoxSelectList");
		this.setLocal(this.local, "sharedList");
		this.setLocal(this.placeType, "place");
		
		this.setDropList(this.local, "localName");
		this.setDropList(this.placeType, "category");
		
		//timeDropper 설정
		$(".blockTime" ).timeDropper(); 
		
		//버튼 이벤트 핸들러 등록
		$("#myTourBoxBt").on( "click", function() {
			ui.showWindow("joinedTourBoxListM");
		});

		//로그인 창에서 로그인 버튼 클릭 시 
		$("#loginBt").on( "click", function() {
			account.login();
		});

		//로그아웃
		$("#logoutBt").on( "click", function() {
			$('#loginM form').trigger("reset");
			account.logout();
		});
		
		//가입하기 버튼 클릭시 회원 가입창 보여줌
		$("#joinBt").on( "click", function() {
			account.showJoin();
		});
		
		//회원가입 창에서 가입하기 눌렀을 시
		$("#joinCommit").on( "click", function() {
			account.join();
		});
		
		//회원가입 창에서 로그인(뒤로가기) 눌렀을 시 다시 로그인창 띄움
		$("#joinCancel").on( "click", function() {
			ui.hideWindow("joinM");
			ui.showWindow("loginM");
		});		
		
		//공유버튼 클릭
		$("#shareBt").on( "click", function() {
			ui.setConfirmMsg("본 여행상자를 공유하시겠습니까?", function(){
				$.post( "./jsp/shareBox.jsp", {"tourBoxId" : ui.getCurrentTourBoxId()}).done(function(result){
					if(result){
						ui.setErrorMsg("여행상자가 공유되었습니다.");
						ui.showWindow("errorM");
						//new sharedBox
					}
				});	
			});
			ui.showWindow("confirmM");
		});		

		//추천하기 버튼 클릭
		$("#recommendBt").on( "click", function() {
			$("#pRecommend")[0].innerHTML ++;
			
			$.post( "./jsp/recPlace.jsp", {"placeNum":$("#placeInfoM").data("placeId")}).done(function(result){
				if(result=="ok"){
					$("#recommendBt").addClass("highlight hover");
//					console.log($("#recommendBt"));	
				}else{
					$("#pRecommend")[0].innerHTML--;					
				}
			});
			/* this.recNum = 0; */
			//hover highlight(class)
		});		
		
      //여행블록 추가
      $("#showTourBlockMBt").on( "click", function() {
		  $('#setTourBlockM form').trigger("reset");
         $("#setTourBlockM .modalTitle").text("새 여행블록 추가");
         ui.hideWindow("placeInfoM");
         ui.hideWindow("recommendPlaceListM");
         ui.showWindow("setTourBlockM");
         //날짜
         console.log($("#placeTourDate"));
         
         var cal = $("#datePicker").glDatePicker(true).options.selectedDate;
         $("#placeTourDate").text(cal.getFullYear() + "/" + (cal.getMonth()+1) + "/" + cal.getDate());
         $("#updateTourBlockBt").hide();
         $("#deleteTourBlockBt").hide();
         $("#addTourBlockBt").show();
         
         //placeInfo 가져오기
         var place = placeList.getPlace($("#placeInfoM").data("placeId"));
         $("#setTourBlockM .place").css({'background-image':'url('+place.getPlaceImageUrl()+')'});
         $("#setTourBlockM .tourTitle").text("["+ place.getLocName() +"] "  + place.getPlaceName());
      });

//여행 블록 등록 버튼
      $("#addTourBlockBt").on( "click", function() {
       var cal = $("#datePicker").glDatePicker(true).options.selectedDate;
       calendar.setSelectableDate(cal.getFullYear(), cal.getMonth(), cal.getDate());
      
         $.post( "./jsp/updateBox.jsp", $("#setTourBlockM form").serialize() + "&type=add&date="+ calendar.getSelectedDate()+"&tourBlockId="+ $("#setTourBlockM").data("tourBlockId")+"&tourBoxId="+ ui.getCurrentTourBoxId()+"&placeNum="+$("#placeInfoM").data("placeId")).done(function(result){
            if(result){
               ui.hideWindow("setTourBlockM", ui.updateLog);
               ui.showWindow("recommendPlaceListM");
               ui.setRecommendM($("#placeInfoM").data("placeId"));
            }
         });   
      });      
      
      //여행블록 수정
      $(document).on("click","#tourBoxContent .block",function(){ 
         var place = placeList.getPlace($(this).data("placeId"));
         $("#setTourBlockM .place").css({'background-image':'url('+place.getPlaceImageUrl()+')'});
         ui.showWindow("setTourBlockM");
         $("#setTourBlockM .modalTitle").text("여행블록 수정");
         $("#addTourBlockBt").hide();
         $("#updateTourBlockBt").show();
         $("#deleteTourBlockBt").show();
         ui.setSelectedBlock($(this));
         
         //여행지 정보 가져오기
         var place = placeList.getPlace($(this).data("placeId"));
         $("#setTourBlockM .place").css({'background-image':'url('+place.getPlaceImageUrl()+')'});
         $("#setTourBlockM .tourTitle").text("["+ place.getLocName() +"] "  + place.getPlaceName());
         
         $("#setTourBlockM").data("tourBlockId", $(this).data("tourBlockId"));
         var tourBlock = tourBoxList.getTourBox(ui.getCurrentTourBoxId()).getTourBlock($(this).data("tourBlockId"));
         var cal = new Date(tourBlock.date);
         $("#placeTourDate").text(cal.getFullYear() + "/" + (cal.getMonth()+1) + "/" + cal.getDate());
         $("#setTourBlockM input[name='etime']").text(tourBlock.etime);
         $("#setTourBlockM input[name='stime']").val(tourBlock.stime);
         $("#setTourBlockM input[name='etime']").val(tourBlock.etime);
         $("#setTourBlockM textarea[name='memo']").val(tourBlock.memo);
         $("#setTourBlockM input[name='cost']").val(tourBlock.cost);
      });

      
      //여행 블록 수정 버튼
      $("#updateTourBlockBt").on( "click", function() {
         $.post( "./jsp/updateBox.jsp", $("#setTourBlockM form").serialize() + "&type=modify&date="+ calendar.getSelectedDate()+"&tourBlockId="+$("#setTourBlockM").data("tourBlockId")+"&tourBoxId="+ ui.getCurrentTourBoxId()+"&placeNum="+$("#placeInfoM").data("placeId")).done(function(result){
            if(result){
               ui.hideWindow("setTourBlockM", ui.updateLog);
            }
         });   
      });        
		
		//여행 블록 삭제 버튼
		$("#deleteTourBlockBt").on( "click", function() {
			$.post( "./jsp/updateBox.jsp", "type=delete&tourBlockId="+ $("#setTourBlockM").data("tourBlockId")+"&tourBoxId="+ ui.getCurrentTourBoxId()).done(function(result){
				if(result){
					ui.hideWindow("setTourBlockM", ui.updateLog);
				}
			});	
		});		

		//여행지 등록 버튼
		$("#registerPlaceBt").on( "click", function() {
			ui.searchLocation($(".placeAddress").val());
			if(!ui.newPlaceSet){
				ui.setErrorMsg("주소를 확인해주세요.");
				ui.showWindow("errorM");
			}else{	
				var newPlace = ui.getNewPlaceAddress();
				$(".placeAddress").val(newPlace.address);
//				console.log( $( "#addPlaceM form" ).serialize() + "&latitude=" + newPlace.latitude + "&longitude=" + newPlace.longitude);
				$.post( "./jsp/registerPlace.jsp", $( "#addPlaceM form" ).serialize() + "&latitude=" + newPlace.latitude + "&longitude=" + newPlace.longitude).done(function(result){
					if(result){
						//새 여행지 추가
						var place = new Place($( "input[name='placeImageUrl']" ).val(), 0, parseInt(result), newPlace.latitude, $( "input[name='placeName']" ).val(), newPlace.longitude, $( "select[name='localName'] option:selected" ).val(), $( "select[name='category'] option:selected" ).val(), newPlace.address);
						place.showPlace();
						ui.hideWindow("addPlaceM");
						ui.hideLoading();
						console.log(place);
					}
				});	
			}		
			//ui.hideWindow("addPlaceM");
			//ui.registerTourBlock();
		});		
		
		$(".placeAddress").on("keydown", function() {
//			console.log(1);
			ui.searchLocation($(".placeAddress").val());
		});

		//여행지 클릭
		$(document).on("click","#placeList .place, #recPlaceList .place",function(){ 
			//placeInfoM set
			var place = placeList.getPlace($(this).data("placeId"));
			$("#recommendBt").removeClass("bt");
			$("#recommendBt").addClass("bt");
			ui.showWindow("placeInfoM");
			$("#placeInfoM .place").css({'background-image':'url('+place.getPlaceImageUrl()+')'});
			$("#placeInfoM").data("placeId", $(this).data("placeId"));
			$("#placeCommentList").empty();
			//댓글, 추천수, 여행횟수를 불러오고 이를 반영함
			$.post( "./jsp/loadComment.jsp", "placeId=" + place.getPlaceId()).done(function(result){
					if(result){
						var placeInfo=$.parseJSON(result);
						$("#placeInfoM .blockTitle").text("["+ place.getLocName() +"] "  + place.getPlaceName());
						$("#pRecommend").text(placeInfo.place_rec);
						$("#pTourBox").text(placeInfo.place_cnt);
						
						var commentList = placeInfo.comment;
						for(var i=0; i < commentList.length; i++){
							place.addComment(commentList[i].id, new Date(commentList[i].date), commentList[i].content);
						}
					}
				});		
		});
		
		//댓글 작성 클릭
		$("#placeCommentWriteBt").on( "click", function(){
			//댓글을 추가하고 서버에 저장
			var place = placeList.getPlace($("#placeInfoM").data("placeId"));
			place.addComment(account.getAccountId(), new Date(), $( "#placeCommentArea input[name*='content']" ).val());
			$.post( "./jsp/storeComment.jsp", "placeId=" + place.getPlaceId()+"&content="+$( "#placeCommentArea input[name*='content']" ).val());
			$('#placeInfoM form').trigger("reset");
		});
		
		//로그인 에러 창에서 확인 버튼 클릭 시
		$("#errorBt").on( "click", function() {
			ui.hideWindow("errorM");
			ui.showWindow("loginM");
		});		

		//list 클릭
		$(".list > li").on( "click", function() {
			$(this).siblings().removeClass();
			$(this).addClass("hover");
			ui.filterTourPlace();
			//place list 새로고침 하는 함수
		});		
		
/*   		//검은 화면 클릭 시 창 모두 제거
		$("#blackPanel").on( "click", function() {
				ui.hideLoading();
				$(".modalWindow").hide();				
		});   */
		
		//닫기 버튼
		$(".cancel, #confirmOk, #confirmCancel, #errorOk").on( "click", function() {
			var parentWindowName = $(this).parent().attr('id');
			
			//여행상자가 로드 된 상태가 아니면 내 여행상자 화면을 닫을 수 없음
			if(parentWindowName=="joinedTourBoxListM"&&!ui.currentTourBoxId){
				return false;
			}
			
			$(this).parent(".modalWindow").fadeOut(100, function(){
				if(parentWindowName=="confirmM"&&$("#errorM:visible").length){
					//nothing
				}else if($(".modalWindow:visible[id!='recommendPlaceListM'][id!='errorM']").length == 0){
					ui.hideLoading();
				}
			});
		});
		
		//새 여행상자 버튼 클릭
		$("#cCreateTourBoxBt").on( "click", function() {
			if($( "#createTourBoxM input[name='boxName']" ).val() == "" || $( "#createTourBoxM input[name='boxPassword']" ).val() == ""){
				ui.setErrorMsg("제목과 비밀번호를 모두 입력하세요.");
				ui.showWindow("errorM");
			}else{
				$.post( "./jsp/createBox.jsp", $( "#createTourBoxM form" ).serialize()).done(function(tourBoxId){
					if(tourBoxId){
						var cal = $('#datePicker').glDatePicker(true);
						cal.options.specialDates = null;
						cal.render();
						ui.setCurrentTourBoxId(tourBoxId);
						$(".modalWindow").hide();	
						ui.reset()
						var newTourBox = new TourBox(parseInt(tourBoxId), $("#createTourBoxM form input[name*='boxName']").val(), null);
						newTourBox.setInfo();
						tourBoxList.addMyTourBoxList(tourBoxId);
						tourBoxList.loadMyTourBoxList();
						ui.showLoading();
						ui.updateTourDate();
						ui.setConfirmMsg("다른 여행자의 여행상자를 가져올 수 있습니다.", function(){
							ui.showWindow("sharedTourBoxListM");
						});	

						ui.showWindow("confirmM");
					}else{
						ui.setErrorMsg("이미 존재하는 여행상자 이름입니다.");
						ui.showWindow("errorM");
					}
				});	
			}			
		});
	
		//새 여행상자
		$("#jCreateTourBoxBt").on( "click", function() {
			$('#createTourBoxM form').trigger("reset");
			ui.showWindow("createTourBoxM");
		});	
		
		//여행상자 참여 버튼 클릭
		$("#joinTourBoxBt").on( "click", function(){
			//여행상자 
			ui.showWindow("allTourBoxListM");
		});
		
		//새 여행지 등록
		$("#registerPlace").on( "click", function(){
			this.newPlaceSet = 0;
			$('#addPlaceM form').trigger("reset");
			ui.showWindow("addPlaceM");
		});
		
		//여행상자 참여
		$(document).on("click","#joinedTourBoxList .block, #allTourBoxList .block",function(){ 
			if(tourBoxList.getMyTourBoxIdList().includes($(this).data("tourBoxId"))){
				tourBoxList.getTourBox($(this).data("tourBoxId")).loadTourBlocks();
			}else{
				$("#joinTourBoxM").data("tourBoxId", $(this).data("tourBoxId"));
				ui.setJoinTourBoxTitle(tourBoxList.getTourBox($(this).data("tourBoxId")).getTourBoxName());
				ui.showWindow("joinTourBoxM");
			}
		});
		
		//공유 여행상자 미리보기
		$(document).on("click","#sharedTourBoxList .block",function(){ 
//			console.log($(this).data("sharedBoxId"));
			sharedBoxList.getSharedBox($(this).data("sharedBoxId")).preview();
		});
		
		$("#joinTourBoxM .bt").on( "click", function(){
			tourBoxList.getTourBox($("#joinTourBoxM").data("tourBoxId")).loadTourBlocks();
		});
	
		//추천 여행지
		$("#recommendListBt").on( "click", function(){
			ui.showWindow("recommendPlaceListM");
//			recommendPlace();
		});
		
		//프린트(요약)
		$("#print").on( "click", function() {
			tourBoxList.getTourBox(ui.getCurrentTourBoxId()).getSummary();
			ui.showWindow("tourBoxPrintM");
		});		
		
		$("#errorM .bt").on( "click", function() {
			$(this).parent().fadeOut(100);
		});
		
		$("#confirmOk").on("click", function() {
			ui.getConfirmOk()();
		});
		
		//인쇄
		$("#summaryPrint").on("click", function() {
			window.print();
		});
	  
		//공유 여행상자 가져오기
		$("#sharedIcon").on("click", function() {
			sharedBoxList.getSharedBox($("#sharedBoxPreviewM").data("sharedBoxId")).copySharedBlock();
		});
		
		//로그인
		this.showWindow("loginM");
	}
	
	filterTourPlace(){
		var tourBlockPlace = placeList;
//		console.log(tourBlockPlace); 요기
		var selectedLocal = $("#destination .hover")[0].innerHTML;
		var selectedType = $("#place .hover")[0].innerText;
		console.log(tourBlockPlace.placeList.length);
		for(var i=0; i<tourBlockPlace.getPlaceTrimList().length;i++){
//			console.log(tourBlockPlace.getPlaceTrimList()[i]);
			var ele = tourBlockPlace.getPlace(tourBlockPlace.getPlaceTrimList()[i].placeId).getBlockElement();
//			console.log(ele);
			$(ele).show();
			console.log(tourBlockPlace.getPlace(tourBlockPlace.getPlaceTrimList()[i].placeId).getCategory());
			if(selectedLocal == tourBlockPlace.getPlace(tourBlockPlace.getPlaceTrimList()[i].placeId).getLocName() || selectedLocal == "전체"){
				if(selectedType == tourBlockPlace.getPlace(tourBlockPlace.getPlaceTrimList()[i].placeId).getCategory()){
				}else{
					$(ele).hide();
				}			
			}else{
				$(ele).hide();
			}
		}
		
	}
		
	filterTourBlock(date){
//		console.log(date); 요기
		//TourBox의 TourBlock
		var tourBlockList = tourBoxList.getTourBox(ui.getCurrentTourBoxId()).getTourBlockList();
		//달력에 음영된 날짜들의 배열
		var cal = $("#datePicker").glDatePicker(true).options;
		var selectedDate = cal.specialDates;

		for(var i=0; i<tourBlockList.length; i++){
			//TourBox의 TourBlock들의 날짜
			var blockDate = tourBlockList[i].date.split('/');
			blockDate[0] = parseInt(blockDate[0]);
			blockDate[1] = parseInt(blockDate[1]);
			blockDate[2] = parseInt(blockDate[2]);

			$(tourBlockList[i].getBlockElement()).hide();
			$(tourBlockList[i].getBlockElement()).next().hide();					
			
			for(var j=0; j<selectedDate.length; j++){
				var splitDate = [selectedDate[0].date.getFullYear(), selectedDate[j].date.getMonth(), selectedDate[j].date.getDate()]; 
				
				if(blockDate[0] == splitDate[0]-1 && blockDate[1] == splitDate[1]+1 && blockDate[2] == splitDate[2]){
					console.log("일치");
					var today = cal.selectedDate;
					var splitToday = [today.getFullYear(), today.getMonth(), today.getDate()];
					
					console.log(splitToday);
					console.log(blockDate);
					
					if(splitToday[0] == blockDate[0] && splitToday[1]+1 == blockDate[1] && splitToday[2] == blockDate[2]){
					$(tourBlockList[i].getBlockElement()).show();
					$(tourBlockList[i].getBlockElement()).next().show();																
					}
				}
			}
		}
	};
	
	//라디안 단위로 변환
	toRad(num){
		return num / 180 * Math.PI;
	}
	
	setSelectedBlock(blockName){
		this.selectedBlock = blockName;
	}

	getSelectedBlock(){
		return this.selectedBlock;
	}
	
	setCurrentTourBoxId(tourBoxId){
		this.currentTourBoxId = tourBoxId;
	}
	
	getCurrentTourBoxId(){
		return this.currentTourBoxId;
	}
	
	updateTourDate(){
		//요기
/* 		var cal = $("#datePicker").glDatePicker(true).options;
		
		var startDate = cal.specialDates[0].date;
		console.log(startDate);
		console.log(cal.specialDates.length);
		var endDate = cal.specialDates[cal.specialDates.length-1].date;
		console.log(endDate);
		
		
		var sdate = startDate.getFullYear()-1 + "-" + (parseInt(startDate.getMonth())+1) + "-" + startDate.getDate();
		var edate = endDate.getFullYear()-1 + "-" + (parseInt(endDate.getMonth())+1) + "-" + endDate.getDate();		
		
		console.log(sdate,edate); */
		
		var blockLists = tourBoxList.getTourBox(ui.getCurrentTourBoxId()).getTourBlockList();
		
		var joinedPersonInfo = $("#infoArea ul > li > span:nth-child(2)");
		
		console.log(blockLists.length);
		if(blockLists.length == 0){
			var today = $("#datePicker").glDatePicker(true).options.todayDate;
			joinedPersonInfo.eq(1).text(today.getFullYear() + "-" + today.getMonth() + "-" + today.getDate() + " ~ " + today.getFullYear() + "-" + today.getMonth() + "-" + today.getDate()) ;
		}else{
			joinedPersonInfo.eq(1).text(blockLists[0].date+" ~ "+blockLists[blockLists.length-1].date);			
		}
	}
	
	
	//구글 지도 API
	initGoogleMap(){
		//구글 지도 초기화
 		this.map = new GMap2(document.getElementById('mapCanvas'));
		this.map.setCenter(new GLatLng(37.566535, 126.9779692), 15);
		this.geocoder = new GClientGeocoder();
		this.map.disableDoubleClickZoom();
		this.map.addControl(new GNavLabelControl());
		this.map.addControl(new GSmallMapControl());
	}
	//위치 검색
	searchLocation(address) {
		this.geocoder.getLocations(address, this.addAddressToMap);
	}
	
	addAddressToMap(response) {
		ui.map.clearOverlays();
		if (!response || response.Status.code != 200) {
		}else {
			var place = response.Placemark[0];
			var point = new GLatLng(place.Point.coordinates[1], place.Point.coordinates[0]);
			var marker = new GMarker(point);
			ui.map.addOverlay(marker);
			ui.setNewPlaceAddress(place);
			marker.openInfoWindowHtml('<b>'+$(".placeName").val()+'<br>주소: </b>' + place.address);
		}
	}
	
	//주소, 위도, 경도 설정
	setNewPlaceAddress(place){
		this.newPlaceSet = 1;
		this.newPlace = {}; 
		this.newPlace.address= place.address;
		this.newPlace.latitude = place.Point.coordinates[1];
		this.newPlace.longitude =  place.Point.coordinates[0];
	}
	
	getNewPlaceAddress(){
		return this.newPlace;
	}

	setLocal(list, windowName){
		for(var i=0; i<list.length; i++){
			var newLi = document.createElement('li');
			newLi.innerHTML = list[i];			
			if(i==0){
				newLi.className="hover";
			}
			$("#"+windowName).append(newLi);
		}	
	}
	
	setDropList(list, listName){
		for(var i=0; i<list.length; i++){
			var newList = document.createElement('option');
			newList.value = list[i];
			newList.innerHTML = list[i];			
			if(list[i]!="전체"){
				$("select[name*='"+listName+"']").append(newList);
			}
		}			
	}

	//현재 로그인 상태 설정(0은 비 로그인 상태, 1은 로그인 상태)
	setLoginStatus(value){
		this.loginStatus = value;
	}
	
	//windowName에 해당하는 창을 나타냄
	showWindow(windowName){
		//추천 여행지 목록은 showLoading에서 제외
		if(windowName != "recommendPlaceListM")
			this.showLoading();
		$("#"+windowName).fadeIn(100);
	}
	
	//windowName에 해당하는 창을 감춤
	hideWindow(windowName, callback){
		$("#"+windowName).fadeOut(100, callback);		
	}
	
	//로딩 아이콘을 보여줌
	showLoading(){
		$("#blackPanel").fadeIn(100);
		$("#loading").fadeIn(100);
	}
	
	//로딩 아이콘을 감춤
	hideLoading(){
		$("#blackPanel").fadeOut(100);
		$("#loading").fadeOut(100);
	}

	   //추천 여행지 설정
	   setRecommendM(id){
	      var recPlaceId = placeList.getPlace(id).getRecommendPlaceId();
	   
	      $("#selectedPlace").empty();
	      $("#recPlaceList").empty();
	      $("#selectedPlace").text("[" + placeList.getPlace(id).getPlaceName() + "]");
	         
	      var newRecPlaceList = document.createElement('div');
	      for(var i=0; i<4; i++){
//	         console.log(i);
	         var newPlaceBlock = document.createElement('div');
	         newPlaceBlock.className = "place block";
	         newPlaceBlock.style.backgroundImage = "url("+placeList.getPlace(recPlaceId[i]).placeImageUrl+")";
	         $(newPlaceBlock).data("placeId", recPlaceId[i]);
	         
	         var newBlockTitle = document.createElement('div');
	         newBlockTitle.className = "blockTitle btBottom btCenter";
	         newBlockTitle.innerHTML = placeList.getPlace(recPlaceId[i]).placeName;

	         newPlaceBlock.appendChild(newBlockTitle);
			 $(newPlaceBlock).data("placeId", recPlaceId[i]);
	         $("#recPlaceList").append(newPlaceBlock);
//	         newRecPlaceList.appendChild(newPlaceBlock);
	      }
	   }
	
	//로그아웃 시 모든 객체 및 데이터 초기화
	reset(){
		$("#tourBoxContent .tour.block").next().remove();
		$("#tourBoxContent .tour.block").remove();
		$("#infoArea ul > li > span:nth-child(2)").empty();
	}
	
	//에러메시지 내용설정
	setErrorMsg(errorMsg){
		$("#errorM .modalTitle").text(errorMsg);
	}
	
	//확인 창 내용 설정
	setConfirmMsg(confirmMsg, callback){
		$("#confirmM .modalTitle").text(confirmMsg);
		this.confirmOk = callback;
	}
	
	getConfirmOk(){
		return this.confirmOk;
	}
	
	setJoinTourBoxTitle(title){
		$("#joinTourBoxM .modalTitle").text(title);
	}
	
	setLastLogNum(logNum){
		this.lastLogNum = logNum;
	}
	
	getLastLogNum(){
		return this.lastLogNum;
	}
	
	   updateLog(isCopy){
		      if(ui.getCurrentTourBoxId()){
		         $.post( "./jsp/getLog.jsp", {"lastLogNum" : ui.getLastLogNum(), "tourBoxId" : ui.getCurrentTourBoxId()}).done(function(result){
					var otherUser = 0;
					var log=$.parseJSON(result);
					if(log.length){
						var currentTourBox = tourBoxList.getTourBox(ui.getCurrentTourBoxId());
		//				console.log(log);
						ui.setLastLogNum(log[log.length-1].logNum);
						
						for(var i = 0; i < log.length; i++){
							//중복처리 방지
							if(ui.updateLogNum.includes(log[i].logNum))
								continue;
							
							ui.updateLogNum.push(log[i].logNum);
							switch(log[i].type){
								case "add": 
									var tourDate = new Date(log[i].content[0].date);
									calendar.setSelectableDate(tourDate.getFullYear(),tourDate.getMonth(),tourDate.getDate());
									var newTourBlock = new TourBlock(log[i].content[0].date, log[i].content[0].path, log[i].content[0].cost, log[i].content[0].placeNum, log[i].content[0].etime, log[i].content[0].num, log[i].content[0].memo, log[i].content[0].stime, log[i].content[0].title, ui.getCurrentTourBoxId());
									newTourBlock.showTourBlock();
									var placeImagePath = placeList.getPlace(log[i].content[0].placeNum).getPlaceImageUrl();
									$(currentTourBox.getAllTourBoxElement()).css({'background-image':'url('+placeImagePath+')'});
									$(currentTourBox.getJoinedTourBoxElement()).css({'background-image':'url('+placeImagePath+')'});
									currentTourBox.setTourBoxImageUrl(placeImagePath);
									currentTourBox.setCost(log[i].content[0].cost);
									currentTourBox.moveTourBlock(log[i].content[0].num);
									break; 
								case "modify":
									var tourBlock = currentTourBox.getTourBlock(log[i].content[0].num);
									currentTourBox.setCost(parseInt(log[i].content[0].cost) - tourBlock.getCost());
									tourBlock.updateInfo(log[i].content[0].date, log[i].content[0].path, log[i].content[0].cost, log[i].content[0].placeNum, log[i].content[0].etime, log[i].content[0].num, log[i].content[0].memo, log[i].content[0].stime, log[i].content[0].title);
									var blockElement = $(tourBlock.getBlockElement());
									blockElement.find(".tourTime").text(log[i].content[0].stime + " ~ " + log[i].content[0].etime);
									currentTourBox.moveTourBlock(log[i].content[0].num);
									break;
								case "delete":
									//calendar.freeSelectableDate(log[i].content[0].date.getFullYear(),log[i].content[0].date.getMonth(),log[i].content[0].date.getDate());
									var tourBlock = currentTourBox.getTourBlock(log[i].num);
									currentTourBox.deleteTourBlock(log[i].num);
									currentTourBox.setCost(-tourBlock.getCost());
									break;
							}
							if(log[i].id != account.getAccountId())
								otherUser++; 
							ui.updateTourDate();
		//					this.updateTourDate(blockList[0].date, blockList[blockList.length].date);
						}
						//if($(".modalWindow:visible[id!='recommendPlaceListM']").length == 0){
							ui.hideLoading();
							if(otherUser){
								ui.setErrorMsg("다른 사용자에 의해 수정되었습니다.");
								ui.showWindow("errorM");
							}
						//}
						
						if(isCopy){
							ui.setErrorMsg("여행상자가 불러오기가 완료되었습니다.");
							ui.showWindow("errorM");
						}
						
						currentTourBox.sortTourBlock();
						
					}
				});	
		}
	}
}

//달력
class Calendar{
	constructor(){
		$('#datePicker').glDatePicker({
			cssName: 'flatwhite',
			showAlways: true,
			borderSize: 0,
			zIndex: 0,

			onClick: function(target, cell, date, data) {
				ui.filterTourBlock(date);
			}
		});   
	}
	
	setSelectableDate(year, month, day){
		var cal = $('#datePicker').glDatePicker(true);
		if(cal.options.specialDates == null){
			cal.options.specialDates = [{date: new Date(year, month, day), data: { message: '' }, repeatYear: true, cssClass: 'special'}];
		}else{
			cal.options.specialDates.push({date: new Date(year, month, day), data: { message: '' }, repeatYear: true, cssClass: 'special'});			
		}
//		console.log(cal.options.specialDates);
		cal.render();
	}
	
	freeSelectableDate(year, month, day){
		var cal = $('#datePicker').glDatePicker(true);
		var deleteDate = new Date(year, month, day)
		if(cal.options.specialDates != null){
			for(var i=0; i<cal.options.specialDates.length; i++){
				if(cal.options.specialDates[i].date.getFullYear() == deleteDate.getFullYear()){
					if(cal.options.specialDates[i].date.getMonth() == deleteDate.getMonth()){
						if(cal.options.specialDates[i].date.getDate() == deleteDate.getDate()){
							cal.options.specialDates.splice(i,1);
						}
					}
				}
			}
		}
		cal.render();
	}	
	
	getSelectedDate(){
		var cal = $('#datePicker').glDatePicker(true);
		var date = cal.options.selectedDate;
		return date.getFullYear() + "/" + (date.getMonth()+1) + "/" + date.getDate();
		
	}
}

//계정
//로그인, 회원가입 창, 회원가입기능 있음
class Account{	
//로그인
   //로그인창의 로그인 버튼을 누르면 실행
   login(){
      if($( "#loginM input[name='id']" ).val() == "" || $( "#loginM input[name='password']" ).val() == ""){
         //에러메시지 출력함수 호출로 변경 필요
         ui.setErrorMsg("아이디와 비밀번호를 모두 입력하세요.");
         ui.showWindow("errorM");
      }else{
         $.post( "./jsp/login.jsp", $( "#loginM form" ).serialize()).done(function(result){
            var myTourBoxList=$.parseJSON(result);
            if(myTourBoxList.id!=""){
               ui.hideWindow("loginM");
               
               tourBoxList.setMyTourBoxList(myTourBoxList.box);
               account.setAccountId(myTourBoxList.id);
               tourBoxList.loadMyTourBoxList();
               // tourBoxList.getMyTourBoxList().forEach(function(tourBox, key){
                  // tourBox.getAllTourBoxElement().remove();
               // });      
               ui.showWindow("joinedTourBoxListM");
               ui.setLoginStatus(1);
               /* $("#blackPanel").css("cursor","pointer"); */         
            }else{
               ui.setErrorMsg("아이디 또는 비밀번호를 확인하세요.");
               ui.showWindow("errorM");
            }         
         });         
      }
   }
	
	logout(){
		ui.showLoading();
		ui.reset();
		$.post( "./jsp/logout.jsp").done(function(result){
			ui.setCurrentTourBoxId(0);
			ui.setErrorMsg("로그아웃 되었습니다.");
			ui.showWindow("errorM");
			ui.showWindow("loginM");
		});	
	}
	
	//회원가입 창을 보여줌
	//로그인창의 회원가입 버튼을 누르면 실행
	showJoin(){
		ui.hideWindow("loginM");
		ui.showWindow("joinM");
	}
	
	//회원가입
	//회원가입창에서 회원가입 버튼을 누르면 실행
	join(){
		if($( "#joinM input[name*='id']").val() == "" || $("#joinM input[name*='name']").val() == "" || $("#joinM input[name*='password']").val() == "" ){
			ui.setErrorMsg("모든 항목을 입력하세요.");
			ui.showWindow("errorM");
		}else{
			$.post( "./jsp/join.jsp", $( "#joinM form" ).serialize()).done(function(result){
				if(result == "ok"){
					ui.hideWindow("joinM");
					ui.setErrorMsg($("#joinM input[name*='name']").val()+"님 회원가입 되었습니다.");
					ui.showWindow("errorM");
					//강제 로그인
					$("#loginM input[name*='id']" ).val($("#joinM input[name*='id']").val());
					$("#loginM input[name*='password']" ).val($("#joinM input[name*='password']").val());
					account.login();
				}else{
					//회원가입 실패 시 
					ui.setErrorMsg("중복된 아이디입니다.");
					ui.showWindow("errorM");
				}
			});
		}
	}
	
	setAccountId(id){
		this.accountId = id;
	}
	
	getAccountId(){
		return this.accountId;
	}
}

class TourBoxList{
	constructor(){
		this.boxList = [];
		$.post( "./jsp/getTourBox.jsp").done(function(tourBoxListData){
			var boxList=$.parseJSON(tourBoxListData);
			if(boxList.length){ 
				for(var i=0; i< boxList.length; i++){
					new TourBox(boxList[i].num, boxList[i].name, boxList[i].path, boxList[i].loc);
				}
				tourBoxList.loadAllTourBoxList();
			}
		});
	}
	
	setMyTourBoxList(myTourBoxListData){
		var myTourBoxNum = [];
		this.myTourBoxList = [];
		this.myTourBoxIdList = [];
		for (var i=0; i< myTourBoxListData.length; i++){
			this.myTourBoxList.push(tourBoxList.getTourBox(myTourBoxListData[i].num));
			this.myTourBoxIdList.push(myTourBoxListData[i].num);
		}
	}
	
	addMyTourBoxList(tourBoxId){
		this.myTourBoxList.push(tourBoxList.getTourBox(tourBoxId));
		this.myTourBoxIdList.push(tourBoxId);
	}
	
	getMyTourBoxIdList(){
		return this.myTourBoxIdList;
	}
	
	getMyTourBoxList(){
		return this.myTourBoxList;
	}	
	
	addTourBox(tourBox){
		this.boxList[tourBox.getTourBoxId()] = tourBox;
	}
	
	getTourBoxList(){
		return this.boxList;
	}
	
	getTourBox(id){
		return this.boxList[id];
	}

	loadMyTourBoxList(){
		$("#joinedTourBoxList").empty();
		this.myTourBoxList.forEach(function(tourBox, key){
			tourBox.showTourBox("joinedTourBoxList");
		});		

		if(this.myTourBoxList.length < 2){
			for (var i=0; i < 2 - this.myTourBoxList.length; i++){
//				console.log("a");
				var newBlock = document.createElement('div');
				newBlock.className = "empty block";
				$("#joinedTourBoxList").append(newBlock);
			}
		}
	}
	
	loadAllTourBoxList(){
		this.boxList.forEach(function(tourBox, key){
			tourBox.showTourBox("allTourBoxList");
		});		
	}
}

class TourBox{
	constructor(tourBoxId, tourBoxName, path, locList){
		this.tourBoxId = tourBoxId;
		this.tourBoxName = tourBoxName;
		this.tourBoxImageUrl = path;
		this.tourBoxLocList = locList;
		this.tourBlockList = [];
		this.totalCost = 0;
		tourBoxList.addTourBox(this);
	}
	
	setTourBoxImageUrl(path){
		this.tourBoxImageUrl = path;
	}
	
	loadTourBlocks(){
		var cal = $('#datePicker').glDatePicker(true);
		cal.options.specialDates = null;
		cal.render();
		$(".modalWindow").hide();		
		this.tourBlockList = [];
		$.post( "./jsp/joinBox.jsp", {"tourBoxId" : this.tourBoxId, tourBoxPw : $("input[name='tourBoxPw']").val()}).done(function(data){
			if(data){
					
				var data = $.parseJSON(data);
				var boxId = data.box;
				var blockList= data.blocks;
				var thisBox = tourBoxList.getTourBox(boxId);
				var cost = 0;
				ui.reset();
				ui.setCurrentTourBoxId(boxId);
				ui.setLastLogNum(data.lastLogNum);
				thisBox.setInfo();
				if(blockList.length){ 
					for(var i=0; i< blockList.length; i++){
						var newTourBlock = new TourBlock(blockList[i].date, blockList[i].path, blockList[i].cost, blockList[i].placeNum, blockList[i].etime, blockList[i].num, blockList[i].memo, blockList[i].stime, blockList[i].title, boxId);
						newTourBlock.showTourBlock();
						cost += parseInt(blockList[i].cost);
						var tempDate = blockList[i].date.split('/');
//						console.log(tempDate);
						calendar.setSelectableDate(tempDate[0], tempDate[1]-1, tempDate[2]);
					}
				}
				thisBox.setCost(cost);
				console.log(thisBox.getTourBlock(0));
				ui.updateTourDate();
				ui.hideLoading();
			}else{
				ui.setErrorMsg("비밀번호가 다릅니다.");
				ui.showWindow("errorM");
				
			}
		});
	}
	
	getTourBlockList(){
		return this.tourBlockList;
	}
	
	getTourBlock(tourBlockId){
		for(var i = 0; i < this.tourBlockList.length; i++){
			if(this.tourBlockList[i].getTourBlockId() == tourBlockId)
				return this.tourBlockList[i];
		}
	}
	
	getTourBlockIndex(tourBlockId){
		for(var i = 0; i < this.tourBlockList.length; i++){
			if(this.tourBlockList[i].getTourBlockId() == tourBlockId)
				return i;
		}
	}
	
	deleteTourBlock(tourBlockId){
		$(this.getTourBlock(tourBlockId).getBlockElement()).next().remove();
		$(this.getTourBlock(tourBlockId).getBlockElement()).remove();
		this.tourBlockList.splice(this.getTourBlockIndex(tourBlockId), 1);
	}
	
	moveTourBlock(tourBlockId){
		//tourBlockList sort
		this.tourBlockList.sort(function(i, j) {
//			console.log(i.date, j.date);
			
			return parseInt(i.date.replace(/\//g,'') + i.stime.split(' ')[0].replace(/\:/g,'')) - parseInt(j.date.replace(/\//g,'') + j.stime.split(' ')[0].replace(/\:/g,''));
			//return parseInt(i.stime.replace(/\:/g,'')) - parseInt(j.stime.replace(/\:/g,''));
		});
	}
		
	getTourBoxId(){
		return this.tourBoxId;
	}
	
	getTourBoxName(){
		return this.tourBoxName;
	}
	
	getTourBoxImageUrl(){
		return this.tourBoxImageUrl;
	}
	
	getLocList(){
		return this.tourBoxLocList;
	}
	
	setInfo(){
		$.post( "./jsp/tourInfo.jsp" ).done(function(json){
			var data=$.parseJSON(json)[0]; 
			var joinedPersonInfo = $("#infoArea ul > li > span:nth-child(2)");
			joinedPersonInfo.eq(0).text(data.name);
//			joinedPersonInfo.eq(1).text(data.sdate+" ~ "+data.edate);
			joinedPersonInfo.eq(2).text(data.member);
		});
	}
	
	setCost(cost){
		this.totalCost = this.totalCost + parseInt(cost);
		var joinedPersonInfo = $("#infoArea ul > li > span:nth-child(2)");
		//http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
		joinedPersonInfo.eq(3).text("\\"+this.totalCost.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
	}
	
	setAllTourBoxElement(elm){
		this.allTourBoxElement = elm;
	}
	
	getAllTourBoxElement(){
		return this.allTourBoxElement;
	}
	
	setJoinedTourBoxElement(elm){
		this.joinedTourBoxElement = elm;
	}
	
	getJoinedTourBoxElement(){
		return this.joinedTourBoxElement;
	}
	
	showTourBox(loc){
		var newBlock = document.createElement('div');
		newBlock.className = "tour block";
		newBlock.style.backgroundImage = "url("+this.getTourBoxImageUrl()+")";
//		console.log(this.getTourBoxImageUrl());
				
		var newBlockTitle = document.createElement('div');
		newBlockTitle.className = "blockTitle";
		newBlockTitle.innerHTML = this.getTourBoxName();	
								
		newBlock.appendChild(newBlockTitle);
		
		if(loc == "allTourBoxList")
			this.setAllTourBoxElement(newBlock);
		else(loc == "joinedTourBoxList")
			this.setJoinedTourBoxElement(newBlock);
		
		$(newBlock).data("tourBoxId", this.tourBoxId);
		$("#"+loc).prepend(newBlock);
	}
	
	sortTourBlock(){
		$("#tourBoxContent .tour.block").next().remove();
		$("#tourBoxContent .tour.block").remove();
		for(var i=0; i< this.tourBlockList.length; i++){
			this.tourBlockList[i].showTourBlock();
		}
		ui.filterTourBlock();
	}
	
	addTourBlock(tourBlock){
		this.tourBlockList.push(tourBlock);
	}

	getSummary(){
		$("#summaryFrame").empty();
		var thisBlock = this.getTourBlockList();

		var newTourName = document.createElement('div');
		newTourName.className = "modalTitle tourName";
		newTourName.innerHTML = this.tourBoxName;
		
		$("#summaryFrame").prepend(newTourName);
		var nowDates = [0,0,0];
		
		for(var i=0; i<thisBlock.length; i++){
			var Dates = thisBlock[i].date.split('/');
			if((nowDates[0] == Dates[0]) && (nowDates[1] == Dates[1]) && (nowDates[2] == Dates[2])){
			}else{
				var newDate = document.createElement('div');
				newDate.className = "modalTitle date";
				newDate.innerHTML = Dates[0] + "/" + Dates[1] + "/" + Dates[2];				
				$("#summaryFrame").append(newDate);
			}
			nowDates[0] = Dates[0];
			nowDates[1] = Dates[1];
			nowDates[2] = Dates[2];

			
			var newTourSummary = document.createElement('div');
			newTourSummary.className = "tourSummary";

			var newTourTimeBox = document.createElement('div');
			newTourTimeBox.id = "tourTimeBox";

			var newStartTime = document.createElement('span');
			newStartTime.innerHTML = thisBlock[i].stime;
			var newDestTime = document.createElement('span');
			newDestTime.innerHTML = thisBlock[i].etime;
			
			newTourTimeBox.appendChild(newStartTime);
			newTourTimeBox.appendChild(newDestTime);

			var newPlaceBlock = document.createElement('div');
			newPlaceBlock.className = "place block";
			newPlaceBlock.style.backgroundImage = "url(" +placeList.getPlace(thisBlock[i].placeId).placeImageUrl + ")";			
			
			var newUl = document.createElement('ul');
			var newLi = document.createElement('li');

			var newTourPlaceLabel = document.createElement('span');
			newTourPlaceLabel.innerHTML = "여행장소";
			var newTourPlace = document.createElement('span');
			newTourPlace.innerHTML = "["+placeList.getPlace(thisBlock[i].placeId).locName+"] "+ placeList.getPlace(thisBlock[i].placeId).placeName;
			
			newLi.appendChild(newTourPlaceLabel);
			newLi.appendChild(newTourPlace);
			newUl.appendChild(newLi);
			
			var newLi2 = document.createElement('li');
			var newSpendMoneyLabel = document.createElement('span');
			newSpendMoneyLabel.innerHTML = "여행 경비";
			var newSpendMoney = document.createElement('span');
			newSpendMoney.innerHTML = thisBlock[i].cost;

			newLi2.appendChild(newSpendMoneyLabel);
			newLi2.appendChild(newSpendMoney);
			newUl.appendChild(newLi2);
			
			var newLi3 = document.createElement('li');
			var newAddressLabel = document.createElement('span');
			newAddressLabel.innerHTML = "여행지 주소";
			var newAddress = document.createElement('span');
//			console.log(placeList.getPlace(thisBlock[i].placeId));
			newAddress.innerHTML = placeList.getPlace(thisBlock[i].placeId).getPlaceAddress();
			
			newLi3.appendChild(newAddressLabel);
			newLi3.appendChild(newAddress);
			newUl.appendChild(newLi3);
			
			var newMemo = document.createElement('div');
			newMemo.className = "memo";
			newMemo.innerHTML = thisBlock[i].memo;
			
			newTourSummary.appendChild(newTourTimeBox);
			newTourSummary.appendChild(newPlaceBlock);
			newTourSummary.appendChild(newUl);
			newTourSummary.appendChild(newMemo);
			
			$("#summaryFrame").append(newTourSummary);

			//위도, 경도 계산
			if(i+1 < thisBlock.length){
				var nowLatitude = placeList.getPlace(thisBlock[i].placeId).getPlaceLatitude() / 180 * Math.PI;
				var nowLongtitude = placeList.getPlace(thisBlock[i].placeId).getPlaceLongtitude() / 180 * Math.PI;
				
				var latitude = placeList.getPlace(thisBlock[i+1].placeId).getPlaceLatitude() / 180 * Math.PI;
				var longtitude = placeList.getPlace(thisBlock[i+1].placeId).getPlaceLongtitude() / 180 * Math.PI;
				var angle = Math.acos(Math.sin(nowLatitude) * Math.sin(latitude) + Math.cos(nowLatitude) * Math.cos(latitude) * Math.cos(nowLongtitude - longtitude)) * 6378.137;	
				
				nowLatitude = latitude;
				nowLongtitude = longtitude;				
			}else{
				var angle = 0;
			}
			
			var newDown = document.createElement('div');
			newDown.className = "down";
			var newDistance = document.createElement('span');
			newDistance.className = "distance";
			newDistance.innerHTML = angle.toFixed(2) + "km";
			
			newDown.appendChild(newDistance);
		
			$("#summaryFrame").append(newTourSummary);
			$("#summaryFrame").append(newDown);
//			console.log("완료");
		}
	}
}

class TourBlock{
	constructor(date, path, cost, placeId, etime, tourBlockId, memo, stime, title, tourBoxId){
		this.date = date;
		this.path = path;
		this.cost = cost;
		this.placeId = placeId;
		this.etime = etime;
		this.tourBlockId = tourBlockId;
		this.memo = memo;
		this.stime = stime;
		this.title = title;
		if(tourBoxId) 
			tourBoxList.getTourBox(tourBoxId).addTourBlock(this);
	}
	
	updateInfo(date, path, cost, placeId, etime, tourBlockId, memo, stime, title){
		this.date = date;
		this.path = path;
		this.cost = cost;
		this.placeId = placeId;
		this.etime = etime;
		this.tourBlockId = tourBlockId;
		this.memo = memo;
		this.stime = stime;
		this.title = title;
	}
	
	showTourBlock(){
		var place= placeList.getPlace(this.placeId);
		var newBlockFrame = document.createElement('div');
		newBlockFrame.className = "tour block";
		newBlockFrame.style.backgroundImage = "url(" + place.getPlaceImageUrl() + ")";
		
		var newBlock = document.createElement('div');
		newBlock.className = "blockTitle btBottom";
		
		var newBlockTourTitle = document.createElement('span');
		newBlockTourTitle.className = "tourTitle";
		newBlockTourTitle.innerHTML = "["+place.getLocName()+"] "+place.getPlaceName();
		
		var newBlockTourTime = document.createElement('span');
		newBlockTourTime.className = "tourTime";
		newBlockTourTime.innerHTML = this.stime  + " ~ " + this.etime;
		
		var downArrow = document.createElement('div');
		downArrow.className = "down";
		
		newBlock.appendChild(newBlockTourTitle);
		newBlock.appendChild(newBlockTourTime);
		newBlockFrame.appendChild(newBlock);
		$(newBlockFrame).data("tourBlockId", this.tourBlockId);
		$(newBlockFrame).data("placeId", this.placeId);
		this.setBlockElement(newBlockFrame);
		$("#tourBoxContent .empty").before(newBlockFrame);
		$("#tourBoxContent .empty").before(downArrow);		
	}
	
	setBlockElement(ele){
		this.blockElement = ele;
	}
	
	getBlockElement(){
		return this.blockElement;
	}
	
	getTourBlockId(){
		return this.tourBlockId;
	}
	
	getCost(){
		return parseInt(this.cost);
	}
}

class PlaceList{
   constructor(){
      this.placeList = [];
      this.placeTrimList = [];
      $.post( "./jsp/viewPlace.jsp").done(function(tourPlaceList){
            var tourPlaceList = $.parseJSON(tourPlaceList);
            if(tourPlaceList.length){ 
               for(var i=0; i< tourPlaceList.length; i++){
                  var newPlace = new Place(tourPlaceList[i].path, tourPlaceList[i].recNum, tourPlaceList[i].num, tourPlaceList[i].latitude, tourPlaceList[i].name, tourPlaceList[i].longtitude, tourPlaceList[i].locName, tourPlaceList[i].category, tourPlaceList[i].addr);
               }
               ui.setRecommendM(placeList.getPlaceTrimList()[0].getPlaceId());
            }
            placeList.loadPlaceList();
      });
   }   
   
	addPlace(place){
		this.placeList[place.getPlaceId()] = place;
	}
	
	addPlaceTrimList(place){
		this.placeTrimList.push(place);
	}
	
	getPlaceTrimList(){
		return this.placeTrimList;
	}
	
	getPlaceList(){
		return this.placeList;
	}
	
	getPlace(id){
		return this.placeList[id];
	}

	loadPlaceList(){
		this.placeList.forEach(function(place, key){
			place.showPlace();		
		});
	}
}

class Place{
	constructor(path, recNum, num, latitude, name, longtitude, locName, category, addr){
		this.placeImageUrl = path;
		this.placeRecNum = recNum;
		this.placeId = num;
		this.latitude = latitude;
		this.placeName = name;
		this.longtitude = longtitude;
		this.locName = locName;
		this.category = category;
		this.address = addr;
		placeList.addPlace(this);
		placeList.addPlaceTrimList(this);
	}
	
	setBlockElement(ele){
		this.blockElement = ele;
	}
	
	getCategory(){
		return this.category;
	}
	
	getBlockElement(){
		return this.blockElement;
	}

	getPlaceLatitude(){
		return this.latitude;
	}

	getPlaceLongtitude(){
		return this.longtitude;
	}
	
	getPlaceImageUrl(){
		return this.placeImageUrl;
	}
	
	getLocName(){
		return this.locName;
	}
	
	getPlaceName(){
		return this.placeName;
	}
	
	getPlaceId(){
		return this.placeId;
	}	
	
	getPlaceAddress(){
		return this.address;
	}
	
	//
	addComment(name, date, content){
		var newPlaceComment = document.createElement('div');
		newPlaceComment.className = "placeComment";
		
		var newInnerComment = document.createElement('div');
		
		var newWriterName = document.createElement('span');
		newWriterName.className = "commentWriter";
		newWriterName.innerHTML = name;

		var newCommentDate = document.createElement('span');
		newCommentDate.className = "commentDate";
		newCommentDate.innerHTML = " (" + date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate()+")";
		
		var newCommentContent = document.createElement('span');
		newCommentContent.className = "commentContent";
		newCommentContent.innerHTML = content;
		
		newInnerComment.appendChild(newWriterName);
		newInnerComment.appendChild(newCommentDate);
		newPlaceComment.appendChild(newInnerComment);
		newPlaceComment.appendChild(newCommentContent);
				
		$("#placeCommentList").prepend(newPlaceComment);
	}
	
	//오른쪽 아래 여행지 리스트 불러오는 함수
	showPlace(id){
      var newPlaceFrame = document.createElement('div');
      newPlaceFrame.className = "place block";
      newPlaceFrame.style.backgroundImage = "url("+this.getPlaceImageUrl()+")";
	  $(newPlaceFrame).data("placeId", this.placeId);
      this.setBlockElement(newPlaceFrame);
      var newBlockTitle = document.createElement('div');
      newBlockTitle.className = "blockTitle btBottom btCenter";
      newBlockTitle.innerHTML = this.getPlaceName();
      
      newPlaceFrame.appendChild(newBlockTitle);      
      $("#placeList").prepend(newPlaceFrame);
   }
	
	getRecommendPlaceId(){
		var recPlaceId = [];
		var recPlaceDistance = [];
		var places = placeList.getPlaceTrimList();
//		console.log(places);
		for(var i=0; i<places.length; i++){
			var compLongtitude = ui.toRad(places[i].longtitude);
			var compLatitude = ui.toRad(places[i].latitude);
			var angle =  Math.acos(Math.sin(compLatitude) * Math.sin(ui.toRad(this.latitude)) + Math.cos(compLatitude) * Math.cos(ui.toRad(this.latitude)) * Math.cos(compLongtitude - ui.toRad(this.longtitude))) * 6378.137;
			
			if(places[i].placeId != this.placeId && isNaN(angle) == false){
				recPlaceDistance.push(angle);
				recPlaceId.push(places[i].placeId);				
			}
		}
		
		for(var i=0; i<recPlaceDistance.length; i++){
			for(var j=0; j<recPlaceDistance.length; j++){
				if(recPlaceDistance[i] < recPlaceDistance[j]){
					var temp = recPlaceDistance[i];
					recPlaceDistance[i] = recPlaceDistance[j];
					recPlaceDistance[j] = temp;
					
					temp = recPlaceId[i];
					recPlaceId[i] = recPlaceId[j];
					recPlaceId[j] = temp;
				}
			}
		}
		
//		console.log(recPlaceDistance);
//		console.log(recPlaceId);
		return recPlaceId;
	}
}

class SharedBoxList{
	//공유된 여행상자 목록 불러오기
	constructor(){
		this.sharedBoxList = [];
		$.post( "./jsp/getSharedBox.jsp").done(function(sharedBoxListData){
			var boxList=$.parseJSON(sharedBoxListData);
			if(boxList.length){ 
				for(var i=0; i< boxList.length; i++){
					new SharedBox(boxList[i].num, boxList[i].name, boxList[i].path, boxList[i].loc);
				}
				sharedBoxList.loadSharedBoxList();
			}
		});
	}
	
	//공유된 여행상자 목록 출력
	loadSharedBoxList(){
		this.sharedBoxList.forEach(function(sharedBox, key){
			sharedBox.showSharedBox("sharedTourBoxList");
		});		
	}
	
	addSharedBox(sharedBox){
		this.sharedBoxList[sharedBox.getSharedBoxId()] = sharedBox;
	}
	
	getSharedBoxList(){
		return this.sharedBoxList;
	}
	
	getSharedBox(id){
		return this.sharedBoxList[id];
	}
}

class SharedBox{
	constructor(sharedBoxId, sharedBoxName, path, locList){
		this.sharedBlockList = [];
		this.sharedBoxId = sharedBoxId;
		this.sharedBoxName = sharedBoxName;
		this.sharedBoxImageUrl = path;
		this.sharedBoxLocList = locList;
		sharedBoxList.addSharedBox(this);
	}
	
	getSharedBoxId(){
		return this.sharedBoxId;
	}
	
	getSharedBoxImageUrl(){
		return this.sharedBoxImageUrl;
	}
	
	getSharedBoxName(){
		return this.sharedBoxName;
	}
	
	showSharedBox(loc){
		var newBlock = document.createElement('div');
		newBlock.className = "tour block";
		newBlock.style.backgroundImage = "url("+this.getSharedBoxImageUrl()+")";
//		console.log(this.getSharedBoxImageUrl());
				
		var newBlockTitle = document.createElement('div');
		newBlockTitle.className = "blockTitle";
		newBlockTitle.innerHTML = this.getSharedBoxName();	
		newBlock.appendChild(newBlockTitle);
		
		$(newBlock).data("sharedBoxId", this.sharedBoxId);
		$("#"+loc).prepend(newBlock);
	}
	
	loadSharedBlocks(callback){
		var sharedBox = this;
		this.sharedBlockList = [];
		$.post( "./jsp/loadSharedBox.jsp", {"sharedBoxId" : sharedBox.sharedBoxId}).done(function(data){
			if(data){	
				var data = $.parseJSON(data);
				var blockList= data.blocks;
				if(blockList.length){ 
					for(var i=0; i< blockList.length; i++){
						sharedBox.sharedBlockList.push(new TourBlock(blockList[i].date, blockList[i].path, blockList[i].cost, blockList[i].placeNum, blockList[i].etime, blockList[i].num, blockList[i].memo, blockList[i].stime, blockList[i].title));
					}
				}
				callback();
			}
		});
	}
	
	//공유 여행상자 미리보기
	preview(){
		var thisSharedBox = this;
		this.loadSharedBlocks(function (){
			$("#sharedBoxPreviewM").data("sharedBoxId", thisSharedBox.sharedBoxId);
			ui.showWindow("sharedBoxPreviewM");

			$("#previewFrame").empty();
			var thisBlock = thisSharedBox.sharedBlockList;
			
	//		console.log(thisBlock);

			var newTourName = document.createElement('div');
			newTourName.className = "modalTitle tourName";
			newTourName.innerHTML = thisSharedBox.sharedBoxName;
			
			$("#previewFrame").prepend(newTourName);
			var nowDates = [0,0,0];
			
			for(var i=0; i<thisBlock.length; i++){
				var Dates = thisBlock[i].date.split('/');
				if((nowDates[0] == Dates[0]) && (nowDates[1] == Dates[1]) && (nowDates[2] == Dates[2])){
				}else{
					var newDate = document.createElement('div');
					newDate.className = "modalTitle date";
					newDate.innerHTML = Dates[0] + "/" + Dates[1] + "/" + Dates[2];				
					$("#previewFrame").append(newDate);
				}
				nowDates[0] = Dates[0];
				nowDates[1] = Dates[1];
				nowDates[2] = Dates[2];

				
				var newTourSummary = document.createElement('div');
				newTourSummary.className = "tourSummary";

				var newTourTimeBox = document.createElement('div');
				newTourTimeBox.id = "tourTimeBox";

				var newStartTime = document.createElement('span');
				newStartTime.innerHTML = thisBlock[i].stime;
				var newDestTime = document.createElement('span');
				newDestTime.innerHTML = thisBlock[i].etime;
				
				newTourTimeBox.appendChild(newStartTime);
				newTourTimeBox.appendChild(newDestTime);

				var newPlaceBlock = document.createElement('div');
				newPlaceBlock.className = "place block";
				newPlaceBlock.style.backgroundImage = "url(" +placeList.getPlace(thisBlock[i].placeId).placeImageUrl + ")";			
				
				var newUl = document.createElement('ul');
				var newLi = document.createElement('li');

				var newTourPlaceLabel = document.createElement('span');
				newTourPlaceLabel.innerHTML = "여행장소";
				var newTourPlace = document.createElement('span');
				newTourPlace.innerHTML = "["+placeList.getPlace(thisBlock[i].placeId).locName+"] "+ placeList.getPlace(thisBlock[i].placeId).placeName;
				
				newLi.appendChild(newTourPlaceLabel);
				newLi.appendChild(newTourPlace);
				newUl.appendChild(newLi);
				
				var newLi2 = document.createElement('li');
				var newSpendMoneyLabel = document.createElement('span');
				newSpendMoneyLabel.innerHTML = "여행 경비";
				var newSpendMoney = document.createElement('span');
				newSpendMoney.innerHTML = thisBlock[i].cost;

				newLi2.appendChild(newSpendMoneyLabel);
				newLi2.appendChild(newSpendMoney);
				newUl.appendChild(newLi2);
				
				var newLi3 = document.createElement('li');
				var newAddressLabel = document.createElement('span');
				newAddressLabel.innerHTML = "여행지 주소";
				var newAddress = document.createElement('span');
	//			console.log(placeList.getPlace(thisBlock[i].placeId));
				newAddress.innerHTML = placeList.getPlace(thisBlock[i].placeId).getPlaceAddress();
				
				newLi3.appendChild(newAddressLabel);
				newLi3.appendChild(newAddress);
				newUl.appendChild(newLi3);
				
				var newMemo = document.createElement('div');
				newMemo.className = "memo";
				newMemo.innerHTML = thisBlock[i].memo;
				
				newTourSummary.appendChild(newTourTimeBox);
				newTourSummary.appendChild(newPlaceBlock);
				newTourSummary.appendChild(newUl);
				newTourSummary.appendChild(newMemo);
				
				$("#previewFrame").append(newTourSummary);

				//위도, 경도 계산
				if(i+1 < thisBlock.length){
					var nowLatitude = placeList.getPlace(thisBlock[i].placeId).getPlaceLatitude() / 180 * Math.PI;
					var nowLongtitude = placeList.getPlace(thisBlock[i].placeId).getPlaceLongtitude() / 180 * Math.PI;
					
					var latitude = placeList.getPlace(thisBlock[i+1].placeId).getPlaceLatitude() / 180 * Math.PI;
					var longtitude = placeList.getPlace(thisBlock[i+1].placeId).getPlaceLongtitude() / 180 * Math.PI;
					var angle = Math.acos(Math.sin(nowLatitude) * Math.sin(latitude) + Math.cos(nowLatitude) * Math.cos(latitude) * Math.cos(nowLongtitude - longtitude)) * 6378.137;	
					
					nowLatitude = latitude;
					nowLongtitude = longtitude;				
				}else{
					var angle = 0;
				}
				
				var newDown = document.createElement('div');
				newDown.className = "down";
				var newDistance = document.createElement('span');
				newDistance.className = "distance";
				newDistance.innerHTML = angle.toFixed(2) + "km";
				
				newDown.appendChild(newDistance);
			
				$("#previewFrame").append(newTourSummary);
				$("#previewFrame").append(newDown);
	//			console.log("완료");
			}
		});
		
	}
	
	//공유 여행상자의 여행블록을 현재 여행상자에 복사
	copySharedBlock(){
		$(".modalWindow").fadeOut(100);
		$.post( "./jsp/copySharedBlock.jsp", {"sharedBoxId":this.sharedBoxId, "tourBoxId": ui.getCurrentTourBoxId()}).done(function(result){
			if(result)
				ui.updateLog(1);
		});	
	}
}

