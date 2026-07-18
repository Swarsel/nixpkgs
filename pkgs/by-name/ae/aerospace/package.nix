{
  lib,
  stdenv,
  fetchzip,
  gitUpdater,
  installShellFiles,
  versionCheckHook,
}:

let
  appName = "AeroSpace.app";
  version = "0.21.2-Beta";
in
stdenv.mkDerivation {
  inherit version;
  pname = "aerospace";

  src = fetchzip {
    url = "https://github.com/nikitabobko/AeroSpace/releases/download/v${version}/AeroSpace-v${version}.zip";
    sha256 = "sha256-+4n9di1NbPs5pttSEHPDzpHinfuSyWSx5CjNA9IOH+Q=";
  };

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv ${appName} $out/Applications
    cp -R bin $out
    mkdir -p $out/share
    runHook postInstall
  '';

  postInstall = ''
    installManPage manpage/*
    installShellCompletion --bash shell-completion/bash/aerospace
    installShellCompletion --fish shell-completion/fish/aerospace.fish
    installShellCompletion --zsh  shell-completion/zsh/_aerospace
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://github.com/nikitabobko/AeroSpace.git";
  };

  meta = {
    description = "i3-like tiling window manager for macOS";
    homepage = "https://github.com/nikitabobko/AeroSpace";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ alexandru0-dev ];
    platforms = lib.platforms.darwin;
    mainProgram = "aerospace";
  };
}
