{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  varint,
}:

buildPythonPackage rec {
  pname = "py-multicodec";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "multiformats";
    repo = "py-multicodec";
    tag = "v${version}";
    hash = "sha256-0s2ICkPkfF+D7HRrnPS2IRm380UhdVg5NCS7VFTP1P4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    varint
  ];

  pyproject = true;
  pythonImportsCheck = [ "multicodec" ];

  meta = {
    description = "Compact self-describing codecs";
    homepage = "https://github.com/multiformats/py-multicodec";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
