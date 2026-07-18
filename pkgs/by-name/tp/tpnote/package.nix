{
  lib,
  fetchFromGitHub,
  cmake,
  installShellFiles,
  nix-update-script,
  oniguruma,
  pkg-config,
  rustPlatform,
  tpnote,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tpnote";
  version = "1.26.6";

  src = fetchFromGitHub {
    owner = "getreu";
    repo = "tp-note";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ELRR2nIbkbD/WWS93lyHHYoPY/KLUBO9+/13UUFhA6Y=";
  };

  postPatch = ''
    # In these `Cargo.toml`s, local dependencies should be specified by path,
    # otherwise they will be looked up in vendored dependencies.
    substituteInPlace tpnote/Cargo.toml \
      --replace-fail 'tpnote-lib = { version =' 'tpnote-lib = { path = "../tpnote-lib", version ='

    substituteInPlace tpnote-lib/Cargo.toml \
      --replace-fail 'tpnote-html2md = { version =' 'tpnote-html2md = { path = "../tpnote-html2md", version ='
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    oniguruma
  ];

  cargoHash = "sha256-gFfESz0yn9AJ4QCujaUyXrFnxyHzqi3IX5Gg0Gma0DQ=";
  env.RUSTONIG_SYSTEM_LIBONIG = true;
  doCheck = true;

  postInstall = ''
    installManPage docs/build/man/man1/tpnote.1
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoTestFlags = [
    "--package"
    "tpnote-lib"
  ];

  # The `tpnote` crate has no unit tests. All tests are in `tpnote-lib`.
  checkType = "debug";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Markup enhanced granular note-taking";
    homepage = "https://blog.getreu.net/projects/tp-note/";
    changelog = "https://github.com/getreu/tp-note/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      getreu
      starryreverie
    ];

    mainProgram = "tpnote";
  };
})
