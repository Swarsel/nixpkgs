{
  lib,
  advancecomp,
  bundlerApp,
  bundlerUpdateScript,
  gifsicle,
  jhead,
  jpeg-archive,
  jpegoptim,
  libjpeg,
  makeWrapper,
  optipng,
  oxipng,
  pngcrush,
  pngout, # disabled by default because it's unfree
  pngquant,
  svgo,
  withAdvpng ? true,
  withGifsicle ? true,
  withJhead ? true,
  withJpegoptim ? true,
  withJpegrecompress ? true,
  withJpegtran ? true,
  withOptipng ? true,
  withOxipng ? true,
  withPngcrush ? true,
  withPngout ? false,
  withPngquant ? true,
  withSvgo ? true,
}:

let
  optionalDepsPath =
    lib.optional withPngcrush pngcrush
    ++ lib.optional withPngout pngout
    ++ lib.optional withAdvpng advancecomp
    ++ lib.optional withOptipng optipng
    ++ lib.optional withPngquant pngquant
    ++ lib.optional withOxipng oxipng
    ++ lib.optional withJhead jhead
    ++ lib.optional withJpegoptim jpegoptim
    ++ lib.optional withJpegrecompress jpeg-archive
    ++ lib.optional withJpegtran libjpeg
    ++ lib.optional withGifsicle gifsicle
    ++ lib.optional withSvgo svgo;

  disabledWorkersFlags =
    lib.optional (!withPngcrush) "--no-pngcrush"
    ++ lib.optional (!withPngout) "--no-pngout"
    ++ lib.optional (!withAdvpng) "--no-advpng"
    ++ lib.optional (!withOptipng) "--no-optipng"
    ++ lib.optional (!withPngquant) "--no-pngquant"
    ++ lib.optional (!withOxipng) "--no-oxipng"
    ++ lib.optional (!withJhead) "--no-jhead"
    ++ lib.optional (!withJpegoptim) "--no-jpegoptim"
    ++ lib.optional (!withJpegrecompress) "--no-jpegrecompress"
    ++ lib.optional (!withJpegtran) "--no-jpegtran"
    ++ lib.optional (!withGifsicle) "--no-gifsicle"
    ++ lib.optional (!withSvgo) "--no-svgo";
in

bundlerApp {
  pname = "image_optim";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/image_optim \
      --prefix PATH : ${lib.escapeShellArg (lib.makeBinPath optionalDepsPath)} \
      --add-flags "${lib.concatStringsSep " " disabledWorkersFlags}"
  '';

  exes = [ "image_optim" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "image_optim";

  meta = {
    description = "Optimize images using multiple utilities";

    longDescription = ''
      Command line tool and ruby interface to optimize (lossless compress,
      optionally lossy) jpeg, png, gif and svg images using external utilities
      (advpng, gifsicle, jhead, jpeg-recompress, jpegoptim, jpegrescan,
      jpegtran, optipng, oxipng, pngcrush, pngout, pngquant, svgo)
    '';

    homepage = "https://github.com/toy/image_optim";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.all;
    mainProgram = "image_optim";
  };
}
