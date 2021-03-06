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

    // здесь живут средние арендные ставки: по всем, и по занятым
    var $div_row_average_prices,
        $p_average_price,
        $p_average_price_busy;

    var fBuild = function () {

        // зафиксируем html элементы
        $main_content = $('#main_content');
        $select_atype = $("#q_atype_id");
        $select_property = $("#q_property_id");
        $input_start_date = $("#q_created_at_gteq");
        $input_end_date = $("#q_created_at_lteq");
        $h2_page_title = $("h2#page_title");

        $ajax_div = $("<div id='ajax_div'></div>");
        $ajax_div2 = $("<div id='ajax_div2'></div>");

        // построим компонент "над таблицей"
        $div_index_adds = $("<div class='index_adds_like_pstats'></div>");

        // строка со средними ценами
        $div_row_average_prices = $("<div id='div_row_average_prices'></div>").appendTo($div_index_adds);
            var $div_average_price = $('<div class="average_price"></div>').appendTo($div_row_average_prices);
                $p_average_price = $('<p class="val"></p>').appendTo($div_average_price);
                var $average_price_comment = $('<p class="abbr"><abbr title="Суммируем все средние ставки всех объектов и делим на кол-во объектов. Если в фильтрах указан тип - то вычисления проводятся относительно указанного типа.">Средняя ставка</abbr></p>').appendTo($div_average_price);

            var $div_average_price_busy = $('<div class="average_price_busy"></div>').appendTo($div_row_average_prices);
                $p_average_price_busy = $('<p class="val"></p>').appendTo($div_average_price_busy);
                var $average_price_comment_busy = $('<p class="abbr"><abbr title="Суммируем все средние ставки по занятым всех объектов и делим на кол-во объектов. Если в фильтрах указан тип - то вычисления проводятся относительно указанного типа.">Средняя ставка по занятым</abbr></p>').appendTo($div_average_price_busy);

        // коэф-ты занятости
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

        // теперь покажем
        $main_content.css('opacity', '1.0');
    };

    // запросим коэф-ты и данные для построения графиков
    var fRequestCoefs = function () {

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
                prop_id: property_id,
                start_date: start_date,
                end_date: end_date
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

                if (data["average_price"] != undefined && data["average_price_busy"] != undefined) {
                    $p_average_price.text(data["average_price"]);
                    $p_average_price_busy.text(data["average_price_busy"]);
                    $div_row_average_prices.css('opacity','1.0');
                } else {
                    $div_row_average_prices.css('display','none');
                }

                $h2_page_title.html(data["title"]);
                $h2_page_title.css('opacity', '1.0');
                $(document).attr('title', data["title"]);

            } else {
                alert('fail: /estate/properties_busy_coef');
            }
            //fPreloaderHide();
        });

        //fPreloaderShow();
    };

    // запросим таблицы объектов
    // результат придёт в виде js и таблицы вставятся сами
    var fRequestCharts = function () {

        var atype_id = $select_atype.val();

        $.ajax({
            url:'/estate/table_properties_coef_busy',
            type:'POST',
            data:{atype_id: atype_id},
            dataType:'script'
        }).done(function (data, result) {
            //alert(result);
        });

        $.ajax({
            url:'/estate/table_properties_coef_busy_sq',
            type:'POST',
            data:{atype_id: atype_id},
            dataType:'script'
        }).done(function (data, result) {
            //alert(result);
        });

    };

    var fInit = function () {
        fBuild();
        fRequestCoefs();
        fRequestCharts();
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