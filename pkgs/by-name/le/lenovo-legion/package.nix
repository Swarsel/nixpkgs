{
  lib,
  fetchFromGitHub,
  libxcb,
  nix-update-script,
  python3,
  qt6,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "lenovo-legion-app";
  version = "0.0.20-unstable-2026-05-12";

  src = fetchFromGitHub {
    owner = "johnfanv2";
    repo = "LenovoLegionLinux";
    rev = "7c19579d13ce686cf1e237699b9a78e80d03c977";
    hash = "sha256-gTlUrbNKCUQ+g70StlqspDn90wKW2scssKPZqaegzTY=";
  };

  postPatch = ''
    # only fixup application (legion-linux-gui), service (legiond) currently not installed so do not fixup
    # /etc
    substituteInPlace ./legion_linux/legion.py \
      --replace-fail "/etc/legion_linux" "$out/share/legion_linux"

    # /usr
    substituteInPlace ./legion_linux/legion_gui.desktop \
      --replace-fail "Icon=/usr/share/pixmaps/legion_logo.png" "Icon=legion_logo"
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3.pkgs; [
    setuptools
    qt6.wrapQtAppsHook
  ];

  dependencies = with python3.pkgs; [
    pyqt6
    qt6.qtbase
    argcomplete
    pillow
    pyyaml
    darkdetect
    libxcb
  ];

  dontWrapQtApps = true;
  pyproject = true;
  sourceRoot = "${src.name}/python/legion_linux";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Utility to control Lenovo Legion laptop";
    homepage = "https://github.com/johnfanv2/LenovoLegionLinux";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      ulrikstrid
      logger
      chn
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "legion_gui";
  };
}
