{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  poetry-core,
  pybluez,
  pytestCheckHook,
  pyusb,
}:

buildPythonPackage rec {
  pname = "nxt-python";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "schodet";
    repo = "nxt-python";
    tag = version;
    hash = "sha256-ffJ7VhXT5I7i5JYfnjFBaud0CxoVBFWx6kRdAz+Ry00=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    pyusb
    pillow
  ];

  optional-dependencies = {
    bluetooth = [ pybluez ];
  };

  pyproject = true;
  pythonImportsCheck = [ "nxt" ];

  meta = {
    description = "Python driver/interface for Lego Mindstorms NXT robot";
    homepage = "https://github.com/schodet/nxt-python";
    changelog = "https://github.com/schodet/nxt-python/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ibizaman ];
  };
}
