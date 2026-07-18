{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "kratos";
  version = "26.2.0";

  src = fetchFromGitHub {
    owner = "ory";
    repo = "kratos";
    rev = "v${finalAttrs.version}";
    hash = "sha256-u298vFFD/zc7ScdQ5rmvcHqkMMenMVIRC9GChfukml8=";
  };

  vendorHash = "sha256-qnG8hdWazKlIFfNPz2z5F7hhgZaTTttUBbg59T+N5OI=";

  preBuild = ''
    # Patch shebangs
    files=(
       test/e2e/run.sh
       script/testenv.sh
       script/test-envs.sh
       script/debug-entrypoint.sh
    )
    patchShebangs "''${files[@]}"

    # patchShebangs doesn't work for this Makefile, do it manually
    substituteInPlace Makefile --replace-fail '/usr/bin/env bash' '${stdenv.shell}'
  '';

  # large portion of tests fail due to:
  #     provider.go:39: building the Go binary returned error: exit status 1
  #        cannot find module providing package github.com/ory/x/jsonnetsecure/cmd: import lookup disabled by -mod=vendor
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  # Pass versioning information via ldflags
  ldflags = [
    "-X github.com/ory/kratos/driver/config.Version=v${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  tags = [ "sqlite" ];
  versionCheckProgramArg = [ "version" ];

  meta = {
    description = "API-first Identity and User Management system that is built according to cloud architecture best practices";
    homepage = "https://www.ory.sh/kratos/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mrmebelman
      debtquity
    ];

    mainProgram = "kratos";
  };
})
