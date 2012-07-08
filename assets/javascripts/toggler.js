    
function toggle_text_field() {

      $("is_recurring").observe("click",function(field) {
           if (this.checked == true)
          {
              $("repeat_count").removeAttribute('disabled');
          }
          else
          {
              $("repeat_count").setAttribute('disabled', 'disabled');
          }
      });

  }