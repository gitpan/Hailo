use autodie;
use strict;
use warnings;
use Test::More tests => 1;
open my $filehandle, '<', __FILE__;

    # Hailo requires Perl 5.10
    use 5.010;
    use Hailo;
   
    # Construct a new in-memory Hailo using the SQLite backend. See
    # backend documentation for other options.
    my $hailo = Hailo->new;
   
    # Various ways to learn
    my @train_this = qw< I like big butts and I can not lie >;
    $hailo->learn(\@train_this);
    $hailo->learn($_) for @train_this;
   
    # Heavy-duty training interface. Backends may drop some safety
    # features like journals or synchronous IO to train faster using
    # this mode.
    $hailo->learn("megahal.trn");
    $hailo->learn($filehandle);

    # Make the brain babble
    say $hailo->reply("hello good sir.");

pass("Synopsis OK");
