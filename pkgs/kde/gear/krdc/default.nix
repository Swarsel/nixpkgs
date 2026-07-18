{
  freerdp,
  fuse3,
  libssh,
  libvncserver,
  mkKdeDerivation,
  pkg-config,
  qtwayland,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "krdc";

  extraBuildInputs = [
    qtwayland
    libssh
    libvncserver
    freerdp
    fuse3
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
  ];

  meta.mainProgram = "krdc";
}
