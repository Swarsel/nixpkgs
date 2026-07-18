{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fs,
  gitUpdater,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyfatfs";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "nathanhi";
    repo = "pyfatfs";
    tag = "v${version}";
    hash = "sha256-26b4EV3WERUqJ10VkYov3PDFhSBcfxCF79P8Eg5xpoM=";
  };

  postPatch = ''
    substituteInPlace ./pyproject.toml \
      --replace-fail 'setuptools ~= 67.8' setuptools \
      --replace-fail '"setuptools_scm[toml] ~= 7.1"' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ fs ];
  pyproject = true;
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Python based FAT12/FAT16/FAT32 implementation with VFAT support";
    homepage = "https://github.com/nathanhi/pyfatfs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vlaci ];
    platforms = lib.platforms.all;
  };
}
