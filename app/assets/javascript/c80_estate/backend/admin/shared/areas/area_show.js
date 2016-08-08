"use strict";

var fAreasShow_initRichShowPage = function () {

    //fCommon();
    fItemImageMagnificPopupStart();
    fItemGalleryPhotosMagnificPopupStart();

    // если нужна кнопка "заказать"
    //var $b = $('.c80_order_invoking_btn');
    //$b.click(function (e) {
    //    if (orderForm) {
    //        orderForm.afterShowForm = function () {
                //$("textarea#mess_comment").focus();
                //
                //var $t = $("textarea#mess_comment");
                //$t.data('toggle', 'tooltip');
                //$t.data('palacement', 'right');
                //$t.data('title', 'Укажите желаемое количество.');
                //$t.tooltip();
                //
                //var $f = $('#form_order');
                //
                //var $b = $f.find('.btn');
                //$b.removeClass('btn');
                //$b.removeClass('btn-primary');
                //$b.addClass('red_button');
                //$b.attr('style','line-height: 34px;font-size: 16px;color: white; text-transform: uppercase; border-radius: 4px !important;');
                //
                //var $c = $f.find('.actions');
                //$c.css('margin-top','15px');
            //};
        //}
    //});

};

var fAreasShow_go = function () {

    // компонент "над таблицей"
    var $div_index_adds;
    var $div_ecoef;
    var $p_ecoef_val;           // здесь выводим число - коэф-т эффективности
    var $p_ecoef_mess;          // здесь вешаем hint на подпись "эффективность"
    var $p_ecoef_comment;       // здесь выводим комментарий
    var $div_area_text_stats;
    var $ul_props;
    var $div_graph;
    var $div_graph_canvas;

    var fBuild = function () {

        // построим компонент "над таблицей"
        $div_index_adds = $("<div class='index_adds_like_sevents'></div>");

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
        $div_graph_canvas = $("<canvas id='graph_canvas' height='50'></canvas>").appendTo($div_graph);

        $div_index_adds.append($div_ecoef);
        $div_index_adds.append($div_area_text_stats);
        $div_index_adds.append($div_graph);

        $(".comments").before($('<h4 style="padding-top:15px;">Статистика</h4>'));
        $(".comments").before($div_index_adds);

        // теперь покажем
        $main_content.css('opacity', '1.0');
    };

    var fRequest = function () {

        //var area_id = $select_area.val();
        //var atype_id = $select_atype.val();
        //var property_id = $select_property.val();
        //var auser_id = $select_auser.val();
        //var start_date = $input_start_date.val();
        //var end_date = $input_end_date.val();
        //

        var area_id = -1;
        var url = unescape(window.location.href);
        var match_res = url.match(/areas\/(\d{1,9})/);
        if (match_res != null) {
            area_id = Number(match_res[1]);
        }

        $.ajax({
            url: '/estate/areas_ecoef',
            type: 'POST',
            dataType: 'json',
            data: {
                area_id: area_id
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

                //$h2_page_title.text(data["title"]);
                //$h2_page_title.css('opacity', '1.0');
                //$(document).attr('title', data["title"]);

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
        fAreasShow_initRichShowPage();
    };

    var fDrawChart_google = function (data_array_rows) {
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

    var fDrawChart_chart_js = function (data) {

        if (data != undefined) {
            var ctx = $("#graph_canvas");

            var chartInstance = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data["labels"],
                    datasets: [
                        {
                            label: "График занята/свободна",
                            backgroundColor: [
                                'rgba(255, 99, 132, 0.2)',
                                'rgba(54, 162, 235, 0.2)',
                                'rgba(255, 206, 86, 0.2)',
                                'rgba(75, 192, 192, 0.2)',
                                'rgba(153, 102, 255, 0.2)',
                                'rgba(255, 159, 64, 0.2)'
                            ],
                            borderColor: [
                                'rgba(255,99,132,1)',
                                'rgba(54, 162, 235, 1)',
                                'rgba(255, 206, 86, 1)',
                                'rgba(75, 192, 192, 1)',
                                'rgba(153, 102, 255, 1)',
                                'rgba(255, 159, 64, 1)'
                            ],
                            borderWidth: 1,
                            barPercentage: 1.0,
                            categoryPercentage: 0,
                            data: data["points"]
                        }
                    ]
                },
                options: {
                    scales: {
                        xAxes: [{
                            type: 'time',
                            time: {
                                displayFormats: {
                                    quarter: 'YYYY/MM/DD'
                                }
                            }
                        }]
                    }
                }
            });

            $('#graph').css('opacity','1.0');

        }

    };

    var fDrawChart = function (data) {
        if (data != undefined && $('#graph').length) {

            var dataPoints = [];
            //[
            //    {x: new Date(2012,0), y: 8.3} ,
            //    {x: new Date(2012,1), y: 8.3} ,
            //    {x: new Date(2012,2), y: 8.2} ,
            //    {x: new Date(2012,3), y: 8.1} ,
            //    {x: new Date(2012,4), y: 8.2} ,
            //    {x: new Date(2012,5), y: 8.2} ,
            //    {x: new Date(2012,6), y: 8.2} ,
            //    {x: new Date(2012,7), y: 8.1} ,
            //    {x: new Date(2012,8), y: 7.8} ,
            //    {x: new Date(2012,9), y: 7.9} ,
            //    {x: new Date(2012,10), y:7.8} ,
            //    {x: new Date(2012,11), y:7.8} ,
            //    {x: new Date(2013,0), y:7.9} ,
            //    {x: new Date(2013,1), y:7.7} ,
            //    {x: new Date(2013,2), y:7.6} ,
            //    {x: new Date(2013,3), y:7.5}
            //]

            var i, iob;
            for (i = 0; i < data.length; i ++) {
                iob = data[i];
                dataPoints.push({
                    x: new Date(iob["year"], iob["month"], iob["day"]),
                    y: iob["val"]
                })
            }

            var chart = new CanvasJS.Chart("graph",
                {
                    title:{
                        text: "График занята/свободна"
                    },
                    animationEnabled: true,
                    axisY:{
                        includeZero: false,
                        interval: 1,
                        valueFormatString: ""
                    },
                    toolTip:{
                        contentFormatter: function ( e ) {
                            var res = "Свободна";
                            if (e.entries[0].dataPoint.y == 1) {
                                res = "Занята"
                            }
                            return res;
                        }
                    },
                    data: [
                        {
                            type: "stepLine",
                            //toolTipContent: "{x}: {y}%",
                            markerSize: 5,
                            dataPoints: dataPoints
                        }

                    ]
                });

            $('#graph').css('opacity','1.0').css('display','block');
            chart.render();

        }
    };

    fInit();

};

var fAreasShow_initActionItems = function (area_id) {

    var html_str = "";
    html_str += "<span class='action_item'><a href='/admin/areas/{ID}/edit'>Изменить</a></span>";
    html_str += "<span class='action_item'><a class='has_many_remove' data-confirm='Вы уверены, что хотите удалить это?' rel='nofollow' data-method='delete' href='/admin/areas/{ID}'>Удалить</a></span>";
    html_str = html_str.split("{ID}").join(area_id);

    $("div.action_items").html($("<div></div>"))
                         .append($(html_str))
                         .css('opacity','1');
};

var fAreasShow = function () {

    // зафиксируем html элементы
    $main_content = $('#main_content');

    $.ajax({
        url: '/estate/can_view_statistics_area',
        type: 'POST',
        dataType:'script'
    });

    var area_id = -1;
    var url = unescape(window.location.href);
    var match_res = url.match(/areas\/(\d{1,9})/);
    if (match_res != null) {
        area_id = Number(match_res[1]);
    }

    $.ajax({
        url: '/estate/can_edit_area',
        type: 'POST',
        data: {
            area_id: area_id
        },
        dataType:'script'
    });

};

// hardcode
// вызовется в can_edit_area.js.erb
var fAreasShow__minorCssFix = function (property_id) {

    setTimeout(function () {

        var $div_vendor_logo = $('div#div_vendor_logo');
        var $a_img = $div_vendor_logo.find('a.no-clickable').find('img');
        console.log($a_img);

        if (property_id == 1) { // строительный
            $div_vendor_logo.css('top','148px');
        }

        if (property_id == 5) { // терминал
            $div_vendor_logo.css('left','-172px');
            $a_img.css('width', '106px');
        }

        $div_vendor_logo.css('opacity','1.0');

    }, 500);
};

