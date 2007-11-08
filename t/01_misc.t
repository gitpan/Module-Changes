use strict;
use warnings;
use Test::More tests => 5;
use Module::Changes;
use Perl::Version;

my $changes = Module::Changes->make_object_for_type('entire');
isa_ok($changes, 'Module::Changes::Entire');

my $release = Module::Changes->make_object_for_type('release');
$release->author('Marcel Gruenauer <marcel@cpan.org>');
$release->version(Perl::Version->new('0.01'));
$release->touch_date;
isa_ok($release, 'Module::Changes::Release');

$changes->releases_unshift($release);
is_deeply($changes->newest_release, $release, 'it is the newest release');

my $formatter_yaml = Module::Changes->make_object_for_type('formatter_yaml');
isa_ok($formatter_yaml, 'Module::Changes::Formatter::YAML');

my $date = DateTime::Format::W3CDTF->new->format_datetime($release->date);
my $expected_yaml = sprintf <<'EOYAML', $date;
---
- global:
    name: ~
- v0.01:
    author: 'Marcel Gruenauer <marcel@cpan.org>'
    changes: []
    date: %s
    tags: []
EOYAML

is($formatter_yaml->format($changes), $expected_yaml, 'YAML output');
