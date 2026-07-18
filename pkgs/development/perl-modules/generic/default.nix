{
  lib,
  stdenv,
  perl,
  toPerlModule,
}:

{
  # From http://wiki.cpantesters.org/wiki/CPANAuthorNotes: "allows
  # authors to skip certain tests (or include certain tests) when
  # the results are not being monitored by a human being."
  AUTOMATED_TESTING ? true,
  # Prevent CPAN downloads.
  PERL_AUTOINSTALL ? "--skipdeps",
  # current directory (".") is removed from @INC in Perl 5.26 but many old libs rely on it
  # https://metacpan.org/pod/release/XSAWYERX/perl-5.26.0/pod/perldelta.pod#Removal-of-the-current-directory-%28%22.%22%29-from-@INC
  PERL_USE_UNSAFE_INC ? "1",
  buildInputs ? [ ],
  checkTarget ? "test",
  doCheck ? true,
  # enabling or disabling does nothing for perl packages so set it explicitly
  # to false to not change hashes when enableParallelBuildingByDefault is enabled
  enableParallelBuilding ? false,
  env ? { },
  nativeBuildInputs ? [ ],
  outputs ? [
    "out"
    "devdoc"
  ],
  postPatch ? "patchShebangs .",
  ...
}@attrs:

lib.throwIf (attrs ? name)
  "buildPerlPackage: `name` (\"${attrs.name}\") is deprecated, use `pname` and `version` instead"

  (
    let
      defaultMeta = {
        inherit (perl.meta) platforms;
        homepage = "https://metacpan.org/dist/${attrs.pname}";
      };

      package = stdenv.mkDerivation (
        attrs
        // {
          inherit
            outputs
            doCheck
            checkTarget
            enableParallelBuilding
            postPatch
            ;

          nativeBuildInputs =
            nativeBuildInputs
            ++ (if !(stdenv.buildPlatform.canExecute stdenv.hostPlatform) then [ perl.mini ] else [ perl ]);

          buildInputs = buildInputs ++ [ perl ];

          env = {
            inherit PERL_AUTOINSTALL AUTOMATED_TESTING PERL_USE_UNSAFE_INC;
            fullperl = perl.__spliced.buildHost or perl;
          }
          // env;

          builder = ./builder.sh;
          name = "perl${perl.version}-${attrs.pname}-${attrs.version}";
          meta = defaultMeta // (attrs.meta or { });
        }
      );

    in
    toPerlModule package
  )
