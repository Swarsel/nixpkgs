{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "neocmakelsp";
  version = "0.10.4";

  src = fetchFromGitHub {
    owner = "neocmakelsp";
    repo = "neocmakelsp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HTyLLhpCDlWoOHllVsB6V6BGvRpFQgsx7KCOfRq5UhE=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-PA9KP17l9EVJQn9sUoZ02EZsw3xgiIMidDXk+tYdsIY=";

  postInstall = ''
    installShellCompletion --bash completions/bash/neocmakelsp
    installShellCompletion --fish completions/fish/neocmakelsp.fish
    installShellCompletion --zsh completions/zsh/_neocmakelsp
  '';

  meta = {
    description = "CMake lsp based on tower-lsp and treesitter";
    homepage = "https://github.com/neocmakelsp/neocmakelsp";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      wineee
      multivac61
    ];

    platforms = lib.platforms.unix;
    mainProgram = "neocmakelsp";
  };
})
