{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gzip,
  versionCheckHook,
}:
let

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      aarch64-darwin = "macos_arm";
      aarch64-linux = "linux_arm";
      x86_64-linux = "linux_x64";

    }
    .${system} or throwSystem;

  hash =
    {
      aarch64-darwin = "sha256-c0BDLK1ilDOdNYbOqzFNoJFeBUlWI7/+z7HaosM/D4o=";
      aarch64-linux = "sha256-r0gGxwhVkQ5MLTmcrBCJpKfsizAJLJYPw1VdfiHJ3i8=";
      x86_64-linux = "sha256-hx5q0JRwvmE63uOpht7+6d7/jCLeknrj2RwiiMkBllc=";
    }
    .${system} or throwSystem;

  bin = "$out/bin/codeium_language_server";

in
stdenv.mkDerivation (finalAttrs: {
  pname = "codeium";
  version = "2.12.5";

  src = fetchurl {
    inherit hash;
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${finalAttrs.version}/language_server_${plat}.gz";
    name = "${finalAttrs.pname}-${finalAttrs.version}.gz";
  };

  nativeBuildInputs = [ gzip ] ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    gzip -dc $src > ${bin}
    chmod +x ${bin}
    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  versionCheckProgram = "${placeholder "out"}/bin/codeium_language_server";
  passthru.updateScript = ./update.sh;

  meta = rec {
    description = "Codeium language server";

    longDescription = ''
      Codeium proprietary language server, patched for Nix(OS) compatibility.
      bin/language_server_x must be symlinked into the plugin directory, replacing the existing binary.
      For example:
      ```shell
      ln -s "$(which codeium_language_server)" /home/a/.local/share/JetBrains/Rider2023.1/codeium/662505c9b23342478d971f66a530cd102ae35df7/language_server_linux_x64
      ```
    '';

    homepage = "https://codeium.com/";
    changelog = homepage;
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ anpin ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "codeium_language_server";
    downloadPage = homepage;
  };
})
