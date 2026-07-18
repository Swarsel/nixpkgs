{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  flock,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "enroot";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "enroot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Sw4kfsb0Gi21At2pU8lt5wIfCih7VZ7Zf9/62xBKKRU=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'git submodule update' 'echo git submodule update'
  '';

  nativeBuildInputs = [
    flock
  ];

  buildInputs = [
    bashInteractive
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "prefix=/"
  ];

  makeTarget = "install";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Simple yet powerful tool to turn traditional container/OS images into unprivileged sandboxes";
    homepage = "https://github.com/NVIDIA/enroot";
    changelog = "https://github.com/NVIDIA/enroot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "enroot";
  };
})
