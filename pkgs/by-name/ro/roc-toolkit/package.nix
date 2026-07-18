{
  lib,
  stdenv,
  fetchFromGitHub,
  gengetopt,
  libpulseaudio,
  libsndfile,
  libunwind,
  libuv,
  openfec,
  openssl,
  pkg-config,
  ragel,
  scons,
  sox,
  speexdsp,
  libsndfileSupport ? true,
  libunwindSupport ? lib.meta.availableOn stdenv.hostPlatform libunwind,
  openfecSupport ? true,
  opensslSupport ? true,
  pulseaudioSupport ? true,
  soxSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "roc-toolkit";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "roc-streaming";
    repo = "roc-toolkit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-53irDq803dTg0YqtC1SOXmYNGypSMAEK+9HJ65pR5PA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    scons
    ragel
    gengetopt
    pkg-config
  ];

  propagatedBuildInputs = [
    libuv
    speexdsp
  ]
  ++ lib.optional openfecSupport openfec
  ++ lib.optional libunwindSupport libunwind
  ++ lib.optional pulseaudioSupport libpulseaudio
  ++ lib.optional opensslSupport openssl
  ++ lib.optional soxSupport sox
  ++ lib.optional libsndfileSupport libsndfile;

  env = lib.optionalAttrs stdenv.hostPlatform.isFreeBSD {
    NIX_CFLAGS_COMPILE = "-D_XOPEN_SOURCE=700 -D__BSD_VISIBLE";
    NIX_LDFLAGS = "-lpthread";
  };

  sconsFlags =
    lib.optionals (!stdenv.hostPlatform.isDarwin) [
      "--build=${stdenv.buildPlatform.config}"
      "--host=${stdenv.hostPlatform.config}"
    ]
    ++ [ "--prefix=${placeholder "out"}" ]
    ++ lib.optional (!opensslSupport) "--disable-openssl"
    ++ lib.optional (!soxSupport) "--disable-sox"
    ++ lib.optional (!libunwindSupport) "--disable-libunwind"
    ++ lib.optional (!pulseaudioSupport) "--disable-pulseaudio"
    ++ lib.optional (!libsndfileSupport) "--disable-sndfile"
    ++ lib.optional stdenv.hostPlatform.isFreeBSD "--platform=unix"
    ++ (
      if (!openfecSupport) then
        [ "--disable-openfec" ]
      else
        [
          "--with-libraries=${openfec}/lib"
          "--with-openfec-includes=${openfec.dev}/include"
        ]
    );

  meta = {
    description = "Roc is a toolkit for real-time audio streaming over the network";
    homepage = "https://github.com/roc-streaming/roc-toolkit";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bgamari ];
    platforms = lib.platforms.unix;
  };
})
