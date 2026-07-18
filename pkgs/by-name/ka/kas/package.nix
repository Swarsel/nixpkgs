{
  lib,
  fetchFromGitHub,
  kas,
  python3,
  testers,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "kas";
  version = "5.4";

  src = fetchFromGitHub {
    owner = "siemens";
    repo = "kas";
    tag = finalAttrs.version;
    hash = "sha256-wETe3VgG5ZEQjWXgcC/u42ZzzPIMqrBEcZmaDcK5yRY=";
  };

  patches = [ ./pass-terminfo-env.patch ];
  # Tests require network as they try to clone repos
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    setuptools # pkg_resources is imported during runtime
    kconfiglib
    jsonschema
    distro
    pyyaml
    gitpython
  ];

  pyproject = true;
  pythonImportsCheck = [ "kas" ];

  passthru.tests.version = testers.testVersion {
    command = "kas --version";
    package = kas;
  };

  meta = {
    description = "Setup tool for bitbake based projects";
    homepage = "https://github.com/siemens/kas";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bachp ];
  };
})
