{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  earthly,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "earthly";
  version = "0.8.16";

  src = fetchFromGitHub {
    owner = "earthly";
    repo = "earthly";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2+Ya5i6V2QDzHsYR+Ro14u0VWR3wrQJHZRXBatGC8BA=";
  };

  vendorHash = "sha256-kEgg7zrT69X4yrsGtLyvnrGQ7+sXaEzdqd4Fz7rpFyg=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/debugger $out/bin/earthly-debugger
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
    "-X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v${finalAttrs.version}"
    "-X main.GitSha=v${finalAttrs.version}"
    "-X main.DefaultInstallationName=earthly"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "-extldflags '-static'"
  ];

  subPackages = [
    "cmd/earthly"
    "cmd/debugger"
  ];

  tags = [
    "dfrunmount"
    "dfrunnetwork"
    "dfrunsecurity"
    "dfsecrets"
    "dfssh"
  ];

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = earthly;
    };
  };

  meta = {
    description = "Build automation for the container era";
    homepage = "https://earthly.dev/";
    changelog = "https://github.com/earthly/earthly/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      zoedsoupe
      konradmalik
    ];
  };
})
