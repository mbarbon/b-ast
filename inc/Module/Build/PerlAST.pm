package Module::Build::PerlAST;

use strict;
use warnings;
use parent qw(Module::Build::WithXSpp);

use Getopt::Long;
use Config;

# yes, doing this in a module is ugly; OTOH it's a private module
GetOptions(
    'g'         => \my $DEBUG,
);

die "OS unsupported"
    unless $^O eq 'linux' ||
           $^O eq 'darwin' ||
           $^O eq 'MSWin32';

sub new {
    my ($class, %args) = @_;
    my $debug_flag = $DEBUG ? ' -g' : '';
    my @extra_libs;

    if ($^O eq 'MSWin32') {
        if ($DEBUG) {
            # TODO add the MSVC equivalent
            my ($ccflags, $lddlflags, $optimize) = map {
                s{(^|\s)-s(\s|$)}{$1$2}r
            } @Config{qw(ccflags lddlflags optimize)};

            $args{config} = {
                ccflags     => $ccflags,
                lddlflags   => $lddlflags,
                optimize    => $optimize,
            };
        }
    }

    return $class->SUPER::new(
        %args,
#        share_dir          => 'share',
        extra_compiler_flags => '-DPERL_NO_GET_CONTEXT' . $debug_flag,
#        extra_linker_flags => [@extra_libs],
        extra_typemap_modules => {
          'ExtUtils::Typemaps::STL::String' => '0',
        },
    );
}

1;
