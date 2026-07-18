{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ffmpeg-headless,
  gitUpdater,
  hm,
  libtool,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kvazaar";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "ultravideo";
    repo = "kvazaar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Th30XO3m4GVeDvdb/RIwKT6+To9C/YU7y8s8hm7vPi0=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
  ];

  postPatch = ''
    substituteInPlace tests/util.sh --replace-fail '../libtool' '${lib.getExe libtool}'
    substituteInPlace tests/util.sh --replace-fail 'TAppDecoderStatic' '${lib.getExe' hm "TAppDecoder"}'

    chmod +x tests/util.sh
  '';

  nativeBuildInputs = [ cmake ];
  env.XFAIL_TESTS = lib.optionalString stdenv.hostPlatform.isDarwin "test_slices.sh";
  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    ffmpeg-headless
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Open-source HEVC encoder";
    homepage = "https://github.com/ultravideo/kvazaar";
    changelog = "https://github.com/ultravideo/kvazaar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "kvazaar" ];
  };
})
