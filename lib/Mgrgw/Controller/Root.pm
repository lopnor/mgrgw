package Mgrgw::Controller::Root;
use Ark 'Controller';
with 'Ark::ActionClass::Form',
    'Mgrgw::ActionClass::LoginUser';

use Mgrgw::Models;

has '+namespace' => default => '';

# default 404 handler

sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    if ($c->user && $c->user->obj) {
        $c->detach('home_timeline');
    }
}

sub username :Path :Args(1) {
    my ($self, $c, $username) = @_;
    $c->res->body($username);
}

sub home_timeline :Private {
    my ($self, $c) = @_;
    $c->forward($c->view('MT')->template('home_timeline'));
}

sub login :Local :Form('Mgrgw::Form::Login') {
    my ($self, $c) = @_;

    if (my $info = $c->authenticate) {
        if ($info->obj) {
            $c->redirect($c->session->remove('nexturl') || $c->uri_for('/'));
        } else {
            $c->redirect($c->uri_for('/setup'));
        }
        $c->detach;
    }
}

sub logout :Local {
    my ($self, $c) = @_;
    $c->logout;
    $c->redirect($c->session->remove('nexturl') || $c->uri_for('/'));
}

sub setup :Local :Form('Mgrgw::Form::Setup') {
    my ($self, $c) = @_;

    my $user = $c->user;
    unless ($user) {
        $c->redirect($c->uri_for('/login'));
        $c->detach;
    }
    if ($user->obj) {
        $c->redirect($c->uri_for('/settings'));
        $c->detach;
    }

    if ($c->req->method eq 'POST' and $self->form->submitted_and_valid) {
        models('Schema::User')->create_from_form(
            {
                openid => $user,
                form => $self->form,
            }
        );
        $c->redirect($c->session->remove('nexturl') || $c->uri_for('/'));
    }
}

sub settings :Local :Form('Mgrgw::Form::Settings') :LoginUser {
    my ($self, $c) = @_;

    my $u = $c->user->obj;
    if ($c->req->method eq 'POST' and $self->form->submitted_and_valid) {
        $u->update($self->form->params);
        return $c->redirect($c->uri_for('/'));
    }
    $self->form->fill({fullname => $c->user->obj->fullname});
}

sub end :Private {
    my ($self, $c) = @_;
    unless ($c->res->body || $c->res->status =~ /^3\d{2}$/) {
        $c->forward($c->view('MT'));
    }
}

1;
