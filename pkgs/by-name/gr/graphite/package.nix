{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  binaryen,
  cargo,
  cargo-about,
  cef-binary,
  fetchNpmDeps,
  fetchzip,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxkbcommon,
  lld,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  removeReferencesTo,
  rustPlatform,
  rustc,
  vulkan-loader,
  wasm-bindgen-cli_0_2_121,
  wayland,
  xz,
}:

let
  version = "0-unstable-2026-07-09";
  rev = "97f8113fe43d41b15ca3a56c300c48b7c8fda5c4";

  srcHash = "sha256-EPZzS3sxHYLi2qaRKvJbjUfS0LWaIWwJW/z4op+/uZM=";
  shaderHash = "sha256-iwtT43vnhgZZhtvWdTLDL5xZVStkOUb2D832/wjqsUE=";
  cargoHash = "sha256-uwLZFB3+jefE3WihUc3ta8L5G1vdmDdhEDVkDOwAveE=";
  npmHash = "sha256-Rb0bLPk54QigNp7TkDkJJy/TEJXAhlXOCruckwvdXks=";

  brandingRev = "0d004aa61e6b48d316e8e5db6d59ccc4788f192d";
  brandingHash = "sha256-wAA6fR+NSxlCAqgwWmpiIAnji9k/jsMXpR0Vt04Ntmk=";

  src = fetchFromGitHub {
    inherit rev;
    owner = "GraphiteEditor";
    repo = "Graphite";
    hash = srcHash;
  };

  shaders = fetchurl {
    hash = shaderHash;
    url = "https://raw.githubusercontent.com/timon-schelling/graphite-artifacts/refs/heads/main/rev/${rev}/raster_nodes_shaders_entrypoint.wgsl";
  };

  branding = fetchzip {
    hash = brandingHash;
    url = "https://github.com/Keavon/graphite-branded-assets/archive/${brandingRev}.tar.gz";
  };

  libraries = [
    stdenv.cc.cc.lib
    stdenv.cc.libc.out
    vulkan-loader
    libGL
    wayland
    openssl
    libxkbcommon
    libxcursor
    libxcb
    libx11
  ];
  cefPath = cef-binary.overrideAttrs (finalAttrs: {
    pname = "cef-path";

    postInstall = ''
      find $out -mindepth 1 -delete
      strip ./Release/*.so*
      mv ./Release/* $out/
      find "./Resources/locales" -maxdepth 1 -type f ! -name 'en-US.pak' -delete
      mv ./Resources/* $out/
      mv ./include $out/

      cat ./CREDITS.html | ${xz}/bin/xz -9 -e -c > $out/CREDITS.html.xz
    '';
  });
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "graphite";

  postPatch = ''
    mkdir branding
    cp -r ${branding}/* branding
    cp $src/.branding branding/.branding

    substituteInPlace $cargoDepsCopy/*/cef-dll-sys-*/build.rs \
      --replace-fail \
        'download_cef::check_archive_json(&package_version, &path.to_string_lossy())?;' \
        ""
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustc
    cargo
    lld
    pkg-config
    npmHooks.npmConfigHook
    binaryen
    wasm-bindgen-cli_0_2_121
    nodejs
    cargo-about
    removeReferencesTo
  ];

  buildInputs = libraries;
  env.CEF_PATH = cefPath;
  env.GRAPHITE_GIT_COMMIT_HASH = finalAttrs.src.rev;
  env.RASTER_NODES_SHADER_PATH = shaders;

  postConfigure = ''
    # Prevent `package-installer.js` from trying to update npm dependencies
    touch -r frontend/package-lock.json -d '+1 year' frontend/node_modules/.install-timestamp
  '';

  buildPhase = ''
    runHook preBuild
    cargo run build desktop
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./target/release/graphite $out/bin/

    mkdir -p $out/share/applications
    cp $src/desktop/assets/*.desktop $out/share/applications/

    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp ${branding}/app-icons/graphite.svg $out/share/icons/hicolor/scalable/apps/art.graphite.Graphite.svg

    runHook postInstall
  '';

  postFixup = ''
    patchelf \
      --set-rpath "${lib.makeLibraryPath libraries}:${cefPath}" \
      --add-needed libGL.so \
      --add-needed libEGL.so \
      $out/bin/graphite

    remove-references-to -t ${rustc} $out/bin/graphite
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = finalAttrs.src;
    hash = cargoHash;
  };

  disallowedReferences = [ rustc ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/frontend";
    hash = npmHash;
  };

  npmRoot = "frontend";
  passthru.updateScript = ./update.nu;

  meta = {
    description = "Open source vector graphics editor and procedural design engine";

    longDescription = ''
      Graphite is an open source vector graphics editor and procedural design engine.
      Create and animate with a nondestructive editing workflow that
      combines layer-based compositing with node-based generative design.
    '';

    homepage = "https://graphite.art";

    # All Graphite code is licensed under the Apache License 2.0.
    # This derivation also bundles the official branding assets
    # which are licensed under the separate Graphite Branding License.
    license = with lib.licenses; [
      asl20
      {
        free = false;
        fullName = "Graphite Branding License";
        redistributable = true;
        url = "https://graphite.art/license/#branding";
      }
    ];

    maintainers = with lib.maintainers; [ timon ];
    platforms = lib.platforms.linux;
    mainProgram = "graphite";
  };
})
