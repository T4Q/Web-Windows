function bs_input_file() {
    $(".input-file").before(
        function () {
            if (!$(this).prev().hasClass('input-ghost')) {
                var element = $("<input type='file' class='input-ghost' style='visibility:hidden; height:0'>");
                element.attr("name", $(this).attr("name"));
                element.attr("id", $(this).attr("id"));
                element.change(function () {
                    element.next(element).find('input').val((element.val()).split('\\').pop());
                    onProcImage(this, element.attr("name"));
                });
                $(this).find("button.btn-choose-left").click(function () {
                    element.click();
                });
                $(this).find("button.btn-choose-right").click(function () {
                    element.click();
                });

                $(this).find('input').css("cursor", "pointer");
                $(this).find('input').mousedown(function () {
                    $(this).parents('.input-file').prev().click();
                    return false;
                });
                return element;
            }
        }
    );
}

$(function () {
    bs_input_file();
});

var g_imgLeft = "";
var g_imgRight = "";
var g_image1;
var g_image2;
var g_canvas;

function onProcImage(input, id) {
    g_canvas = document.createElement('canvas');
    g_canvas.width = 400;
    g_canvas.height = 300;
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        
        reader.onload = function (e) {
            if (id == "fileLeft") {
                var img = new Image();
                img.src = e.target.result;
                img.onload = function () {
                    g_image1 = img;
                };
                //$('#imgLeft').attr('src', e.target.result);
                g_imgLeft = e.target.result;
                g_imgLeft = g_imgLeft.replace(/^data\:image\/\w+\;base64\,/, '');
                match(1);
            }
            else if (id == "fileRight") {
                var img = new Image();
                img.src = e.target.result;
                img.onload = function () {
                    g_image2 = img;
                };
                //$('#imgRight').attr('src', e.target.result);
                g_imgRight = e.target.result;
                g_imgRight = g_imgRight.replace(/^data\:image\/\w+\;base64\,/, '');
                match(2);
            }
        }

        reader.readAsDataURL(input.files[0]);
    }
}

function match(index) {
    var formData = new FormData();
    formData.append("imgLeft", g_imgLeft);
    formData.append("imgRight", g_imgRight);
    formData.append("index", index);
    $.ajax({
        url: "match.aspx",
        type: 'POST',
        data: formData,
        async: true,
        cache: false,
        contentType: false,
        processData: false,
        success: handleResponse,
        error: handleError
    });
}

function handleError(jqXHR, status, error) {

}

function handleResponse(data) {
    var cx = g_canvas.getContext("2d");
    var obj = JSON.parse(data);
    if (obj.index == 1) {
        var face = {};
        face.X = obj.left1;
        face.Y = obj.top1;
        face.Width = obj.width1;
        face.Height = obj.height1;
        var img = new Image();
        img.src = obj.retimg1;
        img.onload = function () {
            g_image1 = img;

            drawFaceImage(cx, g_canvas.width, g_canvas.height, g_image1, face);
            $('#imgLeft').attr('src', g_canvas.toDataURL('image/jpeg'));
        };
    } else {
        var face = {};
        face.X = obj.left2;
        face.Y = obj.top2;
        face.Width = obj.width2;
        face.Height = obj.height2;

        var img = new Image();
        img.src = obj.retimg2;
        img.onload = function () {
            g_image2 = img;

            drawFaceImage(cx, g_canvas.width, g_canvas.height, g_image2, face);
            $('#imgRight').attr('src', g_canvas.toDataURL('image/jpeg'));
        };
    }
    $("#score-label")[0].innerHTML = obj.message;
}

function drawFaceImage(cx, cw, ch, image, face) {
    cx.clearRect(0, 0, cw, ch);

    cx.fillStyle = "white";
    cx.fillRect(0, 0, cw, ch);

    var fx = cw * 1.0 / image.width;
    var fy = ch * 1.0 / image.height;
    var f = fx;
    if (f > fy)
        f = fy;
    var dw, dh;
    dw = f * image.width;
    dh = f * image.height;
    var dx, dy;
    dx = (cw - dw) / 2;
    dy = (ch - dh) / 2;

    /*var deg;
    if (face.Rotation == 1) deg = 90;
    else if (face.Rotation == 2) deg = 180;
    else if (face.Rotation == 3) deg = 270;

    cx.save();
    var rad = deg * Math.PI / 180;
    //set the origin to the center of the image
    cx.translate(cw / 2, ch / 2);
    //rotate the canvas around the origin
    cx.rotate(rad);*/
    //cx.drawImage(image, dx - cw / 2, dy - ch / 2, dw, dh);
    cx.drawImage(image, dx, dy, dw, dh);

    //cx.restore();

    var i;
    cx.strokeStyle = "lightgreen";
    cx.lineWidth = 3;
    var nX = dx + face.X * f;
    var nY = dy + face.Y * f;
    var nWidth = face.Width * f;
    var nHeight = face.Height * f;
    cx.strokeRect(nX, nY, nWidth, nHeight);
}