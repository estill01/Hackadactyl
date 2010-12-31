// JavaScript to facilitate sorting of lists, such as search results
;(function($) {
	
  $(document).ready(function() {
	
		var parameters = null; 
		var path = $.url.attr("path");

		function setupParams() {
			var	params = parameters != null ? parameters : $.query;
			return params.REMOVE('_');
		}

		function sendParams(params) {
			$('td').css({'background-color' : '#E5E2E6', 'color' : '#BDBDBD'});
			$('th').css({'background-color' : 'gray'});
			$('table a').css({'background-color' : 'gray'});
			$('table img').css({'opacity' : '0.2'});
			parameters = params;
			$.get(path, params.toString().replace(/\%5B/g, "[").replace(/\%5D/g, "]"), null, "script");
		}
		
		setupOrderLinks();
		
		$(".order_by").live("click", function () {
			$(this).removeClass("order_by");
			var url = $.url;
			var order_by = $(this).attr("id").replace(/order_/, "");
			var params = setupParams();
			var path = url.attr("path");
			var old_order_by = params.get("order");
			if(order_by == (old_order_by)) {
					params =  (params.get("dir") == 'ASC') ? params.set("dir", "DESC") : params.set("dir", "ASC");
			}
			else {
					params =  params.set("dir", "ASC").set("order", order_by);
			}
			sendParams(params);
			$(this).children('img').show();
		});
		
		//TODO Can we put these in a new js file
		$("#search_form").live("submit",function() {
				var queryValue = $("#query").val();
				var searchByValue = $("#search_by").val();
				var params = setupParams();
				params = params.set('page', 1).set('query', queryValue);
				if(searchByValue !=null) {
					params = params.set('search_by', searchByValue);
				}
				sendParams(params);
				return false;
		  });

		$("#remove_query").live("click",function() {
				var params = setupParams();
				params = params.set('page', 1).REMOVE('query');
				sendParams(params);
				return false;
		});
		
		$(".filter").live("change", function() {
			var params = setupParams();
			var value = $(this).val();
			if(value != ""){
				params = params.set($(this).attr('id'), value).set('page', 1);
			}
			else{
				params = params.REMOVE($(this).attr('id')).set('page', 1);
			}
			sendParams(params);
		});
		
		
  }); 

})(jQuery);

function setupOrderLinks() {
	$(".order_by").css("cursor","pointer").append("<img src='../../images/loading.gif' style='display:none;' class='loading_gif'>");
	var order_by = $.url.param('order');
	var dir = $.url.param('dir');
	var klass = dir == "ASC" ? "ordered" : "ordered_desc";
	$("#order_" + order_by).addClass(klass);
}