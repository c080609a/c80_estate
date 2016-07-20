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
    var $div_graph2;             // в этом div живет график
    var $div_graph2canvas;

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
        $ul_props = $("<ul><li id='title'></li><li id='born_date'></li><li id='atype_filter'></li><li id='all_areas_count'></li><li id='free_areas_count'></li><li id='busy_areas_count'></li></ul>");
        $div_area_text_stats.append($ul_props);

        $div_graph = $("<div id='graph'></div>");
        $div_graph2 = $("<div id='graph2'></div>");
        $div_graph2canvas = $("<canvas id='graph2canvas' height='50'></canvas>").appendTo($div_graph2);

        $div_index_adds.append($div_busy_coef);
        $div_index_adds.append($div_area_text_stats);
        $div_index_adds.append($div_graph);
        $div_index_adds.append($div_graph2);

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
                prop_id: property_id,
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

                if (data["graph"] != undefined || data["graph_dynamic"] != undefined) {
                    fDrawChart(data["graph"], data["graph_dynamic"]);
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

    var fDrawChart = function (data_array_rows_radial, data_array_rows_dynamic) {

        google.charts.load('current', {'packages': ['corechart']});
        google.charts.setOnLoadCallback(drawChart);

        function drawChart() {

            var data, options, chart;

            if (data_array_rows_radial != undefined) {
                data = google.visualization.arrayToDataTable(data_array_rows_radial);

                options = {
                    title: ''
                };

                chart = new google.visualization.PieChart(document.getElementById('graph'));

                chart.draw(data, options);
            }

            if (data_array_rows_dynamic != undefined && false) {
                //data_array = [
                //    ['Director (Year)',  'Rotten Tomatoes', 'IMDB'],
                //    ['Alfred Hitchcock (1935)', 8.4,         7.9],
                //    ['Ralph Thomas (1959)',     6.9,         6.5],
                //    ['Don Sharp (1978)',        6.5,         6.4],
                //    ['James Hawes (2008)',      4.4,         6.2]
                //]

                //var data = google.visualization.arrayToDataTable(data_array_rows_dynamic);

                data = new google.visualization.DataTable();
                data.addColumn('date', ''); // Implicit domain column.
                data.addColumn('number', ''); // Implicit data column.
                //data.addColumn({type:'number', role:'interval'});
                //data.addColumn({type:'number', role:'interval'});
                //data.addColumn('number', 'Expenses');

                var i, iob, yearValue, monthValue, dayValue;
                for (i = 0; i < data_array_rows_dynamic.length; i++) {
                    iob = data_array_rows_dynamic[i];
                    yearValue = iob[0].substr(0, 4);
                    monthValue = iob[0].substr(5, 2) - 1;
                    dayValue = iob[0].substr(8, 2);
                    console.log(iob + " => " + yearValue + "/" + monthValue + "/" + dayValue); // + ": " + data_array_rows_dynamic[i][0]
                    data_array_rows_dynamic[i][0] = new Date(parseInt(yearValue), parseInt(monthValue), parseInt(dayValue));
                }

                data.addRows(data_array_rows_dynamic);

                options = {
                    title: 'Занятость',
                    vAxis: {title: '', ticks: [0, 1]},
                    ignoreBounds: true,
                    isStacked: false
                };

                chart = new google.visualization.SteppedAreaChart(document.getElementById('graph2'));

                chart.draw(data, options);
            }

            if (data_array_rows_dynamic) {

                var ctx = $("#graph2canvas");

                var chartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: data_array_rows_dynamic["labels"],
                        datasets: [
                            {
                                label: "Занятость",
                                fill: false,
                                lineTension: 0.01,
                                steppedLine: true,
                                backgroundColor: "rgba(75,192,192,0.4)",
                                borderColor: "rgba(75,192,192,1)",
                                borderCapStyle: 'butt',
                                borderDash: [],
                                borderDashOffset: 0.0,
                                borderJoinStyle: 'miter',
                                pointBorderColor: "rgba(75,192,192,1)",
                                pointBackgroundColor: "#fff",
                                pointBorderWidth: 1,
                                pointHoverRadius: 5,
                                pointHoverBackgroundColor: "rgba(75,192,192,1)",
                                pointHoverBorderColor: "rgba(220,220,220,1)",
                                pointHoverBorderWidth: 2,
                                pointRadius: 1,
                                pointHitRadius: 10,
                                data: data_array_rows_dynamic["points"]
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

            }

        }

        if (data_array_rows_radial != undefined) {
            $('#graph').css('opacity', '1.0').css('display', 'block');
        }

        if (data_array_rows_dynamic != undefined) {
            $('#graph2').css('opacity', '1.0').css('display', 'block');
        }

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