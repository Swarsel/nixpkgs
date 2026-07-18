{
  cups,
  kdeclarative,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "print-manager";

  # FIXME: cups-smb?
  extraBuildInputs = [
    kdeclarative
    cups
  ];
}
