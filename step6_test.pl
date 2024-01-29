#!/usr/bin/perl -w
use strict;
use Statistics::ChisqIndep;

my $screen_file = shift or die "Usage: perl $0 <screening_file_from_step5> <background_file_from_step5>\n";
my $background_file = shift or die "Usage: perl $0 <screening_file_from_step5> <background_file_from_step5>\n";

my %hits = ();
my %gene2name = ();
my $total_sc = 0;
open( F, $screen_file ) or die "File $screen_file cannot be opened\n";
while ( <F> ) {
    chomp;
    my ( $chr, $start, $end, $reads, $strand, @arr ) = split /\t/;
    my %add = ();
    foreach my $hit ( @arr ) {
        my ( $type, $gene_id, $gene_name, $strand2 ) = split /\:/, $hit;
        $gene2name{$gene_id} = $gene_name unless exists( $gene2name{$gene_id} );
        if ( $type eq 'exon' ) {
            $add{$gene_id}++; #any insert hitting an exon is deleterious
        }
        elsif ( $type eq 'gene' ) {
            $add{$gene_id}++ if $strand eq $strand2; #only inserts on same strand as gene are deleterious
        }
        else {
            die "Wrong type in hit $hit";
        }
    }
    foreach my $gene_id ( keys %add ) {
        $hits{$gene_id}{sc}++;
        $total_sc++;
    }
}
close F;

my $total_bg = 0;
open( F, $background_file ) or die "File $background_file cannot be opened\n";
while ( <F> ) {
    chomp;
    my ( $chr, $start, $end, $reads, $strand, @arr ) = split /\t/;
    my %add = ();
    foreach my $hit ( @arr ) {
        my ( $type, $gene_id, $gene_name, $strand2 ) = split /\:/, $hit;
        $gene2name{$gene_id} = $gene_name unless exists( $gene2name{$gene_id} );
        if ( $type eq 'exon' ) {
            $add{$gene_id}++;
        }
        elsif ( $type eq 'gene' ) {
            $add{$gene_id}++; # inserts into both strands are counted for background
        }
        else {
            die "Wrong type in hit $hit";
        }
    }
    foreach my $gene_id ( keys %add ) {
        $hits{$gene_id}{bg}++;
        $total_bg++;
    }
}
close F;

my $outfile = $screen_file;
$outfile =~ s/\.txt$//;
open F, '>', $outfile.'_chisq.txt';
print F join("\t", 'Gene_id', 'Gene_name', 'gene_inactivations', 'others_inactivations', 'gene_hit_bg', 'others_hit_bg', 'chisq_pval' ), "\n";
foreach my $gene_id ( sort keys %hits ) {
    $hits{$gene_id}{sc} = 0 unless exists($hits{$gene_id}{sc});
    $hits{$gene_id}{bg} = 0 unless exists($hits{$gene_id}{bg});
    my $chi = Statistics::ChisqIndep->new();
    my @obs = ( [ $hits{$gene_id}{sc}, $total_sc - $hits{$gene_id}{sc} ], [ $hits{$gene_id}{bg}, $total_bg - $hits{$gene_id}{bg} ] );
    $chi->load_data( \@obs );
    my $gene_name = exists( $gene2name{$gene_id} ) ? $gene2name{$gene_id} : $gene_id;
    print F join("\t", $gene_id, $gene_name, $hits{$gene_id}{sc}, $total_sc - $hits{$gene_id}{sc}, $hits{$gene_id}{bg}, $total_bg - $hits{$gene_id}{bg}, $chi->{p_value} ), "\n";
}
close F;
