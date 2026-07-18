{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "qnotero";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "ealbiter";
    repo = "qnotero";
    tag = "v${version}";
    sha256 = "sha256-Rym7neluRbYCpuezRQyLc6gSl3xbVR9fvhOxxW5+Nzo=";
  };

  propagatedBuildInputs = [
    python3Packages.pyqt5
    libsForQt5.wrapQtAppsHook
  ];

  # no tests executed
  doCheck = false;

  postInstall = ''
    mkdir $out/share
    mv $out/usr/share/applications $out/share/applications

    substituteInPlace $out/share/applications/qnotero.desktop \
      --replace "Icon=/usr/share/qnotero/resources/light/qnotero.png" "Icon=qnotero"

    mkdir -p $out/share/icons/hicolor/64x64/apps
    ln -s $out/usr/share/qnotero/resources/light/qnotero.png \
      $out/share/icons/hicolor/64x64/apps/qnotero.png
  '';

  preFixup = ''
    wrapQtApp "$out"/bin/qnotero
  '';

  format = "setuptools";

  patchPhase = ''
    substituteInPlace ./setup.py \
      --replace "/usr/share" "usr/share"

    substituteInPlace ./libqnotero/_themes/light.py \
       --replace "/usr/share" "$out/usr/share"
  '';

  meta = {
    description = "Quick access to Zotero references";
    homepage = "https://www.cogsci.nl/software/qnotero";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.nico202 ];
    platforms = lib.platforms.unix;
    mainProgram = "qnotero";
    broken = stdenv.hostPlatform.isDarwin; # Build fails even after adding cx-freeze to `buildInputs`
  };
}
