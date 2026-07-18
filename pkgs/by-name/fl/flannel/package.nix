{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule rec {
  pname = "flannel";
  version = "0.28.6";

  src = fetchFromGitHub {
    inherit rev;
    owner = "flannel-io";
    repo = "flannel";
    sha256 = "sha256-djPi4dgG9iR7K5c9NhMVJI1xdBmCX39+G/zt6dDRZx8=";
  };

  vendorHash = "sha256-io2xUh5jM2x7P01MIpPgLAVXC/CAL22zrC6kfi4uYFs=";
  # TestRouteCache/TestV6RouteCache fail with "Failed to create newns: operation not permitted"
  doCheck = false;
  ldflags = [ "-X github.com/flannel-io/flannel/pkg/version.Version=${rev}" ];
  rev = "v${version}";
  passthru.tests = { inherit (nixosTests) flannel; };

  meta = {
    description = "Network fabric for containers, designed for Kubernetes";
    homepage = "https://github.com/flannel-io/flannel";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      johanot
    ];

    platforms = with lib.platforms; linux;
    mainProgram = "flannel";
  };
}
