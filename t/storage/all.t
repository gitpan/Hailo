use 5.10.0;
use utf8;
use strict;
use warnings;
use Test::More tests => 107;
use Hailo;
use Data::Random qw(:all);
use File::Temp qw(tempfile tempdir);

binmode $_, ':encoding(utf8)' for (*STDIN, *STDOUT, *STDERR);

# Suppress PostgreSQL notices
$SIG{__WARN__} = sub { print STDERR @_ if $_[0] !~ m/NOTICE:\s*CREATE TABLE/; };

for my $backend (qw(Perl Perl::Flat CHI::Memory CHI::File CHI::BerkeleyDB DBD::mysql DBD::SQLite DBD::Pg)) {
    # Skip all tests for this backend?
    my $skip_all;

    # Dir to store our brains
    my $dir = tempdir( CLEANUP => 1 );
    ok($dir, "Got temporary dir $dir");

    my ($fh, $filename) = tempfile( DIR => $dir, SUFFIX => '.db' );
    ok($filename, "Got temporary file $filename");

    if ($backend =~ /mysql/) {
        # It doesn't use the file to store data obviously, it's just a convenient random token.
        if (!$ENV{HAILO_TEST_MYSQL} or
            system qq[echo "SELECT DATABASE();" | mysql -u'hailo' -p'hailo' 'hailo' >/dev/null 2>&1]) {
            $skip_all = 1;
            pass("Skipping mysql tests, can't connect to database named 'hailo'");
        } else {
            pass("Connected to mysql 'hailo' database");
            system q[echo 'drop table info; drop table token; drop table expr; drop table next_token; drop table prev_token;' | mysql -u hailo -p'hailo' hailo];
        }
    }

    if ($backend =~ /Pg/) {
        # It doesn't use the file to store data obviously, it's just a convenient random token.
        if (system "createdb '$filename' >/dev/null 2>&1") {
            $skip_all = 1;
            pass("Skipping PostgreSQL tests, can't create a database named '$filename'");
        } else {
            pass("Created PostgreSQL '$filename' database");
        }
    }

    my $prev_brain;
    for my $i (1 .. 5) {
        my %connect_opts;
        if ($backend =~ /SQLite/ or $backend =~ /Perl/) {
            %connect_opts = (
                brain_resource => $filename,
            );
        } elsif ($backend =~ /Pg/) {
            %connect_opts = (
                storage_args => {
                    dbname => $filename,
                },
            );
        } elsif ($backend =~ /mysql/) {
            %connect_opts = (
                storage_args => {
                    database => 'hailo',
                    host => 'localhost',
                    username => 'hailo',
                    password => 'hailo',
                },
            );
        } elsif ($backend =~ /CHI::BerkeleyDB/) {
            my $chidir = tempdir( DIR => $dir );
            %connect_opts = (
                storage_args => {
                    root_dir => $chidir,
                },
            );
        } elsif ($backend =~ /CHI::File/) {
            my $chidir = tempdir( DIR => $dir );
            %connect_opts = (
                storage_args => {
                    root_dir => $chidir,
                },
            );
        }
      SKIP: {
        skip "Didn't create $backend db, can't test it", 2 if $skip_all;

        my $hailo = Hailo->new(
            storage_class  => $backend,
            %connect_opts,
        );

        if ($backend =~ /Perl/) {
            if ($prev_brain) {
                my $this_brain = $hailo->_storage_obj->_memory;
                is_deeply($prev_brain, $this_brain, "$backend: Our previous $backend brain matches the new one, try $i");
            }
        }

        # Get some training material
        my $size = 10;
        my @random_words = rand_words( size => $size );
        is(scalar @random_words, $size, "$backend: Got $size words to train on, try $i");

        # Learn from it
        eval {
            $hailo->learn("@random_words");
        };

        skip "Couldn't load backend $backend: $@", 1 if $@;

        # Hailo replies
        cmp_ok(length($hailo->reply($random_words[5])) * 2, '>', length($random_words[5]), "Hailo knows how to babble, try $i");

        if ($backend =~ /Perl/) {
            # Save this brain for the next iteration
            $prev_brain = $hailo->_storage_obj->_memory;
        }

        $hailo->save();
        if ($backend =~ /SQLite/) {
            $_->finish for values %{ $hailo->_storage_obj->sth };
            $hailo->_storage_obj->dbh->disconnect;
        }
        undef $hailo;
      }
    }

    if ($backend =~ /Pg/) {
      SKIP: {
        skip "Didn't create PostgreSQL db, no need to drop it", 1 if $skip_all;
        system "dropdb '$filename'" and die "Couldn't drop temporary PostgreSQL database '$filename': $!";
        pass("Dropped PostgreSQL '$filename' database");
      }
    }

    # Don't skip for the next backend
    $skip_all = 0;
}
