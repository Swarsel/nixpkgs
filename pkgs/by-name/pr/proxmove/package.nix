{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "proxmove";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "ossobv";
    repo = "proxmove";
    rev = "v${version}";
    hash = "sha256-8xzsmQsogoMrdpf8+mVZRWPGQt9BO0dBT0aKt7ygUe4=";
  };

  preBuild = ''
    rm -R assets
    rm -R artwork
  '';

  checkPhase = ''
    runHook preCheck

    $out/bin/${pname} --version

    runHook postCheck
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    proxmoxer
  ];

  pyproject = true;

  meta = {
    description = "Proxmox VM migrator: migrates VMs between different Proxmox VE clusters";
    homepage = "https://github.com/ossobv/proxmove";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ AngryAnt ];
    platforms = lib.platforms.linux;
    mainProgram = "proxmove";
  };
}
