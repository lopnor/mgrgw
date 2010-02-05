package Mgrgw::Schema::Result::Appearance;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw(TimeStamp Core));
__PACKAGE__->table('appearance');
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
    address => {
        data_type => 'CHAR',
        size => 15,
        is_nullable => 0,
    },
    user_agent => {
        data_type => 'VARCHAR',
        size => 255,
        is_nullable => 1,
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

sub format {
    my ($self) = @_;

    return {
        created_at => $self->created_at->set_time_zone('UTC')->strftime("%a %b %d %T %z %Y"),
        updated_at => $self->updated_at->set_time_zone('UTC')->strftime("%a %b %d %T %z %Y"),
        id => $self->id,
        address => $self->address,
        user_agent => $self->user_agent,
        user => { 
            id => $self->user->id,
            name => $self->user->fullname,
            screen_name => $self->user->username,
        }
    };
}

1;
