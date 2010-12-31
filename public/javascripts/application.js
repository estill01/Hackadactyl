// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
 // Password Idea
  $("a#password_idea_link").click(function () {
    $("#getting_idea").show();
    $("#get_idea").hide();
    $.ajax({
      url: $(this).attr('href'),
      type: "GET",
      success: function(response, textStatus) {
        // response should either be the assignment_id or 'Failure'
        $("#password_idea").html(response);
        $("#getting_idea").hide();
        $("#get_idea").show();
      }
    });
    return false;
  });
  
  $(".remove-file-input").live("click", function() {
    $(this).parent().parent().remove();
    return false;
  });
  
  $(".delete-image-link").click(function () {
    var remove = confirm("Are you sure you want to remove this image?");
    if(remove) {
      $.ajax({
        url: $(this).attr('href'),
        type: "DELETE",
        dataType: "script"
      });
    }
    return false;
  });

});

 jQuery.fn.addImageInputBinding = function(attributeName, modelName){
   this.click(function () {
       index = new Date().getTime();
       name = attributeName + index;
       $input = $("<dl>");
       $dtTag = $("<dt>");
       $dtTag.append($("<label>").attr({"for": name}).html("Image"));
       $input.append($dtTag);
       $ddTag = $("<dd>");
       $ddTag.append($("<input>").attr({"id": name, "type": "file", "name": modelName + "[" + attributeName + "][" + index + "][image]"}));
       $ddTag.append($("<a>").attr({"href": "#"}).addClass("remove-file-input action").html("&nbsp;remove"));
       $input.append($ddTag);
       $("#" + attributeName + "_fields").append($input);
       return false;
     });
  };