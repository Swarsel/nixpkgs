{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch2,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gqlgenc";
  version = "0.32.1";

  src = fetchFromGitHub {
    owner = "gqlgo";
    repo = "gqlgenc";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-AGbE+R3502Igl4/HaN8yvFVJBsKQ6iVff8IEvddJLEo=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-moidhkkO/5It8kH1VlwbV+YLlMOTXKH3RyLKGCA2chw=";
      name = "fix-version.patch";
      url = "https://github.com/gqlgo/gqlgenc/commit/aad0599a70780696a9530a7adffebfff53538695.patch?full_index=1";
    })
  ];

  vendorHash = "sha256-kBv9Kit5KdPB48V/g1OaeB0ABFd1A1I/9F5LaQDWxUE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # FAIL: TestLoadConfig_LoadSchema/correct_schema
  # panic: httptest: failed to listen on a port: listen tcp6 [::1]:0: bind: operation not permitted
  __darwinAllowLocalNetworking = true;
  excludedPackages = [ "example" ];

  ldflags = [
    "-X"
    "main.version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Go tool for building GraphQL client with gqlgen";
    homepage = "https://github.com/gqlgo/gqlgenc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wattmto ];
    mainProgram = "gqlgenc";
  };
})
