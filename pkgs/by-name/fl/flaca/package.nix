{
  lib,
  fetchurl,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flaca";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "Blobfolio";
    repo = "flaca";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LVk+2zt7Abku3bR5FnpugztMy0A3LmpO2yBkZO1jjxc=";
  };

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  cargoHash = "sha256-73O/h7Cuh+to9MpQ97daPFKI4ACtT0aer3h0EmKKcoA=";

  lockFile = fetchurl {
    hash = "sha256-GNpL51rx3na+ECHUl0JAUQJBRQQ12Ubg4RIhNfXxMRQ=";
    url = "https://github.com/Blobfolio/flaca/releases/download/v${finalAttrs.version}/Cargo.lock";
  };

  postUnpack = ''
    ln -s ${finalAttrs.lockFile} ${finalAttrs.src.name}/Cargo.lock
  '';

  meta = {
    description = "CLI tool to losslessly compress JPEG and PNG images";
    longDescription = "A CLI tool for x86-64 Linux machines that simplifies the task of maximally, losslessly compressing JPEG and PNG images for use in production web environments";
    homepage = "https://github.com/Blobfolio/flaca";
    changelog = "https://github.com/Blobfolio/flaca/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ zzzsy ];
    platforms = lib.platforms.linux;
    mainProgram = "flaca";
  };
})
