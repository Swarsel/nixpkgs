{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  buildNpmPackage,
  curl,
  libz,
  nix-update-script,
  openssl,
  pkg-config,
  postgresql,
  postgresqlTestHook,
  rustPlatform,
}:

let
  # check package.metadata.mln in https://github.com/maplibre/maplibre-native-rs/blob/main/Cargo.toml
  mlnRelease = "core-9b6325a14e2cf1cc29ab28c1855ad376f1ba4903";
  mlnHeaders = fetchurl {
    hash = "sha256-VjVEc/+IZTBG9ixP/i7oeel+7gy3+DhSEOi2UDIqeLc=";
    url = "https://github.com/maplibre/maplibre-native/releases/download/${mlnRelease}/maplibre-native-headers.tar.gz";
  };
  mlnLibrary = fetchurl (
    let
      sources = {
        aarch64-linux = {
          hash = "sha256-PHFNdzcG3+kngZmziMccCTnwBUbtsS2RAUNkTyNYXmc";
          url = "https://github.com/maplibre/maplibre-native/releases/download/${mlnRelease}/libmaplibre-native-core-amalgam-linux-arm64-vulkan.a";
        };

        x86_64-linux = {
          hash = "sha256-T9H7NiXHv+hbMgOd5QetQzxjIX1Ufn6gNmBJJ/7Ha50=";
          url = "https://github.com/maplibre/maplibre-native/releases/download/${mlnRelease}/libmaplibre-native-core-amalgam-linux-x64-vulkan.a";
        };
      };
    in
    sources.${stdenv.hostPlatform.system}
    // {
      downloadToTemp = true;

      postFetch = ''
        install -Dm644 $downloadedFile $out/libmbgl-core-amalgam.a
      '';

      recursiveHash = true;
    }
  );
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "martin";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "maplibre";
    repo = "martin";
    tag = "martin-v${finalAttrs.version}";
    hash = "sha256-Zu3vkU7HQcSqzCL7n0uX4M+DxBDMC0Sii7esxM9AtpA=";
  };

  patches = [ ./dont-build-webui.patch ];
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    libz
    openssl
  ];

  cargoHash = "sha256-OPuUvm4ez5TZUWwJ6D6fqy++cCiVt7f1qP6OPdsOEDA=";

  env = {
    MLN_CORE_LIBRARY_HEADERS_PATH = "${mlnHeaders}";
    MLN_CORE_LIBRARY_PATH = "${mlnLibrary}/libmbgl-core-amalgam.a";
    MLN_PRECOMPILE = 1;
  };

  preBuild = ''
    rm -rf martin/martin-ui/dist
    cp -r ${finalAttrs.webui} martin/martin-ui/dist
  '';

  # Tests are time-consuming and moved to passthru.tests.withCheck.
  doCheck = false;

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
  ];

  checkFlags = [
    # Requires docker
    "--skip=test_nonexistent_tables_functions_generate_warning"
  ];

  webui = buildNpmPackage {
    inherit (finalAttrs) version doCheck;
    pname = "martin-ui";
    src = "${finalAttrs.src}/martin/martin-ui";

    postPatch = ''
      substituteInPlace src/App.tsx \
        --replace-warn "./assets" "$src/src/assets"
      ln -sf ${finalAttrs.src}/demo/frontend/public/favicon.ico public/_/assets/favicon.ico
    '';

    npmDepsHash = "sha256-lX5FSWAQyy4Sa7OPnNyTYttjHiPuYxgrPsmZpwCnpO8=";

    buildPhase = ''
      runHook preBuild
      npm exec vite build
      runHook postBuild
    '';

    checkPhase = ''
      runHook preCheck
      npm run test
      runHook postCheck
    '';

    installPhase = ''
      cp -r dist $out
    '';
  };

  passthru.tests = lib.optionalAttrs (!postgresqlTestHook.meta.broken) {
    withCheck = finalAttrs.finalPackage.overrideAttrs {
      doCheck = true;
    };
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex=martin-v(.*)"
      "--subpackage=webui"
    ];
  };

  meta = {
    description = "Blazing fast and lightweight PostGIS vector tiles server";
    homepage = "https://martin.maplibre.org/";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode # maplibre-native
      fromSource
    ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    teams = [ lib.teams.geospatial ];
  };
})
