? extends 'base';

? block js => sub {
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
<script src="<?= $c->uri_for('/js/jquery.oembed.js') ?>"></script>
<script src="<?= $c->uri_for('/js/pretty.js') ?>"></script>
<script type="text/javascript">

var latest_id = 0;
function insert_status (data) {
    var when = $('<span/>').addClass('timestamp')
        .attr('title', (new Date(data.created_at)).toString())
        .text(data.created_at);
    var text = $('<span/>').addClass('content').html(
        data.text.replace(/https?:\/\/\S+/g, 
            function(arg){return '<a class="oembed" href="'+arg+'">'+arg+'</a>'}
        )
    );
    text.find('a').oembed(null,{ embedMethod: "append" });
    var username = $('<span/>').addClass('username').text(data.user.screen_name);
    var div = $('<div/>').addClass('status').append(username).append(text).append(when);
    $('#statuses').prepend(div);
    $('.timestamp').prettyDate();
}
function appearance () {
    $.getJSON(
        "<?= $c->uri_for('/appearance/current.json') ?>",
        function (data) {
            since = $('<span/>')
                .attr('title', (new Date(data.created_at)).toString())
                .prettyDate();
            $('#appearance').text("you're here since ").append(since);
        }
    );
    $.getJSON(
        "<?= $c->uri_for('/statuses/home_timeline.json') ?>",
        { since_id: latest_id },
        function (statuses) {
            latest_id = statuses[0].id;
            $.each(statuses.reverse(), function(i, e) {
                insert_status(e);
            });
        }
    );
}
$(function() {
    appearance();
    $(':input[name=status]').attr('autocomplete', 'off').focus();
    $('#update_status').submit(function() {
        $.post(
            "<?= $c->uri_for('/statuses/update.json') ?>",
            $(this).serialize(),
            function (data) {
                insert_status(data);
                $('#update_status :input[name=status]').val('').focus();
            },
            "json"
        );
        return false;
    });
    window.setInterval(function(){appearance()}, 1000 * 60 * 5);
});
</script>
? };

? block content => sub {
<form id="update_status" action="#">
<input type="text" size="50" name="status" />
<input type="submit" value="update" />
<span id="appearance"></span>
</form>
<div id="statuses"></div>
? };
