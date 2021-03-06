package Mgrgw::Controller::Application;
use Ark 'Controller';
with 'Ark::ActionClass::Form',
    'Mgrgw::ActionClass::LoginUser';

sub auto :Private :LoginUser { 1 }

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{apps} = [ 
        models('Schema::Application')->search(
            {
                user_id => $c->user->obj->id,
            }
        )
    ];
}

sub item :Chained :PathPart('application') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    $c->stash->{app} = models('Schema::Application')->search(
        {
            user_id => $c->user->obj->id,
            id => $id,
        }
    )->first;
    unless ($c->stash->{app}) {
        $c->res->status(403);
        $c->res->body('forbidden');
        $c->detach;
    }
}

sub show :Chained('item') :PathPart('') :Args(0) {

}

sub edit :Chained('item') :PathPart('edit') :Form('Mgrgw::Form::Application::Edit') :Args(0) {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $app = $c->stash->{app};

    if ($c->req->method eq 'POST' and $form->submitted_and_valid) {
        models('Schema::Application')->update_by_form($app, $form);
        $c->redirect( $c->uri_for('application', $app->id) );
    }
    $form->fill({$app->get_columns});
}

sub create :Local :Form('Mgrgw::Form::Application::Create') {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST' and $self->form->submitted_and_valid) {
        my $app = models('Schema::Application')->create_from_form(
            $c->user->obj,
            $self->form
        );
        $c->redirect( $c->uri_for('application', $app->id) );
    }
}

1;
