{
  lib,
  stdenv,
  fetchPnpmDeps,
  giflib,
  meta,
  node-gyp,
  nodejs,
  pango,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  python3,
  src,
  version,
  xcbuild,
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  inherit meta;
  pname = "paperless-ngx-frontend";
  src = src + "/src-ui";

  nativeBuildInputs = [
    node-gyp
    nodejs
    pkg-config
    pnpmConfigHook
    pnpm
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xcbuild
  ];

  buildInputs = [
    pango
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    giflib
  ];

  buildPhase = ''
    runHook preBuild

    pushd node_modules/canvas
    node-gyp rebuild
    popd

    # cat forcefully disables angular cli's spinner which doesn't work with nix' tty which is 0x0
    pnpm run build --configuration production | cat

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    pnpm run test | cat

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/paperless-ui
    mv ../src/documents/static/frontend $out/lib/paperless-ui/

    runHook postInstall
  '';

  CYPRESS_INSTALL_BINARY = "0";
  NG_CLI_ANALYTICS = "false";

  pnpmDeps = fetchPnpmDeps {
    inherit pnpm;
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-HO+IDNB3NXWgvV0cvZ5zx46JuXv6Tgroz+YfVump5MA=";
  };
})
