{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  cmake,
  fetchPnpmDeps,
  nodejs_22,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  rustc,
  version ? "1.0.0",
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rolldown";
  # Default from top-level; .override { version = "..." } replaces this via merge, and src/cargoDeps/pnpmDeps use finalAttrs.version below.
  version = version;

  # To obtain hashes: use `nix store prefetch-file --unpack <url>` for source; set hash = "" and build for cargoDeps/pnpmDeps.
  src = fetchFromGitHub {
    owner = "rolldown";
    repo = "rolldown";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EbxZe2JBj69F6bpPn4X7BTRE/dTb/mUIvvqw7oqhAe8=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_10
    nodejs_22
    rustPlatform.cargoSetupHook
    cargo
    rustc
    cmake
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run --filter "@rolldown/pluginutils" build
    pnpm run --filter rolldown build-native:release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    local -r nodeModules="$out/lib/node_modules"
    mkdir -p "$nodeModules"

    # Install rolldown package
    local -r outPath="$nodeModules/rolldown"
    mkdir -p "$outPath"
    cp packages/rolldown/package.json "$outPath/"
    for d in bin cli dist; do
      [[ -d packages/rolldown/$d ]] && cp -r "packages/rolldown/$d" "$outPath/"
    done
    cp packages/rolldown/*.node "$outPath/" 2>/dev/null || true
    cp packages/rolldown/dist/*.node "$outPath/dist/" 2>/dev/null || true
    cp packages/rolldown/src/rolldown-binding.*.node "$outPath/dist/" 2>/dev/null || true

    # Install @rolldown/pluginutils (rolldown's runtime dependency; only built output, no node_modules)
    mkdir -p "$nodeModules/@rolldown/pluginutils"
    cp packages/pluginutils/package.json "$nodeModules/@rolldown/pluginutils/"
    [[ -d packages/pluginutils/dist ]] && cp -r packages/pluginutils/dist "$nodeModules/@rolldown/pluginutils/"

    runHook postInstall
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    pname = "rolldown";
    version = finalAttrs.version;
    src = finalAttrs.src;
    hash = "sha256-VDDbS45Lefs/4x0fU1rULgBtjzZJgL1t2lYwENPknEE=";
  };

  # cmake is only needed for Rust build (mimalloc-sys), not for a top-level configure
  dontUseCmakeConfigure = true;

  pnpmDeps = fetchPnpmDeps {
    pname = "rolldown";
    version = finalAttrs.version;
    src = finalAttrs.src;
    fetcherVersion = 3;
    hash = "sha256-pq94ZI0WW9XJFzecdiM/PaOUp7DSSOWWjRO91rd8Xs4=";
    pnpm = pnpm_10;
  };

  meta = {
    inherit (nodejs_22.meta) platforms;
    description = "Fast Rust-based bundler for JavaScript";
    homepage = "https://github.com/rolldown/rolldown";
    changelog = "https://github.com/rolldown/rolldown/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.chrisportela ];
  };
})
