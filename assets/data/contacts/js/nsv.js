/**
 * We need to add a class of `responsive-nav--open` to
 * `#js-responsive-nav` ONLY when the nav is clicked AND
 * when we’re on a viewport of less than `responsiveNavBreakpoint`.
 * It needs removing when someone re-clicks the nav icon, or
 * when the viewport no longer matches `responsiveNavBreakpoint`.
 */
$(document).ready(function() {

	var responsiveNav = $('#js-responsive-nav');
	var burger = responsiveNav.find('.burger');
	var page = $("html");

	burger.click(function(event){
	    responsiveNav.toggleClass("is-open");
	    page.toggleClass("nav-is-open");
	});

	page.find(".mask").click(function(event){
	    responsiveNav.toggleClass("is-open");
	    page.toggleClass("nav-is-open");
	});	

	$(window).scroll(function () {

	    if ($(this).scrollTop() > 50) {
	        $('.main_burger').addClass("is-bkg");
	    } 
	    else {
	        $('.main_burger').removeClass("is-bkg");
	    }

	});

	var hide_elem = $(".content_hide");

	$(".hide_control").click(function() {
		$(this).parent().parent().find(".content_hide").slideToggle(400);
		$(this).parent().parent().find(".name").toggleClass('active');
	    $(this).toggleClass("is-open");
	});
    
	var str = $(".intro").find("p");
	var mas_str = [];

	for (var i = 0; i < str.length; i++) {
		mas_str[i] = str[i].innerHTML;
	};

	function truncate(str,maxl){

	 	if(str.length <= maxl){
	 		return str;
	 	}
	 	else{
	 		return str.slice(0,maxl-3) + '...';
	 	}	
	}

	for (var i = 0; i < mas_str.length; i++) {
		str[i].innerHTML =  truncate(mas_str[i],118);
	};

});
