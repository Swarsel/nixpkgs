{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  exiv2,
  gettext,
  gitUpdater,
  pkg-config,
  pytestCheckHook,
  setuptools,
  toml,
}:
buildPythonPackage (finalAttrs: {
  pname = "exiv2";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "jim-easterbrook";
    repo = "python-exiv2";
    tag = finalAttrs.version;
    hash = "sha256-3r0qGsCkfe2sQuXiCipXzW0vF2JRg77L1IcOiLTPslM=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    exiv2
    gettext
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "exiv2" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Low level Python interface to the Exiv2 C++ library";
    homepage = "https://github.com/jim-easterbrook/python-exiv2";
    changelog = "https://github.com/jim-easterbrook/python-exiv2/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zebreus ];
  };
})
