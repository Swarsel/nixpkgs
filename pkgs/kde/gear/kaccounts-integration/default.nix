{
  intltool,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kaccounts-integration";
  propagatedNativeBuildInputs = [ intltool ];
}
