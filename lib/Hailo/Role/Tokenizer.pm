package Hailo::Role::Tokenizer;
BEGIN {
  $Hailo::Role::Tokenizer::AUTHORITY = 'cpan:AVAR';
}
BEGIN {
  $Hailo::Role::Tokenizer::VERSION = '0.67';
}

use 5.010;
use Any::Moose '::Role';
use namespace::clean -except => 'meta';

has spacing => (
    isa     => 'HashRef[Int]',
    is      => 'rw',
    default => sub { {
        normal  => 0,
        prefix  => 1,
        postfix => 2,
        infix   => 3,
    } },
);

sub BUILD {
    my ($self) = @_;

    # This performance hack is here because calling
    # $self->spacing->{...} was significant part Tokenizer execution
    # time (~20s / ~1200s) since we're doing one method call and a
    # hash dereference

    my $spacing = $self->spacing;
    while (my ($k, $v) = each %$spacing) {
        $self->{"_spacing_$k"} = $v;
    }

    return;
}

requires 'make_tokens';
requires 'make_output';

1;

=encoding utf8

=head1 NAME

Hailo::Role::Tokenizer - A role representing a L<Hailo|Hailo> tokenizer

=head1 METHODS

=head2 C<new>

This is the constructor. It takes no arguments.

=head2 C<make_tokens>

Takes a line of input and returns an array reference of tokens. A token is
an array reference containing two elements: a I<spacing attribute> and the
I<token text>. The spacing attribute is an integer which will be stored along
with the token text in the database. The following values are currently being
used:

=over

=item C<0> - normal token

=item C<1> - prefix token (no whitespace follows it)

=item C<2> - postfix token (no whitespace precedes it)

=item C<3> - infix token (no whitespace follows or precedes it)

=back

=head2 C<make_output>

Takes an array reference of tokens and returns a line of output. A token is
an array reference as described in L<C<make_tokens>|/make_tokens>. The tokens
will be joined together into a sentence according to the whitespace
attributes associated with the tokens, as well as any formatting provided by
the tokenizer implementation.

=head1 AUTHORS

Hinrik E<Ouml>rn SigurE<eth>sson, hinrik.sig@gmail.com

E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Hinrik E<Ouml>rn SigurE<eth>sson and
E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
