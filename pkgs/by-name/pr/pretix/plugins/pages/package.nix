{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pretix-plugin-build,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pretix-pages";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-pages";
    rev = "v${version}";
    hash = "sha256-whpO8aE0VUSrByf3P0JaIoruYbJi8wj4nZo/2tx+XLU=";
  };

  doCheck = false; # no tests

  build-system = [
    pretix-plugin-build
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretix_pages"
  ];

  meta = {
    description = "Plugin to add static pages to your pretix event";
    homepage = "https://github.com/pretix/pretix-pages";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
