{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "npm-lockfile-fix";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "jeslie0";
    repo = "npm-lockfile-fix";
    rev = "v${finalAttrs.version}";
    hash = "sha256-P93OowrVkkOfX5XKsRsg0c4dZLVn2ZOonJazPmHdD7g=";
  };

  doCheck = false; # no tests

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    requests
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Add missing integrity and resolved fields to a package-lock.json file";
    homepage = "https://github.com/jeslie0/npm-lockfile-fix";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      felschr
    ];

    mainProgram = "npm-lockfile-fix";
  };
})
