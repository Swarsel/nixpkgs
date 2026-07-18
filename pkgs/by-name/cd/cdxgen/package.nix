{
  lib,
  stdenv,
  fetchFromGitHub,
  cctools,
  fetchPnpmDeps,
  makeWrapper,
  node-gyp,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cdxgen";
  version = "11.10.0";

  src = fetchFromGitHub {
    owner = "cdxgen";
    repo = "cdxgen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RmgR6OfNrZUYFyn36zTHERIHlzszaFqTX8b4Rf2TF/U=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    node-gyp # required for sqlite3 bindings
    pnpmConfigHook
    pnpm_10
    python3 # required for sqlite3 bindings
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin cctools.libtool;

  buildPhase = ''
    runHook preBuild

    pushd node_modules/sqlite3
    node-gyp rebuild
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r * $out/lib
    makeWrapper ${nodejs}/bin/node "$out/bin/cdxgen" --add-flags "$out/lib/bin/cdxgen.js"
    makeWrapper ${nodejs}/bin/node "$out/bin/cdxgen-evinse" --add-flags "$out/lib/bin/evinse.js"
    makeWrapper ${nodejs}/bin/node "$out/bin/cdxgen-repl" --add-flags "$out/lib/bin/repl.js"
    makeWrapper ${nodejs}/bin/node "$out/bin/cdxgen-verify" --add-flags "$out/lib/bin/verify.js"

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-o7u/ZZS/5PgOtWd07zO4a01mUWZowUTL+JDJ2442mGc=";
    pnpm = pnpm_10;
  };

  meta = {
    description = "Creates CycloneDX Software Bill-of-Materials (SBOM) for your projects from source and container images";
    homepage = "https://github.com/cdxgen/cdxgen";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      quincepie
    ];

    mainProgram = "cdxgen";
  };
})
