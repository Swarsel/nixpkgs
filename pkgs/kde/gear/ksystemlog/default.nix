{
  audit,
  mkKdeDerivation,
  pkg-config,
  qt5compat,
}:
mkKdeDerivation {
  pname = "ksystemlog";

  extraBuildInputs = [
    qt5compat
    audit
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "ksystemlog";
}
