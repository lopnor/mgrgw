package Mgrgw::ControllerBase::CRUD;
use Ark 'Controller';
with
    'Mgrgw::ActionClass::LoginUser',
    'Ark::ActionClass::Form';

use Digest::SHA1;


has model => (
    is => 'ro',
    isa => 'Str',
    default => sub {
        my $self = shift;
        my ($class) = ( ref($self) =~ m{::([^:]+)$} );
        "Schema::$class";
    }
);

has need_login => (
    is => 'ro',
    isa => 'Bool',
    default => sub {0},
);

sub _parse_NeedLoginCheck_attr {
    my ($self, $name, $value) = @_;
    return LoginUser => $self->need_login;
}

sub _parse_PathPrefix_attr {
    my ($self, $name, $value) = @_;
    return PathPart => $self->namespace;
}

sub _parse_AutoForm_attr {
    my ($self, $name, $value) = @_;
    my $class = ref($self);
    $class =~ s/Controller/Form/;
    $class .= "::".ucfirst($name);

    return Form => $class;
}

sub auto :Private :NeedLoginCheck { 1 }

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{list} = [
        models($self->model)->search(
            {
                ($self->need_login ? (user_id => $c->user->obj->id) : ())
            }
        )
    ];
}

sub create :Local :AutoForm :Args(0) {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST' and $self->form->submitted_and_valid) {
        my $item = models($self->model)->create_from_form(
            ($self->need_login ? $c->user->obj : ()),
            $self->form
        );
        $c->redirect( $c->uri_for($self->namespace, $item->id) );
    }
}

sub item :Chained :PathPrefix :CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    $c->stash->{item} = models($self->model)->search(
        {
            ($self->need_login ? (user_id => $c->user->obj->id) : ()),
            id => $id,
        }
    )->first;
    unless ($c->stash->{item}) {
        $c->res->status(404);
        $c->res->body('not found');
        $c->detach;
    }
}

sub read :Chained('item') :PathPart('') :Args(0) {}

sub update :Chained('item') :PathPart('update') :AutoForm :Args(0) {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $item = $c->stash->{item};

    if ($c->req->method eq 'POST' and $form->submitted_and_valid) {
        models($self->model)->update_by_form($item, $form);
        $c->redirect( $c->uri_for($self->namespace, $item->id) );
    }
    $form->fill({$item->get_columns});
}

sub delete :Chained('item') :PathPart('delete') :AutoForm :Args(0) {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $token = do {
        my $token = $c->session->get('__form_delete_token');
        unless ($token) {
            $token = Digest::SHA1::sha1_hex(time, {}, $$, rand);
            $c->session->set('__form_delete_token', $token);
        }
        $token;
    };
    if ($c->req->method eq 'POST' and $form->submitted_and_valid) {
        $c->stash->{item}->delete;
        $c->redirect( $c->uri_for($self->namespace) );
    }
    $self->form->fill({token => $token});
}

1;
