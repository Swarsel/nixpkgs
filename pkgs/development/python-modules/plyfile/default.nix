{
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  numpy,
  # build-system
  pdm-backend,
  # tests
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "plyfile";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "dranjan";
    repo = "python-plyfile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uV5gwRb3LKPF+pPQt/m85mwgVGTaEwusJZVUbmxQrJg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ pdm-backend ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "plyfile" ];

  meta = {
    description = "NumPy-based text/binary PLY file reader/writer for Python";
    homepage = "https://github.com/dranjan/python-plyfile";
    maintainers = [ ];
  };
})
