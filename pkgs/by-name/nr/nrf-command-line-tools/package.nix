{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libusb1,
  segger-jlink,
  udev,
}:

let
  supported = {
    aarch64-linux = {
      hash = "sha256-ACy3rXsvBZNVXdVkpP2AqrsoqKPliw6m9UUWrFOCBzs=";
      name = "linux-arm64";
    };

    armv7l-linux = {
      hash = "sha256-nD1pHL/SQqC7OlxuovWwvtnXKMmhfx5qFaF4ti8gh8g=";
      name = "linux-armhf";
    };

    x86_64-linux = {
      hash = "sha256-zL9tXl2HsO8JZXEGsjg4+lDJJz30StOMH96rU7neDsg=";
      name = "linux-amd64";
    };
  };

  platform = supported.${stdenv.system} or (throw "unsupported platform ${stdenv.system}");

  version = "10.23.2";

  url =
    let
      versionWithDashes = builtins.replaceStrings [ "." ] [ "-" ] version;
    in
    "https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-${lib.versions.major version}-x-x/${versionWithDashes}/nrf-command-line-tools-${version}_${platform.name}.tar.gz";

in
stdenv.mkDerivation {
  inherit version;
  pname = "nrf-command-line-tools";

  src = fetchurl {
    inherit url;
    inherit (platform) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    udev
    libusb1
  ];

  installPhase = ''
    runHook preInstall

    rm -rf ./python
    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  runtimeDependencies = [
    segger-jlink
  ];

  meta = {
    description = "Nordic Semiconductor nRF Command Line Tools";
    homepage = "https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ stargate01 ];
    platforms = lib.attrNames supported;
  };
}
