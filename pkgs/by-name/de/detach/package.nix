{
  lib,
  stdenv,
  fetchzip,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "detach";
  version = "0.2.3";

  src = fetchzip {
    url = "https://inglorion.net/download/detach-${finalAttrs.version}.tar.bz2";
    hash = "sha256-nnhJGtmPlTeqM20FAKRyhhSMViTXFpQT0A1ol4lhsoc=";
  };

  nativeBuildInputs = [ installShellFiles ];
  makeFlags = [ "PREFIX=$(out)" ];
  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd detach \
      --zsh contrib/zsh-completer/_detach
  '';

  dontConfigure = true;

  meta = {
    description = "Utility for running a command detached from the current terminal";
    homepage = "https://inglorion.net/software/detach/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
    platforms = lib.platforms.unix;
    mainProgram = "detach";
  };
})
