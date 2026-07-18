{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  expat,
  glib,
  libmicrohttpd,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "stabber-unstable";
  version = "2026-03-05";

  src = fetchFromGitHub {
    owner = "profanity-im";
    repo = "stabber";
    rev = "ba6ca0707833c70ab38681bcc28bfff025c491f1";
    hash = "sha256-q3WfPjqD4AotdDukVMNg9Hz/Ns2PgBaoNk06sFm0E68=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    glib
    expat
    libmicrohttpd
  ];

  preAutoreconf = ''
    mkdir m4
  '';

  meta = {
    description = "Stubbed XMPP Server";
    homepage = "https://github.com/profanity-im/stabber";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ hschaeidt ];
    platforms = lib.platforms.unix;
    mainProgram = "stabber";
  };
}
