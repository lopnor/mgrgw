? extends 'base';

? block js => sub {
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
<script src="<?= $c->uri_for('/js/jquery.oembed.js') ?>"></script>
<script src="<?= $c->uri_for('/js/pretty.js') ?>"></script>
<script type="text/javascript">
function insert_status (data) {
    var when = $('<span/>').addClass('timestamp')
        .attr('title', (new Date(data.created_at)).toString())
        .text(data.created_at);
    var text = $('<span/>').addClass('content').html(
        data.text.replace(/https?:\/\/\S+/g, 
            function(arg){return '<a class="oembed" href="'+arg+'">'+arg+'</a>'}
        )
    );
    text.find('a').oembed(null, { embedMethod: "append", maxWidth: 500 });
    var username = $('<span/>').addClass('username').text(data.user.screen_name);
    var div = $('<div/>').addClass('status').append(username).append(text).append(when);
    $('#statuses').prepend(div);
    $('.timestamp').prettyDate();
}
$(function() {
    $(':input[name=status]').attr('autocomplete', 'off').focus();
    $.getJSON(
        "<?= $c->uri_for('/statuses/home_timeline.json') ?>",
        function (statuses) {
            $.each(statuses.reverse(), function(i, e) {insert_status(e)});
        }
    );
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
});
</script>
? };

? block content => sub {
<form id="update_status" action="#">
<input type="text" size="50" name="status" />
<input type="submit" value="update" />
</form>
<div id="statuses"></div>
? };
