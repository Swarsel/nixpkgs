{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "pygpoabuse";
  version = "0-unstable-2025-11-09";

  src = fetchFromGitHub {
    owner = "Hackndo";
    repo = "pyGPOAbuse";
    rev = "324a3c3075a7a6a5364b3cb8b3d2e0b755be9c76";
    hash = "sha256-DNdKKxE8UACZ5oEZ2iKuNvFrmpz+RCTYI0O5pCa5jIU=";
  };

  postInstall = ''
    mv $out/bin/pygpoabuse{.py,}
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    impacket
    msldap
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=master" ]; };

  meta = {
    description = "Partial python implementation of SharpGPOAbuse";
    homepage = "https://github.com/Hackndo/pyGPOAbuse";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ letgamer ];
    mainProgram = "pygpoabuse";
  };
}
