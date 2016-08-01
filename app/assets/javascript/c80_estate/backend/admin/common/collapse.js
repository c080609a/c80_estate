$(document).ready(function(){

    var $divfaq = $(".wrap_collapse");
    var $div_anser = $divfaq.find('.collapse');

    $div_anser.on("hide.bs.collapse", function(){
        //$(".btn").html('<span class="glyphicon glyphicon-collapse-down"></span> Open');
        $divfaq.find(".btn").find("span").attr("class","fa fa-chevron-right");
    });
    $div_anser.on("show.bs.collapse", function(){
        //$(".btn").html('<span class="glyphicon glyphicon-collapse-up"></span> Close');
        $divfaq.find(".btn").find("span").attr("class","fa fa-chevron-down");
    });
});