#!usr/bin/perl -w 

use strict;
use Data::Dumper;
use Getopt::Long;

my ($file, $help, $single);
my (@return_list, @return);

GetOptions(
    "file:s" => \$file,
    "single" => \$single, 
    "help" => \$help,
) or die ("Error in command line arguments\n");

help_me() if ($help);

my $command = $file . '_commands.txt';
open(CMD, '>', $command);

if (-e $file){
    open(FILE, $file);
}else{
    print "$file does not exist\n";
    exit;
}

while (<FILE>){
    
    chomp;
    my $key;
    my @data = $_;
    my $id = $data[0];

    my $gms_list = "genome model list --nohead --filter model_groups.project.id=$id,name~'prod-refalign',config_profile_item.status=active -sh latest_build.id"; 
    my @return_list = `$gms_list`;
    chomp(@return_list);
    
    my $outfile = $id . '_model_list.txt';
    
    open(WRITE, '>', $outfile);

    if ($single){

        print CMD 'genome model list --nohead --filter model_groups.project.id='.$id.',name~\'prod-refalign\',config_profile_item.status=active -sh latest_build.id | xargs | sed \'s/ /\//g\' | xargs -n 1 -I BUILDS genome model metric list --filter name=haploid_coverage,build.id=BUILDS --show +model.name,model.subject.name,model.status,model.subject.common_name,build.instrument_data_association_set.count,build.merged_alignment_result.bam_path, > '.$id.'_qc.txt'."\n\n";    

        foreach $key (@return_list){
        print WRITE "$key\n";
        }

         my $gms_metric_list = "genome model metric list --filter name=haploid_coverage,build.id=" . join('/',@return_list) . " --show +model.name,model.subject.name,model.status,model.subject.common_name,build.instrument_data_association_set.count,build.merged_alignment_result.bam_path > $id.gms.summary";
    my $run = `$gms_metric_list`;

    }else{
 
        print CMD 'genome model list --nohead --filter model_groups.project.id='.$id.',name~\'prod-refalign\',config_profile_item.status=active -sh latest_build.id | xargs | sed \'s/ /\//g\' | xargs -n 1 -I BUILDS genome model metric list --filter name=haploid_coverage,build.id:BUILDS --show +model.name,model.subject.name,model.status,model.subject.common_name,build.instrument_data_association_set.count,build.merged_alignment_result.bam_path, > '.$id.'_qc.txt'."\n\n";    

    foreach $key (@return_list){
    print WRITE "$key\n";   
    }

    my $gms_metric_list = "genome model metric list --filter name=haploid_coverage,build.id:" . join('/',@return_list) . " --show +model.name,model.subject.name,model.status,model.subject.common_name,build.instrument_data_association_set.count,build.merged_alignment_result.bam_path > $id.gms.summary";
    my $run = `$gms_metric_list`;    

    }

}



close FILE;
close WRITE;

exit;

sub help_me {

    print"
    usage:
    perl gms_summary.pl --file=

    --file= input file (single column file with id entries)\n
    outputs ID.gms.summary file and ID_model_list.txt files\n
    --s will to run on files with single model id's\n\n
    ";
    exit;
}


