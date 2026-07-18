{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  bison,
  bzip2,
  flex,
  libpcap,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nfdump";
  version = "1.7.8";

  src = fetchFromGitHub {
    owner = "phaag";
    repo = "nfdump";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7e3gV/yibVU76BUeGAlwVbOUgDmj63eh1p9g4MM8YoM=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    flex
    libtool
    pkg-config
    bison
  ];

  buildInputs = [
    bzip2
    libpcap
  ];

  configureFlags = [
    "--enable-nsel"
    "--enable-sflow"
    "--enable-readpcap"
    "--enable-nfpcapd"
  ];

  preConfigure = ''
    # The script defaults to glibtoolize on darwin, so we pass the correct
    # name explicitly.
    LIBTOOLIZE=libtoolize ./autogen.sh
  '';

  meta = {
    description = "Tools for working with netflow data";

    longDescription = ''
      nfdump is a set of tools for working with netflow data.
    '';

    homepage = "https://github.com/phaag/nfdump";
    changelog = "https://github.com/phaag/nfdump/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ takikawa ];
    platforms = lib.platforms.unix;
  };
})
