{
  lib,
  fetchFromGitHub,
  python3Packages,
  unstableGitUpdater,
}:

python3Packages.buildPythonApplication {
  pname = "accelergy";
  version = "0.1-unstable-2025-05-26";

  src = fetchFromGitHub {
    owner = "Accelergy-Project";
    repo = "accelergy";
    rev = "6911d15686ee7efdceba7d95605102df4472ae3a";
    hash = "sha256-YgJbmxJfuw7jk+Ssj5r3cmJYSSepf7aw+Ti3a9brm6o=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pyyaml
    yamlordereddictloader
    pyfiglet
    ruamel-yaml
    deepdiff
    jinja2
  ];

  pyproject = true;

  passthru.updateScript = unstableGitUpdater {
    tagFormat = "v*";
    tagPrefix = "v";
  };

  meta = {
    description = "Architecture-level energy/area estimator for accelerator designs";
    homepage = "https://accelergy.mit.edu/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gdinh ];
  };
}
