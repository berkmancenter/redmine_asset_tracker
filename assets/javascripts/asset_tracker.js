function createPickers() {
    $(document.body).select('input.datepicker').each( function(e) {
        new Control.DatePicker(e, { 'icon': '/images/calendar.png' , timePicker: true, timePickerAdjacent: true});
    } );
}
    Event.observe(window, 'load', createPickers); 