{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "lazy-object-proxy";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "ionelmc";
    repo = "python-lazy-object-proxy";
    tag = "v${version}";
    hash = "sha256-80+QJlm2X2u0OGEkYbEsdg8OiAXLiBwrkVXOF9NBL+I=";
  };

  # Broken tests. Seem to be fixed upstream according to Travis.
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  pyproject = true;

  meta = {
    description = "Fast and thorough lazy object proxy";
    homepage = "https://github.com/ionelmc/python-lazy-object-proxy";
    license = with lib.licenses; [ bsd2 ];
  };
}
