{
  lib,
  stdenv,
  fetchFromGitHub,
  lld,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aver";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "jasisz";
    repo = "aver";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LeI6qy+z8azrrgoskRq/hsk5t0PDydQ/yJNxYIB7I68=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ lld ];
  cargoHash = "sha256-Zqu56tBbKjWZmpRpPuK9JMexcajRcDzBW4AfTRAkPbs=";
  # some tests are generated, some take a long time, some need to be skipped
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  cargoBuildFlags = [
    "--workspace"
    "--bin=aver"
    "--bin=aver-lsp"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Programming language for auditable AI-written code";
    homepage = "https://github.com/jasisz/aver";
    changelog = "https://github.com/jasisz/aver/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Br1ght0ne ];
    mainProgram = "aver";
  };
})
