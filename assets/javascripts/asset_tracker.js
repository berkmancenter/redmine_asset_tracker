Control.DatePicker.Locale['en_MYSQL'] = {
    dateTimeFormat: 'yyyy-MM-dd HH:mm',
    dateFormat: 'yyyy-MM-dd',
    firstWeekDay: 1,
    weekend: [0,6],
    language: 'en'};


function createPickers() {
    $(document.body).select('input.datepicker').each( function(e) {
        new Control.DatePicker(e, { 'icon': '/images/calendar.png' ,
                               timePicker: true,
                               timePickerAdjacent: true,
                               locale: 'en_MYSQL'});
    } );
}
    Event.observe(window, 'load', createPickers); 