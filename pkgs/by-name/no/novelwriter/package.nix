{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  python3,
  qt6,
}:
let
  version = "26.1";
in
python3.pkgs.buildPythonApplication {
  inherit version;
  pname = "novelwriter";

  src = fetchFromGitHub {
    owner = "vkbo";
    repo = "novelWriter";
    tag = "v${version}";
    hash = "sha256-vvJTEfqkxnh7TWnqBtT39nVyVTVQyAKVI6fDjOiiuPk=";
  };

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];
  buildInputs = [ qt6.qtbase ];

  # See setup/debian/install
  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/share/icons
    cp -r setup/data/hicolor $out/share/icons

    install -Dm644 setup/data/novelwriter.desktop -t $out/share/applications
    install -Dm644 setup/data/x-novelwriter-project.xml -t $out/share/mime/packages
  '';

  postFixup = ''
    wrapQtApp $out/bin/novelwriter
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    pyqt6
    pyenchant
    qt6.qtsvg
  ];

  dontWrapQtApps = true;
  pyproject = true;

  passthru.updateScript = nix-update-script {
    # Stable releases only
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Open source plain text editor designed for writing novels";
    homepage = "https://novelwriter.io";
    changelog = "https://github.com/vkbo/novelWriter/blob/main/CHANGELOG.md";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "novelwriter";
    broken = stdenv.hostPlatform.isDarwin; # TODO awaiting build instructions for Darwin
  };
}
