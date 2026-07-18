{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python-dateutil,
  requests,
  setuptools,
  sqlalchemy,
  tqdm,
}:

buildPythonPackage rec {
  pname = "idbutils";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "tcgoetz";
    repo = "utilities";
    tag = version;
    hash = "sha256-niscY7sURrJ7YcPKbI6ByU03po6Hfxm0gHbvmDa6TgM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    sqlalchemy
    requests
    python-dateutil
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "idbutils" ];

  meta = {
    description = "Python utilities useful for database and internal apps";
    homepage = "https://github.com/tcgoetz/utilities";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
