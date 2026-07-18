{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  # runtime dependencies
  decorator,
  knot-floer-homology,
  networkx,
  nix-update-script,
  python,
  # tests
  runCommand,
  sage,
  # build-time dependencies
  setuptools,
  snappy-15-knots,
  snappy-manifolds,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "spherogram";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "spherogram";
    tag = "${version}_as_released";
    hash = "sha256-zQoNuy2rj02GAuRNDufMwA/wQ4U8ZeIADb8LpIvMFOY=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m spherogram.test
    runHook postCheck
  '';

  build-system = [
    setuptools
    cython
  ];

  dependencies = [
    networkx
    decorator
    snappy-manifolds
    knot-floer-homology
  ];

  optional-dependencies.snappy-15-knots = [ snappy-15-knots ];
  pyproject = true;
  pythonImportsCheck = [ "spherogram" ];

  passthru.tests.sage =
    let
      sage' = sage.override {
        extraPythonPackages = ps: [ ps.spherogram ];
        requireSageTests = false;
      };
    in
    runCommand "spherogram-sage-tests"
      {
        nativeBuildInputs = [
          sage'
          writableTmpDirAsHomeHook
        ];
      }
      ''
        sage -python -m spherogram.test
        touch $out
      '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "(.*)_as_released"
    ];
  };

  meta = {
    description = "Spherical diagrams for 3-manifold topology";
    homepage = "https://snappy.computop.org/spherogram.html";
    changelog = "https://github.com/3-manifolds/Spherogram/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];
  };
}
