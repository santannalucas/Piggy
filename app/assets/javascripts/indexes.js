$(document).ready(function() {

    // Show - Item Form Hide - Show
    var show_edit_button = $('#edit-show-items');

    function hideEdit() {
        $('.show-item').show();
        $('.show-item.form').hide();
        show_edit_button.show();
        $('.form-submit').hide();
    }

    function showEdit() {
        $('.show-item').hide();
        $('.show-item.form').show();
        $('.form-submit').show();
    }

    if ($('#editing').val() === 'true'){
        showEdit();
        show_edit_button.hide();
    }else {
        hideEdit()
    }

    show_edit_button.on('click', function (){
        showEdit();
    });

    $('#cancel-edit-show-items').on('click', function (){
        hideEdit()
    });


    function getSearchParams(k){
        var p={};
        location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi,function(s,k,v){p[k]=v})
        return k?p[k]:p;
    }

    $('.fad.fa-pencil-alt.action-icon.row-form-edit-field ').on('click', function () {
        var target = $(this).attr('rel');
        var form = $('#form_record_' + target);
        console.log(form);
        $('.row-form-field').show();
        $(this).closest('tr').hide();
        $('.row-form-form').hide();
        form.show();
    });

// Transfer Methods

    // Inputs
    var rate_select = $('#transfer_rate')
    var from_amount = $('#transfer_from_bank_account_attributes_amount')
    var to_amount = $('#transfer_to_bank_account_attributes_amount')

    // Add Rate to Currency
    $('#transfer_to_bank_account_attributes_bank_account_id').change(function () {
        var bank_rate = $(this).val()
        var rate = '#bank_rate_' + bank_rate
        var rate_value = $(rate).val()
        $('#transfer_rate').val(parseFloat(rate_value));
        if ( from_amount.val() !== '0.0') {
            to_amount.val(parseFloat(rate_value)*parseFloat(from_amount.val()))
        }
    });

    rate_select.change(function () {
        if ( from_amount.val() !== '0.0') {
            to_amount.val(parseFloat(rate_select.val())*parseFloat(from_amount.val()))
        }
    });

    to_amount.change(function () {
        if ( from_amount.val() !== '0.0') {
            rate_select.val(parseFloat(to_amount.val())/parseFloat(from_amount.val()))
        }
    });

    from_amount.change(function () {
        if ( from_amount.val() !== '0.0') {
            to_amount.val(parseFloat(rate_select.val())*parseFloat(from_amount.val()))
        }
    });






    // Reload Transfer
    var from_account_select = $('#transfer_from_bank_account_attributes_bank_account_id')
    from_account_select.change(function () {
        var current_bank_id = 'bank_account_id=' + getSearchParams('bank_account_id')
        var next_bank_id = 'bank_account_id=' + from_account_select.val() + '&new_transfer=true'
        window.location = document.URL.replace(current_bank_id ,next_bank_id);
    });

    // To Amount Change

    $('.cancel-table-row-form').on('click', function () {
        $('.row-form-field').show();
        $('.row-form-form').hide();
        $('#add-row-form-new').show();
        $('#add-row-form-expense').show();
        $('#form-index').hide();
        $("#add-index-form").show()
        $('#search-results').show();
    });


    $("#add-row-form-new").on("click", function() {
        $('#income-category').show();
        $('#expense-category').hide();
        $('.row-form-field').show();
        $('.row-form-form').hide();
        $('#row-form-new').removeClass('error').css({'background-color': '#d9f7d1'}).show();
        $('.transaction-type').text('New Income')
        $('.trans-icon').removeClass('expenses').addClass('deposit')
        $(this).hide();
        $('.income-icon').show()
        $('.expense-icon').hide();
        $("#add-row-form-expense").show()
        $('#transaction_transaction_type_id').val(2)
        $('#form-index').hide();
        $("#add-index-form").show()
        setTimeout(function() { jQuery('#top-anchor').focus() }, 20);
    });

    $("#add-row-form-expense").on("click", function(){
        $('#income-category').hide();
        $('.expense-icon').show();
        $('.income-icon').hide()
        $('#expense-category').show();
        $('.row-form-field').show();
        $('.row-form-form').hide();
        $('.trans-icon').removeClass('deposit').addClass('expenses')
        $('#row-form-new').removeClass('error').css({'background-color': '#f1f1df'}).show();
        $("#add-row-form-new").removeClass('error').show()
        $('.transaction-type').text('New Expense')
        $(this).hide();
        $('#form-index').hide();
        $("#add-index-form").show()
        $('#transaction_transaction_type_id').val(3)
        setTimeout(function() { jQuery('#top-anchor').focus() }, 20);
    });

    $("#add-index-form").on("click", function() {
        $('#form-index').show();
        $('#add-row-form-expense').show()
        $('#add-row-form-new').show()
        $('.row-form-form').hide();
        $(this).hide();
        $('#search-results').hide();
        setTimeout(function() { jQuery('#top-anchor').focus() }, 20);
    });

    function customDate() {
        var period_val = $('#period').val()
        if (period_val === 'custom') {
            $('.custom-date').show()
        } else {
            $('.custom-date').hide()
        }
    };

    customDate();
    // Change Single Input and Go
    $('#period').change(function () {
        customDate();
    });

    $('#transaction_account_id').change(function () {
        if ($(this).val() === 'new_account'){
            $(this).hide();
            $('#new-account').show()
        }
    });

    $('.cancel-new-account').click(function () {
        $('#transaction_account_id').show()
        $('#new-account').hide()
        $('#new_account_name').val('')
        $('#transaction_account_id').val('')
    });

// http://comsim.esac.esa.int/rossim/3dtool/common/utils/jquery/ehynds-jquery-ui-multiselect-widget-f51f209/demos/index.htm#basic

// Close Flash Messages
    $('.close-flash').click(function () {
        $('.flash').hide();
    });

// Ajax auto-complete Objects (Scenarios/Questions) Tag names
    $("input#add_questions_tag_name_ajax").autocomplete({source: "/questions/auto_complete_for_tag_name"});
    $("input#add_scenarios_tag_name_ajax").autocomplete({source: "/scenarios/auto_complete_for_tag_name"});

// Ajax auto-complete Object (Scenarios/Questions) Numbers
    $("input#add_questions_number_ajax").autocomplete(
        {
            source: "/questions/auto_complete_for_number",
            close: function () {
                var ajax_input = $('#add_questions_number_ajax');
                var arr = ajax_input.val().split(',');
                var sum_input = $('#new-obj-summary');
                var summary = arr.filter(function (elem) {
                    return elem !== arr[0];
                });
                ajax_input.val(arr[0]);
                sum_input.text(summary);
            }
        });

    $("input#add_scenarios_number_ajax").autocomplete(
        {
            source: "/scenarios/auto_complete_for_number",
            close: function () {
                var ajax_input = $('#add_scenarios_number_ajax');
                var arr = ajax_input.val().split(',');
                var sum_input = $('#new-obj-summary');
                var summary = arr.filter(function (elem) {
                    return elem !== arr[0];
                });
                ajax_input.val(arr[0]);
                sum_input.text(summary);
            }
        });

    $("input#add_images_codes_ajax").autocomplete(
        {
            source: "/medias/auto_complete_for_code",
            close: function () {
                var ajax_input = $('#add_images_codes_ajax');
                var arr = ajax_input.val().split(',');
                var sum_input = $('#new-img-subject');
                var summary = arr.filter(function (elem) {
                    return elem !== arr[0];
                });
                ajax_input.val(arr[0]);
                sum_input.text(summary);
            }
        });


// Show Loading When Clicking on

    // Toggle Loading with Stop Action
    function stopLoading() {
        var load_screen = $('#loading');
        var search_results = $('#search-results');
        search_results.show();
        load_screen.hide();
        window.stop()
    }

    // Show Loading and Hide Search
    function showLoading() {
        var load_screen = $('#loading');
        var search_results = $('#search-results');
        search_results.hide();
        load_screen.show();
    }

    $('.pagination').children('a').addClass('loading');

    $('.loading').on('click', function () {
        showLoading();
        console.log('Loading Results')
        $('.search-button.apply').removeAttr('data-disable-with');
    });

    $('#search-form').submit(function () {
        showLoading();
        $('.search-button.apply').removeAttr('data-disable-with');
    });

    $('form.batch_selection').submit(function () {
        showLoading();
        $('#add_tags').removeAttr('data-disable-with');
    });

    $('#cancel-loading').on('click', function () {
        stopLoading();
        $('.search-button.apply').removeAttr('data-disable-with');
        $('#add_tags').removeAttr('data-disable-with');
    });


    $('i.toggle-stats-class').on('click', function () {
        var stats_columns = $('.show-stats');
        var class_columns = $('.show-class');
        var stat_text = 'Show Statistics';
        var clas_text = 'Show Synopsis';
        var link_text = $('span.stats-toggle');
        if ($('#synopsis').is(':hidden')) {
            $(this).addClass('fa-analytics').removeClass('fa-align-justify').attr('title', clas_text);
            link_text.text(stat_text);
            class_columns.show();
            stats_columns.hide();
        } else {
            $(this).addClass('fa-align-justify').removeClass('fa-analytics').attr('title', stat_text);
            link_text.text(clas_text);
            stats_columns.show();
            class_columns.hide();

        }
    });

    $('.ui-multiselect').css({'width': '100%'});

    // Initialise Multi Select
    $(".assign-users-to-comment").multiselect({
        height: 150,
        minWidth: 550,
        selectedList: 1, // - Show selected on 3 Selected
        selectAll: false,
        checkAll: false,
        noneSelectedText: "Notify people by email (optional)",
        header: "Choose Users below:"
    });


    // Initialise Multi Select
    $(".multiple_select").multiselect({
        height: 150,
        minWidth: 300,
        selectedList: 1, // - Show selected on 3 Selected
        noneSelectedText: "All"
    });

    // Change Multi Select Input and Go
    $('.ui-multiselect-go').click(function () {
        console.log('test')
        $('#search-form').submit();
    });

    // Change Single Input and Go
    $('.search-submit-input').change(function () {
        this.form.submit();
        showLoading();
    });

    // Add Row to Table
    var add_row = $('#add-new-row'), add_row_button = $('#add-new-row-button');
    if ($('#add_new').val() !== '1') {
        add_row.hide();
    }
    add_row_button.click(function () {
        if (add_row.is(":hidden")) {
            add_row.show()
        } else {
            add_row.hide()
        }
    });
    $('.add-new-row.custom-role-rules-form').change(function () {
        var selected = '&show=custom_rules&filter_wks=1&workspace_id=' + $('.add-new-row').val()
        window.location.search = selected;
    });

    // Search Show / Hide Button
    var search_bar = $("#search-box"), hide_ico = $("#hide-search"), arrow = $("#hide-search-arrow"), search_option = $('#hide_search_option').val();

    // Toggle Show / Hide
    if (search_option === '1') {
        search_bar.hide();
        arrow.addClass('fa-arrow-alt-from-top').removeClass('fa-arrow-alt-from-bottom');
    }


    function hideSearch() {
        if (search_bar.is(":hidden")) {
            console.log("Show Search");
            arrow.addClass('fa-arrow-alt-from-bottom').removeClass('fa-arrow-alt-from-top');
        } else {
            console.log("Hide Search");
            arrow.addClass('fa-arrow-alt-from-top').removeClass('fa-arrow-alt-from-bottom');
        }
        search_bar.slideToggle();
        return false;
    }



    hide_ico.click(function() {
       hideSearch()
    });

    // Add Title
    $(hide_ico, arrow).attr('title', 'Show / Hide Search')

    var workspace = $('#workspace'), new_form = $('#new-transaction'), new_expense = $('.new-expense'), new_income = $('.new_income'), new_transfer = $('.new-transfer')

    new_expense.click(function(){
       if (new_form.is(':hidden')) {
           new_form.show()
       } else {
           new_form.hide()
       }
    });



    // Resize Table Header
        var thElm;
        var startOffset;

        Array.prototype.forEach.call(
            document.querySelectorAll("table.default th"),
            function (th) {
                th.style.position = 'relative';

                var grip = document.createElement('div');
                grip.classList.add('resize-header');
                grip.innerHTML = "&nbsp;";
                grip.addEventListener('mousedown', function (e) {
                    thElm = th;
                    startOffset = th.offsetWidth - e.pageX;
                });

                th.appendChild(grip);
            });

        document.addEventListener('mousemove', function (e) {
            if (thElm) {
                thElm.style.width = startOffset + e.pageX + 'px';
            }
        });

        document.addEventListener('mouseup', function () {
            thElm = undefined;
        });

        function toggleNavbarSearch(){
            $('.search-select').slideToggle();
            $('.navbar-search-select').toggleClass('fa-caret-down fa-caret-up');
        }


    $('.delete-confirm').attr('data-confirm', "Are you sure? This action cannot be reverted.")

    // Field Form - Example: User Form
    var field_f = $('#user_default_dashboard')
    var field_f_edit = $('.field-form.edit');
    var field_f_cancel = $('.field-form.cancel');
    var field_f_fields = $('.field-form-submit-cancel') ;
    field_f_edit.on('click', function (){
        field_f.removeAttr("disabled")
        $(this).hide();
        field_f_fields.show();
    })
    field_f_cancel.on('click', function (){
        field_f.attr('disabled','disabled')
        field_f_edit.show();
        field_f_fields.hide();
    })
// Auto Submit Form

    $('.auto-submit').change(function() {
        this.form.submit();
        showLoading();
    });

});
