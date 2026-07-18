{
  lib,
  fetchFromGitHub,
  buildPecl,
  rabbitmq-c,
}:

let
  version = "2.2.0";
in
buildPecl {
  inherit version;
  pname = "amqp";

  src = fetchFromGitHub {
    owner = "php-amqp";
    repo = "php-amqp";
    rev = "v${version}";
    sha256 = "sha256-HgwuQWxJFno24yo26qM30Qb8s3L9mYVntvMxC2MYxTk=";
  };

  buildInputs = [ rabbitmq-c ];
  env.AMQP_DIR = rabbitmq-c;

  meta = {
    description = "PHP extension to communicate with any AMQP compliant server";
    homepage = "https://github.com/php-amqp/php-amqp";
    changelog = "https://github.com/php-amqp/php-amqp/releases/tag/v${version}";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
