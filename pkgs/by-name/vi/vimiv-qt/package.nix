{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3,
  qt5,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "vimiv-qt";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "karlch";
    repo = "vimiv-qt";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-28sk5qDVmrgXYX2wm5G8zv564vG6GwxNp+gjrFHCRfU=";
  };

  nativeBuildInputs = [
    installShellFiles
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ qt5.qtsvg ] ++ lib.optionals stdenv.hostPlatform.isLinux [ qt5.qtwayland ];

  postInstall = ''
    install -Dm644 misc/vimiv.desktop $out/share/applications/vimiv.desktop
    install -Dm644 misc/org.karlch.vimiv.qt.metainfo.xml $out/metainfo/org.karlch.vimiv.qt.metainfo.xml
    install -Dm644 LICENSE $out/licenses/vimiv/LICENSE
    install -Dm644 icons/vimiv.svg $out/icons/hicolor/scalable/apps/vimiv.svg
    installManPage misc/vimiv.1

    for i in 16 32 64 128 256 512; do
      install -Dm644 icons/vimiv_''${i}x''${i}.png $out/icons/hicolor/''${i}x''${i}/apps/vimiv.png
    done
  '';

  preFixup = ''
    wrapQtApp $out/bin/vimiv
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    pyqt5
    py3exiv2
  ];

  # Vimiv has to be wrapped manually because it is a non-ELF executable.
  dontWrapQtApps = true;
  pyproject = true;
  pythonImportsCheck = [ "vimiv" ];

  meta = {
    description = "Image viewer with Vim-like keybindings (Qt port)";
    homepage = "https://github.com/karlch/vimiv-qt";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dschrempf ];
    platforms = lib.platforms.all;
    mainProgram = "vimiv";
  };
})
