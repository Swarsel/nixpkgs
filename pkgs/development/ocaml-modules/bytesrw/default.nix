{
  lib,
  buildTopkgPackage,
  cmdliner,
  fetchzip,
  libblake3,
  libmd,
  mbedtls_4,
  topkg,
  xxhash,
  zlib,
  zstd,
  withBlake3 ? true,
  withCmdliner ? false,
  withLibmd ? true,
  withMbedtls ? true,
  withXxh ? true,
  withZlib ? true,
  withZstd ? true,
}:

buildTopkgPackage rec {
  pname = "bytesrw";
  version = "0.3.0";

  src = fetchzip {
    url = "https://erratique.ch/software/bytesrw/releases/bytesrw-${version}.tbz";
    hash = "sha256-EFdHKBH4VrWvOqs+I6tiRW9D2s6lY8Pol4YyuB7fqh8=";
  };

  # certown is a CA utility that uses missing b0 APIs (Os.name, Os.Name).
  # …but this is only need if enabling Cmdliner
  postPatch = lib.optionalString withCmdliner ''
    substituteInPlace pkg/pkg.ml --replace-fail \
      'Pkg.bin ~cond:(b0 && cmdliner && mbedtls) "test/certown";' ""
  '';

  buildInputs =
    lib.optional withBlake3 libblake3
    ++ lib.optional withLibmd libmd
    ++ lib.optional withMbedtls mbedtls_4
    ++ lib.optional withXxh xxhash
    ++ lib.optional withZlib zlib
    ++ lib.optional withZstd zstd
    ++ lib.optional withCmdliner cmdliner;

  buildPhase = "${topkg.run} build ${
    lib.escapeShellArgs [
      "--with-conf-libblake3"
      (lib.boolToString withBlake3)

      "--with-conf-libmd"
      (lib.boolToString withLibmd)

      "--with-conf-mbedtls"
      (lib.boolToString withMbedtls)

      "--with-conf-xxhash"
      (lib.boolToString withXxh)

      "--with-conf-zlib"
      (lib.boolToString withZlib)

      "--with-conf-zstd"
      (lib.boolToString withZstd)

      "--with-cmdliner"
      (lib.boolToString withCmdliner)
    ]
  }";

  minimalOCamlVersion = "4.14.0";

  meta = {
    description = "Composable, memory efficient, byte stream readers and writers compatible with effect-based concurrency";

    longDescription = ''
      Bytesrw extends the OCaml Bytes module with composable, memory efficient,
      byte stream readers and writers compatible with effect-based concurrency.

      Except for byte slice life-times, these abstractions intentionally
      separate away resource management and the specifics of reading and
      writing bytes.
    '';

    homepage = "https://erratique.ch/software/bytesrw";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ toastal ];
  };
}
