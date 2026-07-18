{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-markupsafe";
  version = "1.1.10";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hbOocmg9Aq6jpawqjvWQGTw0QJIDL1hFcof7+OBnEbE=";
    pname = "types-MarkupSafe";
  };

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Typing stubs for MarkupSafe";
    homepage = "https://pypi.org/project/types-markupsafe";
    changelog = "https://github.com/typeshed-internal/stub_uploader/blob/main/data/changelogs/MarkupSafe.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nim65s ];
  };
}
