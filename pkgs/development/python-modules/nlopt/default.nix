{
  pkgs,
  python,
  toPythonModule,
}:
toPythonModule (
  pkgs.nlopt.override {
    python3 = python;
    python3Packages = python.pkgs;
    withPython = true;
  }
)
