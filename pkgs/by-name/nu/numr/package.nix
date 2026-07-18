{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "numr";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "nasedkinpv";
    repo = "numr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GmG6iGcN0Y+0YgUmV+sAtdnusNpuVKLUrzKklmz+dvs=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    openssl
  ];

  cargoHash = "sha256-SbgCF+m4dR2zPPJrVFxRLOOAyyjOSubXsYvzOa5tTyg=";
  env.OPENSSL_NO_VENDOR = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Text calculator inspired by Numi - natural language expressions, variables, unit conversions";
    homepage = "https://github.com/nasedkinpv/numr";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "numr";
  };
})
