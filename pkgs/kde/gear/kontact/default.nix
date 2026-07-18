{
  akregator,
  kaddressbook,
  kmail,
  korganizer,
  mkKdeDerivation,
  qtwebengine,
  zanshin,
}:
mkKdeDerivation {
  pname = "kontact";

  extraBuildInputs = [
    qtwebengine
    akregator
    kaddressbook
    kmail
    korganizer
    zanshin
  ];

  meta.mainProgram = "kontact";
}
