? extends 'base';
? block style => sub {
    #timeline {
        height: 150px;
        width: 100%;
        border: 2px #fcc800 solid;
    }
? };
? block js => sub {
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
<script src="http://static.simile.mit.edu/timeline/api-2.3.0/timeline-api.js?bundle=true"></script>
<script src="<?= $c->uri_for('/js/jquery.oembed.js') ?>"></script>
<script src="<?= $c->uri_for('/js/pretty.js') ?>"></script>
<script type="text/javascript">

var latest_id;
var oldest_id;
var tl;
var es;
function clean_statuses() {
    latest_id = 0;
    oldest_id = 0;
    $('#statuses').html('');
}
function parse_text(text) {
    text = text.replace(
        /\b(https?:\/\/[\S]+)(?:\b|$)/g, 
        '<a class="oembed" href="$1" target="_blank">$1</a>'
    );
    text = text.replace(
        /(\W|^)@(\w+)(?:\b|$)/g,
        '$1@<a href="<?= $c->uri_for('/') ?>$2" class="username">$2</a>'
    );
    text = text.replace(
        /(\W|^)(#\w+)(?:\b|$)/g,
        '$1<a href="<?= $c->uri_for('/') ?>search?q=$2" class="hashtag" title="$2">$2</a>'
    );
    return text;
}
function search(query) {
    $.getJSON(
        "<?= $c->uri_for('/search.json') ?>",
        {q: query},
        function (data) {
            clean_statuses();
            load_statuses(data);
        }
    );
}
function insert_status (data) {
    if ($('#status_'+data.id).length != 0) return;
    var when = $('<span/>').addClass('timestamp')
        .attr('title', (new Date(data.created_at)).toString())
        .prettyDate();
    var text = $('<span/>').addClass('content').html(parse_text(data.text));
    text.find('a').oembed(null,{ embedMethod: "append" });
    var username = $('<span/>').addClass('username').text(data.user.screen_name);
    var div = $('<div/>').addClass('status')
        .attr('id', 'status_'+data.id)
        .append(username).append(text).append(when);
    div.find('a.hashtag').click(function(){
        search($(this).attr('title'));
        return false;
    });
    var prev_stat_id;
    var done = 0;
    $('#statuses div.status').each(function(i,e){
        var stat_id = parseInt($(e).attr('id').substr(7));
        if ((prev_stat_id == undefined || prev_stat_id > data.id) && data.id > stat_id) {
            div.insertBefore($(e));
            done = 1;
            return false;
        }
        prev_stat_id = stat_id;
    });
    if (done == 0) $('#statuses').append(div);
    $('.timestamp').prettyDate();
}
function load_statuses(data) {
    var l = parseInt(data[0].id);
    var o = parseInt(data[data.length-1].id);
    if ( oldest_id == 0 || oldest_id > o) oldest_id = o;
    if ( latest_id == 0 || latest_id < l) latest_id = l;
    $.each(data, function(i, e) {
        insert_status(e);
    });
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
        function (data) {load_statuses(data)}
    );
    load_timeline();
}
function load_timeline() {
    Timeline.loadJSON(
        "<?= $c->uri_for('/appearance.json') ?>", 
        function(data, url) { 
            data = $.map(data, function(n,i) {
                var dur = (new Date(n.updated_at)) - (new Date(n.created_at));
                return {
                    start: n.created_at,
                    end: n.updated_at,
                    title: n.address,
                    durationEvent: dur > 10 * 60 * 1000
                };
            });
            es.clear();
            es.loadJSON({events: data}, url);
        }
    );
}
function setup_timeline() {
    var offset = (new Date()).getTimezoneOffset() / 60 * -1;
    es = new Timeline.DefaultEventSource();
    var bi = [
        Timeline.createBandInfo({
            eventSource: es,
            timeZone: offset,
            width: '75%',
            intervalUnit: Timeline.DateTime.HOUR,
            intervalPixels: 100
        }),
        Timeline.createBandInfo({
            overview: true,
            timeZone: offset,
            eventSource: es,
            width: '25%',
            intervalUnit: Timeline.DateTime.DAY,
            intervalPixels: 100
        })
    ];
    bi[1].syncWith = 0;
    bi[1].highlight = true;
    tl = Timeline.create(document.getElementById('timeline'), bi);
}
$(function() {
    clean_statuses();
    setup_timeline();
    appearance();
    $(':input[name=status]').focus();
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
    $('#pager').click(function(){
        $.getJSON(
            "<?= $c->uri_for('/statuses/home_timeline.json') ?>",
            { max_id: oldest_id },
            function (data) {load_statuses(data)}
        )
        return false;
    });
    window.setInterval(function(){appearance()}, 1000 * 60 * 5);
});
</script>
? };

? block content => sub {
<div id="timeline"></div>
<form id="update_status" action="#">
<input type="text" size="50" name="status" autocomplete="off" />
<input type="submit" value="update" />
<span id="appearance"></span>
</form>
<div id="statuses"></div>
<a href="#" id="pager">more</a>
? };
