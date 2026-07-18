{
  lib,
  fetchFromCodeberg,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyper8";
  version = "1.0.1";

  src = fetchFromCodeberg {
    owner = "simonrepp";
    repo = "hyper8";
    tag = finalAttrs.version;
    hash = "sha256-pvtQPL/hPgoKDLYWC/IL04db7Q/FUlgiExthu4xBQEw=";
  };

  cargoHash = "sha256-AQAWGmzixDFfL7wqJJXCvNSYojVtYHRP0zqdj0C8JRE=";
  __structuredAttrs = true;

  meta = {
    description = "Static site generator for video publishing.";
    homepage = "https://hyper8.org";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
    mainProgram = "hyper8";
  };
})
