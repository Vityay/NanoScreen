#!/usr/bin/perl -w
use strict;

foreach my $bam ( <*_srt.bam> ) {
    my %peaks = ();
    my $lib = $bam;
    $lib =~ s/\_srt\.bam$//;
    my $i = 0;
    warn "Busy with $lib\n";
    open F, 'samtools view -q 20 '.$bam.' |';
    while ( <F> ) {
        my ( $name, $mflag, $chr, $pos, $mapq, $cigar ) = split /\t/;
        next unless $mflag == 0 or $mflag == 16;
        warn $i, ' done', "\n" if ++$i % 1_000_000 == 0;
        my $pos2 = $pos-1;
        my $strand = '+';
        if ( $mflag & 16 ) { # minus strand
            die "cigar $cigar" unless $cigar =~ m/^[\dMIDS]+$/;
            while ( $cigar =~ m/(\d+)([MIDS])/g ) {
               $pos2 += $1 if $2 eq 'M' or $2 eq 'D';
            }
            $strand = '-';
            $pos = $pos2;
        }
        $peaks{$chr}{$pos}{$strand}++;
    }
    close F;
    
    open F, '>', $lib.'_peaks.bed';
    foreach my $chr ( sort {$a<=>$b} keys %peaks ) {
        foreach my $pos ( sort {$a<=>$b} keys %{$peaks{$chr}} ) {
            foreach my $strand ( keys %{$peaks{$chr}{$pos}} ) {
                print F join( "\t", 'chr'.$chr, $pos-1, $pos, $peaks{$chr}{$pos}{$strand}, $strand ), "\n";
            }
        }
    }
    close F;
}
