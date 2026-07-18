{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  freefont_ttf,
  graphviz-nox,
  makeFontsConf,
  mock,
  pytest-cov-stub,
  pytest-mock,
  pytest7CheckHook,
  replaceVars,
  setuptools,
  writableTmpDirAsHomeHook,
  xdg-utils,
}:

buildPythonPackage rec {
  pname = "graphviz";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "xflr6";
    repo = "graphviz";
    tag = version;
    hash = "sha256-o6woY+UhbsJtUqIzYGXlC0Pw3su7WG4xlAKSslSADwI=";
  };

  patches = [
    (replaceVars ./paths.patch {
      graphviz = graphviz-nox;
      xdgutils = xdg-utils;
    })
    (fetchpatch {
      hash = "sha256-cZhNsQFi30uFpPXbEJHQ9eol7g6pdv6w8kp1GxLTBD4=";
      # python314 compat; https://github.com/xflr6/graphviz/pull/238
      url = "https://github.com/xflr6/graphviz/commit/7e0fae6d28792a628a25cadd4ec1582c7351a7a3.patch";
    })
  ];

  # Fontconfig error: Cannot load default config file
  env.FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ freefont_ttf ]; };
  # Too many failures due to attempting to connect to com.apple.fonts daemon
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    mock
    pytest-cov-stub
    pytest-mock
    pytest7CheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Simple Python interface for Graphviz";
    homepage = "https://github.com/xflr6/graphviz";
    changelog = "https://github.com/xflr6/graphviz/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
