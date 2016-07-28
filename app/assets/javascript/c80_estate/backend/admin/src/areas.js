"use strict";

// защита от неправильных данных
var fCheckItemProperties = function () {

    var result = true;

    // - название
    if ($("input#area_title").val().length == 0) {
        jAlert('Укажите название.');
        result = false;
    }

    // - тип
    if ($("select#area_atype_id").val() == "") {
        jAlert('Укажите тип.');
        result = false;
    }

    var item_props_input_list = $("li.item_props").find("input");
    var inputs_count = item_props_input_list.length;

    // - заполнение всех свойств
    if (inputs_count == 0) {
        result = false;
        jAlert('Не получится создать площадь без свойств.');
    } else {
        item_props_input_list.each(function () {
            if ($(this).val() != '') {
                inputs_count--;
            }
        });
        if (inputs_count > 0) {
            result = false;
            jAlert('Заполните все свойства площади.');
        }
    }

    return result;
};

var jsinit = {

    _debug:true,
    $select_atype: null,
    $btn_add_area_prop: null,       // кнопка "Добавить "
    $item_props_container: null,    // в этом контейнере живут fieldset-ы, каждый из которых соответствует одному свойству предмета
    $item_props_container_span: null,    // заголовок контейнера, в котором живут fieldset-ы свойств предмета

    // допишем поясняющий текст "сначала выберите подкатегорию"
    _fWelcomeTextAdd: function () {
        jsinit.$item_props_container_span.text("Характеристики [сначала выберите подкатегорию, тогда появятся свойства, присущие выбранной категории]");
    },

    // удалим поясняющий текст "сначала выберите подкатегорию"
    _fWelcomeTextRemove: function () {
        jsinit.$item_props_container_span.text("Характеристики");
    },

    go: function () {
        //jsinit._log("[go]");
        //alert('go');

        // фиксируем селект "Тип площади"
        jsinit.$select_atype = $("select#area_atype_id");

        // фиксируем контейнер, в котором находятся компоненты для управления свойством C80Estate::Area
        jsinit.$item_props_container = $("li.item_props");

        jsinit.$item_props_container.parent().parent().addClass('fieldset_item_props');

        // фиксируем надпись "Характеристики"
        jsinit.$item_props_container_span = jsinit.$item_props_container.parent().parent().find("> legend > span");

        // фиксируем кнопку "Добавить свойство"
        jsinit.$btn_add_area_prop = jsinit.$item_props_container.find("a.has_many_add");

        // фиксируем кнопку "Update/Create"
        jsinit.$btn_submin = $("fieldset.actions").find("input[name=commit]");

        // начинаем слушать изменение селекта "тип" -
        jsinit.$select_atype.on("change", jsinit._onSelectStrSubcatChange);
        jsinit._onSelectStrSubcatChange();

        // в момент нажатия кнопки "отправить" - "разлачиваем" все селекты
        jsinit.$btn_submin.click(function (e) {
            if (fCheckItemProperties()) {
                jsinit.$item_props_container.find("select").attr("disabled", false);
                fLoadingShow();
            } else {
                e.preventDefault();
            }
        });

        // пока пользователь не выбрал подкатегорию - допишем поясняющий текст "сначала выберите подкатегорию"
        jsinit._fWelcomeTextAdd();

    },

    // слушает изменения селекта с типами
    // инициирует запрос за "Именами Свойств" выбранного в селекте "Типа"
    // показывает загрузчик
    _onSelectStrSubcatChange: function () {
        var atype_id = jsinit.$select_atype[0].value;
        //jsinit._log("[_onSelectStrSubcatChange]: atype_id = " + atype_id);
        if (atype_id == '') {
            jsinit._removeMayBeAddedProps();
            jsinit._fWelcomeTextAdd();
        } else {
            fLoadingShow();
            jsinit._reqStrsubcatPropnames(atype_id);
            jsinit._fWelcomeTextRemove();
        }
    },

    // запрашиваем список имён свойств указанной подкатегории
    _reqStrsubcatPropnames: function (atype_id) {
        //jsinit._log("[_reqStrsubcatPropnames]: atype_id = " + atype_id);

        $.ajax({
            url: "/estate/get_atype_propnames",
            data: { atype_id:atype_id },
            dataType: "json",
            type: 'POST'
        }).done(function(data,result) {
            //jsinit._log( data );

            if (result == "success") {
                jsinit._log( "Кол-во свойств: " + data.length );

                // удалим, возможно уже добавленные в форму, свойства
                jsinit._removeMayBeAddedProps();

                // количество свойств
                var n = data.length;

                // "цикловые" переменные
                var $ifs,        // fieldset,
                    $iselprop,   // очередной селект "имя свойства"
                    $iinputprop, // очередной input "значение свойства"
                    $ifindbyid,  // вспомогательная переменная: содержит результат поиска по id с помощью регулярки
                    ielem;      // очередной элемент из data

                for (var i=0; i<n; i++) {

                    // фиксируем объект с данными, описывающий свойство предмета
                    ielem = data[i];

                    // нажмём кнопку "Добавить Item prop"
                    jsinit.$btn_add_area_prop.click();

                    // фиксируем добавленный в форму fieldset

                    //<fieldset class="inputs has_many_fields processed">
                    //    <ol>
                    //        <li id="area_item_props_attributes_37_prop_name_input">
                    //            <select id="area_item_props_attributes_37_prop_name_id">
                    //                <option value="37">Артикул</option>
                    //            </select>
                    //        </li>
                    //        <li id="area_item_props_attributes_37_value_input">
                    //            <input id="area_item_props_attributes_37_value" type="text">
                    //        </li>
                    //    </ol>
                    //</fieldset>

                    $ifs = jsinit.$item_props_container.find("fieldset").not(".processed");
                    $ifs.addClass("processed");

                    $ifindbyid = $ifs.find('[id^="area_item_props_attributes_"]');

                    // находим в ifs селект, отвечающий за имя свойства
                    $iselprop = $ifindbyid.find('select');
                    //console.log(iselprop);

                    // находим в ifs input, отвечающий за значение свойства
                    $iinputprop = $ifindbyid.find('input');

                    // в этот селект жестоко предустанавливаем значение из data, дописываем единицу измерения
                    $iselprop.find("option")
                        .filter(function () {
                            //console.log($(this).val() + " vs " + ielem["id"]);
                            return $(this).val() == ielem["id"]; //return $(this).text() == ielem["title"];
                        })
                        .prop('selected', true)
                        .text(function () {
                            var t = $(this).text();
                            if (ielem["uom_title"] != null) {
                                t += ", " + ielem["uom_title"];
                            }
                            return t;
                        }); // дописываем в конец единицу измерения

                    //делаем его readonly
                    $iselprop.attr("disabled", true); // NOTE:: но в момент нажатия кнопки "Отправить" мы "разлачиваем" селект, чтобы параметры формы "правильно" отправлялись;

                    // в input "производитель" - ставим "-1" и прячем его от пользователя
                    if (ielem["id"] == 36) {
                        $iinputprop.val("-1");
                        $ifs.css("display",'none');
                    }

                }

                fLoadingHide();

            } else {
                alert( "done: не удалось получить данные о свойствах выбранной подкатегории." );
            }

        })
        .fail(function(jqXHR, textStatus) {
            alert( "fail: не удалось получить данные о свойствах выбранной подкатегории: " + textStatus );
        })
        .always(function() {
            //alert( "complete" );
        });
    },

    // удалим, возможно уже добавленные в форму, свойства
    _removeMayBeAddedProps: function () {
        $("a.has_many_remove").click();
    },

    _log: function () {
        if (jsinit._debug) {
            //console.log(arguments[0]);
        }
    }

};

var fEdit = function () {

    var $select_area_atype; // селект подкатегории, которой принадлежит редактируемый предмет
    var $item_props_container;  // здесь живут селекты свойств
    var $btn_submit;
    var atype_id;           // id подкатегории, которой принадлежит редактируемый предмет, извлекается из селекта $select_area_atype
    var $btn_add_area_prop;     // кнопка "добавить свойство"

    // вернёт true, если найдёт в $item_props_container селект свойства atype_id
    var _fCheckSelect = function (atype_id) {
        var result = false;
        var $selects = $item_props_container.find("fieldset").find('select');
        $selects.each(function () {
            if ($(this).val() == atype_id) {
                result = true;
            }
        });
        return result;
    };

    var fReqPropList = function (atype_id) {
        $.ajax({
            url: "/estate/get_atype_propnames",
            data: { atype_id:atype_id },
            dataType: "json",
            type: 'POST'
        }).done(function (data,result) {
            //data - это список свойств, которые должны быть у предмета
            if (result == "success") {

                /* обходим data, ищем соответствующие селекты,
                * по ходу формируем список toAdd - индексы массива data
                * отсутствующих свойств. Затем обрабатываем
                * получившийся список и добавляем отсутствующие селекты. */

                var toAdd = [];

                // количество свойств
                var n = data.length;

                var ielem;

                // обходим список свойств, которые должны быть у предмета
                // и выясняем, кто отсутствует в форме
                for (var i=0; i<n; i++) {

                    // фиксируем объект с данными
                    ielem = data[i];

                    // если такой селекта нет в форме - запомним id свойства
                    if (_fCheckSelect(ielem["id"])) {

                    } else {
                        toAdd.push(i);
                    }
                }

                var $ifs, $iselprop;

                // теперь добавляем отсутствующие селекты
                n = toAdd.length;
                for (i = 0; i<n; i++) {
                    ielem = data[ toAdd[i] ];

                    // нажмём кнопку "Добавить Item prop"
                    $btn_add_area_prop.click();

                    // фиксируем добавленный в форму fieldset
                    $ifs = $item_props_container.find("fieldset").not(".was_before");
                    $ifs.addClass("was_before");

                    // находим в ifs селект, отвечающий за имя свойства
                    $iselprop = $ifs.find('[id^="area_item_props_attributes_"]').find('select');

                    // в этот селект жестоко предустанавливаем значение из data и делаем его readonly
                    $iselprop.find("option").filter(function () {
                        //console.log(this);
                        return $(this).val() == ielem["id"]; //return $(this).text() == ielem["title"];
                    }).prop('selected', true);
                    $iselprop.attr("disabled", true); // NOTE:: но в момент нажатия кнопки "Отправить" мы "разлачиваем" селект, чтобы параметры формы "правильно" отправлялись

                }

                /*дописываем единицы измерения всем селектам*/

                // перед циклом: фиксируем все fieldset
                $ifs = $item_props_container.find("fieldset");

                // перед циклом: фиксируем все интерактивные элементы с таким id
                var $ifindbyid = $ifs.find('[id^="area_item_props_attributes_"]');
                $iselprop = $ifindbyid.find('select');

                n = data.length;
                for (i = 0; i<n; i++) {
                    ielem = data[i];

                    // находим селект, отвечающий за имя свойства и дописываем единицу измерения
                    $iselprop.find("option").filter(function () {
                        //console.log(this);
                        return $(this).val() == ielem["id"]; //return $(this).text() == ielem["title"];
                    }).text(function () {
                        var t = $(this).text();
                        if (ielem["uom_title"] != null) {
                            t += ", " + ielem["uom_title"]
                        }
                        return t;
                    });

                    // в input "производитель" - ставим "-1" и прячем весь fieldset от пользователя
                    if (ielem["id"] == 36) {
                        // находим опцию id=36 селекта "имя свойства"
                        var $opt = $iselprop.find("option").filter(function () {
                            var $t = $(this);
                            return $t.val() == 36 && $t.prop('selected');
                        });
                        // из этой опции добираемся до fieldset, который её содержит
                        var $fieldset = $opt.parent().parent().parent();
                        // а затем уже находим input
                        $fieldset.find("input").val("-1");
                        // прячем
                        $fieldset.css('display','none');

                    }

                }

                fLoadingHide();

            } else {
                alert( "done: не удалось получить данные о свойствах выбранной подкатегории." );
            }
        }).fail(function(jqXHR, textStatus) {
            alert( "fail: не удалось получить данные о свойствах выбранной подкатегории: " + textStatus );
        });
    };

    $(document).ready(function () {

        // инициализация

        // фиксируем селект "Тип площади"
        $select_area_atype = $('select#area_atype_id');
        // заодно запомним, какой тип установленен для текущей редактируемой площади
        atype_id = $select_area_atype[0].value;

        // фиксируем кнопку "Update/Create"
        $btn_submit = $("fieldset.actions").find("input[name=commit]");

        // фиксируем контейнер, в котором находятся компоненты для управления свойством C80Estate::Area
        $item_props_container = $("li.item_props");

        $item_props_container.parent().parent().addClass('fieldset_item_props');

        // фиксируем кнопку "Добавить свойство"
        $btn_add_area_prop = $item_props_container.find("a.has_many_add");

        // блокируем селект "тип"
        $select_area_atype.attr("disabled", true);

        // блокируем селекты "свойства товара"
        $item_props_container.find("select").attr("disabled", true);

        // отмечаем уже имеющиеся fieldsets
        $item_props_container.find("fieldset").each(function () {
            $(this).addClass("was_before");
        });

        //совершаем запрос за свойствами, которые присущи данному типу
        fReqPropList(atype_id);

        // в момент нажатия кнопки "отправить" - "разлачиваем" все селекты
        // и добавляем модальный предзагрузчик
        $btn_submit.click(function (e) {
            if (fCheckItemProperties()) {
                $item_props_container.find("select").attr("disabled", false);
                fLoadingShow();
                //e.preventDefault(); // for debug
            } else {
                e.preventDefault();
            }
        });

    });

    fLoadingShow();
};

//var $slider_square;
//var $slider_price;

var fAreasIndex = function () {

    var csss_input_square = '#q_item_prop_square_val_in';
    var csss_input_price = '#q_item_prop_price_val_in';

    var $original_input_square;
    var $original_input_price;

    var square_min;
    var square_max;
    var price_min;
    var price_max;

    var $slider_square;
    var $slider_price;

    var _fInit = function () {

        $original_input_square = $(csss_input_square);
        $original_input_price = $(csss_input_price);

        _fTranslateScopes();
        _fInitSliders();

        // считываем get параметры
        var rex_square = /item_prop_square_val_in\]=(\d{1,5}),(\d{1,5})/;
        var rex_price = /item_prop_price_val_in\]=(\d{1,5}),(\d{1,5})/;
        var url = unescape(window.location.href);

        var match_square = url.match(rex_square);
        var match_price = url.match(rex_price);

        var min, max, p;

        if (match_square != null) {
            min = Number(match_square[1]);
            max = Number(match_square[2]);
            if (min > max) {
                p = min;
                min = max;
                max = p;
            }
            $slider_square.setValue([min, max],false,true);
        }

        if (match_price != null) {
            min = Number(match_price[1]);
            max = Number(match_price[2]);
            if (min > max) {
                p = min;
                min = max;
                max = p;
            }
            $slider_price.setValue([min, max],false,true);
        }

        //console.log("<_fMakeMinMaxInputs> square = " + param_item_prop_square_val_in + "; price = " + param_item_prop_price_val_in);

        // подставляем начальные значения
    };

    var _fTranslateScopes = function () {
        // переведём scope надписи

        var $li, $a, $a_span;

        $li = $('li.scope.all');
        $a = $li.find(".table_tools_button");
        $a_span = $a.find('span');
        $a.html('Все <span class="count">' + $a_span.text() + '</span>');

        $li = $('li.scope.free');
        $a = $li.find(".table_tools_button");
        $a_span = $a.find('span');
        $a.html('Свободные <span class="count">' + $a_span.text() + '</span>');

        $li = $('li.scope.busy');
        $a = $li.find(".table_tools_button");
        $a_span = $a.find('span');
        $a.html('Занятые <span class="count">' + $a_span.text() + '</span>');

        $('ul.scopes').css('opacity','1.0');
    };

    var _fInitSliders = function () {

        //$slider_square = $original_input_square.bootstrapSlider();
        //$slider_price = $original_input_price.bootstrapSlider();
        $slider_square = new Slider(csss_input_square);
        $slider_price = new Slider(csss_input_price);

        //console.log($original_input_square);
        //console.log($original_input_price);
        square_min = $original_input_square.data('slider-min');
        square_max = $original_input_square.data('slider-max');
        price_min = $original_input_price.data('slider-min');
        price_max = $original_input_price.data('slider-max');

        _fMakeMinMaxInputs($original_input_square, $slider_square, [square_min,square_max] );
        _fMakeMinMaxInputs($original_input_price, $slider_price, [price_min, price_max]);

    };

    var _fMakeMinMaxInputs = function ($input, $slider, minmax) {
        //console.log("<func_normalize_val> minmax = " + minmax);

        // перед этим элементом вставим наши инпуты
        var $trg = $input.parent().find('div.slider');

        // пофиксим отступ для красоты
        $input.parent().find('.label').css('margin-bottom','-5px');

        // вставляемые инпуты
        var $input_min = $('<input type="number" class="min_text_input" placeholder="от"/>');
        var $input_max = $('<input type="number" class="max_text_input" placeholder="до"/>');
        $trg.before($input_min);
        $trg.before($input_max);

        /*взаимодействуя со слайдером - будут меняться значения в текстовых полях*/

        var func_on_change_orig_input = function () {
            //console.log("<func_on_change_orig_input> " + this.value); // #=> 12,333
            var va = this.value.split(',');
            var min = va[0];
            var max = va[1];
            $input_min.val(min);
            $input_max.val(max);
            //$input_min.data('normalized-value',min);
            //$input_max.data('normalized-value',max);
        };
        $input.on('change', func_on_change_orig_input);
        $input.change();

        /*взаимодействуя с текстовыми полями - будет меняться слайдер*/

        var func_normalize_val = function (val) {
            //console.log("<func_normalize_val> val = " + val);
            //console.log("<func_normalize_val> minmax[0] = " + minmax[0]);
            //console.log("<func_normalize_val> minmax[1] = " + minmax[1]);

            var v = val;
            if (v < $input.data('slider-min')) {
                v = $input.data('slider-min');
            }
            if (v > $input.data('slider-max')) {
                v = $input.data('slider-max');
            }
            return Number(v);
        };

        var func_invalidate_slider = function () {

            //$trg.bootstrapSlider('setValue',[
            //    $input_min.data('normalized-value'),
            //    $input_max.data('normalized-value')
            //]);

            var arr = [
                func_normalize_val($input_min.val()),
                func_normalize_val($input_max.val())
            ];
            //console.log("<func_invalidate_slider> " + arr);
            $slider.setValue(arr);

        };

        var func_onblur_min = function () {
            //console.log(this.value);
            var v = func_normalize_val(this.value);
            //$input_min.data('normalized-value',v);
            func_invalidate_slider();
        };

        var func_onblur_max = function () {
            //console.log(this.value);
            var v = func_normalize_val(this.value);
            //$input_max.data('normalized-value',v);
            func_invalidate_slider();
        };

        $input_min.on('blur', func_onblur_min);
        $input_max.on('blur', func_onblur_max);

    };

    _fInit();

};

YOUR_APP.areas = {
    edit: fEdit,
    "new": jsinit.go,
    index: fAreasIndex,
    show: fAreasShow
};