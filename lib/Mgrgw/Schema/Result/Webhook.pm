package Mgrgw::Schema::Result::Webhook;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw(TimeStamp Core));
__PACKAGE__->table('webhook');
__PACKAGE__->add_columns(
    id => {
        data_type => 'INT',
        is_nullable => 0,
        is_auto_increment => 1,
        extra => {
            unsigned => 1,
        }
    },
    user_id => {
        data_type => 'INT',
        is_nullable => 0,
        extra => {
            unsigned => 1,
        }
    },
    type => {
        data_type => 'CHAR',
        size => 16,
        is_nullable => 0,
    },
    uri => {
        data_type => 'VARCHAR',
        size => 255,
    },
    created_at => {
        data_type => 'DATETIME',
        set_on_create => 1,
    },
    updated_at => {
        data_type => 'DATETIME',
        set_on_create => 1,
        set_on_update => 1,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to('user', 'Mgrgw::Schema::Result::User', 'user_id');

1;
