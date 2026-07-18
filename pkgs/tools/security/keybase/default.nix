{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gnupg,
  replaceVars,
}:

buildGoModule rec {
  pname = "keybase";
  version = "6.5.1";

  src = fetchFromGitHub {
    owner = "keybase";
    repo = "client";
    rev = "v${version}";
    hash = "sha256-B3vedsxQM4FDZVpkMKR67DF7FtaTPhGIJ1e2lViKYzg=";
  };

  patches = [
    (replaceVars ./fix-paths-keybase.patch {
      gpg = "${gnupg}/bin/gpg";
      gpg2 = "${gnupg}/bin/gpg2";
    })
  ];

  vendorHash = "sha256-uw1tiaYoMpMXCYt5bPL5OBbK09PJmAQYQDrDwuPShxU=";
  dontRenameImports = true;

  ldflags = [
    "-s"
    "-w"
  ];

  modRoot = "go";

  subPackages = [
    "kbnm"
    "keybase"
  ];

  tags = [ "production" ];

  meta = {
    description = "Keybase official command-line utility and service";
    homepage = "https://www.keybase.io/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      avaq
      np
      rvolosatovs
      shofius
      ryand56
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "keybase";
  };
}
