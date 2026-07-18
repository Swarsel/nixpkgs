{
  lib,
  fetchFromGitHub,
  libpcap,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "netwatch-tui";
  version = "0.26.1";

  src = fetchFromGitHub {
    owner = "matthart1983";
    repo = "netwatch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gJTJ8Fn/McFdzlITvSrmgnOKu2f+KOeA9KODkAljoV8=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libpcap ];
  cargoHash = "sha256-brCc2FjS/GvjCxHZFLFZaSeTIukIAkfGl/gtpmhShls=";
  nativeCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Real-time network diagnostics in your terminal.";
    homepage = "https://github.com/matthart1983/netwatch";
    changelog = "https://github.com/matthart1983/netwatch/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasrivera ];
    mainProgram = "netwatch";
  };
})
