{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  fetchpatch,
  gitUpdater,
  versionCheckHook,
  zig_0_14,
}:

let
  zig = zig_0_14;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bold";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "kubkon";
    repo = "bold";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9qq0RIeplv/Y/6ilr6Nv+DAT8xx3e2SoDugCckxXw+M=";
  };

  patches = [
    # Correct version
    (fetchpatch {
      hash = "sha256-UdicLUoH7ApnKxoI91hDcuO/NSINLkxb2h9sA9NShfw=";
      url = "https://github.com/kubkon/bold/commit/e8a3245b1f03ea8ba7136d76807400610c068bac.patch";
    })
  ];

  nativeBuildInputs = [
    zig
  ];

  postConfigure = ''
    ln -s ${callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Drop-in replacement for Apple system linker ld";
    homepage = "https://github.com/kubkon/bold";
    changelog = "https://github.com/kubkon/bold/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ DimitarNestorov ];
    platforms = lib.platforms.darwin;
    mainProgram = "bold";
  };
})
