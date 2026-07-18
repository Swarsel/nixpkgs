{
  libwacom,
  mkKdeDerivation,
  pkg-config,
  xf86-input-wacom,
}:
mkKdeDerivation {
  pname = "wacomtablet";

  extraBuildInputs = [
    libwacom
    xf86-input-wacom
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "kde_wacom_tabletfinder";
}
