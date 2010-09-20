package Mgrgw::Controller::Webhook;
use Ark '+Mgrgw::ControllerBase::CRUD';

has '+need_login' => default => sub {1};

1;
