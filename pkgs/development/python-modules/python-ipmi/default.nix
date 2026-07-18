{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-ipmi";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "kontron";
    repo = "python-ipmi";
    tag = version;
    hash = "sha256-9xPnLNyHKvVebRM/mIoEVzhT2EwmgJxCTztLSZrnXVc=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "version=version," "version='${version}',"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyipmi" ];

  meta = {
    description = "Python IPMI Library";
    homepage = "https://github.com/kontron/python-ipmi";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ipmitool.py";
  };
}
