//
$(document).ready(function () {

    var $carousel_div = $('#gallery3');

    $carousel_div.slick({
        slidesToShow: 1,
        slidesToScroll: 1,
        autoplay: false,
        fade: true,
        arrows: true,
        speed: 200,
        dots: false,
        infinite: true,
        asNavFor: '#gallery3_nav'
    });

    if (typeof(small_frames_dots) != 'undefined' && typeof(small_frames_slidesToShow) != 'undefined' && small_frames_dots !== undefined && small_frames_slidesToShow !== undefined) {
        $('#gallery3_nav').slick({
            slidesToShow: small_frames_slidesToShow,
            slidesToScroll: 1,
            asNavFor: '#gallery3',
            dots: small_frames_dots,
            //centerMode: true,
            arrows: false,
            focusOnSelect: true
        });

        setTimeout(function () {
            var $b = $("#gallery3_nav").find(".img-holder");
            //console.log($b);
            $b.bind({
                mouseenter: function () {
                    $(this).addClass("plusOpacity");
                },
                mouseleave: function () {
                    $(this).removeClass("plusOpacity");
                }
            })
        }, 100);
    }

});