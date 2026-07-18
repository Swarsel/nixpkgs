{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libsass,
  pytestCheckHook,
  setuptools_80,
  werkzeug,
}:

buildPythonPackage (finalAttrs: {
  pname = "libsass";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "sass";
    repo = "libsass-python";
    tag = finalAttrs.version;
    hash = "sha256-CiSr9/3EDwpDEzu6VcMBAlm3CtKTmGYbZMnMEjyZVxI=";
  };

  buildInputs = [ libsass ];
  env.SYSTEM_SASS = "true";

  nativeCheckInputs = [
    pytestCheckHook
    werkzeug
  ];

  build-system = [ setuptools_80 ];
  enabledTestPaths = [ "sasstests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "sass" ];

  meta = {
    description = "Python binding for libsass to compile Sass/SCSS";
    homepage = "https://sass.github.io/libsass-python/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "pysassc";
    downloadPage = "https://github.com/sass/libsass-python";
  };
})
