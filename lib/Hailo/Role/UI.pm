package Hailo::Role::UI;
BEGIN {
  $Hailo::Role::UI::AUTHORITY = 'cpan:AVAR';
}
{
  $Hailo::Role::UI::VERSION = '0.72';
}

use 5.010;
use Any::Moose '::Role';
use namespace::clean -except => 'meta';

requires 'run';

1;

=encoding utf8

=head1 NAME

Hailo::Role::UI - A role representing a L<Hailo|Hailo> UI

=head1 METHODS

=head2 C<new>

This is the constructor. It takes no arguments.

=head2 C<run>

Run the UI, a L<Hailo|Hailo> object will be the first and only
argument.

=head1 AUTHOR

E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason.

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
