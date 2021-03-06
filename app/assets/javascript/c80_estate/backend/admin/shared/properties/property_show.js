"use strict";

var fPropertiesShow_initRichShowPage = function () {

    //fCommon();
    fItemImageMagnificPopupStart();

    // если нужна кнопка "заказать"
    //var $b = $('.c80_order_invoking_btn');
    //$b.click(function (e) {
    //    if (orderForm) {
    //        orderForm.afterShowForm = function () {
                $("textarea#mess_comment").focus();
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

var fPropertiesShow_go = function () {

    // компонент "над таблицей"
    var $div_index_adds;

    // блок ЗАНЯТОСТЬ
    var $div_busy_coef,
        $p_busy_coef,               // здесь выводим число - занятость
        $p_busy_coef_mess,          // здесь вешаем hint на подпись "занятость"
        $p_busy_coef_comment;       // здесь выводим комментарий

    // блок ЗАНЯТОСТЬ (В М.КВ)
    var $div_busy_coef_sq,
        $p_busy_coef_sq,                // здесь выводим число - занятость в м.кв
        $p_busy_coef_mess_sq,          // здесь вешаем hint на подпись "занятость в м"
        $p_busy_coef_comment_sq;       // здесь выводим комментарий

    var $div_area_text_stats,
        $ul_props;              // здесь выводим текстовые свойства

    var $div_area_text_stats_sq,
        $ul_props_sq;              // здесь выводим текстовые свойства занятости в метрах

    // тут живут круговые графики
    var $div_graph_radial;
    var $div_graph_radial_sq;

    // тут живут динамические графики
    var $div_graph_dynamic,
        $div_graph_dynamic_sq;

    var $ajax_div, $ajax_div2;

    var fBuild = function () {

        $ajax_div = $("<div id='ajax_div'></div>");
        $ajax_div2 = $("<div id='ajax_div2'></div>");

        // построим компонент "над таблицей"
        $div_index_adds = $("<div class='index_adds_like_pstats'></div>");

        $div_busy_coef = $("<div id='coef'></div>").appendTo($div_index_adds);
        $p_busy_coef = $("<p class='val'></p>").appendTo($div_busy_coef);
        $p_busy_coef_mess = $("<p class='title'><abbr class='abbr_busy_coef' title='TITLE'>Занятость</abbr></p>").appendTo($div_busy_coef);
        $p_busy_coef_comment = $("<p class='comment'></p>").appendTo($div_busy_coef);

        $div_area_text_stats = $("<div id='text_stats'></div>").appendTo($div_index_adds);
        $ul_props = $("<ul><li id='title'></li><li id='born_date'></li><li id='atype_filter'></li><li id='all_areas_count'></li><li id='free_areas_count'></li><li id='busy_areas_count'></li></ul>");
        $div_area_text_stats.append($ul_props);

        $div_graph_radial = $("<div id='graph_radial'></div>").appendTo($div_index_adds);

        $div_busy_coef_sq = $("<div id='coef_sq'></div>").appendTo($div_index_adds);
        $p_busy_coef_sq = $("<p class='val'></p>").appendTo($div_busy_coef_sq);
        $p_busy_coef_mess_sq = $("<p class='title'><abbr class='abbr_busy_coef_sq' title='TITLE'>Занятость (в м.кв.)</abbr></p>").appendTo($div_busy_coef_sq);
        $p_busy_coef_comment_sq = $("<p class='comment'></p>").appendTo($div_busy_coef_sq);

        $div_area_text_stats_sq = $("<div id='text_stats_sq'></div>").appendTo($div_index_adds);
        $ul_props_sq = $("<ul><li id='all_areas_count_sq'></li><li id='free_areas_count_sq'></li><li id='busy_areas_count_sq'></li></ul>");
        $div_area_text_stats_sq.append($ul_props_sq);

        $div_graph_radial_sq = $("<div id='graph_radial_sq'></div>").appendTo($div_index_adds);

        $div_graph_dynamic = $("<div id='graph2'></div>").appendTo($div_index_adds);

        $div_graph_dynamic_sq = $("<div id='graph3'></div>").appendTo($div_index_adds);

        $main_content.prepend($ajax_div2);
        $main_content.prepend($ajax_div);
        $main_content.prepend($div_index_adds);

        $(".comments").before($('<h4 style="padding-top:15px;">Статистика</h4>'))
                      .before($div_index_adds);

        // теперь покажем
        $main_content.css('opacity', '1.0');
    };

    // запросим коэф-ты и данные для построения графиков
    var fRequestCoefs = function () {

        //var atype_id = $select_atype.val();
        //var property_id = $select_property.val();
        //var start_date = $input_start_date.val();
        //var end_date = $input_end_date.val();

        var property_id = -1;
        var url = unescape(window.location.href);
        var match_res = url.match(/properties\/(\d{1,9})/);
        if (match_res != null) {
            property_id = Number(match_res[1]);
        }

        $.ajax({
            url: '/estate/properties_busy_coef',
            type: 'POST',
            dataType: 'json',
            data: {
                prop_id: property_id
            }
        }).done(function (data, result) {
            if (result == 'success') {

                console.log(data);

                var i, iob, itag, ival, $ili;

                $p_busy_coef.text(data["busy_coef"]);
                $p_busy_coef_comment.html(data["comment"]);
                $p_busy_coef_mess.find('.abbr_busy_coef').attr('title', data["abbr"]);

                $p_busy_coef_sq.text(data["busy_coef_sq"]);
                $p_busy_coef_comment_sq.html(data["comment_sq"]);
                $p_busy_coef_mess_sq.find('.abbr_busy_coef').attr('title', data["abbr_sq"]);

                if (data["props"] != undefined) {

                    for (i = 0; i < data["props"].length; i++) {
                        iob = data["props"][i];
                        itag = iob["tag"];
                        ival = iob["val"];
                        $ili = $ul_props.find("#" + itag);
                        $ili.html(ival);
                    }

                }

                if (data["props_sq"] != undefined) {

                    for (i = 0; i < data["props_sq"].length; i++) {
                        iob = data["props_sq"][i];
                        itag = iob["tag"];
                        ival = iob["val"];
                        $ili = $ul_props_sq.find("#" + itag);
                        $ili.html(ival);
                    }

                }

                if (data["graph_radial"] != undefined) {
                    fDrawChartRadial(data["graph_radial"]);
                }

                if (data["graph_dynamic"] != undefined) {
                    fDrawChartDynamic(data["graph_dynamic"]);
                }

                if (data["graph_dynamic_sq"] != undefined) {
                    fDrawChartDynamicSq(data["graph_dynamic_sq"]);
                }

                if (data["graph_radial_sq"] != undefined) {
                    fDrawChartRadialSq(data["graph_radial_sq"]);
                }

                //$h2_page_title.text(data["title"]);
                //$h2_page_title.css('opacity', '1.0');
                //$(document).attr('title', data["title"]);

            } else {
                alert('fail: /estate/properties_busy_coef');
            }
            //fPreloaderHide();
        });

        //fPreloaderShow();
    };

    var fInit = function () {
        fBuild();
        fRequestCoefs();
        fPropertiesShow_initRichShowPage();
    };

    // рисуем динамический график занятости
    var fDrawChartDynamic = function (data) {
        $div_graph_dynamic.css('opacity','1.0').css('display','block');
        $('#graph2').highcharts('StockChart', {

            yAxis: {
                min:0,
                max:120
            },

            plotOptions: {
                line: {
                    linecap: 'square'
                }
            },

            rangeSelector : {
                selected : 1
            },

            title : {
                text : 'Коэф-т занятости объекта за указанный период'
            },

            series : [{
                name : 'Занятость',
                data : data,
                tooltip: {
                    valueDecimals: 2
                }
            }]
        });
    };
    var fDrawChartDynamic_old = function (data_array_rows_dynamic) {

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
        for (i = 0; i < data_array_rows_dynamic.length; i ++) {
            iob = data_array_rows_dynamic[i];
            dataPoints.push({
                x: new Date(iob["year"], iob["month"], iob["day"]),
                y: iob["val"]
            })
        }

        var chart = new CanvasJS.Chart("graph2",
            {
                title:{
                    text: "Занятость"
                },
                animationEnabled: true,
                axisY:{
                    includeZero: false,
                    interval: 10,
                    valueFormatString: ""
                },
                data: [
                    {
                        type: "stepArea",
                        toolTipContent: "{x}: {y}%",
                        markerSize: 5,
                        dataPoints: dataPoints
                    }

                ]
            });

        $div_graph_dynamic.css('opacity','1.0').css('display','block');
        chart.render();

    };

    // рисуем динамический график занятости в м.кв.
    var fDrawChartDynamicSq = function (data) {
        $div_graph_dynamic_sq.css('opacity','1.0').css('display','block');
        $('#graph3').highcharts('StockChart', {

            yAxis: {
                min:0,
                max:120
            },

            plotOptions: {
                line: {
                    linecap: 'square'
                }
            },

            rangeSelector : {
                selected : 1
            },

            title : {
                text : 'Коэф-т занятости в м.кв.'
            },

            series : [{
                name : 'Занятость в м.кв.',
                data : data,
                tooltip: {
                    valueDecimals: 2
                }
            }]
        });
    };
    var fDrawChartDynamicSq_old = function (data) {

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

        var chart = new CanvasJS.Chart("graph3",
            {
                title:{
                    text: "Занятость в м.кв."
                },
                animationEnabled: true,
                axisY:{
                    includeZero: false,
                    interval: 10,
                    valueFormatString: ""
                },
                data: [
                    {
                        type: "stepArea",
                        toolTipContent: "{x}: {y}%",
                        markerSize: 5,
                        dataPoints: dataPoints
                    }

                ]
            });

        $div_graph_dynamic_sq.css('opacity','1.0').css('display','block');
        chart.render();

    };

    var fDrawChartRadial = function (data) {

        //  data:
        //  [
        //    {  y: 6, legendText:"Свободно", label: "Площадей свободно" },
        //    {  y: 4, legendText:"Занято", label: "Площадей занято" }
        //  ]

        var chart = new CanvasJS.Chart("graph_radial",
            {
                animationEnabled: true,
                legend:{
                    verticalAlign: "center",
                    horizontalAlign: "",
                    fontSize: 0,
                    fontFamily: "Open Sans"
                },
                theme: "theme",
                data: [
                    {
                        type: "pie",
                        indexLabelFontFamily: "Open Sans",
                        indexLabelFontSize: 14,
                        indexLabel: "{label}: {y}",
                        startAngle:-10,
                        showInLegend: true,
                        toolTipContent:"{legendText} {y}",
                        dataPoints: data
                    }
                ]
            });
        chart.render();
    };

    var fDrawChartRadialSq = function (data) {

        //  data:
        //  [
        //    {  y: 6, legendText:"", label: "Метров свободно" },
        //    {  y: 4, legendText:"", label: "Метров занято" }
        //  ]

        var chart = new CanvasJS.Chart("graph_radial_sq",
            {
                animationEnabled: true,
                legend:{
                    verticalAlign: "center",
                    horizontalAlign: "",
                    fontSize: 0,
                    fontFamily: "Open Sans"
                },
                theme: "theme",
                data: [
                    {
                        type: "pie",
                        indexLabelFontFamily: "Open Sans",
                        indexLabelFontSize: 14,
                        indexLabel: "{label}: {y}",
                        startAngle:-10,
                        showInLegend: true,
                        toolTipContent:"{legendText} {y}",
                        dataPoints: data
                    }
                ]
            });
        chart.render();
    };

    fInit();

};

var fPropertiesShow = function () {

    // зафиксируем html элементы
    $main_content = $('#main_content');

    $.ajax({
        url: '/estate/can_view_statistics_property',
        type: 'POST',
        dataType:'script'
    })
};
