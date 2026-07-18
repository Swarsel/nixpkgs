{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libopus,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libopusenc";
  version = "0.3";

  src = fetchFromGitLab {
    owner = "xiph";
    repo = "libopusenc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-n4wmIUyCNPpgHhyRpv4Xpw292M6XRFhQtuY77x6+7JA=";
    domain = "gitlab.xiph.org";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  postPatch = ''
    echo PACKAGE_VERSION="${finalAttrs.version}" > ./package_version
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [ libopus ];
  doCheck = true;
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Library for encoding .opus audio files and live streams";
    homepage = "https://www.opus-codec.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pmiddend ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libopusenc" ];
  };
})
