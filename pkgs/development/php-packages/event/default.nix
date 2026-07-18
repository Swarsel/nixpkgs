{
  lib,
  buildPecl,
  libevent,
  openssl,
  php,
  pkg-config,
}:
buildPecl {
  pname = "event";
  version = "3.1.4";
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    libevent
  ];

  configureFlags = [
    "--with-event-libevent-dir=${libevent.dev}"
    "--with-event-core"
    "--with-event-extra"
    "--with-event-pthreads"
  ];

  internalDeps = [ php.extensions.sockets ];

  postPhpize = ''
    substituteInPlace configure --replace \
      'as_fn_error $? "Couldn'\'''t find $phpincludedir/sockets/php_sockets.h. Please check if sockets extension installed" "$LINENO" 5' \
      ':'
  '';

  sha256 = "sha256-XEyqc7wtzu4xCS/5GSE53yjpqA8RR63g3+hp2y5N39M=";

  meta = {
    description = "Efficiently schedule I/O, time and signal based events using the best I/O notification mechanism available";
    homepage = "https://bitbucket.org/osmanov/pecl-event/";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
