{
  lib,
  stdenv,
  fetchFromGitHub,
  binutils,
  fetchpatch,
  gnugrep,
  makeBinaryWrapper,
  php,
  phpPackages,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "phpspy";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "adsr";
    repo = "phpspy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QphoDdnSFPVRvEro0WDUC/yRsOf4I5p5BpHq32olqJI=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-IMO9GV0Z8PDEAVhLevg5jGh/PHcbNq3f3fMGFaKoLL4=";
      url = "https://github.com/adsr/phpspy/commit/8854e60ac38cfd2455d4a3d797f283eb3940cb7b.patch";
    })
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
    php.unwrapped
  ];

  env.USE_ZEND = 1;

  installPhase = ''
    runHook preInstall

    install -Dt "$out/bin" phpspy stackcollapse-phpspy.pl

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/phpspy" \
      --prefix PATH : "${
        lib.makeBinPath [
          gnugrep
          # for objdump
          binutils
        ]
      }"
  '';

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "phpspy -v";
    package = phpPackages.phpspy;
  };

  meta = {
    description = "Low-overhead sampling profiler for PHP";
    homepage = "https://github.com/adsr/phpspy";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "phpspy";
  };
})
