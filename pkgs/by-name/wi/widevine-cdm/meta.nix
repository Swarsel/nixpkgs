lib: {
  description = "Widevine CDM";
  homepage = "https://www.widevine.com";
  license = lib.licenses.unfree;

  maintainers = with lib.maintainers; [
    jlamur
    bearfm
  ];

  platforms = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
}
