{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  intltool,
  libtool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ddccontrol-db";
  version = "20260714";

  src = fetchFromGitHub {
    owner = "ddccontrol";
    repo = "ddccontrol-db";
    tag = finalAttrs.version;
    sha256 = "sha256-9X22Vt1LbaVLrjFqafnPPfsKQdLPBKxQR7cz75yqML0=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    intltool
    libtool
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = {
    description = "Monitor database for DDCcontrol";
    homepage = "https://github.com/ddccontrol/ddccontrol-db";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      pakhfn
      doronbehar
    ];

    platforms = lib.platforms.linux;
  };
})
