{
  lib,
  fetchFromGitHub,
  nixpkgs-openjdk-updater,
  pyright,
  python3Packages,
  ruff,
}:

python3Packages.buildPythonApplication {
  pname = "nixpkgs-openjdk-updater";
  version = "0.1.0";
  src = ./nixpkgs-openjdk-updater;

  nativeCheckInputs = [
    ruff
    pyright
    python3Packages.pytestCheckHook
  ];

  preCheck = ''
    ruff format --check
    ruff check
    pyright
  '';

  postCheck = ''
    $out/bin/nixpkgs-openjdk-updater --help >/dev/null
  '';

  build-system = [ python3Packages.hatchling ];

  dependencies = [
    python3Packages.pydantic
    python3Packages.pygithub
  ];

  pyproject = true;

  passthru.openjdkSource =
    {
      featureVersionPrefix,
      sourceFile,
    }:
    let
      sourceInfo = lib.importJSON sourceFile;
    in
    {
      src = fetchFromGitHub {
        inherit (sourceInfo)
          owner
          repo
          rev
          hash
          ;
      };

      updateScript = {
        command = [
          (lib.getExe nixpkgs-openjdk-updater)

          "--source-file"
          sourceFile

          "--owner"
          sourceInfo.owner

          "--repo"
          sourceInfo.repo

          "--feature-version-prefix"
          featureVersionPrefix
        ];

        supportedFeatures = [ "silent" ];
      };
    };

  meta = {
    description = "Updater for Nixpkgs OpenJDK packages";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.emily ];
    mainProgram = "nixpkgs-openjdk-updater";
  };
}
