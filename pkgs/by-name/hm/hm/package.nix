{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  fetchpatch,
  gitUpdater,
  llvmPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hm";
  version = "18.0";

  src = fetchFromGitLab {
    owner = "jvet";
    repo = "HM";
    tag = "HM-${finalAttrs.version}";
    hash = "sha256-zWBwrnCNKi2sIopdu2XQj/7IoTsJQzlcIFNNKM0glDQ=";
    domain = "vcgit.hhi.fraunhofer.de";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "-msse4.1" ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    llvmPackages.openmp
  ];

  cmakeFlags = [
    (lib.cmakeBool "HIGH_BITDEPTH" true)
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    [
      "-Wno-error=array-bounds"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "-Wno-error=bitwise-instead-of-logical"
      "-Wno-error=missing-braces"
      "-Wno-error=nontrivial-memcall"
    ]
  );

  installPhase = ''
    runHook preInstall

    install -Dm 755 -t $out/bin ../bin/umake/*/*/release/*

    runHook postInstall
  '';

  passthru = {
    updateScript = gitUpdater {
      ignoredVersions = "rc";
      rev-prefix = "HM-";
    };
  };

  meta = {
    description = "Reference software for HEVC";
    homepage = "https://vcgit.hhi.fraunhofer.de/jvet/HM";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.all;
  };
})
