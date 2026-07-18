{
  lib,
  appdirs,
  build,
  buildPythonPackage,
  fetchPypi,
  importlib-metadata,
  packaging,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pkg-about";
  version = "2.4.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-CqO4k49pEhjYKPtKC088wdT77WjEc8QH23uKBtfBR0g=";
    pname = "pkg_about";
  };

  # Unnecessarily requires the newest versions available for these
  postPatch = ''
    sed -i 's/"setuptools>=[^"]*"/"setuptools>=${setuptools.version}"/' pyproject.toml
    sed -i 's/"packaging>=[^"]*"/"packaging>=${packaging.version}"/' pyproject.toml
  '';

  nativeCheckInputs = [
    appdirs
    pytestCheckHook
  ];

  build-system = [
    packaging
    setuptools
  ];

  dependencies = [
    build
    importlib-metadata
    packaging
    typing-extensions
  ];

  # Tries and fails to install itself via pip
  disabledTests = [ "test_about_from_setup" ];
  pyproject = true;
  pythonImportsCheck = [ "pkg_about" ];

  meta = {
    description = "Python metadata sharing at runtime";
    homepage = "https://github.com/karpierz/pkg_about/";
    changelog = "https://github.com/karpierz/pkg_about/blob/${version}/CHANGES.rst";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ kip93 ];
  };
}
