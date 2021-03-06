<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Fishers N Farmers</title>

<!-- Font awesome -->
<link href="/resources/css/font-awesome.css" rel="stylesheet">
<!-- Bootstrap -->
<link href="/resources/css/bootstrap.css" rel="stylesheet">
<!-- SmartMenus jQuery Bootstrap Addon CSS -->
<link href="/resources/css/jquery.smartmenus.bootstrap.css"
	rel="stylesheet">
<!-- Product view slider -->
<link rel="stylesheet" type="text/css"
	href="/resources/css/jquery.simpleLens.css">
<!-- slick slider -->
<link rel="stylesheet" type="text/css" href="/resources/css/slick.css">
<!-- price picker slider -->
<link rel="stylesheet" type="text/css"
	href="/resources/css/nouislider.css">
<!-- Theme color -->
<link id="switcher" href="/resources/css/theme.css" rel="stylesheet">
<!-- Top Slider CSS -->
<link href="/resources/css/slide.css" rel="stylesheet" media="all">

<!-- Main style sheet -->
<link href="/resources/css/style2.css" rel="stylesheet">

<link href="/resources/css/sidebar2.css" rel="stylesheet">
<script src="js/jquery.min.js"></script>
<style type="text/css">
.widget_customer_page_info {
	margin-top: 0px;
	background: #ededed;
	text-align: center;
}

/*  버튼 */
/* 	#container #contents { width:100% !important; } */
.fixed_customer_page {
	width: 650px;
	margin: 0 auto;
}

.banner {
	overflow: hidden;
	margin: 80px 0 0px 0;
}

.banner ul {
	margin: 0 0 0 -8px;
	padding: 0;
}

.banner ul li {
	float: left;
	margin: 0 0 9px 15px;
}

.banner ul li a:hover img {
	opacity: 0.6;
}

ul {
	list-style: none;
}

#subtitle {
	color: 355b8f;
}

/* 검색  */
#search, #click, #search_key {
	height: 30px
}

#click {
	margin: 0px 0 5px 0;
}

#find {
	text-align: right;
}

h2 {
	margin: 0px 0 30px 0;
}

/* #paging{
		margin:0px 0 40px 0;
	} */
</style>

<script src="js/jquery.min.js"></script>
<script>
	var page = null;
	$(document).ready(function() {
		$.ajax({
			url : "/admin/faq/1",
			dataType : "json",
			method : "POST",
			success : function(data) {
				display(data);
			},
			error : function(err) {
				console.log("Error 발생 : " + err);
			}
		});
	});

	function goPage(pge) { //page 이동
		page = pge;
		$.ajax({
			url : "/admin/faq/" + pge,
			dataType : "json",
			method : "POST",
			success : function(result) {
				display(result);
			}
		});
	}
	function display(result) {
		var startPage = result.startPage;
		var endPage = result.endPage;
		var totalPage = result.totalPage;
		var pageSize = result.pageSize;
		page = result.page; //current Page
		var data = result.data;
		var count = data.length;
		var str = null;
		if (count == 0) {
			str = "<tr>";
			str += "<td colspan='5' align='center'>";
			str += "글이 없습니다.</td>";
			str += "</tr>";
		} else if (count > 0) {
			for (var i = 0; i < count; i++) {
				var faq = data[i];
				var writedate = faq.writedate.substr(0, 10);

				str += "<tr>";
				str += "<td>"
						+ faq.idx
						+ "</td>"
						+ "<td>&nbsp;"
						+ "<a href='/admin/faq/" + page + "/" + faq.idx +
					"'>"
						+ faq.title + "</a></td>" + "<td>" + faq.user_id
						+ "</td>" + "<td>" + faq.readnum + "</td>" + "<td>"
						+ writedate + "</td>";
				str += "</tr>";
			}
		}
		$("#records").html(str);
		$("#paging").empty();
		$("#paging").attr("style", "text-align:center");
		var pageStr = "<nav><div class='text-center'><ul class='pagination'>";

		if (page == 1) {
			pageStr += "<li><a aria-label='Previous'>";
			pageStr += "<span aria-hidden='true'>&lt;&lt;</span></a></li>";
			pageStr += "<li><a aria-label='Previous'>";
			pageStr += "<span aria-hidden='true'>&lt;</span></a></li>";
		} else if (page != 1) {
			pageStr += "<li><a href='javascript:goPage(1)' aria-label='Previous'>";
			pageStr += "<span aria-hidden='true'>&lt;&lt;</span></a></li>";
			if ((startPage - pageSize) <= 0) {
				pageStr += "<li><a href='javascript:goPage(" + 1
						+ ")' aria-label='Previous'>";
				pageStr += "<span aria-hidden='true'>&lt;</span></a></li>";
			} else {
				pageStr += "<li><a href='javascript:goPage("
						+ (startPage - pageSize) + ")' aria-label='Previous'>";
				pageStr += "<span aria-hidden='true'>&lt;</span></a></li>";
			}
		}

		if (endPage <= 10) { // 끝 나는 페이지가 10보다 작으면
			for (var k = 1; k <= endPage; k++) {
				if (page == k) //현재 페이지
					pageStr += "<li><a>" + k + "</a></li>";
				else
					pageStr += "<li><a href='javascript:goPage(" + k + ")'>"
							+ k + "</a></li>";
			}
		} else {
			for (var k = 1; k <= endPage; k++) {
				if (page == k) //현재 페이지
					pageStr += "<li><a>" + k + "</a></li>";
				else
					pageStr += "<li><a href='javascript:goPage(" + k + ")'>"
							+ k + "</a></li>";
			}
		}

		if (page == totalPage) {
			pageStr += "<li><a aria-label='Next'> ";
			pageStr += "<span aria-hidden='true'>&gt;</span></a></li>";
			pageStr += "<li><a aria-label='Next'> ";
			pageStr += "<span aria-hidden='true'>&gt;&gt;</span></a></li></ul></div></nav>";
		} else if (page != totalPage) {
			pageStr += "<li><a href='javascript:goPage("
					+ (startPage + pageSize) + ")'aria-label='Next'> ";
			pageStr += "<span aria-hidden='true'>&gt;</span></a></li>";
			pageStr += "<li><a href='javascript:goPage(" + totalPage
					+ ")'aria-label='Next'> ";
			pageStr += "<span aria-hidden='true'>&gt;&gt;</span></a></li></ul></div></nav>";
		}

		$("#paging").html(pageStr);
	}
</script>
</head>
<body>
	<jsp:include page="header.jsp" />
	<section id="aa-popular-category">
		<!-- 본문 -->
		<div id="wrapper">
			<!-- 사이드바 -->
			<div id="sidebar-wrapper">
				<div id="aa-sidebar-widget">
					<ul class="sidebar-nav">
						<li><a href="/admin"><h2>[관리자 페이지]</h2></a></li>
						<h3>&nbsp;&nbsp;&nbsp;Member</h3>
						<li><a href="/admin/user">회원 관리</a></li>
						<li><a href="/admin/seller">판매자 관리</a></li>
						<h3>&nbsp;&nbsp;&nbsp;Product</h3>
						<li><a href="/admin/product">상품 관리</a></li>
						<li><a href="/admin/recomm">추천 상품 등록</a></li>
						<h3>&nbsp;&nbsp;&nbsp;Board</h3>
						<li><a href="/admin/board">게시판 관리</a></li>
						<li><a href="/admin/cs">공지사항</a></li>
						<li><a href="/admin/qaa">1:1문의</a></li>
						<li><a href="/admin/faq">FAQ</a></li>
					</ul>
				</div>
			</div>
			<!-- /사이드바 -->

			<div id="page-content-wrapper">
				<div class="container-fluid">
					<div class="row">
						<div class="col-md-1"></div>
						<div class="col-md-9">

							<h2 class="text-center" style="color: #3673be;">
								<strong>자주 묻는 질문</strong>
							</h2>
							<p />
							<form action="boardarticlelist.sd" class="form-horizontal"
								name="frm" id="frm" method="post">

								<input id="s_pagenum" name="s_pagenum" type="hidden" value="1" />
								<input id="s_pagesize" name="s_pagesize" type="hidden"
									value="10" /> <input id="s_rowsize" name="s_rowsize"
									type="hidden" value="10" /> <input name="bda_bdid"
									id="bda_bdid" type="hidden" value="oneone" />

								<div class="table-responsive">
									<table class="table table-hover table1">

										<colgroup>
											<col width="10%">
											<col width="50%">
											<col width="15%">
											<col width="10%">
											<col width="20%">
										</colgroup>

										<thead>
											<tr id="headtitle">
												<th class="hidden-xs">#</th>
												<th>제목</th>
												<th>작성자</th>
												<th class="hidden-sm hidden-xs">조회</th>
												<th class="hidden-xs">등록일</th>
											</tr>
										</thead>

										<tbody id="records">

										</tbody>

									</table>
								</div>
							</form>
							<div class="aa-blog-archive-pagination">
								<nav id="paging"></nav>
							</div>
							<div class="sd-blog-content">
								
								<div class="col-sm-12 aa-login-form">
									<button  class="btn btn-primary btn-lg" type="button"
										onclick="location.href='faq/faqwrite'">글쓰기</button>
								</div>
							</div>

						</div>
					</div>
				</div>






			</div>
		</div>

		</div>
		</div>
		<!-- /본문 -->
		</div>
	</section>









	<jsp:include page="footer.jsp" />

</body>
</html>