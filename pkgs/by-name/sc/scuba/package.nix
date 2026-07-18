{
  lib,
  fetchFromGitHub,
  pkgsStatic,
  python3Packages,
}:

let
  version = "2.14.2";

  src = fetchFromGitHub {
    owner = "JonathonReinhart";
    repo = "scuba";
    tag = "v${version}";
    hash = "sha256-kYr7JyrwDDMJkazZ1cMZNkLo19stnOtc/gSp3nRWAuU=";
  };

  # This must be built statically because scuba will execute unknown docker environments
  scubainit = pkgsStatic.rustPlatform.buildRustPackage rec {
    inherit src version;
    pname = "scubainit";
    cargoHash = "sha256-YUYo2B5hzzmDeNiWUC+198Qbz+JPgUJfpAqyPWAXTRA=";
    sourceRoot = "${src.name}/scubainit";
  };
in
python3Packages.buildPythonPackage rec {
  inherit src version;
  pname = "scuba";

  postPatch = ''
    # Version detection fails
    # Patch in the version instead
    substituteInPlace scuba/version.py \
      --replace-fail "__version__ = get_version()" "__version__ = \"${version}\""

    # Disable calling cargo through the make file
    # scubainit has already been built
    substituteInPlace setup.py \
      --replace-fail "check_call([\"make\"])" "pass"
  '';

  preBuild = ''
    # Link scubainit into the build tree
    ln -s ${scubainit}/bin/scubainit scuba/scubainit
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    argcomplete
    pyyaml
  ];

  pyproject = true;

  meta = {
    description = "Simple Container-Utilizing Build Apparatus";
    homepage = "https://github.com/JonathonReinhart/scuba";
    changelog = "https://github.com/JonathonReinhart/scuba/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tbaldwin ];
    platforms = lib.platforms.linux;
    mainProgram = "scuba";
  };
}
