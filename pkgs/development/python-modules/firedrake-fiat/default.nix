{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  firedrake-ufl,
  nix-update-script,
  numpy,
  pytestCheckHook,
  recursivenodes,
  scipy,
  setuptools,
  symengine,
  sympy,
}:

buildPythonPackage (finalAttrs: {
  pname = "firedrake-fiat";
  version = "2026.4.0";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "fiat";
    tag = finalAttrs.version;
    hash = "sha256-aO4iFDwt9l5+s+96kjxja92OWnJb64OBpYXu6oxk51c=";
  };

  postPatch =
    let
      fiat-reference-data = fetchFromGitHub {
        hash = "sha256-Ylq5u3d54SnCiB3nLRkkQu7IkRVuMcUWPgIjn7SIQ0M=";
        owner = "firedrakeproject";
        repo = "fiat-reference-data";
        rev = "508bd755e024010f6fc691a36e51a8f4d7de7efe";
      };
    in
    ''
      ln -s ${fiat-reference-data} test/FIAT/regression/fiat-reference-data
    '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    sympy
    recursivenodes
    firedrake-ufl
    symengine
  ];

  pyproject = true;

  pytestFlags = [
    "--skip-download"
  ];

  pythonImportsCheck = [
    "FIAT"
    "finat"
    "finat.ufl"
    "gem"
  ];

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "([0-9.]+)"
      ];
    };
  };

  meta = {
    description = "FInite element Automatic Tabulator";
    homepage = "http://fenics-fiat.readthedocs.org/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ qbisi ];
    downloadPage = "https://github.com/firedrakeproject/fiat";
  };
})
