{
  lib,
  buildPecl,
  pcre2,
  rdkafka,
}:

buildPecl {
  pname = "rdkafka";
  version = "6.0.5";

  buildInputs = [
    rdkafka
    pcre2
  ];

  hash = "sha256-Cva2ZcljyMfREJzsc4A0N42ciGPL9hLAvTI15RmnCPE=";

  postPhpize = ''
    substituteInPlace configure \
      --replace-fail 'SEARCH_PATH="/usr/local /usr"' 'SEARCH_PATH=${lib.getInclude rdkafka}'
  '';

  meta = {
    description = "Kafka client based on librdkafka";
    homepage = "https://github.com/arnaud-lb/php-rdkafka";
    license = lib.licenses.mit;
    teams = [ lib.teams.php ];
  };
}
