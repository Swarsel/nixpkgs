{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  zstd,
}:

rustPlatform.buildRustPackage {
  pname = "unzrip";
  version = "0-unstable-2023-04-16";

  src = fetchFromGitHub {
    owner = "quininer";
    repo = "unzrip";
    rev = "14ba4b4c9ff9c80444ecef762d665acaa5aecfce";
    hash = "sha256-QYu4PXWQGagj7r8lLs0IngIXzt6B8uq2qonycaGDg6g=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zstd
  ];

  cargoHash = "sha256-3EbZv4mguNT3FtqcDBJriqRGGzz/093AMHqH6c2xYvQ=";

  meta = {
    description = "Unzip implementation, support for parallel decompression, automatic detection encoding";
    homepage = "https://github.com/quininer/unzrip";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "unzrip";
  };
}
