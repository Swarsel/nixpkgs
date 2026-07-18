{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "imgcrypt";
  version = "1.1.10";

  src = fetchFromGitHub {
    owner = "containerd";
    repo = "imgcrypt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-81jfoWHYYenGQFcQI9kk8uPnv6FcyOtcJjpo1ykdtOI=";
  };

  vendorHash = null;

  postFixup = ''
    mv $out/bin/ctr $out/bin/ctr-enc
  '';

  ldflags = [
    "-X github.com/containerd/containerd/version.Version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/ctd-decoder"
    "cmd/ctr"
  ];

  meta = {
    description = "Image encryption library and command line tool";
    homepage = "https://github.com/containerd/imgcrypt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mikroskeem ];
    platforms = lib.platforms.linux;
  };
})
