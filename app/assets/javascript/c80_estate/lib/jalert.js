
var jAlert = function (message) {
    $('<div id="dialog" class="my-dialog" title="Ошибка"><p>'+message+'</p></div>').dialog({
        dialogClass: "no-close",
        modal: true,
        buttons: [
            {
                text: "OK",
                buttonClass: 'nn',
                click: function() {
                    $( this ).dialog( "close" );
                }
            }
        ]
    });
};