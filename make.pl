#!/usr/bin/perl
use strict;
use warnings;
use v5.12;

use Template;
use IO::Dir;

my $tt = Template->new(
    INCLUDE_PATH => './templates',
    OUTPUT_PATH  => './',
    INTERPOLATE => 1,
);

my $vars = {
    author => 'Jakob Voß',
    title => 'Versioned Publications',
    repositories => [],
};

my $dir = IO::Dir->new('repos');
while (defined(my $file = $dir->read)) {
    next unless $file =~ /\d{4}$/ and -d "repos/$file";
    say $file;

    my $repo = {
        name => $file,
        forms => { },
    };

    # TODO: get metadata from about.yml if exists

    mkdir $file;
    `cp -rf repos/$file/img $file`;

    mkdir "$file/templates"; # FIXME
    `cp -f repos/$file/templates/*.css $file/templates/`; 

    foreach my $form (qw(paper slides)) {
        my $md = "repos/$file/$form.md";
        next unless -f $md;

        say "..$form";

        my @head = map { s/^%\s+//g; $_} grep { /^%/ } 
            do { local @ARGV="head -n3 $md|"; <> };

        $repo->{title}  //= $head[0];
        $repo->{author} //= $head[1];
        $repo->{date}   //= $head[2];

        chdir "repos/$file/";
        `make $form`;
        foreach my $type (qw(html pdf epub)) {
            my $filename = "$form.$type";
            next unless -f $filename;
        
            my $newfile = $file; # FIXME: nice title URL
            `cp $filename ../../$newfile`;

            my $forms = ($repo->{forms}->{$form} //= { });
            $forms->{$type} = {
                file => $filename,
                type => $type,
            };
        }
        chdir "../../";
    }

    push @{ $vars->{repositories} }, $repo;
}

$tt->process('index.html',$vars,'index.html')
    || die $Template::ERROR, "\n";
