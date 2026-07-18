{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  cargo-tauri,
  glib,
  gtk3,
  nodejs,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "balatro-mod-manager";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "skyline69";
    repo = "balatro-mod-manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cazd6Cns87cjwBORQIsAD5rBes7eTGCAz7bytZO+TsQ=";
  };

  postPatch = ''
    cp -r ${finalAttrs.nodeModules}/node_modules .
    chmod -R +w node_modules
    patchShebangs --build node_modules
  '';

  nativeBuildInputs = [
    pkg-config
    cargo-tauri.hook
    bun
    wrapGAppsHook4
    nodejs
  ];

  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
  ];

  cargoHash = "sha256-m27OdD+hpj1fGiTbe9VmdY+2EFBZKJ3o/4WMdpCpRSw=";

  checkFlags = [
    # skip tests that depend on networking
    "--skip paging_stops_when_cursor_is_none"
    "--skip apply_changed_updates_and_deletes"
    # skip tests that looks for CA certificates
    "--skip test_is_installed_with_no_dir"
    "--skip test_mod_installer_new"
  ];

  postInstall = ''
    for size in 32 128 512; do
      install -Dm644 src-tauri/icons/"$size"x"$size".png $out/share/icons/hicolor/"$size"x"$size"/apps/balatro-mod-manager.png
    done
  '';

  dontUseCargoParallelTests = true;

  nodeModules = stdenv.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "${finalAttrs.pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    buildPhase = ''
      runHook preBuild
      bun install --frozen-lockfile --allow-scripts --no-progress
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/node_modules
      runHook postInstall
    '';

    dontConfigure = true;

    outputHash =
      {
        aarch64-linux = "sha256-YobKPWe+0StlyJkYEeUmNzYAinGwR042HWpdwWOCt6Q=";
        x86_64-linux = "sha256-SQCF05uuJg16Il7SvCXlzkm64wJyPfNzVqfgDj7YldI=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system ${stdenv.hostPlatform.system}");

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  meta = {
    description = "A mod manager for the game Balatro";
    homepage = "https://balatro-mod-manager.dasguney.com/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mhdask
      ryand56
    ];

    platforms = lib.intersectLists lib.platforms.linux (lib.platforms.x86_64 ++ lib.platforms.aarch64);
    mainProgram = "BMM";
  };
})
