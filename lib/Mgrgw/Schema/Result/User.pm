package Mgrgw::Schema::Result::User;
use strict;
use warnings;
use base 'DBIx::Class';
use Mgrgw::Models;

__PACKAGE__->load_components(qw(EncodedColumn TimeStamp Core));
__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    id => {
        data_type => 'INT',
        is_nullable => 0,
        is_auto_increment => 1,
        extra => {
            unsigned => 1,
        }
    },
    fullname => {
        data_type => 'VARCHAR',
        size => 255,
        is_nullable => 1,
    },
    username => {
        data_type => 'VARCHAR',
        size => '255',
        is_nullable => 1,
    },
    password => {
        data_type => 'CHAR',
        size => 40,
        is_nullable => 1,
        encode_column => 1,
        encode_class => 'Digest',
        encode_args => {
            algorithm => 'SHA-1', 
            format => 'hex',
        },
        encode_check_method => 'check_password',
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
__PACKAGE__->add_unique_constraint(['username']);
__PACKAGE__->has_many(statuses => 'Mgrgw::Schema::Result::Status' => 'user_id');
__PACKAGE__->has_many(applications => 'Mgrgw::Schema::Result::Application' => 'user_id');
__PACKAGE__->has_many(openids => 'Mgrgw::Schema::Result::OpenID' => 'user_id');
__PACKAGE__->has_many(tokens => 'Mgrgw::Schema::Result::Token' => 'user_id');

1;
