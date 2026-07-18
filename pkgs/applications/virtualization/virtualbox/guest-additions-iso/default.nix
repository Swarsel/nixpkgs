{
  lib,
  fetchurl,
  virtualboxVersion,
}:
fetchurl {
  sha256 = "306b1dea6022647bde19424816b995714fa5815ff7bdf00f6a015bf8af0839e7";
  url = "http://download.virtualbox.org/virtualbox/${virtualboxVersion}/VBoxGuestAdditions_${virtualboxVersion}.iso";

  meta = {
    description = "Guest additions ISO for VirtualBox";

    longDescription = ''
      ISO containing various add-ons which improves guests inside VirtualBox.
    '';

    license = lib.licenses.gpl2;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = [
      lib.maintainers.friedrichaltheide
    ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
