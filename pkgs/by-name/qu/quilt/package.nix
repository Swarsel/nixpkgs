{
  lib,
  stdenv,
  fetchurl,
  bash,
  coreutils,
  diffstat,
  diffutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  makeWrapper,
  patch,
  perl,
  unixtools,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "quilt";
  version = "0.69";

  src = fetchurl {
    url = "mirror://savannah/quilt/quilt-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-VV3f/eIto8htHK9anB+4oVKsK4RzBDe9OcwIhJyfSFI=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bash
    coreutils
    diffstat
    diffutils
    findutils
    gawk
    gnugrep
    gnused
    patch
    perl
    unixtools.column
    unixtools.getopt
  ];

  configureFlags = [
    # configure only looks in $PATH by default,
    # which does not include buildInputs if strictDeps is true
    "--with-perl=${lib.getExe perl}"
  ];

  postInstall = ''
    wrapProgram $out/bin/quilt --prefix PATH : ${lib.makeBinPath finalAttrs.buildInputs}
  '';

  meta = {
    description = "Easily manage large numbers of patches";

    longDescription = ''
      Quilt allows you to easily manage large numbers of
      patches by keeping track of the changes each patch
      makes. Patches can be applied, un-applied, refreshed,
      and more.
    '';

    homepage = "https://savannah.nongnu.org/projects/quilt";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ smancill ];
    platforms = lib.platforms.all;
  };

})
