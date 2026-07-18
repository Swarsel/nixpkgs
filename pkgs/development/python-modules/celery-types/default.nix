{
  lib,
  buildPythonPackage,
  fetchPypi,
  typing-extensions,
  uv-build,
}:

buildPythonPackage rec {
  pname = "celery-types";
  version = "0.26.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+jGBNv2tg/g/FTHe7Nn+Zktd///ynzwx6RIKRrjjkI8=";
    pname = "celery_types";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.18,<0.10.0" "uv_build"
  '';

  doCheck = false;
  build-system = [ uv-build ];
  dependencies = [ typing-extensions ];
  pyproject = true;

  meta = {
    description = "PEP-484 stubs for Celery";
    homepage = "https://github.com/sbdchd/celery-types";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
