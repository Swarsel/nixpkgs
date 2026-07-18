{
  lib,
  fetchFromGitHub,
  git,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
let
  version = "1.1.11";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "committed";

  src = fetchFromGitHub {
    owner = "crate-ci";
    repo = "committed";
    tag = "v${version}";
    hash = "sha256-6uWiZRvR7QszZQbGwo+fPbKtr+wsIHVl6iomODz2cu0=";
  };

  cargoHash = "sha256-qV5WaszJ/VeC6XkgBim3IRmDCU7ieAIGl7Vr5t1F8Ow=";

  nativeCheckInputs = [
    git
  ];

  # Ensure libgit2 can read user.name and user.email for `git_signature_default`.
  # https://github.com/crate-ci/committed/blob/v1.1.5/crates/committed/tests/cmd.rs#L126
  preCheck = ''
    export HOME=$(mktemp -d)
    git config --global user.name nobody
    git config --global user.email no@where
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Nitpicking commit history since beabf39";
    homepage = "https://github.com/crate-ci/committed";
    changelog = "https://github.com/crate-ci/committed/blob/v${version}/CHANGELOG.md";

    license = [
      lib.licenses.asl20 # or
      lib.licenses.mit
    ];

    maintainers = [ lib.maintainers.pigeonf ];
    mainProgram = "committed";
  };
}
