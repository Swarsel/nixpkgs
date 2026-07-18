{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  docutils,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxmp";
  version = "4.7.1";

  src = fetchFromGitHub {
    owner = "libxmp";
    repo = "libxmp";
    tag = "libxmp-${finalAttrs.version}";
    hash = "sha256-X+oIXTwlrLEl3n8gu5+LlNfIOBkZ02hiivrjTgVrqRk=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    docutils
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_STATIC" stdenv.hostPlatform.isStatic)
    (lib.cmakeBool "WITH_UNIT_TESTS" finalAttrs.doCheck)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "libxmp-(.*)"
    ];
  };

  meta = {
    description = "Extended module player library";

    longDescription = ''
      Libxmp is a library that renders module files to PCM data. It supports
      over 90 mainstream and obscure module formats including Protracker (MOD),
      Scream Tracker 3 (S3M), Fast Tracker II (XM), and Impulse Tracker (IT).
    '';

    homepage = "https://xmp.sourceforge.net/";
    changelog = "https://github.com/libxmp/libxmp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcin-serwin ];
    platforms = lib.platforms.all;
  };
})
