{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-ipware";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "un33k";
    repo = "python-ipware";
    tag = "v${version}";
    hash = "sha256-S8/HbRztYGzrpLQRTHcvO7Zv3mNn/0+y5PNBYLpd++E=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "python_ipware" ];

  meta = {
    description = "Python package for server applications to retrieve client's IP address";
    homepage = "https://github.com/un33k/python-ipware";
    changelog = "https://github.com/un33k/python-ipware/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ e1mo ];
  };
}
