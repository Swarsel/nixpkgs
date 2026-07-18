{
  lib,
  stdenv,
  fetchFromGitHub,
  acl,
  glibmm_2_68,
  gtk4,
  gtkmm4,
  itstool,
  meson,
  nautilus,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eiciel";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "rofirrim";
    repo = "eiciel";
    rev = finalAttrs.version;
    sha256 = "sha256-gpuxx1Ts9HCO+3C+Z3k1tVA+1Mip8/Bd+FvWisVdsVY=";
  };

  outputs = [
    "out"
    "nautilusExtension"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    itstool
    wrapGAppsHook4
    gtk4
  ];

  buildInputs = [
    acl
    glibmm_2_68
    gtkmm4
    nautilus
  ];

  mesonFlags = [
    "-Dnautilus-extension-dir=${placeholder "nautilusExtension"}/lib/nautilus/extensions-4"
  ];

  meta = {
    description = "Graphical editor for ACLs and extended attributes";
    homepage = "https://rofi.roger-ferrer.org/eiciel/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "eiciel";
  };
})
