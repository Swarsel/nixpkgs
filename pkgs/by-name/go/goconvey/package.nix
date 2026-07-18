{
  lib,
  fetchFromGitHub,
  applyPatches,
  buildGoModule,
  fetchpatch,
}:

buildGoModule {
  pname = "goconvey";
  version = "1.8.1-unstable-2024-03-06";

  src = applyPatches {
    patches = [
      # Update golang.org/x/tools to v0.42.0 for Go 1.25+ compatibility
      # https://github.com/smartystreets/goconvey/pull/703
      (fetchpatch {
        hash = "sha256-4JZs4/kxt3KP21q4U8mpBJkueVmRsCsKqST1Cn6ySN8=";
        url = "https://github.com/smartystreets/goconvey/commit/a8d73b2e5380902ab6caa6716ad69c324f390a2d.patch";
      })
    ];

    src = fetchFromGitHub {
      owner = "smartystreets";
      repo = "goconvey";
      rev = "a50310f1e3e53e63e2d23eb904f853aa388a5988";
      hash = "sha256-w5eX/n6Wu2gYgCIhgtjqH3lNckWIDaN4r80cJW3JqFo=";
    };
  };

  vendorHash = "sha256-0LQ5yxqy+WGc9TzmXiiHYyUNIIImoLsItkv5KcHjVGc=";

  checkFlags = [
    "-short"
  ];

  excludedPackages = "web/server/watch/integration_testing";

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;

  meta = {
    description = "Go testing in the browser. Integrates with `go test`. Write behavioral tests in Go";
    homepage = "https://github.com/smartystreets/goconvey";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vdemeester ];
    mainProgram = "goconvey";
  };
}
