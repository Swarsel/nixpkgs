{
  lib,
  stdenv,
  callPackage,
  fetchgit,
  installShellFiles,
  versionCheckHook,
  zig_0_14,
}:

let
  zig = zig_0_14;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lsr";
  version = "1.0.0";

  src = fetchgit {
    url = "https://tangled.sh/@rockorager.dev/lsr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VeB0R/6h9FXSzBfx0IgpGlBz16zQScDSiU7ZvTD/Cds=";

    sparseCheckout = [
      "src"
      "docs"
    ];
  };

  nativeBuildInputs = [
    installShellFiles
    zig
  ];

  postConfigure = ''
    ln -s ${callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "ls but with io_uring";
    homepage = "https://tangled.sh/@rockorager.dev/lsr";
    changelog = "https://tangled.sh/@rockorager.dev/lsr/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ddogfoodd ];
    platforms = lib.platforms.linux;
    mainProgram = "lsr";
  };
})
