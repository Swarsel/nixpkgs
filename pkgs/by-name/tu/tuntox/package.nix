{
  lib,
  stdenv,
  fetchFromGitHub,
  libtoxcore,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tuntox";
  version = "0.0.10.1-unstable-2025-08-27";

  src = fetchFromGitHub {
    owner = "gjedeer";
    repo = "tuntox";
    rev = "4c9fc50da3f7d7b3d5e3981ede66819644e1af0d";
    hash = "sha256-mqhCLIJOQfiSWi6iY56ZPQmXSLhdC/yX1KAItEz8sZo=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '$(shell git rev-parse HEAD)' "${finalAttrs.src.rev}"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libtoxcore
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  buildFlags = [ "tuntox_nostatic" ];

  meta = {
    description = "Tunnel TCP connections over the Tox protocol";
    homepage = "https://github.com/gjedeer/tuntox";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      willcohen
    ];

    platforms = lib.platforms.unix;
    mainProgram = "tuntox";
  };
})
