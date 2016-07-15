"use strict";

var fSeventsIndex = function () {

    // элементы html страницы
    var $main_content;          // правая сторона, там живёт таблица
    var $select_area;           // фильтр area
    var $select_atype;          // фильтр atype
    var $select_property;       // фильтр property
    var $select_auser;          // фильтр auser
    var $input_start_date;      // фильтр "дата начала периода"
    var $input_end_date;        // фильтр "дата конца периода"
    var $h2_page_title;         // заголовок страницы

    // компонент "над таблицей"
    var $div_index_adds;
    var $div_ecoef;
    var $p_ecoef_val;           // здесь выводим число - коэф-т эффективности
    var $p_ecoef_mess;          // здесь вешаем hint на подпись "эффективность"
    var $p_ecoef_comment;       // здесь выводим комментарий
    var $div_area_text_stats;
    var $ul_props;
    var $div_graph;

    var fBuild = function () {

        // зафиксируем html элементы
        $main_content = $('#main_content');
        $select_area = $("#q_area_id");
        $select_atype = $("#q_atype_id");
        $select_property = $("#q_property_id");
        $select_auser = $("#q_auser_id");
        $input_start_date = $("#q_created_at_gteq");
        $input_end_date = $("#q_created_at_lteq");
        $h2_page_title = $("h2#page_title");

        // построим компонент "над таблицей"
        $div_index_adds = $("<div id='index_adds'></div>");

        $div_ecoef = $("<div id='ecoef'></div>");
        $p_ecoef_val = $("<p class='val'></p>");
        $p_ecoef_mess = $("<p class='title'><abbr class='abbr_ecoef' title='TITLE'>Эффективность</abbr></p>");
        $p_ecoef_comment = $("<p class='comment'></p>");

        $div_ecoef.append($p_ecoef_val);
        $div_ecoef.append($p_ecoef_mess);
        $div_ecoef.append($p_ecoef_comment);

        $div_area_text_stats = $("<div id='text_stats'></div>");
        $ul_props = $("<ul><li id='title'></li><li id='atype'></li><li id='born_date' class='hidden'></li><li id='busy_time'></li><li id='free_time'></li><li id='all_time'></li><li id='assigned_person_title'></li><li id='property_title'></li><li id='all_areas_count'></li><li id='free_areas_count'></li><li id='busy_areas_count'></li></ul>");
        $div_area_text_stats.append($ul_props);

        $div_graph = $("<div id='graph'></div>");

        $div_index_adds.append($div_ecoef);
        $div_index_adds.append($div_area_text_stats);
        $div_index_adds.append($div_graph);

        $main_content.prepend($div_index_adds);

        // теперь покажем
        $main_content.css('opacity', '1.0');
    };

    var fRequest = function () {

        var area_id = $select_area.val();
        var atype_id = $select_atype.val();
        var property_id = $select_property.val();
        var auser_id = $select_auser.val();
        var start_date = $input_start_date.val();
        var end_date = $input_end_date.val();

        $.ajax({
            url: '/estate/areas_ecoef',
            type: 'POST',
            dataType: 'json',
            data: {
                area_id: area_id,
                atype_id: atype_id,
                property_id: property_id,
                auser_id: auser_id,
                start_date: start_date,
                end_date: end_date
            }
        }).done(function (data, result) {
            if (result == 'success') {
                console.log(data);

                $p_ecoef_val.text(data["average_value"]);
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
                alert('fail: /estate/areas_ecoef');
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
        //data_array = [
        //    ['Director (Year)',  'Rotten Tomatoes', 'IMDB'],
        //    ['Alfred Hitchcock (1935)', 8.4,         7.9],
        //    ['Ralph Thomas (1959)',     6.9,         6.5],
        //    ['Don Sharp (1978)',        6.5,         6.4],
        //    ['James Hawes (2008)',      4.4,         6.2]
        //]

        google.charts.load('current', {'packages': ['corechart']});
        google.charts.setOnLoadCallback(drawChart);
        function drawChart() {

            //var data = google.visualization.arrayToDataTable(data_array_rows);

            var data = new google.visualization.DataTable();
            data.addColumn('date', ''); // Implicit domain column.
            data.addColumn('number', ''); // Implicit data column.
            //data.addColumn({type:'number', role:'interval'});
            //data.addColumn({type:'number', role:'interval'});
            //data.addColumn('number', 'Expenses');

            var i, iob, yearValue, monthValue, dayValue;
            for (i=0; i<data_array_rows.length; i++) {
                iob = data_array_rows[i];
                yearValue = iob[0].substr(0,4);
                monthValue = iob[0].substr(5,2)-1;
                dayValue = iob[0].substr(8,2);
                console.log(iob + " => " + yearValue + "/" + monthValue + "/" + dayValue ); // + ": " + data_array_rows[i][0]
                data_array_rows[i][0] = new Date(parseInt(yearValue),parseInt(monthValue),parseInt(dayValue));
            }

            data.addRows(data_array_rows);

            var options = {
                title: 'График занята/свободна',
                vAxis: { title: '', ticks: [0,1] },
                ignoreBounds: true,
                isStacked: false
            };

            var chart = new google.visualization.SteppedAreaChart(document.getElementById('graph'));

            chart.draw(data, options);
        }

        $('#graph').css('opacity','1.0').css('display','block');

    };

    fInit();

};

var fSeventsEdit = function () {

    alert("edit");

};

var fSeventsNew = function () {

    alert("new");

};

YOUR_APP.sevents = {
    edit: fSeventsEdit,
    "new": fSeventsNew,
    index: fSeventsIndex
};