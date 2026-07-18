{
  cmake,
  extra-cmake-modules,
  gtk3,
  hicolor-icon-theme,
  mkDerivation,
  qtsvg,
}:

mkDerivation {
  pname = "breeze-icons";
  outputs = [ "out" ]; # only runtime outputs

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    gtk3
  ];

  buildInputs = [ qtsvg ];

  propagatedBuildInputs = [
    hicolor-icon-theme
  ];

  postInstall = ''
    gtk-update-icon-cache "''${out:?}/share/icons/breeze"
    gtk-update-icon-cache "''${out:?}/share/icons/breeze-dark"
  '';

  dontDropIconThemeCache = true;
}
