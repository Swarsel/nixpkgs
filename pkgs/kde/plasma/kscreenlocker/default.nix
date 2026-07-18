{
  mkKdeDerivation,
  pam,
  qqc2-breeze-style,
  wayland-scanner,
}:
mkKdeDerivation {
  pname = "kscreenlocker";

  extraBuildInputs = [
    pam
    qqc2-breeze-style
  ];

  extraNativeBuildInputs = [ wayland-scanner ];
}
