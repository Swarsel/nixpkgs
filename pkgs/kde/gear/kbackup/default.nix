{
  libarchive,
  mkKdeDerivation,
  qt5compat,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kbackup";

  extraBuildInputs = [
    qt5compat
    libarchive
  ];

  extraNativeBuildInputs = [ shared-mime-info ];
  meta.mainProgram = "kbackup";
}
