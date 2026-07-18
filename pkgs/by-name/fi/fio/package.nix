{
  lib,
  stdenv,
  fetchFromGitHub,
  cunit,
  gnuplot,
  libaio,
  libnbd,
  makeWrapper,
  pkg-config,
  python3,
  zlib,
  withGnuplot ? false,
  withLibnbd ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fio";
  version = "3.42";

  src = fetchFromGitHub {
    owner = "axboe";
    repo = "fio";
    tag = "fio-${finalAttrs.version}";
    hash = "sha256-v2A2mY0Lvoje632761urfR7h1KHVcGnVDaKOMjexqis=";
  };

  postPatch = ''
    substituteInPlace tools/plot/fio2gnuplot \
      --replace-fail /usr/share/fio $out/share/fio
  '';

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3.pkgs.wrapPython
  ];

  buildInputs = [
    cunit
    python3
    zlib
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) libaio
  ++ lib.optional withLibnbd libnbd;

  configureFlags = [
    "--disable-native"
  ]
  ++ lib.optional withLibnbd "--enable-libnbd";

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    ./unittests/unittest

    runHook postCheck
  '';

  postInstall = ''
    wrapPythonProgramsIn "$out/bin" "$out ''${pythonPath[*]}"
  '';

  # ./configure does not support autoconf-style --build=/--host=.
  # We use $CC instead.
  configurePlatforms = [ ];
  dontAddStaticConfigureFlags = true;
  enableParallelBuilding = true;

  makeWrapperArgs = lib.optionals withGnuplot [
    "--prefix PATH : ${lib.makeBinPath [ gnuplot ]}"
  ];

  pythonPath = [ python3.pkgs.six ];

  meta = {
    description = "Flexible IO Tester - an IO benchmark tool";
    homepage = "https://git.kernel.dk/cgit/fio/";
    changelog = "https://github.com/axboe/fio/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
