{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ghostscript,
  gmt,
  ipython,
  numpy,
  packaging,
  pandas,
  pytest-mpl,
  pytestCheckHook,
  setuptools-scm,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "pygmt";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "GenericMappingTools";
    repo = "pygmt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yWB/IRu5B6hnu8e1TvpAaLehr1TMqvnDc5sRgyMw2mM=";
  };

  postPatch = ''
    substituteInPlace pygmt/clib/loading.py \
      --replace-fail "env.get(\"GMT_LIBRARY_PATH\")" "env.get(\"GMT_LIBRARY_PATH\", \"${gmt}/lib\")"
  '';

  postBuild = ''
    export HOME=$TMP
  '';

  # The *entire* test suite requires network access
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mpl
    ghostscript
    ipython
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    numpy
    pandas
    packaging
    xarray
  ];

  pyproject = true;
  pythonImportsCheck = [ "pygmt" ];

  meta = {
    description = "Python interface for the Generic Mapping Tools";
    homepage = "https://github.com/GenericMappingTools/pygmt";
    changelog = "https://github.com/GenericMappingTools/pygmt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
})
