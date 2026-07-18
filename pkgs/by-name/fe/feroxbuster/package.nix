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

rustPlatform.buildRustPackage rec {
  pname = "feroxbuster";
  version = "2.13.1";

  src = fetchFromGitHub {
    owner = "epi052";
    repo = "feroxbuster";
    tag = "v${version}";
    hash = "sha256-x0oNgDEuRIHDUUSAiIgcjmm6NadyBFuvz/hOcqquM3g=";
  };

  nativeBuildInputs = [
    pkg-config
    versionCheckHook
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-kWRODW1BsnifEqGZj8jK5tUK/5zK1AIRSq3JSo6YmkI=";
  env.OPENSSL_NO_VENDOR = true;
  # Tests require network access
  doCheck = false;
  doInstallCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Recursive content discovery tool";
    homepage = "https://github.com/epi052/feroxbuster";
    changelog = "https://github.com/epi052/feroxbuster/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.unix;
    mainProgram = "feroxbuster";
  };
}
