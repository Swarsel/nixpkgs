{
  lib,
  stdenv,
  fetchurl,
  # runtime
  buildPackages,
  ffmpeg-headless,
  # build
  meson,
  ninja,
  # tests
  nixosTests,
  pkg-config,
  python3Packages,
  # docs
  sphinx,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unpaper";
  version = "7.0.0";

  src = fetchurl {
    url = "https://www.flameeyes.eu/files/unpaper-${finalAttrs.version}.tar.xz";
    hash = "sha256-JXX7vybCJxnRy4grWWAsmQDH90cRisEwiD9jQZvkaoA=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    buildPackages.libxslt.bin
    meson
    ninja
    pkg-config
    sphinx
  ];

  buildInputs = [
    ffmpeg-headless
  ];

  doCheck = true;

  nativeCheckInputs = with python3Packages; [
    pytest
    pytest-xdist
    pillow
  ];

  # Tests take quite a long time
  # Using pytest-xdist, we launch multiple workers
  # Restrict to max 6 to avoid having a large number of idlers
  preCheck = ''
    mesonCheckFlagsArray+=(--test-args "--numprocesses=auto --maxprocesses=6")
  '';

  passthru.tests = {
    inherit (nixosTests) paperless;
  };

  meta = {
    description = "Post-processing tool for scanned sheets of paper";
    homepage = "https://www.flameeyes.eu/projects/unpaper";
    changelog = "https://github.com/unpaper/unpaper/blob/unpaper-${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
    mainProgram = "unpaper";
  };
})
