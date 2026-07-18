{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "0.43.8";
in
buildGoModule {
  inherit version;
  pname = "geesefs";

  src = fetchFromGitHub {
    owner = "yandex-cloud";
    repo = "geesefs";
    rev = "v${version}";
    hash = "sha256-NDe3GnB0xVly6Elfpa60+Wx3RyWhfPfssf1l7Tt20zY=";
  };

  vendorHash = "sha256-mvzt/pk+S7DRcU6T3fBBQw1uvluO/tfeFmONucMv7t8=";
  # hashes differ per architecture otherwise.
  proxyVendor = true;
  subPackages = [ "." ];

  meta = {
    description = "Finally, a good FUSE FS implementation over S3";
    homepage = "https://github.com/yandex-cloud/geesefs";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.flokli ];
    platforms = lib.platforms.unix;
    mainProgram = "geesefs";
  };
}
