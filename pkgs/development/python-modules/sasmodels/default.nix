{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  bumps,
  # build-system
  columnize,
  docutils,
  hatch-requirements-txt,
  hatch-sphinx,
  hatch-vcs,
  hatchling,
  matplotlib,
  numpy,
  opencl-headers,
  pycuda,
  pyopencl,
  # optional-dependencies
  # tests
  pytestCheckHook,
  scipy,
  siphash24,
  sphinx,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "sasmodels";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "SasView";
    repo = "sasmodels";
    tag = "v${version}";
    hash = "sha256-2AeFYFyK3jgJB/t4wMiHyKuKBD7CVLKl6cRSeICO+zQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"tccbox",' ""
  '';

  buildInputs = [ opencl-headers ];

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ optional-dependencies.full;

  build-system = [
    columnize
    hatch-requirements-txt
    hatch-sphinx
    hatch-vcs
    hatchling
    siphash24
    sphinx
  ];

  dependencies = [
    numpy
    scipy
  ];

  optional-dependencies = {
    cuda = [ pycuda ];

    full = [
      docutils
      bumps
      matplotlib
      columnize
    ];

    opencl = [ pyopencl ];
    server = [ bumps ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sasmodels" ];

  pythonRemoveDeps = [
    "tccbox" # unpackaged
  ];

  meta = {
    description = "Library of small angle scattering models";
    homepage = "https://github.com/SasView/sasmodels";
    changelog = "https://github.com/SasView/sasmodels/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rprospero ];
  };
}
