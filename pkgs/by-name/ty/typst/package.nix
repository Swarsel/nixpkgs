{
  lib,
  fetchFromGitHub,
  callPackage,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "typst";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "typst";
    repo = "typst";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R8hgStbn/oWN+FklUkbuKnODTToRvvw3XSE0AxN/EG0=";
    leaveDotGit = true;

    postFetch = ''
      cd $out
      git rev-parse HEAD > COMMIT
      rm -rf .git
    '';
  };

  # Fix for "Found argument '--test-threads' which wasn't expected, or isn't valid in this context"
  postPatch = ''
    substituteInPlace tests/src/tests.rs --replace-fail \
      'ARGS.num_threads' \
      'ARGS.test_threads'
    substituteInPlace tests/src/args.rs --replace-fail \
      'num_threads' \
      'test_threads'

    export TYPST_COMMIT_SHA="$(cat COMMIT | cut -c1-8)"
  '';

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-g+w0fkATxnWNcLuNrEMzI52psPKXMrsWqnHgfXNc8tI=";

  env = {
    GEN_ARTIFACTS = "artifacts";
    OPENSSL_NO_VENDOR = true;
  };

  postInstall = ''
    installManPage crates/typst-cli/artifacts/*.1
    installShellCompletion \
      crates/typst-cli/artifacts/typst.{bash,fish} \
      --zsh crates/typst-cli/artifacts/_typst
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  cargoTestFlags = [ "--workspace" ];

  passthru = {
    packages = callPackage ./typst-packages.nix { };
    updateScript = nix-update-script { };
    withPackages = ps: finalAttrs.passthru.wrapper { packages = ps; };
    wrapper = callPackage ./wrapper.nix { };
  };

  meta = {
    description = "New markup-based typesetting system that is powerful and easy to learn";
    homepage = "https://github.com/typst/typst";
    changelog = "https://github.com/typst/typst/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kanashimia
      RossSmyth
      faukah
    ];

    mainProgram = "typst";
  };
})
