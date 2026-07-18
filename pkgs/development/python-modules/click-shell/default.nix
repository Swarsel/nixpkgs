{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  pytest-click,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "click-shell";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "clarkperkins";
    repo = "click-shell";
    tag = version;
    hash = "sha256-4QpQzg0yFuOFymGiTI+A8o6LyX78iTJMqr0ernYbilI=";
  };

  nativeCheckInputs = [
    pytest-click
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ click ];
  pyproject = true;
  pythonImportsCheck = [ "click_shell" ];

  meta = {
    description = "Extension to click that easily turns your click app into a shell utility";

    longDescription = ''
      This is an extension to click that easily turns your click app into a
      shell utility. It is built on top of the built in python cmd module,
      with modifications to make it work with click. It adds a 'shell' mode
      with command completion to any click app.
    '';

    homepage = "https://github.com/clarkperkins/click-shell";
    changelog = "https://github.com/clarkperkins/click-shell/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ binsky ];
  };
}
