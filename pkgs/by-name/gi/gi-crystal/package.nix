{
  lib,
  fetchFromGitHub,
  crystal,
  gitUpdater,
  gobject-introspection,
}:
crystal.buildCrystalPackage rec {
  pname = "gi-crystal";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "hugopl";
    repo = "gi-crystal";
    rev = "v${version}";
    hash = "sha256-+sc36YjaVKBkrg8Ond4hCZoObnSHIU/jyMRalZ+OAwk=";
  };

  patches = [
    ./src.patch
  ];

  nativeBuildInputs = [ gobject-introspection ];
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r * $out

    runHook postInstall
  '';

  doInstallCheck = false;
  buildTargets = [ "generator" ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "GI Crystal is a binding generator used to generate Crystal bindings for GObject based libraries using GObject Introspection";
    homepage = "https://github.com/hugopl/gi-crystal";
    maintainers = with lib.maintainers; [ sund3RRR ];
    mainProgram = "gi-crystal";
  };
}
