#!perl
use strict;
use warnings;
use FindBin;
use DBI;
use AnyEvent::XMPP::Client;
use Config::Pit;
use Net::Twitter;
use Data::Dumper;

our $VERSION='0.01';

my $config = pit_get('im.mgrgw.jp');

my $db = "$FindBin::Bin/mgrgw-im.db";
my $exists = -r $db;
my $dbh = DBI->connect("dbi:SQLite:$db");
unless ($exists) {
    $dbh->do(<<END);
CREATE TABLE user (
    jid varchar(255) primary key not null,
    token char(40) not null,
    token_secret char(40) not null,
    verifier char(16)
);
END
}
my $jid_search = $dbh->prepare('select * from user where jid = ?');
sub get_user {
    my ($jid) = @_;
    $jid_search->execute($jid);
    my ($user) = @{$jid_search->fetchall_arrayref({})};
    return $user;
}

sub update {
    my ($jid, $status) = @_;

}

my $BASEURL = $ENV{MGRGW_BASEURL} || 'http://mgrgw.jp';
(my $BASEURL_HTTPS = $BASEURL) =~ s{^http://}{https://};


sub _nt {
    my $nt = Net::Twitter->new(
        traits => [qw(API::REST OAuth)],
        apiurl => $BASEURL,
        oauth_urls => {
            request_token_url  => "$BASEURL/oauth/request_token",
            authentication_url => "$BASEURL/oauth/authenticate",
            authorization_url  => "$BASEURL/oauth/authorize",
            access_token_url   => "$BASEURL/oauth/access_token",
            xauth_url          => "$BASEURL_HTTPS/oauth/access_token",
        },
        consumer_key => $config->{consumer_key},
        consumer_secret => $config->{consumer_secret},
    );
}


my $cv = AnyEvent->condvar;

my $client = AnyEvent::XMPP::Client->new(
    debug => 0,
);
$client->add_account(
    $config->{username},
    $config->{password},
    'talk.google.com',
    5222
);
$client->reg_cb(
    disconnect => sub {
        $cv->broadcast;
    },
    roster_update => sub {
        my ($cl, $acc, $roster, $contacts) = @_;
        $acc->connection->retrieve_roster();
    },
    presence_update => sub {
        my ($cl, $acc, $roster, $contact, $old, $new) = @_;
        warn sprintf("presence_update:%s, old:%s, new:%s", 
            $contact->jid,
            $old ? $old->show || 'available' : 'exit',
            $new ? $new->show || 'available' : 'exit',
        );
        my $nt = _nt();
        my $user = get_user($contact->jid);
        if ($user && $user->{token} && $user->{token_secret}) {
            $nt->access_token($user->{token});
            $nt->access_token_secret($user->{token_secret});
            eval {$nt->update_profile};
        }
    },
    contact_request_subscribe => sub {
        my ($cl, $acc, $roster, $contact, $message) = @_;
        $acc->connection->retrieve_roster();
        $contact->send_subscribed;
    },
    contact_unsubscribed => sub {
        my ($cl, $acc, $roster, $contact, $message) = @_;
        $dbh->do('delete from user where jid = ?', {}, $contact->jid);
        $acc->connection->retrieve_roster();
        $contact->send_unsubscribed;
    },
    message => sub {
        my ($cl, $acc, $message) = @_;
# write mgrgw or authorize account
        my ($sender) = split('/', $message->from);
        my $user = get_user($sender);
        my $nt = _nt();
        unless ($user) {
            my $url = $nt->get_authorization_url;
            $dbh->do(
                'insert into user (jid, token, token_secret) values (?,?,?)',
                {},
                $sender,
                $nt->request_token,
                $nt->request_token_secret,
            );
            $cl->send_message(qq(* follow the link\n* get pin code\n* send me the pin code\n\n$url), $message->from);
        } elsif (! $user->{verifier}) {
            $nt->request_token($user->{token});
            $nt->request_token_secret($user->{token_secret});
            my ($token, $secret) = eval {
                $nt->request_access_token(
                    verifier => $message->body
                )
            };
            if ($token && $secret) {
                $dbh->do(
                    'update user set token = ?, token_secret = ?, verifier = ? where jid = ?',
                    {},
                    $token,
                    $secret,
                    $message->body,
                    $sender
                );
                $cl->send_message('ok', $message->from);
            } else {
                $dbh->do('delete from user where jid = ?', {}, $sender);
                $cl->send_message('ng', $message->from);
            }
        } else {
            $nt->access_token($user->{token});
            $nt->access_token_secret($user->{token_secret});
            eval {$nt->update({status => $message->body})};
            if ($@) {
                my $url = $nt->get_authorization_url;
                $dbh->do('delete from user where jid = ?', {}, $sender);
                $dbh->do(
                    'insert into user (jid, token, token_secret) values (?,?,?)',
                    {},
                    $sender,
                    $nt->request_token,
                    $nt->request_token_secret,
                );
                $cl->send_message(qq(* follow the link\n* get pin code\n* send me the pin code\n\n$url), $message->from);
            } else {
                $cl->send_message('ok', $message->from);
            }
        }
    }
);
$client->start;

my $timer = AnyEvent->timer(
    after => 10,
    interval => 60,
    cb => sub {
        my ($ac) = $client->get_accounts;
        $ac->connection->retrieve_roster(
            sub {
                my ($con, $roster, $err) = @_;
                for my $c ($roster->get_contacts) {
                    warn $c->jid;
                    my $user = get_user($c->jid) or next;
                    $user->{token_secret} or next;
                    for ($c->get_presences) {
                        unless ($_->show) {
                            my $nt = _nt;
                            $nt->access_token($user->{token});
                            $nt->access_token_secret($user->{token_secret});
                            eval {$nt->update_profile};
                        }
                    }
                }
            }
        );
    }
);

$cv->recv;
$cv->wait;

