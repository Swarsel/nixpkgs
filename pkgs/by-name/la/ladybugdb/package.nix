{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  python3,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ladybugdb";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "LadybugDB";
    repo = "ladybug";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3d0gsSLkO5Np6P4l8AEfEPvzMlkf2wYMCluAtDrwEDc=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/lbug";

  meta = {
    description = "Embeddable property graph database management system (fork of Kuzu)";
    homepage = "https://ladybugdb.com/";
    changelog = "https://github.com/LadybugDB/ladybug/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hamidr ];
    platforms = lib.platforms.all;
    mainProgram = "lbug";
  };
})
