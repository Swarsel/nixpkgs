{
  lib,
  stdenv,
  fetchurl,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vcal";
  version = "2.8";

  src = fetchurl {
    url = "https://waynemorrison.com/software/vcal";
    sha256 = "0jrm0jzqxb1xjp24hwbzlxsh22gjssay9gj4zszljzdm68r5afvc";
  };

  nativeBuildInputs = [ perl ]; # for pod2man
  # There are no tests
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/man/man1}
    substitute ${finalAttrs.src} $out/bin/vcal \
      --replace /usr/bin/perl ${perl}/bin/perl
    chmod 0755 $out/bin/*
    pod2man --name=vcal --release=${finalAttrs.version} ${finalAttrs.src} > $out/share/man/man1/vcal.1

    runHook postInstall
  '';

  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "Parser for VCalendar and ICalendar files, usable from the command line";
    homepage = "https://waynemorrison.com/software/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "vcal";
  };
})
