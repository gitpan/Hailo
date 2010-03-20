package Hailo::Test::Tokenizer;
our $VERSION = '0.34';
use 5.010;
use Any::Moose;
use namespace::clean -except => 'meta';
use Hailo::Tokenizer::Words;

with 'Hailo::Role::Tokenizer';

sub make_tokens { goto &Hailo::Tokenizer::Words::make_tokens }
sub make_output { goto &Hailo::Tokenizer::Words::make_output }

__PACKAGE__->meta->make_immutable;
