// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//= require bootstrap
//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
//= require_tree .
$(document).ready(function(){
   $("5").tooltip();
});
$(document).ready(function(){
 $("#div1").hide();
  $("input[name='file_upload[shared_with]']").change(function(){
  	if(this.value=='Selected Users' && this.checked){
  		$('#div1').show();
  	}
  	else{ $('#div1').hide();
  	}
  });
  
});
