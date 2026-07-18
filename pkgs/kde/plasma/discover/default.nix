{
  discount,
  flatpak,
  fwupd,
  mkKdeDerivation,
  pkg-config,
  qcoro,
  qtwebview,
}:
mkKdeDerivation {
  pname = "discover";
  # The PackageKit backend doesn't work for us and causes Discover
  # to freak out when loading. Disable it to not confuse users.
  excludeDependencies = [ "packagekit-qt" ];

  extraBuildInputs = [
    qtwebview

    qcoro

    discount
    flatpak
    fwupd
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
