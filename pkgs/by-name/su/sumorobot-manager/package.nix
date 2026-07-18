{
  lib,
  stdenv,
  fetchFromGitHub,
  dos2unix,
  python3Packages,
  qt5,
}:

stdenv.mkDerivation rec {
  pname = "sumorobot-manager";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "robokoding";
    repo = "sumorobot-manager";
    rev = "v${version}";
    sha256 = "07snhwmqqp52vdgr66vx50zxx0nmpmns5cdjgh50hzlhji2z1fl9";
  };

  nativeBuildInputs = [
    python3Packages.wrapPython
    qt5.wrapQtAppsHook
    dos2unix
  ];

  buildInputs = [ python3Packages.python ];

  installPhase = ''
    mkdir -p $out/opt/sumorobot-manager
    cp -r main.py lib res $out/opt/sumorobot-manager
    chmod -R 644 $out/opt/sumorobot-manager/lib/*
    mkdir $out/bin
    dos2unix $out/opt/sumorobot-manager/main.py
    makeQtWrapper $out/opt/sumorobot-manager/main.py $out/bin/sumorobot-manager \
      --chdir "$out/opt/sumorobot-manager"
  '';

  preFixup = ''
    patchShebangs $out/opt/sumorobot-manager/main.py
    wrapPythonProgramsIn "$out/opt" "''${pythonPath[*]}"
  '';

  dontBuild = true;

  pythonPath = with python3Packages; [
    pyqt5.dev
    pyserial
  ];

  meta = {
    description = "Desktop App for managing SumoRobots";
    homepage = "https://www.robokoding.com/kits/sumorobot/sumomanager/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "sumorobot-manager";
  };
}
