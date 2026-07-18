{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pidgin,
  xosd,
}:

stdenv.mkDerivation rec {
  pname = "pidgin-osd";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "edanaher";
    repo = "pidgin-osd";
    rev = "${pname}-${version}";
    sha256 = "07wa9anz99hnv6kffpcph3fbq8mjbyq17ij977ggwgw37zb9fzb5";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    xosd
    pidgin
  ];

  postInstall = ''
    mkdir -p $out/lib/pidgin
    mv $out/lib/pidgin-osd.{la,so} $out/lib/pidgin
  '';

  # autoreconf is run such that it *really* wants all the files, and there's no
  # default ChangeLog.  So make it happy.
  preAutoreconf = "touch ChangeLog";

  meta = {
    description = "Plugin for Pidgin which implements on-screen display via libxosd";
    homepage = "https://github.com/mbroemme/pidgin-osd";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
