{
  lib,
  fetchFromForgejo,
  nettle,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "proxyauth";
  version = "0.8.0";

  src = fetchFromForgejo {
    owner = "ProxyAuth";
    repo = "ProxyAuth";
    rev = "13b353e4a8b34fc1736c834cfcaa9afe06e8abf8";
    # Tags were not replicated from GitHub to git.proxyauth.app
    hash = "sha256-cVjD91tBCGyslLsYUSP1Gy7KuMQZDVxQXU7fQkWeWyM=";
    domain = "git.proxyauth.app";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    nettle
  ];

  cargoHash = "sha256-YhFOh60D014Tb/Gi3u+tpmXbaaIFIB5HU4X8rhWPV40=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Proxy Authentication Token - Fast authentication gateway for backend APIs";
    homepage = "https://git.proxyauth.app/ProxyAuth/ProxyAuth";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ liberodark ];
    platforms = lib.platforms.linux;
    mainProgram = "proxyauth";
  };
})
