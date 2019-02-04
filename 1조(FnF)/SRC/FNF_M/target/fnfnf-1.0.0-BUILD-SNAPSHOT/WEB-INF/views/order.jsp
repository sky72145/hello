<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<c:set var="user" value="${user}" />

<c:set var="data" value="${data}" />
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>주문페이지</title>
<script src="js/jquery.min.js"></script>
<script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.min.js" ></script>
 <script type="text/javascript" src="https://cdn.iamport.kr/js/iamport.payment-1.1.5.js"></script>

<script>
IMP.init('imp74949970');
$(document).ready(function(){	
	$("#bank").hide();
	$("#kpay2").hide();
	$.ajax({
		url : "/order",
		dataType : "json",
		method : "POST",
		success : function(data){
			
			var result = data.data;
			var fee = data.fee;
			var productsum = data.productSum;
			var allsum = data.allSum;
			var pcode = data.pcode;
			var mile = data.mile_remain
			var str = "";
			for(var i = 0 ; i < result.length ; i++){
				str += "<tr class='text-center'>"
				str += "<td><img class='img-rounded' style='width: 100px; height: 100px;' src='img/"+ result[i].filename+"'></td>" + 
							"<td class='text-center' id='pname'>"+ result[i].pname +"</td><td class='text-center' id='price'>"+ addComma(result[i].price)+ "원"+"</td>" +
				             "<td class='text-center' id='product_count'>" + result[i].product_count + "개"+"</td><td class='text-center' id='mile_give'>" + addComma((result[i].product_count * result[i].price)*0.01) + "원"+"</td>" +
				             "<td class='text-center' id='del_price'>" + addComma(fee) + "원"+"</td>" + "<td class='text-center'>" + addComma(result[i].product_count * result[i].price) + "원"+"</td>";
				str += "</tr>";
			}
				str+=	"<tr class='bg-light'>";
				str+=	"<td colspan='8' class='text-right'>상품구매금액 : " +addComma(productsum) +"원" + "+" + "배송비 :"+addComma(fee) +"원  =  합계 :" +addComma(allsum) +"원</td></tr>"
				
			$("#records").html(str);
			$("#psum").html(addComma(productsum)+"원");
			$("#fee").html(fee);
			$("#totalprice").html(allsum);
			$("#fee2").html(addComma(fee)+"원");
			$("#totalprice2").html(addComma(allsum)+"원");
			$("#mile").html(addComma(mile));
			
			
		},
		error : function(err){
			console.log("Error 발생 : " + err);
		}
	});
	 if($.trim($("#mile_used").val())==''){
		 
	}
});
function addr() {
	window.open("/user_address", "User_addr", "width=800, height=300, left=800, top=30");
}


function addComma(num) {
	  var regexp = /\B(?=(\d{3})+(?!\d))/g;
	  return num.toString().replace(regexp, ',');
	}

function f_save(){
	var frm = document.getElementById('frm');
	
	if($("#receiver_name").val() ==""){
		alert("받는분 이름을 작성해주세요");
		$("#receiver_name").focus();
		return;
	}
	if($("#zipcode").val() ==""){
		alert("우편번호를 입력해주세요.");
		$("#zipcode").focus();
		return ;
	}
	if($("#address1").val() ==""){
		alert("기본 주소를 입력해주세요.");
		$("#address1").focus();
		return;
	}
	if($("#address2").val() ==""){
		alert("나머지 주소를 입력해주세요.");
		$("#address2").focus();
		return;
	}
	if($("#phone").val() ==""){
		alert("휴대전화번호를 입력해주세요.");
		$("#phone").focus();
		return;
	}
	if($("#email").val() ==""){
		alert("이메일을  입력해주세요.");
		$("#email").focus();
		return;
	}
	if($("input:radio[name='pay']").is(":checked") == true){
	}else{
		alert('결제수단 을 체크해주세요.');
		$('#pay').focus();
		return false;
	}
	 if($("#agree_chk").is(":checked") == false){
         alert("약관에 동의 하셔야 다음 단계로 진행 가능합니다.");
         return false;
     }
	 /* 마일리지 유효성 체크 */
	var mile = $("#mile").text()
	var total = $("#totalprice2").text()
	 if($("#mile_used").val() < 1000 && $("#mile_used").val() >= 1){
		 alert("최소사용금액은 1000원 이상입니다.");
		 return false;
	 }else if($("#mile_used").val() > mile){
		 alert("보유한 적립금보다 높은 금액입니다.");
		 $("#mile_used").focus();
		 return false;
	}else if($("#mile_used").val() > total){
		alert("최종결제 금액보다 높습니다");
		 $("#mile_used").focus();
		return false;
	 }
	if($("input:radio[id='kpay']").is(":checked") == true){
		   IMP.request_pay({
			    pg : 'kakaopay', // version 1.1.0부터 지원.
			    pay_method : 'card',
			    merchant_uid : 'merchant_' + new Date().getTime(),
			    name : $("#pname").text(),
			    amount : $("#totalprice").text()-$("#mile_used").val(),
			    buyer_email : $("#email").val(),
			    buyer_name : $("#receiver_name").val(),
			    buyer_tel : $("#phone").val(),
			    buyer_addr : $("#address1").val() + $("#address2").val(),
			    buyer_postcode : $("#zipcode").val(),
			}, function(rsp) {
			    if ( rsp.success ) {
			        var msg = '결제가 완료되었습니다.';
			        msg += '고유ID : ' + rsp.imp_uid;
			        msg += '상점 거래ID : ' + rsp.merchant_uid;
			        msg += '결제 금액 : ' + rsp.paid_amount;
			        msg += '카드 승인번호 : ' + rsp.apply_num;
			        alert("카카오페이 결제 완료");
			        
			        frm.submit();
			    } else {
			        var msg = '결제에 실패하였습니다.';
			        msg += '에러내용 : ' + rsp.error_msg;
			        alert(msg);
			    }
			});
		   
	   }else{
		   frm.submit();
	   }
}

function contentsView(objVlaue) {
    if (objVlaue.value == '무통장') {
    	$("#bank").show();
    	$("#kpay2").hide();
    }else{
    
    	$("#kpay2").show();
    	$("#bank").hide();
    }
}

$(function(){

    $("#phone").on('keydown', function(e){
       // 숫자만 입력받기
        var trans_num = $(this).val().replace(/-/gi,'');
	var k = e.keyCode;
				
	if(trans_num.length >= 11 && ((k >= 48 && k <=126) || (k >= 12592 && k <= 12687 || k==32 || k==229 || (k>=45032 && k<=55203)) ))
	{
  	    e.preventDefault();
	}
    }).on('blur', function(){ // 포커스를 잃었을때 실행합니다.
        if($(this).val() == '') return;

        // 기존 번호에서 - 를 삭제합니다.
        var trans_num = $(this).val().replace(/-/gi,'');
      
        // 입력값이 있을때만 실행합니다.
        if(trans_num != null && trans_num != '')
        {
            // 총 핸드폰 자리수는 11글자이거나, 10자여야 합니다.
            if(trans_num.length==11 || trans_num.length==10) 
            {   
                // 유효성 체크
                var regExp_ctn = /^(01[016789]{1}|02|0[3-9]{1}[0-9]{1})([0-9]{3,4})([0-9]{4})$/;
                if(regExp_ctn.test(trans_num))
                {
                    // 유효성 체크에 성공하면 하이픈을 넣고 값을 바꿔줍니다.
                    //trans_num = trans_num.replace(/^(01[016789]{1}|02|0[3-9]{1}[0-9]{1})-?([0-9]{3,4})-?([0-9]{4})$/, "$1-$2-$3");                  
                    $(this).val(trans_num);
                }
                else
                {
                    alert("유효하지 않은 전화번호 입니다.");
                    $(this).val("");
                    $(this).focus();
                }
            }
            else 
            {
                alert("유효하지 않은 전화번호 입니다.");
                $(this).val("");
                $(this).focus();
            }
      }
  });  
});


</script>
</head>
<body>

<jsp:include page="header.jsp"></jsp:include>

  <!-- order  -->
	<div class="container" >
    <div calss="pt-2">&nbsp;</div>
	<table class="table">
		 <div class="row">
    		<div class="col align-self-start">
     			<p class="text-primary h4 strong">주문상품</p>
    		</div>
  <thead class="table-bordered">
    <tr class="active">
      <th class="text-center" scope="col">사진</th>
      <th class="text-center" scope="col">상품정보</th>
      <th class="text-center" scope="col">판매가</th>
      <th class="text-center" scope="col">수량</th>
      <th class="text-center" scope="col">적립금</th>
      <th class="text-center" scope="col">배송비</th>
      <th class="text-center" scope="col">합계</th>
    </tr>
  </thead>
  <tbody id="records">
    <tr>
      	<!-- 리스트출력구간 -->
      
	<tfoot>
  		 <tr>
  			 <td colspan="7" class="table-sm text-danger bg-danger text-left ">
            <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>상품의 옵션 및 수량 변경은 상품상세 또는 장바구니에서 가능합니다.</td>
   	 	</tr>
   	 </tfoot>
   	 
</table>
	
<!-- 배송지 -->
<form name="frm" id="frm" action="/order_ing" method="post">
<table class="table table-bordered">
		 <div class="row">
    		<div class="col align-self-start">
     			<p class="text-primary h4 strong">배송지 정보</p>
    		</div></div>
    		<c:forEach items="${plist}" var="cart">
    		<input type="hidden" name="pcode" value="${cart.pcode }" />
    		</c:forEach>
    		<tr>
    			<td class="p-3 mb-2 active">받는분 : <img src="img/ico_required.gif" alt="필수"></td><td><input type="text" name="receiver_name" id="receiver_name" size="10" value="${user.user_name }"> <input type="button" id="useraddress" value="최근배송지" onclick="addr();"></td>
    		</tr>
    		<tr>
    			<td class="p-3 mb-2 active">우편번호 : <img src="img/ico_required.gif" alt="필수"></td><td><input type="text" name="zipcode" id="zipcode"  size="10" readonly>&nbsp;<input  type="button" name="zipbtn" value="우편번호" onclick="dzip();"></td>
    		</tr>
    		<tr>
    			<td class="p-3 mb-2 active" rowspan="2 ">주소 : <img src="img/ico_required.gif" alt="필수"></td><td colspan="2"><input type="text" name="address1" id="address1" size="60" readonly> 기본주소</td>
    		</tr>
    		<tr>
    			<td colspan="2"><input type="text" name="address2" id="address2" size="60" > 나머지 주소</td>
    		</tr>
    		<tr>
    			<td class="p-3 mb-2 active">휴대전화 : <img src="img/ico_required.gif" alt="필수"></td><td colspan="2"><input type="text" name="phone" id="phone" value="${user.phone }"></td>
    		</tr>
    		<tr>
    			<td class="p-3 mb-2 active">이메일 : <img src="img/ico_required.gif" alt="필수"></td><td colspan="2"><input type="email" name="email" id="email" value="${user.email }"></td>
    		</tr>
    		<tr>
    			<td class="p-3 mb-2 active">배송 메세지 : </td><td colspan="2"><textarea cols="70" maxlength="20" name="del_message" id="del_message" style="resize: none;"></textarea>
           <br>택배기사님께 전달할 내용을 기재해주세요. (15자이내)
          </td>
    		</tr>
    		
</table>

<!-- 적립금 사용 -->
<div class="row">
        <div class="col align-self-start">
          <p class="text-primary h4 strong">적립금 사용</p>
        </div>
        <div>사용 할 적립금 :<span><input class="text-right" type="number" id="mile_used" name="mile_used" size="8" value="0" ></span>&nbsp;&nbsp;&nbsp;(사용가능한 적립금 : <strong><span class="text-danger" id="mile"></span></strong>)
        </div>
<div class="pt-2">&nbsp;</div>

<!-- 이용약관 -->
    		<div class="col align-self-start ">
     			<p class="text-primary h4 strong">쇼핑몰 이용약관 동의</p>
    		</div>
  <!--  <table class="table"> -->
                <textarea class="form-control" rows="7"  name="mall_agreement" maxlength="250" cols="155" readonly >제1조(목적)이 약관은 (주)1조(전자상거래 사업자)가 운영하는 FnF (이하 “몰”이라 한다)에서 제공하는 인터넷 관련 서비스(이하 “서비스”라 한다)를 이용함에 있어 사이버 몰과 이용자의 권리․의무 및 책임사항을 규정함을 목적으로 합니다.※「PC통신, 무선 등을 이용하는 전자상거래에 대해서도 그 성질에 반하지 않는 한 이 약관을 준용합니다.」제2조(정의)① “몰”이란 (주)1조 회사가 재화 또는 용역(이하 “재화 등”이라 함)을 이용자에게 제공하기 위하여 컴퓨터 등 정보통신설비를 이용하여 재화 등을 거래할 수 있도록 설정한 가상의 영업장을 말하며, 아울러 사이버몰을 운영하는 사업자의 의미로도 사용합니다.② “이용자”란 “몰”에 접속하여 이 약관에 따라 “몰”이 제공하는 서비스를 받는 회원 및 비회원을 말합니다.③ ‘회원’이라 함은 “몰”에 (삭제) 회원등록을 한 자로서, 계속적으로 “몰”이 제공하는 서비스를 이용할 수 있는 자를 말합니다.④ ‘비회원’이라 함은 회원에 가입하지 않고 “몰”이 제공하는 서비스를 이용하는 자를 말합니다.제3조 (약관 등의 명시와 설명 및 개정) ① “몰”은 이 약관의 내용과 상호 및 대표자 성명, 영업소 소재지 주소(소비자의 불만을 처리할 수 있는 곳의 주소를 포함), 전화번호․모사전송번호․전자우편주소, 사업자등록번호, 통신판매업 신고번호, 개인정보보호책임자등을 이용자가 쉽게 알 수 있도록 FnF의 초기 서비스화면(전면)에 게시합니다. 다만, 약관의 내용은 이용자가 연결화면을 통하여 볼 수 있도록 할 수 있습니다.② “몰은 이용자가 약관에 동의하기에 앞서 약관에 정하여져 있는 내용 중 청약철회․배송책임․환불조건 등과 같은 중요한 내용을 이용자가 이해할 수 있도록 별도의 연결화면 또는 팝업화면 등을 제공하여 이용자의 확인을 구하여야 합니다.③ “몰”은 「전자상거래 등에서의 소비자보호에 관한 법률」, 「약관의 규제에 관한 법률」, 「전자문서 및 전자거래기본법」, 「전자금융거래법」, 「전자서명법」, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」, 「방문판매 등에 관한 법률」, 「소비자기본법」 등 관련 법을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다.④ “몰”이 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 몰의 초기화면에 그 적용일자 7일 이전부터 적용일자 전일까지 공지합니다. 다만, 이용자에게 불리하게 약관내용을 변경하는 경우에는 최소한 30일 이상의 사전 유예기간을 두고 공지합니다. 이 경우 &quot;몰“은 개정 전 내용과 개정 후 내용을 명확하게 비교하여 이용자가 알기 쉽도록 표시합니다. ⑤ “몰”이 약관을 개정할 경우에는 그 개정약관은 그 적용일자 이후에 체결되는 계약에만 적용되고 그 이전에 이미 체결된 계약에 대해서는 개정 전의 약관조항이 그대로 적용됩니다. 다만 이미 계약을 체결한 이용자가 개정약관 조항의 적용을 받기를 원하는 뜻을 제3항에 의한 개정약관의 공지기간 내에 “몰”에 송신하여 “몰”의 동의를 받은 경우에는 개정약관 조항이 적용됩니다.⑥ 이 약관에서 정하지 아니한 사항과 이 약관의 해석에 관하여는 전자상거래 등에서의 소비자보호에 관한 법률, 약관의 규제 등에 관한 법률, 공정거래위원회가 정하는 전자상거래 등에서의 소비자 보호지침 및 관계법령 또는 상관례에 따릅니다.제4조(서비스의 제공 및 변경) ① “몰”은 다음과 같은 업무를 수행합니다.  1. 재화 또는 용역에 대한 정보 제공 및 구매계약의 체결  2. 구매계약이 체결된 재화 또는 용역의 배송  3. 기타 “몰”이 정하는 업무② “몰”은 재화 또는 용역의 품절 또는 기술적 사양의 변경 등의 경우에는 장차 체결되는 계약에 의해 제공할 재화 또는 용역의 내용을 변경할 수 있습니다. 이 경우에는 변경된 재화 또는 용역의 내용 및 제공일자를 명시하여 현재의 재화 또는 용역의 내용을 게시한 곳에 즉시 공지합니다.③ “몰”이 제공하기로 이용자와 계약을 체결한 서비스의 내용을 재화등의 품절 또는 기술적 사양의 변경 등의 사유로 변경할 경우에는 그 사유를 이용자에게 통지 가능한 주소로 즉시 통지합니다.④ 전항의 경우 “몰”은 이로 인하여 이용자가 입은 손해를 배상합니다. 다만, “몰”이 고의 또는 과실이 없음을 입증하는 경우에는 그러하지 아니합니다.제5조(서비스의 중단) ① “몰”은 컴퓨터 등 정보통신설비의 보수점검․교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있습니다.② “몰”은 제1항의 사유로 서비스의 제공이 일시적으로 중단됨으로 인하여 이용자 또는 제3자가 입은 손해에 대하여 배상합니다. 단, “몰”이 고의 또는 과실이 없음을 입증하는 경우에는 그러하지 아니합니다.③ 사업종목의 전환, 사업의 포기, 업체 간의 통합 등의 이유로 서비스를 제공할 수 없게 되는 경우에는 “몰”은 제8조에 정한 방법으로 이용자에게 통지하고 당초 “몰”에서 제시한 조건에 따라 소비자에게 보상합니다. 다만, “몰”이 보상기준 등을 고지하지 아니한 경우에는 이용자들의 마일리지 또는 적립금 등을 “몰”에서 통용되는 통화가치에 상응하는 현물 또는 현금으로 이용자에게 지급합니다.제6조(회원가입) ① 이용자는 “몰”이 정한 가입 양식에 따라 회원정보를 기입한 후 이 약관에 동의한다는 의사표시를 함으로서 회원가입을 신청합니다.② “몰”은 제1항과 같이 회원으로 가입할 것을 신청한 이용자 중 다음 각 호에 해당하지 않는 한 회원으로 등록합니다.  1. 가입신청자가 이 약관 제7조제3항에 의하여 이전에 회원자격을 상실한 적이 있는 경우, 다만 제7조제3항에 의한 회원자격 상실 후 3년이 경과한 자로서 “몰”의 회원재가입 승낙을 얻은 경우에는 예외로 한다.  2. 등록 내용에 허위, 기재누락, 오기가 있는 경우  3. 기타 회원으로 등록하는 것이 “몰”의 기술상 현저히 지장이 있다고 판단되는 경우③ 회원가입계약의 성립 시기는 “몰”의 승낙이 회원에게 도달한 시점으로 합니다.④ 회원은 회원가입 시 등록한 사항에 변경이 있는 경우, 상당한 기간 이내에 “몰”에 대하여 회원정보 수정 등의 방법으로 그 변경사항을 알려야 합니다.제7조(회원 탈퇴 및 자격 상실 등) ① 회원은 “몰”에 언제든지 탈퇴를 요청할 수 있으며 “몰”은 즉시 회원탈퇴를 처리합니다.② 회원이 다음 각 호의 사유에 해당하는 경우, “몰”은 회원자격을 제한 및 정지시킬 수 있습니다.  1. 가입 신청 시에 허위 내용을 등록한 경우  2. “몰”을 이용하여 구입한 재화 등의 대금, 기타 “몰”이용에 관련하여 회원이 부담하는 채무를 기일에 지급하지 않는 경우  3. 다른 사람의 “몰” 이용을 방해하거나 그 정보를 도용하는 등 전자상거래 질서를 위협하는 경우  4. “몰”을 이용하여 법령 또는 이 약관이 금지하거나 공서양속에 반하는 행위를 하는 경우③ “몰”이 회원 자격을 제한․정지 시킨 후, 동일한 행위가 2회 이상 반복되거나 30일 이내에 그 사유가 시정되지 아니하는 경우 “몰”은 회원자격을 상실시킬 수 있습니다.④ “몰”이 회원자격을 상실시키는 경우에는 회원등록을 말소합니다. 이 경우 회원에게 이를 통지하고, 회원등록 말소 전에 최소한 30일 이상의 기간을 정하여 소명할 기회를 부여합니다.제8조(회원에 대한 통지)① “몰”이 회원에 대한 통지를 하는 경우, 회원이 “몰”과 미리 약정하여 지정한 전자우편 주소로 할 수 있습니다.② “몰”은 불특정다수 회원에 대한 통지의 경우 1주일이상 “몰” 게시판에 게시함으로서 개별 통지에 갈음할 수 있습니다. 다만, 회원 본인의 거래와 관련하여 중대한 영향을 미치는 사항에 대하여는 개별통지를 합니다.제9조(구매신청) ① “몰”이용자는 “몰”상에서 다음 또는 이와 유사한 방법에 의하여 구매를 신청하며, “몰”은 이용자가 구매신청을 함에 있어서 다음의 각 내용을 알기 쉽게 제공하여야 합니다. (삭제)  1. 재화 등의 검색 및 선택  2. 받는 사람의 성명, 주소, 전화번호, 전자우편주소(또는 이동전화번호) 등의 입력  3. 약관내용, 청약철회권이 제한되는 서비스, 배송료․설치비 등의 비용부담과 관련한 내용에 대한 확인  4. 이 약관에 동의하고 위 3.호의 사항을 확인하거나 거부하는 표시(예, 마우스 클릭)  5. 재화등의 구매신청 및 이에 관한 확인 또는 “몰”의 확인에 대한 동의  6. 결제방법의 선택② “몰”이 제3자에게 구매자 개인정보를 제공•위탁할 필요가 있는 경우 실제 구매신청 시 구매자의 동의를 받아야 하며, 회원가입 시 미리 포괄적으로 동의를 받지 않습니다. 이 때 “몰”은 제공되는 개인정보 항목, 제공받는 자, 제공받는 자의 개인정보 이용 목적 및 보유‧이용 기간 등을 구매자에게 명시하여야 합니다. 다만 「정보통신망이용촉진 및 정보보호 등에 관한 법률」 제25조 제1항에 의한 개인정보 처리위탁의 경우 등 관련 법령에 달리 정함이 있는 경우에는 그에 따릅니다.제10조 (계약의 성립)① “몰”은 제9조와 같은 구매신청에 대하여 다음 각 호에 해당하면 승낙하지 않을 수 있습니다. 다만, 미성년자와 계약을 체결하는 경우에는 법정대리인의 동의를 얻지 못하면 미성년자 본인 또는 법정대리인이 계약을 취소할 수 있다는 내용을 고지하여야 합니다.  1. 신청 내용에 허위, 기재누락, 오기가 있는 경우  2. 미성년자가 담배, 주류 등 청소년보호법에서 금지하는 재화 및 용역을 구매하는 경우  3. 기타 구매신청에 승낙하는 것이 “몰” 기술상 현저히 지장이 있다고 판단하는 경우② “몰”의 승낙이 제12조제1항의 수신확인통지형태로 이용자에게 도달한 시점에 계약이 성립한 것으로 봅니다.③ “몰”의 승낙의 의사표시에는 이용자의 구매 신청에 대한 확인 및 판매가능 여부, 구매신청의 정정 취소 등에 관한 정보 등을 포함하여야 합니다.제11조(지급방법)“몰”에서 구매한 재화 또는 용역에 대한 대금지급방법은 다음 각 호의 방법중 가용한 방법으로 할 수 있습니다. 단, “몰”은 이용자의 지급방법에 대하여 재화 등의 대금에 어떠한 명목의 수수료도 추가하여 징수할 수 없습니다.1. 폰뱅킹, 인터넷뱅킹, 메일 뱅킹 등의 각종 계좌이체 2. 선불카드, 직불카드, 신용카드 등의 각종 카드 결제3. 온라인무통장입금4. 전자화폐에 의한 결제5. 수령 시 대금지급6. 마일리지 등 “몰”이 지급한 포인트에 의한 결제7. “몰”과 계약을 맺었거나 “몰”이 인정한 상품권에 의한 결제 8. 기타 전자적 지급 방법에 의한 대금 지급 등제12조(수신확인통지․구매신청 변경 및 취소)① “몰”은 이용자의 구매신청이 있는 경우 이용자에게 수신확인통지를 합니다.② 수신확인통지를 받은 이용자는 의사표시의 불일치 등이 있는 경우에는 수신확인통지를 받은 후 즉시 구매신청 변경 및 취소를 요청할 수 있고 “몰”은 배송 전에 이용자의 요청이 있는 경우에는 지체 없이 그 요청에 따라 처리하여야 합니다. 다만 이미 대금을 지불한 경우에는 제15조의 청약철회 등에 관한 규정에 따릅니다.제13조(재화 등의 공급)① “몰”은 이용자와 재화 등의 공급시기에 관하여 별도의 약정이 없는 이상, 이용자가 청약을 한 날부터 7일 이내에 재화 등을 배송할 수 있도록 주문제작, 포장 등 기타의 필요한 조치를 취합니다. 다만, “몰”이 이미 재화 등의 대금의 전부 또는 일부를 받은 경우에는 대금의 전부 또는 일부를 받은 날부터 3영업일 이내에 조치를 취합니다. 이때 “몰”은 이용자가 재화 등의 공급 절차 및 진행 사항을 확인할 수 있도록 적절한 조치를 합니다.② “몰”은 이용자가 구매한 재화에 대해 배송수단, 수단별 배송비용 부담자, 수단별 배송기간 등을 명시합니다. 만약 “몰”이 약정 배송기간을 초과한 경우에는 그로 인한 이용자의 손해를 배상하여야 합니다. 다만 “몰”이 고의․과실이 없음을 입증한 경우에는 그러하지 아니합니다.제14조(환급)“몰”은 이용자가 구매신청한 재화 등이 품절 등의 사유로 인도 또는 제공을 할 수 없을 때에는 지체 없이 그 사유를 이용자에게 통지하고 사전에 재화 등의 대금을 받은 경우에는 대금을 받은 날부터 3영업일 이내에 환급하거나 환급에 필요한 조치를 취합니다.제15조(청약철회 등)① “몰”과 재화등의 구매에 관한 계약을 체결한 이용자는 「전자상거래 등에서의 소비자보호에 관한 법률」 제13조 제2항에 따른 계약내용에 관한 서면을 받은 날(그 서면을 받은 때보다 재화 등의 공급이 늦게 이루어진 경우에는 재화 등을 공급받거나 재화 등의 공급이 시작된 날을 말합니다)부터 7일 이내에는 청약의 철회를 할 수 있습니다. 다만, 청약철회에 관하여 「전자상거래 등에서의 소비자보호에 관한 법률」에 달리 정함이 있는 경우에는 동 법 규정에 따릅니다. ② 이용자는 재화 등을 배송 받은 경우 다음 각 호의 1에 해당하는 경우에는 반품 및 교환을 할 수 없습니다.  1. 이용자에게 책임 있는 사유로 재화 등이 멸실 또는 훼손된 경우(다만, 재화 등의 내용을 확인하기 위하여 포장 등을 훼손한 경우에는 청약철회를 할 수 있습니다)  2. 이용자의 사용 또는 일부 소비에 의하여 재화 등의 가치가 현저히 감소한 경우  3. 시간의 경과에 의하여 재판매가 곤란할 정도로 재화등의 가치가 현저히 감소한 경우  4. 같은 성능을 지닌 재화 등으로 복제가 가능한 경우 그 원본인 재화 등의 포장을 훼손한 경우③ 제2항제2호 내지 제4호의 경우에 “몰”이 사전에 청약철회 등이 제한되는 사실을 소비자가 쉽게 알 수 있는 곳에 명기하거나 시용상품을 제공하는 등의 조치를 하지 않았다면 이용자의 청약철회 등이 제한되지 않습니다.④ 이용자는 제1항 및 제2항의 규정에 불구하고 재화 등의 내용이 표시•광고 내용과 다르거나 계약내용과 다르게 이행된 때에는 당해 재화 등을 공급받은 날부터 3월 이내, 그 사실을 안 날 또는 알 수 있었던 날부터 30일 이내에 청약철회 등을 할 수 있습니다.제16조(청약철회 등의 효과)① “몰”은 이용자로부터 재화 등을 반환받은 경우 3영업일 이내에 이미 지급받은 재화 등의 대금을 환급합니다. 이 경우 “몰”이 이용자에게 재화등의 환급을 지연한때에는 그 지연기간에 대하여 「전자상거래 등에서의 소비자보호에 관한 법률 시행령」제21조의2에서 정하는 지연이자율(괄호 부분 삭제)을 곱하여 산정한 지연이자를 지급합니다.② “몰”은 위 대금을 환급함에 있어서 이용자가 신용카드 또는 전자화폐 등의 결제수단으로 재화 등의 대금을 지급한 때에는 지체 없이 당해 결제수단을 제공한 사업자로 하여금 재화 등의 대금의 청구를 정지 또는 취소하도록 요청합니다.③ 청약철회 등의 경우 공급받은 재화 등의 반환에 필요한 비용은 이용자가 부담합니다. “몰”은 이용자에게 청약철회 등을 이유로 위약금 또는 손해배상을 청구하지 않습니다. 다만 재화 등의 내용이 표시•광고 내용과 다르거나 계약내용과 다르게 이행되어 청약철회 등을 하는 경우 재화 등의 반환에 필요한 비용은 “몰”이 부담합니다.④ 이용자가 재화 등을 제공받을 때 발송비를 부담한 경우에 “몰”은 청약철회 시 그 비용을 누가 부담하는지를 이용자가 알기 쉽도록 명확하게 표시합니다.제17조(개인정보보호)① “몰”은 이용자의 개인정보 수집시 서비스제공을 위하여 필요한 범위에서 최소한의 개인정보를 수집합니다. ② “몰”은 회원가입시 구매계약이행에 필요한 정보를 미리 수집하지 않습니다. 다만, 관련 법령상 의무이행을 위하여 구매계약 이전에 본인확인이 필요한 경우로서 최소한의 특정 개인정보를 수집하는 경우에는 그러하지 아니합니다.③ “몰”은 이용자의 개인정보를 수집•이용하는 때에는 당해 이용자에게 그 목적을 고지하고 동의를 받습니다. ④ “몰”은 수집된 개인정보를 목적외의 용도로 이용할 수 없으며, 새로운 이용목적이 발생한 경우 또는 제3자에게 제공하는 경우에는 이용•제공단계에서 당해 이용자에게 그 목적을 고지하고 동의를 받습니다. 다만, 관련 법령에 달리 정함이 있는 경우에는 예외로 합니다.⑤ “몰”이 제2항과 제3항에 의해 이용자의 동의를 받아야 하는 경우에는 개인정보보호 책임자의 신원(소속, 성명 및 전화번호, 기타 연락처), 정보의 수집목적 및 이용목적, 제3자에 대한 정보제공 관련사항(제공받은자, 제공목적 및 제공할 정보의 내용) 등 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」 제22조제2항이 규정한 사항을 미리 명시하거나 고지해야 하며 이용자는 언제든지 이 동의를 철회할 수 있습니다.⑥ 이용자는 언제든지 “몰”이 가지고 있는 자신의 개인정보에 대해 열람 및 오류정정을 요구할 수 있으며 “몰”은 이에 대해 지체 없이 필요한 조치를 취할 의무를 집니다. 이용자가 오류의 정정을 요구한 경우에는 “몰”은 그 오류를 정정할 때까지 당해 개인정보를 이용하지 않습니다.⑦ “몰”은 개인정보 보호를 위하여 이용자의 개인정보를 처리하는 자를 최소한으로 제한하여야 하며 신용카드, 은행계좌 등을 포함한 이용자의 개인정보의 분실, 도난, 유출, 동의 없는 제3자 제공, 변조 등으로 인한 이용자의 손해에 대하여 모든 책임을 집니다.⑧ “몰” 또는 그로부터 개인정보를 제공받은 제3자는 개인정보의 수집목적 또는 제공받은 목적을 달성한 때에는 당해 개인정보를 지체 없이 파기합니다.⑨ “몰”은 개인정보의 수집•이용•제공에 관한 동의란을 미리 선택한 것으로 설정해두지 않습니다. 또한 개인정보의 수집•이용•제공에 관한 이용자의 동의거절시 제한되는 서비스를 구체적으로 명시하고, 필수수집항목이 아닌 개인정보의 수집•이용•제공에 관한 이용자의 동의 거절을 이유로 회원가입 등 서비스 제공을 제한하거나 거절하지 않습니다.제18조(“몰“의 의무)① “몰”은 법령과 이 약관이 금지하거나 공서양속에 반하는 행위를 하지 않으며 이 약관이 정하는 바에 따라 지속적이고, 안정적으로 재화․용역을 제공하는데 최선을 다하여야 합니다.② “몰”은 이용자가 안전하게 인터넷 서비스를 이용할 수 있도록 이용자의 개인정보(신용정보 포함)보호를 위한 보안 시스템을 갖추어야 합니다.③ “몰”이 상품이나 용역에 대하여 「표시․광고의 공정화에 관한 법률」 제3조 소정의 부당한 표시․광고행위를 함으로써 이용자가 손해를 입은 때에는 이를 배상할 책임을 집니다.④ “몰”은 이용자가 원하지 않는 영리목적의 광고성 전자우편을 발송하지 않습니다.제19조(회원의 ID 및 비밀번호에 대한 의무)① 제17조의 경우를 제외한 ID와 비밀번호에 관한 관리책임은 회원에게 있습니다.② 회원은 자신의 ID 및 비밀번호를 제3자에게 이용하게 해서는 안됩니다.③ 회원이 자신의 ID 및 비밀번호를 도난당하거나 제3자가 사용하고 있음을 인지한 경우에는 바로 “몰”에 통보하고 “몰”의 안내가 있는 경우에는 그에 따라야 합니다.제20조(이용자의 의무)이용자는 다음 행위를 하여서는 안 됩니다.1. 신청 또는 변경시 허위 내용의 등록2. 타인의 정보 도용3. “몰”에 게시된 정보의 변경4. “몰”이 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시5. “몰” 기타 제3자의 저작권 등 지적재산권에 대한 침해6. “몰” 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위7. 외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 몰에 공개 또는 게시하는 행위제21조(연결“몰”과 피연결“몰” 간의 관계)① 상위 “몰”과 하위 “몰”이 하이퍼링크(예: 하이퍼링크의 대상에는 문자, 그림 및 동화상 등이 포함됨)방식 등으로 연결된 경우, 전자를 연결 “몰”(웹 사이트)이라고 하고 후자를 피연결 “몰”(웹사이트)이라고 합니다.② 연결“몰”은 피연결“몰”이 독자적으로 제공하는 재화 등에 의하여 이용자와 행하는 거래에 대해서 보증 책임을 지지 않는다는 뜻을 연결“몰”의 초기화면 또는 연결되는 시점의 팝업화면으로 명시한 경우에는 그 거래에 대한 보증 책임을 지지 않습니다.제22조(저작권의 귀속 및 이용제한)① “몰“이 작성한 저작물에 대한 저작권 기타 지적재산권은 ”몰“에 귀속합니다.② 이용자는 “몰”을 이용함으로써 얻은 정보 중 “몰”에게 지적재산권이 귀속된 정보를 “몰”의 사전 승낙 없이 복제, 송신, 출판, 배포, 방송 기타 방법에 의하여 영리목적으로 이용하거나 제3자에게 이용하게 하여서는 안됩니다.③ “몰”은 약정에 따라 이용자에게 귀속된 저작권을 사용하는 경우 당해 이용자에게 통보하여야 합니다.제23조(분쟁해결)① “몰”은 이용자가 제기하는 정당한 의견이나 불만을 반영하고 그 피해를 보상처리하기 위하여 피해보상처리기구를 설치․운영합니다.② “몰”은 이용자로부터 제출되는 불만사항 및 의견은 우선적으로 그 사항을 처리합니다. 다만, 신속한 처리가 곤란한 경우에는 이용자에게 그 사유와 처리일정을 즉시 통보해 드립니다.③ “몰”과 이용자 간에 발생한 전자상거래 분쟁과 관련하여 이용자의 피해구제신청이 있는 경우에는 공정거래위원회 또는 시•도지사가 의뢰하는 분쟁조정기관의 조정에 따를 수 있습니다.제24조(재판권 및 준거법)① “몰”과 이용자 간에 발생한 전자상거래 분쟁에 관한 소송은 제소 당시의 이용자의 주소에 의하고, 주소가 없는 경우에는 거소를 관할하는 지방법원의 전속관할로 합니다. 다만, 제소 당시 이용자의 주소 또는 거소가 분명하지 않거나 외국 거주자의 경우에는 민사소송법상의 관할법원에 제기합니다.② “몰”과 이용자 간에 제기된 전자상거래 소송에는 한국법을 적용합니다.#카카오톡 알림톡 시행에 관한 내용&quot;FnF&quot;는 회원가입, 주문안내, 배송안내 등 비광고성 정보를 카카오톡 알림톡으로 알려드리며, 만약 알림톡 수신이 불가능하거나 수신 차단하신 경우에는 일반 문자메시지로 보내드립니다. 카카오톡 알림톡을 통해 안내되는 정보를 와이파이가 아닌 이동통신망으로 이용할 경우, 알림톡 수신 중 데이터 요금이 발생할 수 있습니다. 카카오톡을 통해 발송되는 알림톡 수신을 원치 않으실 경우 반드시 알림톡을 차단하여 주시기 바랍니다.#카카오톡 상담톡 시행에 관한 내용&quot;FnF&quot;는 상담업무를 카카오톡 상담톡으로 진행하며, 만약 카카오톡을 통해 안내되는 상담 내용을 Wi-Fi 나 PC가 아닌 이동통신망으로 이용할 경우, 데이터 요금이 발생할 수 있습니다. 카카오톡을 통해 상담을 원치 않으실 경우 고객센터, 게시판 문의를 이용해 주시기 바랍니다.부 칙(시행일) 이 약관은 2017년 12월 7일부터 시행합니다.</textarea>
                <br><div class="text-right"><input type="checkbox" name="agree_chk" id="agree_chk" value="">동의</div>
  <!--  </table> -->
   
   <!-- 결제예상금액 -->
   <div class="col align-self-start">
     			<p class="text-primary h4 strong">결제 예상 금액</p>
    	</div>
    		<table class="table">
    		<tr>
    		<th class="text-center">총 주문금액</th><th class="text-center">총 할인 + 부가 결제금액</th><th class="text-center">총 결제금액</th>
    		</tr>
    		<tr class="text-center h3">
    		<td id="psum"></td><td id="fee2"></td><td class="text-primary" id="totalprice2"></td>
    		
    		</tr>
    		</table>
    <!-- 결제수단 -->
    <div class="col align-self-start">
     			<p class="text-primary h4">결제 수단</p>
    </div>
    <div  class="ml-5 mt-3">
    	<table class="table table-bordered">
    	<tr>
    		<td class="col-md-2">
    		<input type="radio" value="무통장" name="pay" id="pay"  onclick="javascript:contentsView(pay);" ><img style="padding:5px" src="img/input.gif"><br />
    		<input type="radio" value="카카오페이" name="pay" id="kpay" onclick="javascript:contentsView(kpay);"><img style="padding:5px" src="img/payment_icon_yellow_medium.png">
    		</td>
    	<td>
    	 <div id="bank" class="h5">
                            무통장 입금 입니다.<br />
                             예금주 : FNF, 신한은행 : 110-000-00000 <br />
			입금자명은 받는분 이름과 동일하지않거나 결제금액이 다를 경우 결제확인이 되지 않습니다. <br />
			입금후 한 시간내로 결제완료 문자가 오지 않으면 고객센터로 연락바랍니다.
            </div>
			<div id="kpay2" class="h5"> 
                           휴대폰에 설치된 카카오톡 앱에서 비밀번호 입력만으로 빠르고 안전하게 결제가 가능한 서비스 입니다.<br />
		       안드로이드의 경우 구글 플레이, 아이폰의 경우 앱 스토어에서 카카오톡 앱을 설치 한 후,<br />
		        최초 1회 카드 및 계좌 정보를 등록하셔야 사용 가능합니다.<br />
		       인터넷 익스플로러의 경우 8 이상에서만 결제 가능합니다.  
            </div>
    	</td>
    	</tr>
    	</table>
    	</div>

        
          <div class="text-center p-3">
          	<input type="button" class="btn btn-outline-success" value="뒤로가기" onclick="history.back()">
          	 <input type="button" class="btn btn-outline-success" value="결제하기" onclick="f_save()">

          </div>
          </form>
         <div class="pt-2">&nbsp; </div>
          <input type="hidden" id="totalprice" />
 	  	 </div>
  

   <!-- footer -->  
<jsp:include page="footer.jsp"></jsp:include>
  <!-- / footer -->
</body>
<!-- SCRIPT -->
<script src="css/bootstrap.css"></script>
<script src="js/bootstrap.js"></script>
<script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
<script src="http://dmaps.daum.net/map_js_init/postcode.v2.js"></script>
<script type="text/javascript" src="jquery.validate.min.js"></script>
<script>
/* 다음 우편번호 */
function dzip() {
    new daum.Postcode({
        oncomplete: function(data) {
            var fullAddr = ''; 
            var extraAddr = '';

            if (data.userSelectedType === 'R') { 
                fullAddr = data.roadAddress;
            } else { 
                fullAddr = data.jibunAddress;
            }
            if(data.userSelectedType === 'R'){
                
                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                    extraAddr += data.bname;
                }
               
                if(data.buildingName !== '' && data.apartment === 'Y'){
                    extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                fullAddr += (extraAddr !== '' ? ' ('+ extraAddr +')' : '');
            }
            document.getElementById('zipcode').value = data.zonecode; 
            document.getElementById('address1').value = fullAddr;

            document.getElementById('address2').focus();
        }
    }).open();
}

</script>
</html>