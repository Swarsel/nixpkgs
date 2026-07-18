{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  versionCheckHook,
}:

let
  version = "2.9.0";
in
buildNpmPackage {
  inherit version;
  pname = "git-conventional-commits";

  src = fetchFromGitHub {
    owner = "qoomon";
    repo = "git-conventional-commits";
    tag = "v${version}";
    hash = "sha256-Mt99QTrWv+uuThL7tyM2wyOFj6/MrSKXg5ai0RNyyDE=";
  };

  npmDepsHash = "sha256-6Dgf6wx0G0Ev8IPrgHU/dTdRNvrtKa+Shdvv1IJolN4=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontNpmBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generate semantic versions, markdown changelogs, and validate commit messages";
    homepage = "https://github.com/qoomon/git-conventional-commits";
    changelog = "https://github.com/qoomon/git-conventional-commits/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ yzx9 ];
    mainProgram = "git-conventional-commits";
  };
}
