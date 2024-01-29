#!/usr/bin/perl -w
use strict;

my $annotation_file = 'Homo_sapiens.GRCh38.111.gtf.gz';
die "No annotation file" unless -s $annotation_file;

warn "Loading annotation\n";
my %genes = ();
my %exons = ();
my $i = 0;
open F, 'gunzip -c '.$annotation_file.' |';
while ( <F> ) {
    next if m/^\#/;
    my ( $chr, $source, $feature, $start, $end, $score, $strand, $phase, $info ) = split /\t/;
    warn "$i records processed\n" if ++$i % 10_000 == 0; 
    if ( $feature eq 'gene' ) {
         my ( $gene_id ) = $info =~ m/gene_id \"([^\"]*)\"/;
         my ( $gene_name ) = $info =~ m/gene_name \"([^\"]*)\"/;
         $genes{$chr}{join( "\t", $start, $end, $gene_id, $gene_name, $strand) } = 1;
    }
    elsif ( $feature eq 'exon' ) {
         my ( $gene_id ) = $info =~ m/gene_id \"([^\"]*)\"/;
         my ( $gene_name ) = $info =~ m/gene_name \"([^\"]*)\"/;
         foreach my $pos ( $start .. $end ) {
             $exons{$chr}{$pos}{join( ":", $gene_id, $gene_name, $strand ) } = 1;
         }
    }
}
close F;

foreach my $bed ( <*.bed> ) {
    my $lib = $bed;
    $lib =~ s/\.bed$//;
    warn "Annotating $lib\n";
    open F, $bed;
    open F1, '>', $lib.'_anno.txt';
    while ( <F> ) {
        chomp;
        my ( $chr, $pos, $pos2, $count, $strand ) = split /\t/;
        $chr =~ s/^chr//;
        print F1 join( "\t", $chr, $pos, $pos2, $count, $strand );
        foreach my $record ( keys %{$genes{$chr}} ) {
            my ( $start, $end, $gene_id, $gene_name, $strand ) = split /\t/, $record;
            print F1 "\t", join( "\:", 'gene', $gene_id, $gene_name, $strand) if $start <= $pos2 and $pos2 <= $end;
        }
        foreach my $ov ( keys %{$exons{$chr}{$pos2}} ) {
            print F1 "\texon:",$ov;
        }
        print F1 "\n";
    }
    close F;
    close F1;
}
