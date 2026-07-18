{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  # Upstream replaces minor versions, so use cached URLs.
  srcs = {
    "x86_64-linux" = fetchurl {
      sha256 = "b68c4907cf9258ab47102e8f0e489c11d528a8f614bfa45e3a2fa198639e2362";
      url = "https://web.archive.org/web/20231109221336id_/https://ftp.perforce.com/perforce/r23.1/bin.linux26x86_64/helix-core-server.tgz";
    };
  };
in
stdenv.mkDerivation {
  pname = "p4d";
  version = "2023.1.2513900";

  src =
    assert lib.assertMsg (builtins.hasAttr stdenv.hostPlatform.system srcs)
      "p4d is not available for ${stdenv.hostPlatform.system}";
    srcs.${stdenv.hostPlatform.system};

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    install -D -t $out/bin p4broker p4d p4p
    install -D -t $out/doc/p4d -m 0644 *.txt
  '';

  dontBuild = true;
  sourceRoot = ".";

  meta = {
    description = "Perforce Helix Core Server";
    homepage = "https://www.perforce.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      corngood
      impl
    ];

    platforms = builtins.attrNames srcs;
    mainProgram = "p4d";
  };
}
