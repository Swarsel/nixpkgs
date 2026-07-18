{ fetchurl }:
let
  pname = "roam-research";
  version = "0.0.24";
in
{
  inherit pname version;

  sources = {
    aarch64-darwin = fetchurl {
      hash = "sha256-fPtJAKfh65/dEryi0kdg+1hLfdvzBU87uS0y6eaaVy4=";
      url = "https://roam-electron-deploy.s3.us-east-2.amazonaws.com/Roam+Research-${version}-arm64.dmg";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-vpceynkr0/IOSqdmtVxKliSIJEGvLhczqgrsQyqPVIo=";
      url = "https://roam-electron-deploy.s3.us-east-2.amazonaws.com/${pname}_${version}_amd64.deb";
    };
  };
}
