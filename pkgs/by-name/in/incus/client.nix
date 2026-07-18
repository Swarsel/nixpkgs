{
  lib,
  buildGoModule,
  fetchpatch2,
  installShellFiles,
  meta,
  patches,
  src,
  vendorHash,
  version,
  lts ? false,
}:
let
  pname = "incus${lib.optionalString lts "-lts"}-client";
  evaluatedPatches = if lib.isFunction patches then patches fetchpatch2 else patches;
in

buildGoModule {
  inherit
    pname
    src
    vendorHash
    version
    ;

  patches = evaluatedPatches;
  nativeBuildInputs = [ installShellFiles ];
  env.CGO_ENABLED = 0;
  # don't run the full incus test suite
  doCheck = false;

  postInstall = ''
    # Needed for builds on systems with auto-allocate-uids to pass.
    # Incus tries to read ~/.config/incus while generating completions
    # to resolve user aliases.
    export HOME="$(mktemp -d)"
    mkdir -p "$HOME/.config/incus"

    installShellCompletion --cmd incus \
      --bash <($out/bin/incus completion bash) \
      --fish <($out/bin/incus completion fish) \
      --zsh <($out/bin/incus completion zsh)
  '';

  subPackages = [ "cmd/incus" ];

  meta = meta // {
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
