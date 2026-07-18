{
  mkKdeDerivation,
  pkg-config,
  qtdeclarative,
  systemd,
}:
mkKdeDerivation {
  pname = "kjournald";

  extraBuildInputs = [
    qtdeclarative
    systemd
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "kjournaldbrowser";
}
