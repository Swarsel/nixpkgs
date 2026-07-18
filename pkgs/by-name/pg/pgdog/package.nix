{
  lib,
  fetchFromGitHub,
  clangStdenv,
  openssl,
  pkg-config,
  rustPlatform,
  useMoldLinker,
  versionCheckHook,
  withMold ? with clangStdenv.hostPlatform; isUnix && !isDarwin,
}:
let
  stdenv = if withMold then useMoldLinker clangStdenv else clangStdenv;
in
rustPlatform.buildRustPackage.override { inherit stdenv; } (finalAttrs: {
  pname = "pgdog";
  version = "0.1.48";

  src = fetchFromGitHub {
    owner = "pgdogdev";
    repo = "pgdog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0lun9HmJvpSWguckUtudDcNlBc/KgpHk/fBJnj4HSuo=";
  };

  # Hardcoded paths for C compiler and linker
  postPatch = ''
    rm .cargo/config.toml
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-cNIjTNuxHPofkTYpEb3+8Jhqz5AMAeXj7avNAAOG5D8=";
  # Several tests rely on networking
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoBuildFlags = [
    "--package"
    "pgdog"
  ];

  meta = {
    description = "PostgreSQL connection pooler, load balancer, and database sharder";
    homepage = "https://pgdog.dev/";
    changelog = "https://github.com/pgdogdev/pgdog/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ EpicEric ];
    platforms = lib.platforms.all;
    mainProgram = "pgdog";
  };
})
