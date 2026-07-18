{
  lib,
  stdenv,
  fetchurl,
  expat,
  fsnotifier,
  libdbm,
  libxcrypt-legacy,
  libxml2,
  mkJetBrainsProduct,
  openssl,
  patchSharedLibs,
  python3,
  xz,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-Hly4NBv9mg/RMmxCM6m9w5eS/CQ7ycxp7V2VQZwyGQE=";
      url = "https://download.jetbrains.com/rustrover/RustRover-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-KpF3jCnLKCEeEXkBdB8ZsPPqP9FOVRTwRV/FQLKyh1Q=";
      url = "https://download.jetbrains.com/rustrover/RustRover-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-8x/AP6uKSVJavwjA9tYT1IM1xVspOZZzwmcwpGloIcw=";
      url = "https://download.jetbrains.com/rustrover/RustRover-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
(mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "rust-rover";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      python3
      openssl
      libxcrypt-legacy
    ]
    ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch) [
      expat
      libxml2
      xz
    ];

  buildNumber = "261.26222.73";
  product = "RustRover";
  wmClass = "jetbrains-rustrover";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Rust IDE from JetBrains";
    longDescription = "Rust IDE from JetBrains";
    homepage = "https://www.jetbrains.com/rust/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = [ ];
  };
}).overrideAttrs
  (attrs: {
    postFixup = ''
      ${attrs.postFixup or ""}
      ${patchSharedLibs}
    '';
  })
