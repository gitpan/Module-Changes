use strict;
use warnings;
use Test::More tests => 19;
use Module::Changes;
use Perl::Version;

my $changes = Module::Changes->make_object_for_type('entire');
isa_ok($changes, 'Module::Changes::Entire');
$changes->name('Foo-Bar');

my $author = 'Marcel Gruenauer <marcel@cpan.org>';
my $release = Module::Changes->make_object_for_type('release');
$release->author($author);
$release->version(Perl::Version->new('0.01'));

is($release->version_as_string, '0.01', 'version as string');

$release->touch_date;
isa_ok($release, 'Module::Changes::Release');

$changes->releases_unshift($release);
is_deeply($changes->newest_release, $release, 'it is the newest release');

my $formatter_yaml = Module::Changes->make_object_for_type('formatter_yaml');
isa_ok($formatter_yaml, 'Module::Changes::Formatter::YAML');

my $date = DateTime::Format::W3CDTF->new->format_datetime($release->date);
my $expected_yaml = sprintf <<'EOYAML', $date;
---
global:
  name: Foo-Bar
releases:
  - 0.01:
      author: 'Marcel Gruenauer <marcel@cpan.org>'
      changes: []
      date: %s
      tags: []
EOYAML

is($formatter_yaml->format($changes), $expected_yaml, 'YAML output');

my $parser = Module::Changes->make_object_for_type('parser_yaml');
my $changes2 = $parser->parse_string($expected_yaml);
is_deeply($changes2, $changes, 'same after formatting and parsing again');

$changes->add_new_subversion;
is($changes->releases_count, 2, 'now two releases');
is($changes->newest_release->author, $author, 'second release author');
is($changes->newest_release->version_as_string, '0.01.01',
    'second release version');

$changes->add_new_alpha;
is($changes->releases_count, 3, 'now three releases');
is($changes->newest_release->author, $author, 'third release author');
is($changes->newest_release->version_as_string, '0.01.01_01',
    'third release version');

$changes->add_new_version;
is($changes->releases_count, 4, 'now four releases');
is($changes->newest_release->author, $author, 'fourth release author');
is($changes->newest_release->version_as_string, '0.02',
    'fourth release version');

$changes->add_new_revision;
is($changes->releases_count, 5, 'now five releases');
is($changes->newest_release->author, $author, 'fifth release author');
is($changes->newest_release->version_as_string, '1.00',
    'fifth release version');

