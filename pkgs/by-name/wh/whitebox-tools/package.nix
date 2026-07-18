{
  lib,
  fetchFromGitHub,
  atk,
  cmake,
  glib,
  gtk3,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "whitebox_tools";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "jblindsay";
    repo = "whitebox-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kvtfEEydwonoDux1VbAxqrF/Hf8Qh8mhprYnROGOC6g=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    atk
    glib
    gtk3
    openssl
  ];

  cargoHash = "sha256-yQFGuhEGgkaa5N4uUIZ/0GFzP9CsPtiFet0hUppIQzQ=";
  doCheck = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advanced geospatial data analysis platform";
    homepage = "https://jblindsay.github.io/ghrg/WhiteboxTools/index.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mpickering ];
    teams = [ lib.teams.geospatial ];
  };
})
