{
  lib,
  brotli,
  buildPythonPackage,
  pkgconfig,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  inherit (brotli) version src;
  pname = "brotli";

  buildInputs = [
    brotli
  ];

  env.USE_SYSTEM_BROTLI = 1;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    pkgconfig
    setuptools
  ];

  # only returns information how to really build
  dontConfigure = true;
  enabledTestPaths = [ "python/tests" ];
  pyproject = true;

  meta = {
    description = "Generic-purpose lossless compression algorithm";
    homepage = "https://github.com/google/brotli";
    changelog = "https://github.com/google/brotli/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
  };
}
