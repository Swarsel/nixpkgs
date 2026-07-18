{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  libxcrypt,
  nixosTests,
  pam,
  withPAM ? true,
  withTimestamp ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "doas";
  version = "6.8.2";

  src = fetchFromGitHub {
    owner = "Duncaen";
    repo = "OpenDoas";
    rev = "v${finalAttrs.version}";
    sha256 = "9uOQ2Ta5HzEpbCz2vbqZEEksPuIjL8lvmfmynfqxMeM=";
  };

  patches = [
    # Allow doas to discover binaries in /run/current-system/sw/{s,}bin and
    # /run/wrappers/bin
    ./0001-add-NixOS-specific-dirs-to-safe-PATH.patch
  ];

  postPatch = ''
    sed -i '/\(chown\|chmod\)/d' GNUmakefile
  ''
  + lib.optionalString (withPAM && stdenv.hostPlatform.isStatic) ''
    sed -i 's/-lpam/-lpam -laudit/' configure
  '';

  nativeBuildInputs = [ bison ];
  buildInputs = [ ] ++ lib.optional withPAM pam ++ lib.optional (!withPAM) libxcrypt;

  configureFlags = [
    (lib.optionalString withTimestamp "--with-timestamp") # to allow the "persist" setting
    (lib.optionalString (!withPAM) "--without-pam")
  ];

  # ./configure script does not understand `--disable-shared`
  dontAddStaticConfigureFlags = true;
  # otherwise confuses ./configure
  dontDisableStatic = true;
  passthru.tests = { inherit (nixosTests) doas; };

  meta = {
    description = "Executes the given command as another user";
    homepage = "https://github.com/Duncaen/OpenDoas";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ cole-h ];
    platforms = lib.platforms.linux;
    mainProgram = "doas";
  };
})
