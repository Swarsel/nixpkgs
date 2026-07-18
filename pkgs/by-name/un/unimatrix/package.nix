{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "unimatrix";
  version = "0-unstable-2023-04-25";

  src = fetchFromGitHub {
    owner = "will8211";
    repo = "unimatrix";
    rev = "65793c237553bf657af2f2248d2a2dc84169f5c4";
    hash = "sha256-fiaVEc0rtZarUQlUwe1V817qWRx4LnUyRD/j2vWX5NM=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 ./unimatrix.py $out/bin/unimatrix

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  pyproject = false;

  meta = {
    description = ''Python script to simulate the display from "The Matrix" in terminal'';
    homepage = "https://github.com/will8211/unimatrix";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ anomalocaris ];
    mainProgram = "unimatrix";
  };
}
