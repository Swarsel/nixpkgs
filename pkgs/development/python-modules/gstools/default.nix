{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  emcee,
  gstools-cython,
  hankel,
  hatch-vcs,
  hatchling,
  # optional dependencies
  matplotlib,
  meshio,
  numpy,
  pyevtk,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  pyvista,
  scipy,
}:

buildPythonPackage (finalAttrs: {
  pname = "gstools";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "GeoStat-Framework";
    repo = "GSTools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rQ7mSa1BWAaRiiE6aQD6jl8BktihY9bjFJV+5eT9n/M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    emcee
    gstools-cython
    hankel
    meshio
    numpy
    pyevtk
    scipy
  ];

  optional-dependencies = {
    plotting = [
      matplotlib
      pyvista
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "gstools" ];

  meta = {
    description = "Geostatistical toolbox";
    homepage = "https://github.com/GeoStat-Framework/GSTools";
    changelog = "https://github.com/GeoStat-Framework/GSTools/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
