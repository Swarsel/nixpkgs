{
  lib,
  stdenv,
  fetchFromGitHub,
  pidgin,
}:

let
  version = "0.8";
in
stdenv.mkDerivation {
  inherit version;
  pname = "pidgin-xmpp-receipts";

  src = fetchFromGitHub {
    owner = "noonien-d";
    repo = "pidgin-xmpp-receipts";
    rev = "release_${version}";
    sha256 = "13kwaymzkymjsdv8q95byd173i4vanj211vgx9cm0y8ag2r3cjsb";
  };

  buildInputs = [ pidgin ];

  installPhase = ''
    mkdir -p $out/lib/pidgin/
    cp xmpp-receipts.so $out/lib/pidgin/
  '';

  meta = {
    description = "Message delivery receipts (XEP-0184) Pidgin plugin";
    homepage = "http://devel.kondorgulasch.de/pidgin-xmpp-receipts/";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
