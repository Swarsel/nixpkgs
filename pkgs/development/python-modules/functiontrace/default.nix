{
  lib,
  buildPythonPackage,
  fetchPypi,
  functiontrace-server,
  setuptools,
  toml,
}:

buildPythonPackage rec {
  pname = "functiontrace";
  version = "0.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yRzcg8BDuwF74J2EYa/3GMkTaRGsx0WyDIQEWHwj12M=";
  };

  nativeBuildInputs = [
    setuptools
    toml
  ];

  # `functiontrace` needs `functiontrace-server` in its path.
  # Technically we also need this when running via a Python import, such as for
  # `python3 -m functiontrace`, but that's a less common use-case.
  postFixup = ''
    wrapProgram $out/bin/functiontrace \
      --prefix PATH : ${lib.makeBinPath [ functiontrace-server ]}
  '';

  pyproject = true;
  pythonImportsCheck = [ "functiontrace" ];

  meta = {
    description = "Python module for Functiontrace";
    homepage = "https://functiontrace.com";
    license = lib.licenses.prosperity30;

    maintainers = with lib.maintainers; [
      mathiassven
      tehmatt
    ];
  };
}
