{
  lib,
  fetchFromGitHub,
  libgit2,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tui-journal";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "AmmarAbouZor";
    repo = "tui-journal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ahjCfSodq4foBV3aBbU0FsSUrEo3wgvFYSBr/OClmpc=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    zlib
  ];

  cargoHash = "sha256-hbRSQ9iVmp0oKEK53y4IuU34WNgq+pRefNxFbP1DPVQ=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Your journal app if you live in a terminal";
    homepage = "https://github.com/AmmarAbouZor/tui-journal";
    changelog = "https://github.com/AmmarAbouZor/tui-journal/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "tjournal";
  };
})
