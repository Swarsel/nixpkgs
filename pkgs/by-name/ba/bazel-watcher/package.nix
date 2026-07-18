{
  lib,
  stdenv,
  fetchFromGitHub,
  bazel-watcher,
  buildGoModule,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "bazel-watcher";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-watcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ssG2BFd2utB9xu9zYdcvZYLq+XF9ZOctxNGtpbrhLG8=";
  };

  vendorHash = "sha256-u1Zg/M9DSkwscy49qtPQygk1gyxKaPbhlFDYNtBQ9NY=";
  # The dependency github.com/fsnotify/fsevents requires CGO
  env.CGO_ENABLED = if stdenv.hostPlatform.isDarwin then "1" else "0";

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/ibazel" ];

  passthru = {
    tests.version = testers.testVersion {
      command = "ibazel version";
      package = bazel-watcher;
    };
  };

  meta = {
    description = "Tools for building Bazel targets when source files change";
    homepage = "https://github.com/bazelbuild/bazel-watcher";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kalbasit ];
    platforms = lib.platforms.all;
    mainProgram = "ibazel";
  };
})
