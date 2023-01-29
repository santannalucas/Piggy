$(document).ready(function() {

    var type_select = $('#scheduler_transaction_type_id')
    var period_select = $('#scheduler_scheduler_period_id')
    var split_select = $('#scheduler_split')
    var payment_type_select = $('#scheduler_scheduler_type_id')
    var split_amount = $('#split_amount')
    var scheduler_amount = $('#scheduler_amount')
    var last_date = $('.f-last-date')

    function hidePaysOpts() {
        split_amount.hide()
        split_select.hide()
        period_select.hide()
        last_date.hide()
    }

    function changePaymentType(){
        if ($(payment_type_select).val() === '2') {
            split_select.show()
            period_select.show()
            split_amount.show()
            last_date.hide()
            $('.split-head').text('Instalments / Amount')
            $('.period-head').text('Period')
        } else if($(payment_type_select).val() ==='3'){
            last_date.show()
            split_select.hide()
            split_amount.hide()
            period_select.show()
            $('.split-head').text('Last Payment Date')
            $('.period-head').text('Period')
        } else {
            $('.split-head').text('')
            $('.period-head').text('')
            hidePaysOpts()
        }
    }
    changePaymentType();
    // Reload Transfer

    payment_type_select.change(function () {
        changePaymentType()
    });

    scheduler_amount.change(function (){
       if (payment_type_select.val() === '2'){
           split_amount.val($(this).val()/split_select.val())
       }
    });

    split_select.change(function (){
        scheduler_amount.val($(this).val()*split_amount.val())
    });

    split_amount.change(function (){
        scheduler_amount.val($(this).val()*split_select.val())
    });

    type_select.change(function (){
        window.location = document.URL.split('?')[0] + '?&new_form=1&transaction_type_id='+ $(this).val()
    });
});

