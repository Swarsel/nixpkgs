{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "lexid";
  version = "2021.1006";

  src = fetchPypi {
    inherit pname version;
    sha256 = "509a3a4cc926d3dbf22b203b18a4c66c25e6473fb7c0e0d30374533ac28bafe5";
  };

  propagatedBuildInputs = [ click ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  prePatch = ''
    # Disable lib3to6, since we're only building this on 3.6+ anyway.
    substituteInPlace setup.py \
      --replace 'if any(arg.startswith("bdist") for arg in sys.argv):' 'if False:'
  '';

  meta = {
    description = "Micro library to increment lexically ordered numerical ids";
    homepage = "https://pypi.org/project/lexid/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kfollesdal ];
    mainProgram = "lexid_incr";
  };
}
