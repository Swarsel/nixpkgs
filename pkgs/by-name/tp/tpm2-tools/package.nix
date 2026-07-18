{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  curl,
  libuuid,
  makeWrapper,
  openssl,
  pandoc,
  pkg-config,
  tpm2-tss,
  abrmdSupport ? true,
  enableManpages ? buildPackages.pandoc.compiler.bootstrapAvailable,
  tpm2-abrmd ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tpm2-tools";
  version = "5.7";

  src = fetchurl {
    url = "https://github.com/tpm2-software/tpm2-tools/releases/download/${finalAttrs.version}/tpm2-tools-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-OBDTa1B5JW9PL3zlUuIiE9Q7EDHBMVON+KLbw8VwmDo=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ]
  ++ lib.optionals enableManpages [
    pandoc
  ];

  buildInputs = [
    curl
    openssl
    tpm2-tss
    libuuid
  ];

  # Unit tests disabled, as they rely on a dbus session
  #configureFlags = [ "--enable-unit" ];
  doCheck = false;

  preFixup =
    let
      ldLibraryPath = lib.makeLibraryPath (
        [
          tpm2-tss
        ]
        ++ (lib.optional abrmdSupport tpm2-abrmd)
      );
    in
    ''
      wrapProgram $out/bin/tpm2 --suffix LD_LIBRARY_PATH : "${ldLibraryPath}"
      wrapProgram $out/bin/tss2 --suffix LD_LIBRARY_PATH : "${ldLibraryPath}"
    '';

  meta = {
    description = "Command line tools that provide access to a TPM 2.0 compatible device";
    homepage = "https://github.com/tpm2-software/tpm2-tools";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ scottstephens ];
    platforms = lib.platforms.linux;
  };
})
