{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPecl,
  libiconv,
  pcre2,
  php,
}:

buildPecl rec {
  pname = "snuffleupagus";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "jvoisin";
    repo = "snuffleupagus";
    rev = "v${version}";
    hash = "sha256-14Hci2/f1kSV/lCAlFTNrv/WLJxeh+Wyf0QF0+xoedc=";
  };

  buildInputs = [
    pcre2
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  configureFlags = [ "--enable-snuffleupagus" ];
  internalDeps = with php.extensions; [ session ];

  postPhpize = ''
    ./configure --enable-snuffleupagus
  '';

  sourceRoot = "${src.name}/src";

  meta = {
    description = "Security module for php7 and php8 - Killing bugclasses and virtual-patching the rest";
    homepage = "https://github.com/jvoisin/snuffleupagus";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.zupo ];
    teams = [ lib.teams.php ];
  };
}
