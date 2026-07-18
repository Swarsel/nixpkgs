{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libsecret,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "sigtop";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "tbvdm";
    repo = "sigtop";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-HxU0A5t+O3414dIK/dmL1tUz3M7qrN4nQpEQfSmzhmc=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libsecret ];
  vendorHash = "sha256-qUXevafaUDxtaj+4e7ZxrUtkkX0T2WANp+axXdtQr+A=";

  makeFlags = [
    "PREFIX=\${out}"
  ];

  meta = {
    description = "Utility to export messages, attachments and other data from Signal Desktop";
    homepage = "https://github.com/tbvdm/sigtop";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ fricklerhandwerk ];
    platforms = lib.platforms.all;
    mainProgram = "sigtop";
  };
})
