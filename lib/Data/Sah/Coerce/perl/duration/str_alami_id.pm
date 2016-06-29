package Data::Sah::Coerce::perl::duration::str_alami_id;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 2,
        enable_by_default => 0,
        might_die => 1,
        prio => 60, # a bit lower than normal
        precludes => [qr/\Astr_alami(_.+)?\z/, 'str_human'],
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};
    my $coerce_to = $args{coerce_to} // 'float(secs)';

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"DateTime::Format::Alami::ID"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my \$res = DateTime::Format::Alami::ID->new->parse_datetime_duration($dt, {format=>'combined'}) or die \"Can't coerce string '\".$dt.\"' to duration\"; ",
        ($coerce_to eq 'float(secs)' ? "\$res = \$res->{seconds}; " :
             $coerce_to eq 'DateTime::Duration' ? "\$res = \$res->{Duration}; " :
             (die "BUG: Unknown coerce_to '$coerce_to'")),
        "\$res }",
    );
    $res;
}

1;
# ABSTRACT: Coerce duration from string parsed by DateTime::Format::Alami::ID

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["duration", "x.perl.coerce_rules"=>["str_alami_id"]]
