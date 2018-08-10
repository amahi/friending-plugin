$(document).on('click', '#friend_user_create_button', function(event) {
    if(this.className.indexOf(" disabled") == -1){
        this.style.display = "inline-block";
        this.nextSibling.style.display = "inline-block";
        this.nextSibling.disabled = true;
        this.previousSibling.style.display = "";
        this.className = this.className + " disabled";
        return true;
    }else{
        return false;
    }
});

$(document).on('ajax:success', '#new-user-form', function(event, results) {
    var spinner = this.querySelector(".spinner");
    spinner.style.display = "none";

    var btn = this.querySelector("#friend_user_create_button");
    btn.className = btn.className.replace(" disabled","");

    var messages_span = this.querySelector("#response_message");
    messages_span.innerHTML = results["message"];
    response_message.style.display = "inline-block";

    if(results["success"]){
        messages_span.style.color="green";

        // add new row in table
        var fr_divs = document.getElementsByClassName("friend_request_div");
        if(fr_divs.length > 0){
            var requests_table = document.getElementById("requests-table");
            var div_element = getRequestElement(results);
            for(var j=0; j<div_element.childNodes.length; j++){
                requests_table.appendChild(div_element.childNodes[j]);
            }

            // for adding ajax:success trigger to newly created form
            var last_div = requests_table.lastElementChild;
            $(last_div).on('ajax:success', function(event, results){
                deleteRequestAjaxSuccess(this, results);
            });

        }else{
            setTimeout(function(){
                window.location.reload();
            }, 2000);
        }

    }else{
        messages_span.style.color = "#a44";
    }

    var cancel_btn = this.querySelector(".cancel-link");
    cancel_btn.disabled = false;

    setTimeout(function(){
        messages_span.style.display="none";
        cancel_btn.click();
        var add_btn = document.getElementById("new-user-to-step1");
        add_btn.style.display = "";
    }, 4000);
});

$(document).on('click', '.cancel-link', function(event) {
    setTimeout(function(){
        var add_btn = document.getElementById("new-user-to-step1");
        add_btn.style.display = "";
    }, 30);
});

function getRequestElement(results){
    var node = document.createElement('div');
    node.innerHTML = "<div class='user friend_request_div' id='whole_request_"+results["id"]+"'> <table class='settings stretchtoggle'> <tbody> <tr> <td class='settings-col1'>"+ results["amahi_user"]["email"] +"</td> <td class='ml-4' id='custom-width-fr-table' style='padding-left: 32px; width: 234px;'>"+ results["parsed_time"] +"</td> <td class='ml-4' style='padding-left: 32px;'>"+ results["status"] +"</td> <td class='settings-col1'> <form class='request-delete-form form-inline' id='request-delete-form-id-"+ results["id"] +"' action='/tab/friendings/frnd/request' accept-charset='UTF-8' data-remote='true' method='post'> <input name='utf8' type='hidden' value='✓'> <input type='hidden' name='_method' value='delete'> <input class='d-none' name='id' value='"+ results["id"] +"'> <input class='d-none' name='email' value='"+results["amahi_user"]["email"]+"'> <input type='submit' name='commit' value='Delete' onclick='deleteRequestBtn(this);' class='delete-request-btn btnn btn-create btn btn-info btn-sm left-margin-10' data-disable-with='Delete'> <span class='spinner ' style='display: none'> </span></form></td></tr></tbody></table></div>";
    return node;
}

$(".delete-request-btn").on('click', function(event){
    deleteRequestBtn(event.target);
});

function deleteRequestBtn(element){
    var btn = element;
    var form = element.parentElement;
    form.querySelector(".spinner").style.display = "";
    $(form).trigger('submit.rails');
}

$(".request-delete-form").on('ajax:success', function(event, results){
    deleteRequestAjaxSuccess(this, results);
});

function deleteRequestAjaxSuccess(element, results){
    var spinner = element.querySelector(".spinner");
    spinner.style.display = "none";
    if(results["success"]){
        var fr_divs = document.getElementsByClassName("friend_request_div");
        if(fr_divs.length == 1){
            window.location.reload();
        }else{
            var div = document.getElementById("whole_request_"+results["id"]);
            div.parentElement.removeChild(div);
        }
    }
}

$(".remote-user-delete").on('ajax:success', function(event, results){
    if(results["success"]){
        this.closest(".friend_user_div").remove();
    }else{
        this.previousSibling.style.display="none";
        this.style.display="";
    }
});

$(".share_access_checkbox").on('change', function(event){
    console.log("changed");
});
