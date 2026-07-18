{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nixosTests,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ssh-audit";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "jtesta";
    repo = "ssh-audit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JWhKtQk9jLumblM3eKchPtlqeGgM+/NW7jZ7+dq6w3Y=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  postInstall = ''
    installManPage $src/ssh-audit.1
  '';

  build-system = with python3Packages; [ setuptools ];
  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) ssh-audit;
  };

  meta = {
    description = "Tool for ssh server auditing";
    homepage = "https://github.com/jtesta/ssh-audit";
    changelog = "https://github.com/jtesta/ssh-audit/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      tv
      SuperSandro2000
    ];

    platforms = lib.platforms.all;
    mainProgram = "ssh-audit";
  };
})
