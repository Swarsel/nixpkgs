{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "gitmux";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "arl";
    repo = "gitmux";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-TObnmV/NiMCcyC9zG0OcCuCqUChQZmpqPptQUDtF85A=";
  };

  vendorHash = "sha256-MvvJGB9KPMYeqYclmAAF6qlU7vrJFMPToogbGDRoCpU=";
  # After bump of Go toolchain to version >1.22, tests fail with:
  #   vendor/github.com/rogpeppe/go-internal/testscript/exe_go118.go:14:27:
  #   cannot use nopTestDeps{} (value of struct type nopTestDeps) as testing.testDeps value in argument to testing.MainStart:
  #   nopTestDeps does not implement testing.testDeps (missing method InitRuntimeCoverage)'.
  doCheck = false;
  nativeCheckInputs = [ git ];
  ldflags = [ "-X main.version=${finalAttrs.version}" ];
  subPackages = [ "." ];

  passthru.tests.version = testers.testVersion {
    command = "gitmux -V";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Git in your tmux status bar";
    homepage = "https://github.com/arl/gitmux";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nialov ];
    mainProgram = "gitmux";
  };
})
