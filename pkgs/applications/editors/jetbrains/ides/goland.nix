{
  lib,
  stdenv,
  fetchurl,
  fsnotifier,
  libdbm,
  libgcc,
  mkJetBrainsProduct,
}:
let
  system = stdenv.hostPlatform.system;
  # update-script-start: urls
  urls = {
    aarch64-darwin = {
      hash = "sha256-y7mEke0z0MvQs+kMtrmrq7EeAtJUbgo6sGZrOB0MraM=";
      url = "https://download.jetbrains.com/go/goland-2026.1.4-aarch64.dmg";
    };

    aarch64-linux = {
      hash = "sha256-7s98kY08aKjdRGQLDkffeVhgj1FWurLmTTYmtb5Qx6c=";
      url = "https://download.jetbrains.com/go/goland-2026.1.4-aarch64.tar.gz";
    };

    x86_64-linux = {
      hash = "sha256-pHSbmAZ+tSfa0wdtDp/3Ib/GNMP30OFNQlHWUfMwrW0=";
      url = "https://download.jetbrains.com/go/goland-2026.1.4.tar.gz";
    };
  };
  # update-script-end: urls
in
(mkJetBrainsProduct {
  inherit libdbm fsnotifier;
  pname = "goland";
  # update-script-start: version
  version = "2026.1.4";
  # update-script-end: version
  src = fetchurl (urls.${system} or (throw "Unsupported system: ${system}"));

  buildInputs = [
    libgcc
  ];

  buildNumber = "261.26222.72";

  extraWrapperArgs = [
    # fortify source breaks build since delve compiles with -O0
    ''--prefix CGO_CPPFLAGS " " "-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0"''
  ];

  product = "Goland";
  wmClass = "jetbrains-goland";

  # NOTE: meta attrs are used for the Linux desktop entries and may cause rebuilds when changed
  meta = {
    description = "Go IDE from JetBrains";

    longDescription = ''
      Goland is a commercial IDE by JetBrains aimed at providing an ergonomic environment for Go development.
      The IDE extends the IntelliJ platform with the coding assistance and tool integrations specific for the Go language.
    '';

    homepage = "https://www.jetbrains.com/go/";
    license = lib.licenses.unfree;

    sourceProvenance =
      if stdenv.hostPlatform.isDarwin then
        [ lib.sourceTypes.binaryNativeCode ]
      else
        [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [ tymscar ];
  };
}).overrideAttrs
  (attrs: {
    postFixup =
      (attrs.postFixup or "")
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        interp="$(cat $NIX_CC/nix-support/dynamic-linker)"
        patchelf --set-interpreter $interp $out/goland/plugins/go-plugin/lib/dlv/linux/dlv
        chmod +x $out/goland/plugins/go-plugin/lib/dlv/linux/dlv
      '';
  })
