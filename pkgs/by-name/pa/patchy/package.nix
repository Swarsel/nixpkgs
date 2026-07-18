{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
let
  version = "1.3.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "patchy";

  src = fetchFromGitHub {
    owner = "nik-rev";
    repo = "patchy";
    tag = "v${version}";
    hash = "sha256-7WAdfbnvsmaD8fMCJQ8dQenCDmLLxjVTj2DGcAhMxcg=";
  };

  cargoHash = "sha256-QaFIu7YVixQsDGL5fjQ3scKMyr0hw8lEWVc80EMTBB8=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Makes it easy to maintain personal forks";

    longDescription = ''
      Patchy makes it easy to declaratively manage personal forks by
      automatically merging pull request of your liking to have more
      features.
    '';

    homepage = "https://github.com/nik-rev/patchy";
    changelog = "https://github.com/nik-rev/patchy/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ louis-thevenet ];
    mainProgram = "patchy";
  };
}
