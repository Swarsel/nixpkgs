{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "varlink";
  version = "32.1.0";

  src = fetchFromGitHub {
    owner = "varlink";
    repo = "python";
    tag = finalAttrs.version;
    hash = "sha256-cdTQ5OIhyPts3wuiyWZjEv9ItbHRlKbHd0nW0eAnj6s=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Python implementation of the Varlink protocol";
    homepage = "https://varlink.org/python";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jmbaur ];
  };
})
