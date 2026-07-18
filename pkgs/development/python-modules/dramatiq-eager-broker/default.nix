{
  lib,
  buildPythonPackage,
  dramatiq,
  fetchFromCodeberg,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage rec {
  pname = "dramatiq-eager-broker";
  version = "0.3.0";

  src = fetchFromCodeberg {
    owner = "yaal";
    repo = "dramatiq-eager-broker";
    tag = version;
    hash = "sha256-tz4Gy31y5oaTHFAzb5L7bg0AhG1U/JKDySGloA7/A/8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];
  dependencies = [ dramatiq ];
  pyproject = true;

  meta = {
    description = "An eager broker for Dramatiq that executes tasks synchronously and immediately, without queuing";
    homepage = "https://codeberg.org/yaal/dramatiq-eager-broker";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.erictapen ];
  };
}
