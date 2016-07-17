"use strict";

var fPstatsIndex = function () {

    // элементы html страницы
    var $main_content;          // правая сторона, там живёт таблица
    var $select_atype;          // фильтр atype
    var $select_property;       // фильтр property
    var $input_start_date;      // фильтр "дата начала периода"
    var $input_end_date;        // фильтр "дата конца периода"
    var $h2_page_title;         // заголовок страницы

    // компонент "над таблицей"
    var $div_index_adds;
    var $div_busy_coef;
    var $p_busy_coef;           // здесь выводим число - коэф-т эффективности
    var $p_ecoef_mess;          // здесь вешаем hint на подпись "эффективность"
    var $p_ecoef_comment;       // здесь выводим комментарий
    var $div_area_text_stats;
    var $ul_props;              // здесь выводим текстовые свойства
    var $div_graph;             // в этом div живет график

    var fBuild = function () {

        // зафиксируем html элементы
        $main_content = $('#main_content');
        $select_atype = $("#q_atype_id");
        $select_property = $("#q_property_id");
        $input_start_date = $("#q_created_at_gteq");
        $input_end_date = $("#q_created_at_lteq");
        $h2_page_title = $("h2#page_title");

        // построим компонент "над таблицей"
        $div_index_adds = $("<div id='index_adds'></div>");

        $div_busy_coef = $("<div id='coef'></div>");
        $p_busy_coef = $("<p class='val'></p>");
        $p_ecoef_mess = $("<p class='title'><abbr class='abbr_ecoef' title='TITLE'>Занятость</abbr></p>");
        $p_ecoef_comment = $("<p class='comment'></p>");

        $div_busy_coef.append($p_busy_coef);
        $div_busy_coef.append($p_ecoef_mess);
        $div_busy_coef.append($p_ecoef_comment);

        $div_area_text_stats = $("<div id='text_stats'></div>");
        $ul_props = $("<ul><li id='title'></li><li id='born_date'></li><li id='all_areas_count'></li><li id='free_areas_count'></li><li id='busy_areas_count'></li></ul>");
        $div_area_text_stats.append($ul_props);

        $div_graph = $("<div id='graph'></div>");

        $div_index_adds.append($div_busy_coef);
        $div_index_adds.append($div_area_text_stats);
        $div_index_adds.append($div_graph);

        $main_content.prepend($div_index_adds);

        // теперь покажем
        $main_content.css('opacity', '1.0');
    };

    var fRequest = function () {

        var atype_id = $select_atype.val();
        var property_id = $select_property.val();
        var start_date = $input_start_date.val();
        var end_date = $input_end_date.val();

        $.ajax({
            url: '/estate/properties_busy_coef',
            type: 'POST',
            dataType: 'json',
            data: {
                atype_id: atype_id,
                property_id: property_id,
                start_date: start_date,
                end_date: end_date
            }
        }).done(function (data, result) {
            if (result == 'success') {
                console.log(data);

                $p_busy_coef.text(data["busy_coef"]);
                $p_ecoef_comment.html(data["comment"]);
                $p_ecoef_mess.find('.abbr_ecoef').attr('title', data["abbr"]);

                if (data["props"] != undefined) {

                    var i, iob, itag, ival, $ili;
                    for (i = 0; i < data["props"].length; i++) {
                        iob = data["props"][i];
                        itag = iob["tag"];
                        ival = iob["val"];
                        $ili = $ul_props.find("#" + itag);
                        $ili.html(ival);
                    }

                }

                if (data["graph"] != undefined) {
                    fDrawChart(data["graph"]);
                }

                $h2_page_title.text(data["title"]);
                $h2_page_title.css('opacity', '1.0');
                $(document).attr('title', data["title"]);

            } else {
                alert('fail: /estate/properties_busy_coef');
            }
            //fPreloaderHide();
        });

        //fPreloaderShow();
    };

    var fInit = function () {
        fBuild();
        fRequest();
    };

    var fDrawChart = function (data_array_rows) {
    };

    fInit();

};

var fPstatsEdit = function () {

    alert("edit");

};

var fPstatsNew = function () {

    alert("new");

};

YOUR_APP.pstats = {
    edit: fPstatsEdit,
    "new": fPstatsNew,
    index: fPstatsIndex
};