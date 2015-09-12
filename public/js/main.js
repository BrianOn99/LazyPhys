/*
 * djb2 hash function
 * The answer is stored as its djb2 hash in the server.  I would like the user
 * validates himself (server will double validate) to reduce ajax call.  If you
 * can reverse djb2, go ahead.
 * There are md5 and sha256 js library, but its a waste to load a library
 * Modified from https://github.com/wearefractal/djb2/blob/master/index.js
 * written by contra who kindly release it in MIT License
 */
djb2 = function(word) {
  return word.split('').reduce(function(prev, curr){
    code = curr.charCodeAt(0);
    return ((prev << 5) + prev) + code;
  }, 5381);
};

prepare_submit = function(ans) {
  $("#config-submit").prop("disabled", false);
  $("#config-submit").click(function() {
    $.ajax({
      method: "POST",
      url: "/submit_edit",
      data: { answer: ans, config: $("#config-edit").val() }
    })
      .done(function(msg) { alert(msg); })
      .fail(function(jqXHR, textStatus) { alert( "Request failed: " + textStatus ); })
  });
};

testUser = function(QA){
  QA = JSON.parse(QA);
  var idModal = $("#id-Modal");
  var question = QA["Q"].replace('xxx', '<input type="text" name="answer">');
  idModal.find(".modal-body").html(question);
  idModal.modal();
  idModal.find(".submit").click(function() {
    var ans = idModal.find("input").val();
    if (djb2(ans) != QA["A"]) {
      alert("wrong");
      return;
    }

    idModal.modal("hide");
    prepare_submit(ans);
  });
};
