{
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  openssl,
  openwsman,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wsmancli";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "Openwsman";
    repo = "wsmancli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pTA5p5+Fuiw2lQaaSKnp/29HMy8NZNTFwP5K/+sJ9OU=";
  };

  postPatch = ''
    touch AUTHORS NEWS README
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    openwsman
    openssl
  ];

  meta = {
    inherit (openwsman.meta)
      homepage
      license
      maintainers
      platforms
      ;

    description = "Openwsman command-line client";

    longDescription = ''
      Openwsman provides a command-line tool, wsman, to perform basic
      operations on the command-line. These operations include Get, Put,
      Invoke, Identify, Delete, Create, and Enumerate. The command-line tool
      also has several switches to allow for optional features of the
      WS-Management specification and Testing.
    '';

    downloadPage = "https://github.com/Openwsman/wsmancli/releases";
  };
})
