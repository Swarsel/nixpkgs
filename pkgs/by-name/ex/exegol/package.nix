{
  lib,
  fetchFromGitHub,
  python3Packages,
  xhost,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "exegol";
  version = "5.1.10";

  src = fetchFromGitHub {
    owner = "ThePorgs";
    repo = "Exegol";
    tag = finalAttrs.version;
    hash = "sha256-iyzTBZHOzr6CfZDqHvycdWZply/BXH7kESaO5pDLBMY=";
  };

  doCheck = true;
  __structuredAttrs = true;
  build-system = with python3Packages; [ pdm-backend ];

  dependencies =
    with python3Packages;
    [
      argcomplete
      cryptography
      docker
      gitpython
      ifaddr
      pydantic
      pyjwt
      pyyaml
      requests
      rich
      supabase
    ]
    ++ pyjwt.optional-dependencies.crypto
    ++ [ xhost ]
    ++ lib.optionals (!stdenv.hostPlatform.isLinux) [
      tzlocal
    ];

  pyproject = true;
  pythonImportsCheck = [ "exegol" ];

  pythonRelaxDeps = [
    "argcomplete"
    "cryptography"
    "requests"
    "rich"
    "supabase"
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
    changelog = "https://github.com/ThePorgs/Exegol/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      gpl3Only
      {
        # Please use exegol4 if you prefer to avoid the unfree version of Exegol.
        free = false;
        fullName = "Exegol Software License (ESL) - Version 1.0";
        redistributable = false;
        url = "https://docs.exegol.com/legal/software-license";
      }
    ];

    maintainers = with lib.maintainers; [
      _0b11stan
      charB66
      macbucheron
    ];

    mainProgram = "exegol";
  };
})
