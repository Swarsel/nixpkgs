{
  lib,
  fetchFromGitHub,
  buildGoModule,
  e2tools,
  makeWrapper,
  mtools,
}:

buildGoModule (finalAttrs: {
  pname = "fwanalyzer";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "cruise-automation";
    repo = "fwanalyzer";
    rev = finalAttrs.version;
    sha256 = "sha256-fcqtyfpxdjD+1GsYl05RSJaFDoLSYQDdWcQV6a+vNGA=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-nLr12VQogr4nV9E/DJu2XTcgEi7GsOdOn/ZqVk7HS7I=";
  # The tests requires an additional setup (unpacking images, etc.)
  doCheck = false;

  postInstall = ''
    wrapProgram "$out/bin/fwanalyzer" --prefix PATH : "${
      lib.makeBinPath [
        e2tools
        mtools
      ]
    }"
  '';

  subPackages = [ "cmd/fwanalyzer" ];

  meta = {
    description = "Tool to analyze filesystem images";
    homepage = "https://github.com/cruise-automation/fwanalyzer";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "fwanalyzer";
  };
})
