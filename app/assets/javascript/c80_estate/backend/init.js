// initialize your global object will all your model names
//YOUR_APP = {
//
//};

var $main_content;

var fLoadingShow = function () {
    $("body").append($('<div id="loading"></div>'));
};

var fLoadingHide = function () {
    $("#loading").remove();
};

//jQuery(document).ready(function ($) {
//    get the page action
    //var action, model, b = $("body");
    //if (b.hasClass("edit")) {
    //    action = "edit";
    //} else if (b.hasClass("view")) {
    //    action = "view";
    //} else if (b.hasClass("index")) {
    //    action = "index"
    //} else if (b.hasClass("new")) {
    //    action = "new"
    //}
    //
    //run the code specific to a model and an action
    //for (var m in YOUR_APP) {
    //    if (b.hasClass("admin_" + m)) {
    //        if (YOUR_APP[m][action] && typeof YOUR_APP[m][action] == "function") {
    //            YOUR_APP[m][action]();
    //            break;
    //        }
    //    }
    //}
//});