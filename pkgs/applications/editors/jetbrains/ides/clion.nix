{
  lib,
  stdenv,
  fetchurl,
  dotnetCorePackages,
  expat,
  fsnotifier,
  libdbm,
  libxcrypt-legacy,
  libxml2,
  lttng-ust_2_12,
  mkJetBrainsProduct,
  musl,
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
      hash = "sha256-i3stX7dyRgSOJkFTMD9/hkw6e2mGNqn13S7X/vJ66RQ=";
      url = "https://download.jetbrains.com/cpp/CLion-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-I6IKQng4lNtRlQIq08K5bueqgKI/q1awX4EuRnyAnOk=";
      url = "https://download.jetbrains.com/cpp/CLion-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-uOhFuDqVw3pxtqBvOQH+FpJTFrneaD/R0VcpJZRYD2o=";
      url = "https://download.jetbrains.com/cpp/CLion-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
(mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "clion";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      python3
      openssl
      libxcrypt-legacy
      lttng-ust_2_12
      musl
    ]
    ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch) [
      expat
      libxml2
      xz
    ];

  buildNumber = "261.26222.59";
  product = "CLion";
  wmClass = "jetbrains-clion";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "C/C++ IDE from JetBrains";
    longDescription = "Enhancing productivity for every C and C++ developer on Linux, macOS and Windows.";
    homepage = "https://www.jetbrains.com/clion/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      mic92
      tymscar
    ];
  };
}).overrideAttrs
  (attrs: {
    postInstall =
      (attrs.postInstall or "")
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        for dir in $out/clion/plugins/clion-radler/DotFiles/linux-*; do
          rm -rf $dir/dotnet
          ln -s ${dotnetCorePackages.sdk_10_0-source}/share/dotnet $dir/dotnet
        done
      '';

    postFixup = ''
      ${attrs.postFixup or ""}
      ${patchSharedLibs}
    '';
  })
