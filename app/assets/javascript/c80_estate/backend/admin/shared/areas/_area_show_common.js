// запускаем механизм просмотра картинки товара
var fItemImageMagnificPopupStart = function () {
    $("div#div_main_show_area").magnificPopup({
        delegate: 'a.lazy-image-wrapper',
        fixedContentPos: false,
        removalDelay: 300,
        mainClass: 'mfp-fade',
        type: 'image'
    });
};

var fItemGalleryPhotosMagnificPopupStart = function() {
    $("div#gallery3").magnificPopup({
        delegate: 'a',
        fixedContentPos: false,
        removalDelay: 300,
        mainClass: 'mfp-fade',
        type: 'image',
        gallery: {enabled:true}
    });
}