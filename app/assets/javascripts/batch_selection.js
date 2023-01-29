$(document).ready(function() {

// Batch Select

// Add Selected to Tags on Questions and Scenarios Searches

    // Enable Disabled When Selected
    if ($("form.batch_selection input[type=checkbox]:checked").length === 0) {
        $(".add-objects-tags").addClass("disabled");
    }

    // Add Objects to Tags
    var obj_tags_form = $('.objects-box-form');
    var obj_tags_button = $('.add-objects-tags')  ;
    // Toggle Show / Hide Objects to Tags
    obj_tags_form.hide();
    obj_tags_button.click(function() {
        if (obj_tags_form.is(":hidden") && $("form.batch_selection input[type=checkbox]:checked").length !== 0) {
            obj_tags_button.css('color', '#aaaaaa');
            obj_tags_form.show();
        } else {
            obj_tags_button.css('color', '#2c3e50');
            obj_tags_form.hide()
        }
        return false;
    });

    // Enable And Disable On Populate AJAX FIELD are in boxes.js

// Batch adding Object to a tag from the tag's show page

    // Tags Show / Hide Button
    var add_to_tag_icon = $('.add-to-tag');
    var add_to_tag_save = $('button#add_to_tags');
    var add_to_tag_objects = $('input#object_nos');

    add_to_tag_icon.attr('title', "Show Add to Tag.");
    // Toggle Show / Hide
    add_to_tag_icon.click(function() {
        var new_title = $(this).attr('title');
        if (obj_tags_form.is(":hidden")) {
            $('#switch-box-form').hide();
            $('.switch-position').css('color','#2c3f50 !important');
            obj_tags_form.show();
            $(this).attr('title', new_title.replace('Show','Hide')).removeClass('fa-plus-circle').addClass('fa-times-circle').css('color','#a5a5a5 !important');
        } else {
            $(this).attr('title', new_title.replace('Hide','Show')).removeClass('fa-times-circle').addClass('fa-plus-circle').css('color','#57bb3d !important');
            obj_tags_form.hide();
        }
        return false;
    });
    // Enable Disable Save
    add_to_tag_objects.keyup(function() {
        if (add_to_tag_objects.val() === "") {
            add_to_tag_save.attr("disabled", "disabled").addClass('disabled');
        }
        else {
            add_to_tag_save.removeAttr("disabled").removeClass('disabled');
        }
    });

    // Tag Questions - switch-position
    $('.switch-position').click(function () {
        if ($('#switch-box-form').is(":hidden")) {
            $(this).css('color','#a5a5a5 !important');
            $('#switch-box-form').show();
            $('.objects-box-form').hide();
        } else {
            $('#switch-box-form').hide();
            $(this).css('color','#2c3f50 !important');
            }
        add_to_tag_icon.attr('title', 'Show Add to Tag.').removeClass('fa-times-circle').addClass('fa-plus-circle').css('color','#57bb3d !important');
        return false;
    });

    // Enable Disable Save
    $('#new_number').keyup(function() {
        if ($('#new_number').val() === "") {
            $('button#switch-position').attr("disabled", "disabled").addClass('disabled');
        }
        else {
            $('button#switch-position').removeAttr("disabled").removeClass('disabled');
        }
    });




  if ($(active_tab).length < 1) active_tab = '';

  register_batch_toggler();

});

var active_tab = 'div#reports-tabs div.ui-tabs-panel[aria-hidden="false"] ';


//// Form Batch Selection (form.batch_selection)
// toggle on/off checkboxes
// enable/disable submit buttons
// disable submit buttons by default when checkboxes are unchecked

function register_batch_toggler() {

  // Initially disable (only if no items are selected)
  if ($(active_tab + "form.batch_selection input[type=checkbox]:checked").length == 0) {
    $(active_tab + "form.batch_selection input[type=submit]").attr("disabled", "disabled");
    $('#remove_tags,#archive_tags,#apply_tags,.add-objects-tags,#remove_from_tag,.move-tag-to-group').attr("disabled", "disabled").addClass('disabled');
    $('#remove_tags,#remove_from_tag').attr('title','Remove Selected')
    $('#move-tag-group-box-form,#switch-box-form').hide()
      console.log('Batch Action Disable')
  }

  // THIS IS THE ONE BEING USED MOSTLY
  // For forms that aren't tables: // Enable when items are selected / Disable when no items are selected
  $(active_tab + "form.batch_selection input[type=checkbox]").click(function() {
    if (this.checked) {
      $(active_tab + "form.batch_selection input[type=submit]").removeAttr("disabled");
        $('#remove_tags,#archive_tags,#apply_tags,#remove_from_exam,.add-objects-tags,#remove_from_tag,.move-tag-to-group').removeAttr("disabled").removeClass('disabled');
        $('.add-objects-tags').css('color', '#2c3e50')
        console.log("Batch Action Enabled")
    } else {
      if ($(active_tab + "form.batch_selection input[type=checkbox]:checked").length == 0) {
        $(active_tab + "form.batch_selection input[type=submit]").attr("disabled", "disabled");
          $('#add-tags,#remove_tags,#archive_tags,#remove_from_exam,#apply_tags,.add-objects-tags,#remove_from_tag,.move-tag-to-group').attr("disabled", "disabled").addClass('disabled');
          $(".objects-box-form").hide();
          console.log("Batch Action Disabled")
      }
    }
  });

  //// Toggle All Selections

  // checking toggler selects all items and enables submit buttons
  // unchecking toggler deselects all items and disables submit buttons
  $("input#batch_selection_toggler[type=checkbox]").click(function() {
    $(active_tab + "form.batch_selection input[type=checkbox]")
      .prop('checked', $(active_tab + 'input#batch_selection_toggler[type=checkbox]').is(':checked'));
    if ($(active_tab + "form.batch_selection input[type=checkbox]:checked").length === 0) {
      $(active_tab + "form.batch_selection input[type=submit]").attr("disabled", "disabled");
        $('#add_tags,#remove_tags,#archive_tags,#apply_tags,.add-objects-tags,#remove_from_tag').attr("disabled", "disabled").addClass('disabled');
        $('.objects-box-form').hide();
        console.log("Disable Actions - None selected")

    } else {
      $(active_tab + "form.batch_selection input[type=submit]").removeAttr("disabled");
        $('.add-objects-tags').css('color', '#2c3e50')
        console.log("Enable Actions - all selected")
    }
    populate_report_field();
  });

    // for using batch selections in other forms
    function populate_report_field() {
          var values = [];
          $('input[id^="selected_"]:checked').each(function(e) {
                values.push($(this).val());
              });
          if ($('#report_hidden')) $('#report_hidden').val(values.join(','));
          if ($('#export_hidden')) $('#export_hidden').val(values.join(','));
          if ($('.selected_hidden')) $('.selected_hidden').val(values.join(','));
        };

    // Tags Search - Move to Group
    var move_to_group = $('#move-tag-group-box-form');
    var move_to_group_button = $('.move-tag-to-group');
    move_to_group_button.click(function () {
        // No Tags Selected, do nothing.
        if ($(active_tab + "form.batch_selection input[type=checkbox]:checked").length == 0) {
        } else {
        // Enable Archive Tags if move to Group is hidden
            if (move_to_group.is(":hidden")) {
              $('#archive_tags').hide();
              $('.move-tag-to-group').addClass('fa-arrow-alt-circle-left').removeClass('fa-arrow-alt-circle-right').attr('title','Hide move selected to another group.');
            } else {
                $('#archive_tags').show();
                $('.move-tag-to-group').addClass('fa-arrow-alt-circle-right').removeClass('fa-arrow-alt-circle-left').attr('title','Move selected to another group.');
            }
            move_to_group.slideToggle();
            return false;
        }
        });



}

