{
  lib,
  fetchFromGitHub,
  antlr4-python3-runtime,
  buildPythonPackage,
  colorama,
  gitUpdater,
  markdown,
  setuptools,
  setuptools-scm,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "systemrdl-compiler";
  version = "1.32.2";

  src = fetchFromGitHub {
    owner = "SystemRDL";
    repo = "systemrdl-compiler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1Dx6WxSzGaZxwRzXR/bjfZSU7TsvTYNVN0NaK3qQ7eo=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    antlr4-python3-runtime
    colorama
    markdown
    typing-extensions
  ];

  pyproject = true;
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "SystemRDL 2.0 language compiler front-end";
    homepage = "https://systemrdl-compiler.readthedocs.io/en/stable/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jmbaur ];
  };
})
