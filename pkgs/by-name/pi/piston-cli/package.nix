{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "piston-cli";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Shivansh-007";
    repo = "piston-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5S+1YGoPMprWnlsTGGPHtlQT974TsFgct3jVPngTT1k=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'piston = "piston:main"' 'piston = "piston.cli:cli_app"'
  '';

  nativeCheckInputs = [ versionCheckHook ];

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = with python3Packages; [
    appdirs
    click
    coloredlogs
    more-itertools
    prompt-toolkit
    rich
    requests-cache
    pygments
    pyyaml
    more-itertools
  ];

  pyproject = true;
  pythonImportsCheck = [ "piston" ];

  pythonRelaxDeps = [
    "rich"
    "more-itertools"
    "PyYAML"
    "requests-cache"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/piston";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Piston api tool";
    homepage = "https://github.com/Shivansh-007/piston-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "piston";
  };
})
