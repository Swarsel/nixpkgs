{
  lib,
  fetchFromGitLab,
  berryCacheVersion,
  berryVersion,
  libzip,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yarn-berry-${toString berryVersion}-fetcher";
  version = "1.3.1";

  src = fetchFromGitLab {
    owner = "yuka";
    repo = "yarn-berry-fetcher";
    tag = finalAttrs.version;
    hash = "sha256-4dT01SgTPwo9Vw7WIKtdRVP5+dd45YsTPOuf3V6SJg8=";
    domain = "cyberchaos.dev";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
  ];

  buildInputs = [
    libzip
    openssl
  ];

  cargoHash = "sha256-l8zTzr2y8i2ENb8iadIBz59YLmNwfDZcrbUqIUibFqg=";
  env.LIBZIP_SYS_USE_PKG_CONFIG = 1;
  env.YARN_ZIP_SUPPORTED_CACHE_VERSION = berryCacheVersion;
  impureEnvVars = lib.fetchers.proxyImpureEnvVars;

  meta = {
    homepage = "https://cyberchaos.dev/yuka/yarn-berry-fetcher";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flokli
    ];

    mainProgram = "yarn-berry-fetcher";
  };
})
