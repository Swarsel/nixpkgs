{
  lib,
  buildPythonPackage,
  deprecation,
  fetchPypi,
  hatch-requirements-txt,
  packaging,
}:
buildPythonPackage rec {
  pname = "deprecation-alias";
  version = "0.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-pY0udEkceDTp0xh4jaYCcvovga64FLQFWkupCgpBdA8=";
    pname = "deprecation_alias";
  };

  build-system = [ hatch-requirements-txt ];

  dependencies = [
    deprecation
    packaging
  ];

  pyproject = true;

  meta = {
    description = "Wrapper around ‘deprecation’ providing support for deprecated aliases";
    homepage = "https://github.com/domdfcoding/deprecation-alias";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tyberius-prime ];
  };
}
