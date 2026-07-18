{
  mkKdeDerivation,
  python3,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kajongg";

  extraBuildInputs = [
    qtsvg
    python3
    python3.pkgs.twisted
  ];

  # FIXME: completely horked, is actually a Python app, needs a lot of fixing
  meta.broken = true;
}
