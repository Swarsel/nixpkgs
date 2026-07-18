{
  lib,
  extra-cmake-modules,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "plasma-workspace-wallpapers";
  extraBuildInputs = [ extra-cmake-modules ];
  meta.platforms = lib.platforms.all;
}
