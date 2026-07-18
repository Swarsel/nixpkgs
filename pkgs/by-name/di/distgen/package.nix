{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "distgen";
  version = "2.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-EDRCGf4laHZs//E3w5FxlkuTfbVLxnaGmQF/xjwaKDQ=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytest
    mock
  ];

  checkPhase = ''
    runHook preCheck

    make test-unit PYTHON=${python3.executable}

    runHook postCheck
  '';

  build-system = with python3.pkgs; [
    setuptools
    argparse-manpage
  ];

  dependencies = with python3.pkgs; [
    distro
    jinja2
    six
    pyyaml
  ];

  pyproject = true;

  meta = {
    description = "Templating system/generator for distributions";
    homepage = "https://distgen.readthedocs.io";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bachp ];
    mainProgram = "dg";
  };
})
