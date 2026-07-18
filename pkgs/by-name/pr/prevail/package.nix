{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  microsoft-gsl,
  pkg-config,
  replaceVars,
  yaml-cpp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prevail";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "vbpf";
    repo = "prevail";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qlQSoz9GE2Z2rzmrPIj+HnIQmNxiBSgvR40FR9psuDc=";
    fetchSubmodules = true;
  };

  patches = [
    (replaceVars ./remove-fetchcontent-usage.patch {
      # We will download them instead of cmake's fetchContent
      catch2Src = catch2_3.src;
      gslSrc = microsoft-gsl.src;
    })
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    boost
    yaml-cpp
  ];

  cmakeFlags = [
    (lib.cmakeBool "prevail_ENABLE_TESTS" finalAttrs.doCheck)
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    pushd ..
    bin/tests
    popd
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ../bin/prevail $out/bin/prevail

    runHook postInstall
  '';

  meta = {
    description = "eBPF verifier based on abstract interpretation";
    homepage = "https://github.com/vbpf/prevail";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "prevail";
  };
})
