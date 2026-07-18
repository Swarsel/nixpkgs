{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gobject-introspection,
  gtk3,
  pygobject3,
  pytest,
  setuptools,
  xvfb-run,
}:

buildPythonPackage rec {
  pname = "liblarch";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "getting-things-gnome";
    repo = "liblarch";
    rev = "v${version}";
    hash = "sha256-A2qChe2z6rAhjRVX5VoHQitebf/nMATdVZQgtlquuYg=";
  };

  buildInputs = [ gtk3 ];
  propagatedBuildInputs = [ pygobject3 ];

  nativeCheckInputs = [
    gobject-introspection # for setup hook
    gtk3
    pytest
  ];

  checkPhase = ''
    runHook preCheck
    ${xvfb-run}/bin/xvfb-run -s '-screen 0 800x600x24' pytest
    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Python library built to easily handle data structure such are lists, trees and acyclic graphs";
    homepage = "https://github.com/getting-things-gnome/liblarch";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ oyren ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/getting-things-gnome/liblarch/releases";
  };
}
