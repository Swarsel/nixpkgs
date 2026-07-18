{
  lib,
  fetchFromGitHub,
  bash,
  nix-update-script,
  replaceVars,
  rust-jemalloc-sys,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pyrefly";
  version = "1.2.0-dev.2";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "pyrefly";
    tag = finalAttrs.version;
    hash = "sha256-IQOyAYSnQ8GTIWhfNr/fMQl/TP4v3/tcf72hyHzkfjk=";
  };

  patches = [
    (replaceVars ./fix-shebang.patch { bash = lib.getExe bash; })
  ];

  buildInputs = [ rust-jemalloc-sys ];
  cargoHash = "sha256-x2gKbMopAN9FJ276KhPQouvb6Gw1z3PY4RRCdhkuhmo=";

  # redirect tests writing to /tmp
  preCheck = ''
    export TMPDIR=$(mktemp -d)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildAndTestSubdir = "pyrefly";
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast type checker and IDE for Python";
    homepage = "https://github.com/facebook/pyrefly";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cybardev
      QuiNzX
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "pyrefly";
  };
})
