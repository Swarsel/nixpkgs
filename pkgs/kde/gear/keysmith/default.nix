{
  libsodium,
  mkKdeDerivation,
  pkg-config,
  qtsvg,
}:
mkKdeDerivation {
  pname = "keysmith";

  extraBuildInputs = [
    qtsvg
    libsodium
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "keysmith";
}
