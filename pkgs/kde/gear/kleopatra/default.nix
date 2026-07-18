{
  akonadi-mime,
  mkKdeDerivation,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kleopatra";
  extraBuildInputs = [ akonadi-mime ];
  extraNativeBuildInputs = [ shared-mime-info ];
}
