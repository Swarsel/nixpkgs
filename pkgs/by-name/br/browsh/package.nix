{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "1.8.3";

  # TODO: must build the extension instead of downloading it. But since it's
  # literally an asset that is indifferent regardless of the platform, this
  # might be just enough.
  webext = fetchurl {
    hash = "sha256-wLctfGHDCgy3nMG/nc882qNjHOAp8VeOZcEWJD7QThY=";
    url = "https://github.com/browsh-org/browsh/releases/download/v${version}/browsh-${version}.xpi";
  };

in

buildGoModule rec {
  inherit version;
  pname = "browsh";

  src = fetchFromGitHub {
    owner = "browsh-org";
    repo = "browsh";
    rev = "v${version}";
    hash = "sha256-Abna1bAaqOT44zZJsObLMR5fTW2xlWBg1M0JYH0Yc6g=";
  };

  vendorHash = "sha256-481dC7UrNMnb1QswvK2FqUiioTZ9xJP4dSd3rvRkqro=";

  preBuild = ''
    cp "${webext}" src/browsh/browsh.xpi
  '';

  # Tests require network access
  doCheck = false;
  sourceRoot = "${src.name}/interfacer";

  meta = {
    description = "Fully-modern text-based browser, rendering to TTY and browsers";
    homepage = "https://www.brow.sh/";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      kalbasit
      siraben
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "browsh";
  };
}
