#!/usr/bin/perl -w
use strict;

my $distance_to_exclude = 5;
my $min_reads_to_exclude = 1;

foreach my $file ( <*_anno.txt> ) {
    my %chrs = ();
    open F, $file;
    while ( <F> ) {
        chomp;
        my @arr = split /\t/;
        $chrs{$arr[0]} = 1;
    }
    close F;

    my $outfile = $file;
    $outfile =~ s/_anno\.txt$//;
    open F1, '>', $outfile.'_anno_filtered.txt';

    foreach my $target ( sort {$a<=>$b} keys %chrs ) {
        my %data = ();
        open F, $file;
        while ( <F> ) {
            chomp;
            my @arr = split /\t/;
            next unless $arr[0] eq $target;
            $data{ $arr[4]."\t".$arr[1]} = $arr[3]; 
        }
        close F;
    

AGAIN:
        foreach my $coord ( sort {$data{$b}<=>$data{$a}} keys %data) {
            my $change = 0;
            my ( $strand, $pos ) = split /\t/, $coord;
            foreach my $shift ( -$distance_to_exclude..-1,1..$distance_to_exclude ) {
                if ( exists($data{$strand."\t".($pos+$shift)} ) ) {
                    delete $data{$strand."\t".($pos+$shift)};
                    $change = 1;
                }
            }
            warn "Cleaned neighbours from $target $coord having $data{$coord} hits\n" if $change;
            goto AGAIN if $change;
        }

        open F, $file;
        while ( <F> ) {
            chomp;
            my @arr = split /\t/;
            next unless $arr[0] eq $target; 
            print F1 join( "\t", @arr), "\n" if $arr[3] > $min_reads_to_exclude and exists($data{ $arr[4]."\t".$arr[1]});
        }
        close F;
    }
    close F1;
}
