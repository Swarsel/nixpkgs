{
  lib,
  fetchFromGitLab,
  callPackage,
}:

let
  version = "4.3.1";

  src = fetchFromGitLab {
    owner = "coolercontrol";
    repo = "coolercontrol";
    tag = version;
    hash = "sha256-nFlaiQtc4r3FBmdhErUAucG3SQ1GWQX9ClnZXGVWjbc=";
  };

  meta = {
    description = "Monitor and control your cooling devices";
    homepage = "https://gitlab.com/coolercontrol/coolercontrol";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      codifryed
      OPNA2608
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  applySharedDetails = drv: drv { inherit version src meta; };
in
{
  coolercontrol-gui = applySharedDetails (callPackage ./coolercontrol-gui.nix { });
  coolercontrol-ui-data = applySharedDetails (callPackage ./coolercontrol-ui-data.nix { });
  coolercontrold = applySharedDetails (callPackage ./coolercontrold.nix { });
}
