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
        console.log(results);
        var div_element = getRequestElement("");
        var requests_table = document.getElementById("requests-table");
        for(var j=0; j<div_element.childNodes.length; j++){
            requests_table.insertBefore(div_element.childNodes[j], requests_table.children[requests_table.children.length-1]);
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

function getRequestElement(path){
    var node = document.createElement('div');
    node.innerHTML = "<div class='user' id='whole_request_54hjker'><table class='settings stretchtoggle'><tbody><tr> <td class='settings-col1'>cde@temp.com</td> <td class='ml-4' style='padding-left: 32px; width: 234px;'>Fri, 03 Aug 2018 05:41:18</td> <td class='ml-4' style='padding-left: 32px;'>Accepted</td> <td class='settings-col1'> <form class='form-inline' id='request_54hjker_trigger' action='/frnd/54hjker' accept-charset='UTF-8' data-remote='true' method='post'> <input name='utf8' type='hidden' value='✓'> <input type='submit' name='commit' value='Delete' class='btnn btn-create btn btn-info btn-sm left-margin-10' data-disable-with='Delete'> <span class='spinner ' style='display: none'></span></form></td></tr></tbody></table></div>";
    return node;
}