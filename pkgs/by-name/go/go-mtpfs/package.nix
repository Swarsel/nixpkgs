{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  libusb1,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "go-mtpfs";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hanwen";
    repo = "go-mtpfs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HVfB8/MImgZZLx4tcrlYOfQjpAdHMHshEaSsd+n758w=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];
  vendorHash = "sha256-OrAEvD2rF0Y0bvCD9TUv/E429lASsvC3uK3qNvbg734=";

  checkFlags = [
    # Only run tests under mtp/encoding_test.go
    # Other tests require an Android deviced attached over USB.
    "-run=Test(Encode|Decode|Variant)"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Simple FUSE filesystem for mounting Android devices as a MTP device";
    homepage = "https://github.com/hanwen/go-mtpfs";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "go-mtpfs";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
