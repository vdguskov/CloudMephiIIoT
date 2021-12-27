document.addEventListener("DOMContentLoaded", function(event) {

    $('.move').css('pointer-events', 'none');

    console.log(ip)
    
    function update_mode() {
        let mode = ''
        if ($("#mode").val() === "Auto")
        {
            mode = 'manual'
            $('.move').css('pointer-events', 'initial');
        }
        else
        {
            mode = "auto"
            $('.move').css('pointer-events', 'none');
        }
        
        let data = JSON.stringify({mode: mode, move: "default"})
        $.ajax({
            url: `http://${ip}:443/condition`,
            cache: false,
            contentType: false,
            processData: false,
            data: data,
            type: 'post',
            success: function(data){
                $("#mode").val(mode.charAt(0).toUpperCase() + mode.slice(1))
                console.log(data)
            }
        });
    };

    function update_move(move="default") {
        let data = JSON.stringify({mode: "manual", move: move})
        $.ajax({
            url: `http://${ip}:443/condition`,
            cache: false,
            contentType: false,
            processData: false,
            data: data,
            type: 'post',
            success: function(data){
                console.log('done')
                console.log(data)
            }
        });
    }

    $("#forward").click( function() {
        update_move('forward');
    });

    $("#back").click( function() {
        update_move('back');
    });

    $("#left").click( function() {
        update_move('left');
    });

    $("#right").click( function() {
        update_move('right');
    });

    $("#stop").click( function() {
        update_move('stop');
    });

    $("#mode").click(function() {
        update_mode();
    });

    let timerId = setInterval(refreshLog, 2000);

    function refreshLog() {
        $.ajax({
            url: `http://${ip}:443/get_log`,
            cache: false,
            contentType: false,
            processData: false,
            type: 'get',
            success: function(data){
                console.log('done')
                console.log(data)
                $('#log').val(data.join('\n'))
            }
        });
    }

});
