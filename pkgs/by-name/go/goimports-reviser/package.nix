{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "goimports-reviser";
  version = "3.12.6";

  src = fetchFromGitHub {
    owner = "incu6us";
    repo = "goimports-reviser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QFnTiFINWprGuBrRwLFMexIbv6Xu+tq7rTVif7YvLsc=";
  };

  vendorHash = "sha256-aTPzvqIwjZzEq9LHFdebIgbKMwsBOqLbpEWB7rN7cYY=";
  env.CGO_ENABLED = 0;

  checkFlags = [
    "-skip=TestSourceFile_Fix_WithAliasForVersionSuffix/success_with_set_alias"
  ];

  preCheck = ''
    # unset to run all tests
    unset subPackages
    # unset as some tests require cgo
    unset CGO_ENABLED
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.Tag=${finalAttrs.src.rev}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Right imports sorting & code formatting tool (goimports alternative)";
    homepage = "https://github.com/incu6us/goimports-reviser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "goimports-reviser";
  };
})
