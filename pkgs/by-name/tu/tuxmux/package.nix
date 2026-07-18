{
  lib,
  fetchFromGitHub,
  installShellFiles,
  libiconv,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tuxmux";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "edeneast";
    repo = "tuxmux";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WcHsFKpYexBEg382837NqGgNMTKzVUG3XIER9aa1zK8=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [ libiconv ];
  cargoHash = "sha256-ceEF9ySxcU9vVZdNIogSiHbN/xYjudAoohy7jyeKrBU=";

  postInstall = ''
    installShellCompletion $releaseDir/../completions/tux.{bash,fish}
    installShellCompletion --zsh $releaseDir/../completions/_tux

    installManPage $releaseDir/../man/*
  '';

  meta = {
    description = "Tmux session manager";
    homepage = "https://github.com/edeneast/tuxmux";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ edeneast ];
    mainProgram = "tux";
  };
})
