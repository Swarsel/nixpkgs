{
  lib,
  fetchPypi,
  glibcLocales,
  python3Packages,
  taskwarrior2,
}:

with python3Packages;

buildPythonApplication (finalAttrs: {
  pname = "vit";
  version = "2.3.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NGohCqDedUz3ra9zcjv30syO51Tut4XrGDcNM/dOXOI=";
  };

  nativeCheckInputs = [ glibcLocales ];

  preCheck = ''
    export TERM=''${TERM-linux}
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = [
    tasklib
    urwid
  ];

  disabled = lib.versionOlder python.version "3.7";

  makeWrapperArgs = [
    "--suffix"
    "PATH"
    ":"
    "${taskwarrior2}/bin"
  ];

  pyproject = true;
  pythonImportsCheck = [ "vit" ];

  meta = {
    description = "Visual Interactive Taskwarrior";
    homepage = "https://github.com/scottkosty/vit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arcnmx ];
    platforms = lib.platforms.all;
    mainProgram = "vit";
  };
})
