{
  lib,
  fetchFromGitHub,
  libusb-compat-0_1,
  rustPlatform,
}:

let
  version = "0.7.9";
  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "wishbone-utils";
    rev = "v${version}";
    hash = "sha256-Gl0bxHJ8Y0ytYJxToYAR2tVkD4YNMihk+zRpieSvMGE=";
  };
in
rustPlatform.buildRustPackage {
  inherit version;
  inherit src;
  pname = "wishbone-tool";
  buildInputs = [ libusb-compat-0_1 ];
  cargoHash = "sha256-YJEsTGnBUkQ35VOwZQeBbO3RZqglLYm2xecmIS4jiZM=";
  sourceRoot = "${src.name}/wishbone-tool";

  meta = {
    description = "Manipulate a Wishbone device over some sort of bridge";
    homepage = "https://github.com/litex-hub/wishbone-utils";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ edef ];
    platforms = lib.platforms.linux;
    mainProgram = "wishbone-tool";
  };
}
