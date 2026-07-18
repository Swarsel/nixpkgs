{
  lib,
  fetchFromGitHub,
  ghostscript,
  installShellFiles,
  perlPackages,
  replaceVars,
}:

perlPackages.buildPerlPackage rec {
  pname = "ps2eps";
  version = "1.70";

  src = fetchFromGitHub {
    owner = "roland-bless";
    repo = "ps2eps";
    rev = "v${version}";
    hash = "sha256-SPLwsGKLVhANoqSQ/GJ938cYjbjMbUOXkNn9so3aJTA=";
  };

  # Override buildPerlPackage's outputs setting
  outputs = [
    "out"
    "man"
  ];

  patches = [
    (replaceVars ./hardcode-deps.patch {
      # bbox cannot be substituted here because replaceVars doesn't know what
      # will be the $out path of the main derivation
      bbox = null;
      gs = "${ghostscript}/bin/gs";
    })
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  buildPhase = ''
    runHook preBuild

    make -C src/C bbox
    patchShebangs src/perl/ps2eps
    substituteInPlace src/perl/ps2eps \
      --replace @bbox@ $out/bin/bbox

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    installManPage \
      doc/ps2eps.1 \
      doc/bbox.1

    install -D src/perl/ps2eps $out/bin/ps2eps
    install -D src/C/bbox $out/bin/bbox

    runHook postInstall
  '';

  configurePhase = "true";

  meta = {
    inherit (src.meta) homepage;
    description = "Calculate correct bounding boxes for PostScript and PDF files";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.doronbehar ];
    platforms = lib.platforms.unix;
  };
}
