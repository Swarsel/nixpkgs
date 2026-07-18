{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "sammler";
  version = "20210523-${lib.strings.substring 0 7 rev}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "redcode-labs";
    repo = "Sammler";
    sha256 = "1gsv83sbqc9prkigbjvkhh547w12l3ynbajpnbqyf8sz4bd1nj5c";
  };

  vendorHash = "sha256-0ZBPLONUZyazZ22oLO097hdX5xuHx2G6rZCAsCwqq4s=";
  rev = "259b9fc6155f40758e5fa480683467c35df746e7";
  subPackages = [ "." ];

  meta = {
    description = "Tool to extract useful data from documents";
    homepage = "https://github.com/redcode-labs/Sammler";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "sammler";
  };
}
