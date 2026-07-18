{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libgcc,
  oakctl,
  testers,
}:

let
  version = "0.16.5";

  # Note: Extracted from install script
  # https://oakctl-releases.luxonis.com/oakctl-installer.sh
  sources = {
    aarch64-darwin = fetchurl {
      hash = "sha256-tJl9OKhaY9dIxkN+tsbQ3isyAfFPSDOqkgLgDDaRaSg=";
      url = "https://oakctl-releases.luxonis.com/data/${version}/darwin_arm64/oakctl";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-RiZXHOxYJZHhIdIGGwO5BTDaoj4NYl0nZZbK3ULUhLI=";
      url = "https://oakctl-releases.luxonis.com/data/${version}/linux_aarch64/oakctl";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-bTa/0jwYuRNLNYjqHlAjIbbIAdY7Qyq3m0I6GFnEW0s=";
      url = "https://oakctl-releases.luxonis.com/data/${version}/linux_x86_64/oakctl";
    };
  };

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "oakctl";
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libgcc
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m 0755 $src $out/bin/oakctl

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  passthru.tests.version = testers.testVersion {
    command = "HOME=$TMPDIR oakctl version";
    package = oakctl;
  };

  # Note: The command 'oakctl self-update' won't work as the binary is located in the nix/store
  meta = {
    description = "Tool to interact with Luxonis OAK4 cameras";
    homepage = "https://docs.luxonis.com/software-v3/oak-apps/oakctl/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ phodina ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "oakctl";
  };
})
