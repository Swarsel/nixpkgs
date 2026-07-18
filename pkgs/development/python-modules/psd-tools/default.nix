{
  lib,
  fetchFromGitHub,
  aggdraw,
  attrs,
  buildPythonPackage,
  cython,
  docopt,
  ipython,
  numpy,
  pillow,
  pytest-cov-stub,
  pytestCheckHook,
  scikit-image,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "psd-tools";
  version = "1.12.2";

  src = fetchFromGitHub {
    owner = "psd-tools";
    repo = "psd-tools";
    tag = "v${version}";
    hash = "sha256-YasCeRl9oF0ES1E9D7WXCOFTGKhQZltu7EPu6llndrM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    ipython
  ];

  build-system = [
    setuptools
    cython
  ];

  dependencies = [
    aggdraw
    attrs
    docopt
    numpy
    pillow
    scikit-image
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "psd_tools" ];

  meta = {
    description = "Python package for reading Adobe Photoshop PSD files";
    homepage = "https://github.com/kmike/psd-tools";
    changelog = "https://github.com/psd-tools/psd-tools/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "psd-tools";
  };
}
