#!/usr/bin/env perl 
use warnings 'FATAL';
use strict;
use Test::More;
use above 'Genome';

my $infile = Genome::Sys->create_temp_file_path;
Genome::Sys->write_file($infile, "2849757\n");
Genome::Sys->shellcmd(cmd => "gms_sum.pl --file=$tempfile");
my $outfile = Genome::Sys->create_temp_file_path;
Genome::Sys->write_file($outfile, "PUT OUT\n");
Genome::Utility::Test::compare_ok('OUTFILE FROM SCRIPT', $outfile, 'gms file match test');
done_testing();

 