{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "check-esxi-hardware";
  version = "20250716";

  src = fetchFromGitHub {
    owner = "Napsty";
    repo = "check_esxi_hardware";
    tag = version;
    hash = "sha256-tw1b2ZmkEIdlqov4JoEDc8cR2AmAiZWocKjir4AFIv0=";
  };

  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 check_esxi_hardware.py $out/bin/check_esxi_hardware
    install -Dm644 -t $out/share/doc/${pname} README.md

    runHook postInstall
  '';

  dependencies = with python3Packages; [
    packaging
    pywbem
    requests
    setuptools
  ];

  dontBuild = true;
  pyproject = false;

  meta = {
    homepage = "https://github.com/Napsty/check_esxi_hardware";
    changelog = "https://github.com/Napsty/check_esxi_hardware/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "check_esxi_hardware";
  };
}
