{
  lib,
  stdenv,
  # python dependencies
  acres,
  bash,
  buildPythonPackage,
  click,
  # optional-dependencies
  datalad,
  duecredit,
  etelemetry,
  fetchPypi,
  filelock,
  glibcLocales,
  hatch-vcs,
  # build-system
  hatchling,
  looseversion,
  lxml,
  networkx,
  nibabel,
  numpy,
  packaging,
  pandas,
  paramiko,
  prov,
  psutil,
  puremagic,
  pybids,
  pydot,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  rdflib,
  scipy,
  simplejson,
  sphinx,
  traits,
  # other dependencies
  which,
  xvfbwrapper,
}:

buildPythonPackage rec {
  pname = "nipype";
  version = "1.11.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZwfsTDz44Zg673+O6nlifue3q0qklkmZFVDhKcFlt6c=";
  };

  postPatch = ''
    substituteInPlace nipype/interfaces/base/tests/test_core.py \
      --replace-fail "/usr/bin/env bash" "${bash}/bin/bash"
    substituteInPlace nipype/pipeline/engine/tests/test_nodes.py \
      --replace-fail "/bin/bash" "${bash}/bin/bash"
  '';

  # checks on darwin inspect memory which doesn't work in build environment
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    glibcLocales
    pandas
    pytestCheckHook
    pytest-cov-stub
    pytest-xdist
    sphinx
    which
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    acres
    click
    etelemetry
    filelock
    looseversion
    lxml
    networkx
    nibabel
    numpy
    packaging
    prov
    puremagic
    pydot
    python-dateutil
    rdflib
    scipy
    simplejson
    traits
  ];

  pyproject = true;

  pythonImportsCheck = [
    "nipype"
    "nipype.algorithms"
    "nipype.interfaces"
  ];

  passthru.optional-dependencies = {
    data = [ datalad ];
    duecredit = [ duecredit ];
    profiler = [ psutil ];
    pybids = [ pybids ];
    ssh = [ paramiko ];
    xvfbwrapper = [ xvfbwrapper ];
  };

  meta = {
    description = "Neuroimaging in Python: Pipelines and Interfaces";
    homepage = "https://nipy.org/nipype";
    changelog = "https://github.com/nipy/nipype/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ashgillman ];
    mainProgram = "nipypecli";
  };
}
