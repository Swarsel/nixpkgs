{
  lib,
  fetchFromGitHub,
  fetchzip,
  openssl,
  pkg-config,
  ripunzip,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ripunzip";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "google";
    repo = "ripunzip";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oujRw/4yKNNqLJLTN4wxaOllSUGMu077YgWZkD0DJ4M=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-J6FtaWjeJhbSB1WoAbh6c4DeShPmqGgmh2NTNRS6CUk=";

  checkFlags = [
    # Skip tests involving network
    "--skip=unzip::http_range_reader::tests::test_with_accept_range"
    "--skip=unzip::http_range_reader::tests::test_without_accept_range"
    "--skip=unzip::seekable_http_reader::tests::test_big_readahead"
    "--skip=unzip::seekable_http_reader::tests::test_random_access"
    "--skip=unzip::seekable_http_reader::tests::test_small_readahead"
    "--skip=unzip::seekable_http_reader::tests::test_unlimited_readahead"
    "--skip=unzip::tests::test_extract_biggish_zip_from_ranges_server"
    "--skip=unzip::tests::test_extract_from_server"
    "--skip=unzip::tests::test_small_zip_from_no_content_length_server"
    "--skip=unzip::tests::test_small_zip_from_no_range_server"
    "--skip=unzip::tests::test_small_zip_from_ranges_server"
  ];

  setupHook = ./setup-hook.sh;

  passthru.tests = {
    version = testers.testVersion {
      package = ripunzip;
    };

    fetchzipWithRipunzip =
      testers.invalidateFetcherByDrvHash (fetchzip.override { unzip = ripunzip; })
        {
          hash = "sha256-BoErC5VL3Vpvkx6xJq6J+eUJrBnjVEdTuSo7zh98Jy4=";
          url = "https://github.com/google/ripunzip/archive/cb9caa3ba4b0e27a85e165be64c40f1f6dfcc085.zip";
        };
  };

  meta = {
    description = "Tool to unzip files in parallel";
    homepage = "https://github.com/google/ripunzip";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = [ lib.maintainers.lesuisse ];
    mainProgram = "ripunzip";
  };
})
