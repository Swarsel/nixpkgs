{
  lib,
  fetchPypi,
  python3Packages,
  xhost,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "exegol";
  version = "4.3.11";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-+LnZSFRW7EvG+cPwMStgO6qD4AjOGkLzCarXBrW3Aak=";
  };

  doCheck = true;
  build-system = with python3Packages; [ pdm-backend ];

  dependencies =
    with python3Packages;
    [
      pyyaml
      gitpython
      docker
      requests
      rich
      argcomplete
      tzlocal
    ]
    ++ [ xhost ];

  pyproject = true;
  pythonImportsCheck = [ "exegol" ];

  pythonRelaxDeps = [
    "argcomplete"
    "requests"
    "rich"
  ];

  meta = {
    description = "Fully featured and community-driven hacking environment";

    longDescription = ''
      Exegol is a community-driven hacking environment, powerful and yet
      simple enough to be used by anyone in day to day engagements. Exegol is
      the best solution to deploy powerful hacking environments securely,
      easily, professionally. Exegol fits pentesters, CTF players, bug bounty
      hunters, researchers, beginners and advanced users, defenders, from
      stylish macOS users and corporate Windows pros to UNIX-like power users.
    '';

    homepage = "https://github.com/ThePorgs/Exegol";
    changelog = "https://github.com/ThePorgs/Exegol/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      _0b11stan
      charB66
    ];

    mainProgram = "exegol";
  };
})
