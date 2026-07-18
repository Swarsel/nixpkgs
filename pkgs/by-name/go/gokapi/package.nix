{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gokapi";
  version = "2.2.4";

  src = fetchFromGitHub {
    owner = "Forceu";
    repo = "Gokapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N9rV8/IJy4eMwdXXh+7z3raPcalSFUWP7EwN84tfbk8=";
  };

  patches = [ ];
  vendorHash = "sha256-oZyZD4kPqgSIaphXRyXVzY+8gYd7kpWAAo1cfiE1ln8=";

  # This is the go generate is ran in the upstream builder, but we have to run the components separately for things to work.
  preBuild = ''
    # Some steps expect GOROOT to be set.
    export GOROOT="$(go env GOROOT)"
    # Go generate runs from this working dir upstream
    cd ./cmd/gokapi/
    go run ../../build/go-generate/updateVersionNumbers.go
    # Tries to download "golang.org/x/exp/slices", and fails
    # go run ../../build/go-generate/updateProtectedUrls.go
    go run ../../build/go-generate/buildWasm.go
    go run ../../build/go-generate/copyStaticFiles.go
    # Attempts to download program to minify content, and fails
    # go run ../../build/go-generate/minifyStaticContent.go
    go run ../../build/go-generate/updateApiRouting.go
    cd ../..
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/gokapi"
  ];

  passthru = {
    tests = {
      inherit (nixosTests) gokapi;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lightweight selfhosted Firefox Send alternative without public upload";
    homepage = "https://github.com/Forceu/Gokapi";
    changelog = "https://github.com/Forceu/Gokapi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      delliott
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gokapi";
  };
})
