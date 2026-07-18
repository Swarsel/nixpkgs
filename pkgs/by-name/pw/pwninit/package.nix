{
  lib,
  fetchFromGitHub,
  elfutils,
  makeBinaryWrapper,
  openssl,
  pkg-config,
  rustPlatform,
  xz,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pwninit";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "io12";
    repo = "pwninit";
    rev = finalAttrs.version;
    sha256 = "sha256-WKOndOkaKr+dUnx61LW6ZZxUFUESerjE5W6hgLA3n1o=";
  };

  nativeBuildInputs = [
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [
    openssl
    xz
  ];

  cargoHash = "sha256-KMvaKTNC84K6N0NAZizK9M1nP4rV4cfwlOTI/HidQYc=";
  doCheck = false; # there are no tests to run

  postInstall = ''
    wrapProgram $out/bin/pwninit \
      --prefix PATH : "${lib.getBin elfutils}/bin"
  '';

  meta = {
    description = "Automate starting binary exploit challenges";
    homepage = "https://github.com/io12/pwninit";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.scoder12 ];
    platforms = lib.platforms.all;
    mainProgram = "pwninit";
  };
})
