{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchDebianPatch,
  gtk2,
  libnet,
  libpcap,
  ncurses,
  pkg-config,
  # enable remote admin interface
  enableAdmin ? false,
  # alpha version of GTK interface
  withGtk ? false,
}:

stdenv.mkDerivation {
  pname = "yersinia";
  version = "unstable-2022-11-20";

  src = fetchFromGitHub {
    owner = "tomac";
    repo = "yersinia";
    rev = "867b309eced9e02b63412855440cd4f5f7727431";
    sha256 = "sha256-VShg9Nzd8dzUNiqYnKcDzRgqjwar/8XRGEJCJL25aR0=";
  };

  patches = [
    (fetchDebianPatch {
      pname = "yersinia";
      version = "0.8.2";
      debianRevision = "2.3";
      hash = "sha256-qoD627fcIGmlWT2Uz+85tgIf7KtD11gtUu1N+Ol4T/A=";
      patch = "fix-ftbfs.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libpcap
    libnet
    ncurses
  ]
  ++ lib.optional withGtk gtk2;

  configureFlags = [
    "--with-pcap-includes=${lib.getDev libpcap}/include"
    "--with-libnet-includes=${lib.getDev libnet}/include"
  ]
  ++ lib.optional (!enableAdmin) "--disable-admin"
  ++ lib.optional (!withGtk) "--disable-gtk";

  makeFlags = [ "LDFLAGS=-lncurses" ];
  autoreconfPhase = "./autogen.sh";

  meta = {
    description = "Framework for layer 2 attacks";
    homepage = "https://github.com/tomac/yersinia";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ vdot0x23 ];
    # INSTALL and FAQ in this package seem a little outdated
    # so not sure, but it could work on openbsd, illumos, and freebsd
    # if you have a machine to test with, feel free to add these
    platforms = with lib.platforms; linux;
    mainProgram = "yersinia";
  };
}
