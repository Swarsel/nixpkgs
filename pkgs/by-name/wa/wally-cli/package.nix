{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libusb1,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "wally-cli";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "zsa";
    repo = "wally-cli";
    rev = "${finalAttrs.version}-linux";
    sha256 = "NuyQHEygy4LNqLtrpdwfCR+fNy3ZUxOClVdRen6AXMc=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];
  vendorHash = "sha256-HffgkuKmaOjTYi+jQ6vBlC50JqqbYiikURT6TCqL7e0=";
  subPackages = [ "." ];

  meta = {
    description = "Tool to flash firmware to mechanical keyboards";
    homepage = "https://ergodox-ez.com/pages/wally-planck";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      spacekookie
      r-burns
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "wally-cli";
  };
})
