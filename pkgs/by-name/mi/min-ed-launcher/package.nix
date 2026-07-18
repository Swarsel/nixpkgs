{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  git,
}:
buildDotnetModule rec {
  pname = "min-ed-launcher";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "rfvgyhn";
    repo = "min-ed-launcher";
    tag = "v${version}";
    hash = "sha256-blqGq6PORBEtCLO007TR3xJ6UXX8nFSOIoFh8Dc/5B8=";
    leaveDotGit = true; # During build the current commit is appended to the version
  };

  buildInputs = [
    git # During build the current commit is appended to the version
  ];

  executables = [ "MinEdLauncher" ];
  nugetDeps = ./deps.json;
  projectFile = "MinEdLauncher.sln";

  meta = {
    description = "Minimal Elite Dangerous Launcher";
    homepage = "https://github.com/rfvgyhn/min-ed-launcher";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jiriks74 ];
    platforms = lib.platforms.x86_64;
    mainProgram = "MinEdLauncher";
  };
}
