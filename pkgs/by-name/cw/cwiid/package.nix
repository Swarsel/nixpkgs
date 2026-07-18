{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  bluez,
  flex,
  gtk2,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "cwiid";
  version = "unstable-2010-02-21";

  src = fetchFromGitHub {
    owner = "abstrakraft";
    repo = "cwiid";
    rev = "fadf11e89b579bcc0336a0692ac15c93785f3f82";
    sha256 = "0qdb0x757k76nfj32xc2nrrdqd9jlwgg63vfn02l2iznnzahxp0h";
  };

  patches = [
    ./fix-ar.diff
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
    flex
  ];

  buildInputs = [
    bluez
    gtk2
  ];

  configureFlags = [ "--without-python" ];

  env = {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
    NIX_LDFLAGS = "-lbluetooth";
  };

  postInstall = ''
    # Some programs (for example, cabal-install) have problems with the double 0
    sed -i -e "s/0.6.00/0.6.0/" $out/lib/pkgconfig/cwiid.pc
  '';

  hardeningDisable = [ "format" ];

  prePatch = ''
    sed -i -e '/$(LDCONFIG)/d' common/include/lib.mak.in
  '';

  meta = {
    description = "Linux Nintendo Wiimote interface";
    homepage = "http://cwiid.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bennofs ];
    platforms = lib.platforms.linux;
  };
}
