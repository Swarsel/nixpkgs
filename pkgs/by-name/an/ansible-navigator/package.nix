{
  lib,
  ansible-lint,
  fetchPypi,
  podman,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ansible-navigator";
  version = "26.6.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-WyazCoFg4uPx0jLAG8u19l4dr806pQFzbYFadJwYfTM=";
    pname = "ansible_navigator";
  };

  # Tests want to run in tmux
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    ansible-builder
    ansible-runner
    jinja2
    jsonschema
    tzdata
    pyyaml
    onigurumacffi
    ansible-lint
    podman
  ];

  pyproject = true;
  pythonImportsCheck = [ "ansible_navigator" ];

  meta = {
    description = "Text-based user interface (TUI) for Ansible";
    homepage = "https://ansible.readthedocs.io/projects/navigator/";
    changelog = "https://github.com/ansible/ansible-navigator/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      melkor333
      ilkecan
    ];
  };
})
