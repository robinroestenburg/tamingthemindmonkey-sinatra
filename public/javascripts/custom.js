

///////////////////////
//JQUERY No Conflict Code//
///////////////////////
var $ = jQuery.noConflict();

////////////////////////
//Background changer
///////////////////////

$(document).ready(function() {
  $('.bgSwitcher').click(function(e){
         e.preventDefault();
         $("body").css("background", "#000 url('" + $(this).attr("href") + "')");

  });
});

///////////////////////
//Tooltip
///////////////////////
$(function() {
  $('.tooltip').tipsy({fade: true, gravity: 's'});
});

///////////////////////
//Tab Cateogry Numbers
///////////////////////
$(function () {
  var tabContainers = $('div.tabs > div');
  tabContainers.hide().filter(':first').show();

  $('div.tabs ul.tabNavigation a').click(function () {
  tabContainers.hide();
  tabContainers.filter(this.hash).fadeIn();
  $('div.tabs ul.tabNavigation a').removeClass('selected');
  $(this).addClass('selected');
    return false;
  }).filter(':first').click();
});
//////////////////////////
//Tab Category Categories
//////////////////////////
$(function () {
  var tabContainers = $('div.categories-tabs > div');
  tabContainers.hide().filter(':first').show();

  $('div.categories-tabs ul.switcher a').click(function () {
  tabContainers.hide();
  tabContainers.filter(this.hash).fadeIn();
  $('div.categories-tabs ul.switcher a').removeClass('selected');
  $(this).addClass('selected');
    return false;
  }).filter(':first').click();
});


///////////////////////
//Cufon Styles
///////////////////////

//Replacing The Menu Heading With Cufon
Cufon.replace('a.menuTitle');
//Replacing About Page Picture Text With Cufon
Cufon.replace('span.left, span.right');
//Replacing Button Texts With Cufon.
Cufon.replace('.button');
//Replacing Default Headings With Cufon.
Cufon.replace('h1, h2, h3, h4, h5, h6');
Cufon.replace('#name_label, #email_label, #message_label, p.location-title');


///////////////////////
//Menu Activation
///////////////////////
$(document).ready(function () {
$(".menu li").hover(function() {
    $(this).find(".dropdown").delay(300).animate({height: "show"},300);

},function(){
    $(this).find(".dropdown").delay(300).stop(true, true).animate({height: "hide"},300);
    });
});

///////////////////////
//Hover Effects.
///////////////////////
$(window).load(function() {

   $("#comments").click(function () {
      $("#recent-box").hide()
    $("#comments-box").fadeIn()
    $("#popular-box").hide()
   });

   $("#recent").click(function () {
      $("#recent-box").fadeIn()
    $("#comments-box").hide()
    $("#popular-box").hide()
   });

    $("#popular").click(function () {
      $("#recent-box").hide()
    $("#comments-box").hide()
    $("#popular-box").fadeIn()
   });

  $("img.footer-image, .demo-image, .icon-hover").hover(function(){
    $(this).animate({"opacity": "0.5"}, "medium");
  },
  function(){
    $(this).animate({"opacity": "1"}, "medium");
  });

  $(".blog-img, .recent-item").hover(function(){
    $(this).delay(100).animate({"opacity": "0.7"}, "fast");
  },
  function(){
    $(this).animate({"opacity": "1"}, "fast");
  });

  $("img.port-one-over, img.port-two-over, img.port-three-over, img.home-thumb-over").hover(function(){
    $(this).delay(100).animate({"opacity": "1"}, "slow");
  },
  function(){
    $(this).animate({"opacity": "0"}, "fast");
  });
});

///////////////////////
//Nivo-Slider
///////////////////////
$(window).load(function() {
  $('#slider').nivoSlider();
});

///////////////////////

///////////////////////


///////////////////////
//Twitter
///////////////////////
$(window).load(function() {
  $(function(){
    $('#tweets').tweetable({username: 'iEnabled', time: true, limit: 1, replies: true, position: 'append'});
  });
});

///////////////////////
//About Slider
///////////////////////
$(window).load(function() {
  $(function(){
    $('#slides').slides({
      preload: true,
      generateNextPrev: false,
      generatenumberation: false,
      play: 6000
    });
  });
});

///////////////////////
//Back To Top
///////////////////////
$(document).ready(function(){
  $('a.top').click(function(){
     $('html, body').delay(200).animate({scrollTop: '0px'}, 600);
     return false;
  });
});
//////////////////////////
//ColorBox Gallery Engage
//////////////////////////
$(document).ready(function(){
  $("a.home-gallery").colorbox();
  $("a.one-columns").colorbox();
  $("a.two-columns").colorbox();
  $("a.three-columns").colorbox();
  $("a.one-column-cat-three").colorbox();
  $("a.one-column-cat-four").colorbox();
});

//////////////////////////
//About Page Slider Engage
//////////////////////////
$(document).ready(function() {
   $('#about-slider').s3Slider({
     timeOut: 6000
  });
});

////////////////////////
//Javascript clear field
////////////////////////
function clearText(field){
  if (field.defaultValue==field.value)
  field.value = ""
}


