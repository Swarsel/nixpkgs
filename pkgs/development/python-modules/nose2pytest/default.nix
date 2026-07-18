{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  fissix,
  pytest,
  setuptools,
}:

let
  version = "1.0.12";
in

buildPythonPackage {
  inherit version;
  pname = "nose2pytest";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "nose2pytest";
    rev = "v${version}";
    hash = "sha256-BYyj2ZOZvWBpmzQACpmxAzCdQhlZlDYt+HLMdft+wYY=";
  };

  patches = [
    # Drop Python 3.6 and 3.7 support
    #
    # Relaxes the runtime check for Python < 3.12.
    (fetchpatch2 {
      hash = "sha256-BpazrsB4b1oMBx9OemdVxhj/Jqbc8RKv2GC6gqkdGK8=";
      url = "https://github.com/pytest-dev/nose2pytest/commit/75ff506aaf11b5e20672441730657ee7540387e1.patch?full_index=1";
    })
  ];

  # Tests depend on nose!
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    fissix
    pytest
  ];

  pyproject = true;
  pythonImportsCheck = [ "nose2pytest.assert_tools" ];

  meta = {
    description = "Scripts to convert Python Nose tests to PyTest";
    homepage = "https://github.com/pytest-dev/nose2pytest";
    license = lib.licenses.bsd3;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.emily ];
    mainProgram = "nose2pytest";
  };
}
