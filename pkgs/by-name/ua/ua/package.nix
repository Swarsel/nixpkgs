{
  lib,
  fetchFromGitHub,
  buildGoModule,
  glib,
  libxml2,
  pkg-config,
}:

buildGoModule {
  pname = "ua";
  version = "0-unstable-2022-10-23";

  src = fetchFromGitHub {
    owner = "sloonz";
    repo = "ua";
    rev = "f636f5eec425754d8a8be8e767c5b3e4f31fe1f9";
    hash = "sha256-U9fApk/dyz7xSho2W8UT0OGIeOYR/v9lM0LHN2OqTEQ=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    libxml2
  ];

  vendorHash = "sha256-0O80uhxSVsV9N7Z/FgaLwcjZqeb4MqSCE1YW5Zd32ns=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Universal Aggregator";
    homepage = "https://github.com/sloonz/ua";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
}
