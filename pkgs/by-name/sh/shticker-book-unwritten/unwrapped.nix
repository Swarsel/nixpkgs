{
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shticker-book-unwritten";
  version = "1.2.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-jI2uL8tMUmjZ5jPkCV2jb98qtKwi9Ti4NVCPfuO3iB4=";
    crateName = "shticker_book_unwritten";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-0eumZoAL8/nkeFS+sReCAYKHiXiqZHfdC/9Ao5U6/SQ=";
})
