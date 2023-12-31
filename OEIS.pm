#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# Edit: 16 September 2023
# https://github.com/trizen

# Check and use formulas defined in terms of OEIS sequences.

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::AnyNum;
use File::Basename        qw(dirname);
use File::Spec::Functions qw(catdir catfile);

my $main_dir = dirname(
                         File::Spec->file_name_is_absolute(__FILE__)
                       ? __FILE__
                       : File::Spec->rel2abs(__FILE__)
                      );

my $bfiles_dir = catdir($main_dir, 'bfiles');

if (not -d $bfiles_dir) {
    mkdir($bfiles_dir) or die "Can't create dir `$bfiles_dir`: $!";
}

my %cache;

sub parse_bfile ($bfile) {

    my %data;

    open my $fh, '<', $bfile or die "Can't open `$bfile`: $!";

    while (defined(my $line = <$fh>)) {

        $line =~ /\S/ or next;
        $line =~ /^#/ and next;

        my ($n, $k) = split(' ', $line);
        ($k // '') =~ /^[+-]?[0-9]+\z/ or next;
        $data{$n} = Math::AnyNum->new($k);
    }

    close $fh;

    return \%data;
}

sub mirror_url ($url, $file) {

    state $HAS_HTTPS_SUPPORT = eval {
        require LWP::UserAgent;
        require LWP::Protocol::https;
    };

    if (not $HAS_HTTPS_SUPPORT) {

        $url =~ s{^https://}{http://};

        state $http_tiny = do {
            require HTTP::Tiny;
            HTTP::Tiny->new(agent => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0",);
        };

        return $http_tiny->mirror($url, $file);
    }

    state $lwp = do {
        require LWP::UserAgent;
        LWP::UserAgent->new(
                            timeout       => 60,
                            show_progress => 1,
                            agent         => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0",
                            ssl_opts      => {verify_hostname => 1, SSL_version => 'TLSv1_3'},
                           );
    };

    $lwp->mirror($url, $file);
}

sub download_sequence ($id) {

    if (exists $cache{$id}) {
        return $cache{$id};
    }

    my $url   = sprintf("https://oeis.org/A%s/b%s.txt", $id, $id);
    my $bfile = catfile($bfiles_dir, "$id.txt");

    if (not -e $bfile) {
        mirror_url($url, $bfile);
    }

    $cache{$id} = parse_bfile($bfile);
}

our $AUTOLOAD;

sub AUTOLOAD ($n, $k = undef) {

    $AUTOLOAD =~ /::A([0-9]+)\z/ or die "unknown method: $AUTOLOAD";

    my $oeis_id = $1;
    my $len     = length($oeis_id);

    if ($oeis_id == 0 or $len > 6) {
        die "Invalid OEIS ID: $oeis_id";
    }

    if ($len < 6) {
        $oeis_id = sprintf("%06s", $oeis_id);
    }

    my $data = download_sequence($oeis_id);

    if (defined($k)) {
        $n = (($n * ($n + 1)) >> 1) + $k;
    }

    if (not exists $data->{$n}) {
        die "A$oeis_id($n) does not exist in the b-file...\n";
    }

    $data->{$n};
}

1;
