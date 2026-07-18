{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "transaction";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "transaction";
    tag = version;
    hash = "sha256-8yvA2dvB69+EqsAa+hc93rgg6D64lcajl6JgFabhjwY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools<74" "setuptools"
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "transaction" ];

  meta = {
    description = "Transaction management";
    homepage = "https://transaction.readthedocs.io/";
    changelog = "https://github.com/zopefoundation/transaction/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
