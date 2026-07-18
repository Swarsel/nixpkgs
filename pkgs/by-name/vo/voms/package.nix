{
  lib,
  stdenv,
  fetchFromGitHub,
  # Native build inputs
  autoreconfHook,
  bison,
  # Build inputs
  expat,
  flex,
  gsoap,
  openssl,
  pkg-config,
  zlib,
  # Configuration overridable with .override
  # If not null, the builder will
  # create a new output "etc", move "$out/etc" to "$etc/etc"
  # and symlink "$out/etc" to externalEtc.
  externalEtc ? "/etc",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "voms";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "italiangrid";
    repo = "voms";
    rev = "v${finalAttrs.version}";
    hash = "sha256-odwaIGaiJEnxNeysScYknOTimpvvx1vhuHf82VGPoVg=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
  ]
  # `etc` output for default configurations that can optionally be
  # installed to /etc (system-wide) or profile-path>/etc.
  ++ lib.optional (externalEtc != null) "etc";

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    pkg-config
  ];

  buildInputs = [
    expat
    gsoap
    openssl
    zlib
  ];

  configureFlags = [
    "--with-gsoap-wsdl2h=${gsoap}/bin/wsdl2h"
    "--sysconfdir=${placeholder "out"}/etc"
  ];

  postFixup = lib.optionalString (externalEtc != null) ''
    moveToOutput etc "$etc"
    ln -s ${lib.escapeShellArg externalEtc} "$out/etc"
  '';

  postAutoreconf = ''
    # FHS patching
    substituteInPlace configure \
      --replace "/usr/bin/soapcpp2" "${gsoap}/bin/soapcpp2"

    # Tell gcc about the location of zlib
    # See https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=voms
    export GSOAP_SSL_PP_CFLAGS="$(pkg-config --cflags gsoapssl++ zlib)"
    export GSOAP_SSL_PP_LIBS="$(pkg-config --libs gsoapssl++ zlib)"
  '';

  preAutoreconf = ''
    mkdir -p aux src/autogen
  '';

  passthru = {
    inherit externalEtc;
  };

  meta = {
    description = "C/C++ VOMS server, client and APIs v2.x";
    homepage = "https://italiangrid.github.io/voms/";
    changelog = "https://github.com/italiangrid/voms/blob/master/ChangeLog";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      ShamrockLee
      veprbl
    ];

    platforms = lib.platforms.unix;
  };
})
