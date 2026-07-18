{
  lib,
  fetchFromGitHub,
  buildLakePackage,
  fetchNpmDeps,
  nodejs,
  npmHooks,
}:

buildLakePackage (finalAttrs: {
  pname = "lean4-proofwidgets";
  # nixpkgs-update: no auto update
  version = "0.0.99";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "ProofWidgets4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kGoEkKGrucNUWFYkHW2LsS1gI4C0J8bAHQL2MiE4Pzc=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  postConfigure = ''
    local realNpm
    realNpm="$(type -P npm)"
    mkdir -p "$TMPDIR/npm-wrap"
    cat > "$TMPDIR/npm-wrap/npm" <<WRAPPER
    #!/bin/sh
    case "\$1" in ci|clean-install) exit 0 ;; esac
    exec "$realNpm" "\$@"
    WRAPPER
    chmod +x "$TMPDIR/npm-wrap/npm"
    export PATH="$TMPDIR/npm-wrap:$PATH"
  '';

  lakeHash = null;
  leanPackageName = "proofwidgets";

  npmDeps = fetchNpmDeps {
    src = finalAttrs.src;
    hash = "sha256-ssWSr2qfsIbX25DidiVPm0tsLGjrhQhQ6YKPL0rfc1k=";
    name = "lean4-proofwidgets-npm-deps";
    sourceRoot = "source/widget";
  };

  npmRoot = "widget";

  meta = {
    description = "Interactive UI framework for Lean 4 proof assistants";
    homepage = "https://github.com/leanprover-community/ProofWidgets4";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
})
