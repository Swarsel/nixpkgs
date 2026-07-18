{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  runCommand,
  testers,
  uglify-js,
  writeText,
}:

buildNpmPackage rec {
  pname = "uglify-js";
  version = "3.19.3";

  src = fetchFromGitHub {
    owner = "mishoo";
    repo = "UglifyJS";
    rev = "v${version}";
    hash = "sha256-sMLQSB1+ux/ya/J22KGojlAxWhtPQdk22KdHy43zdyg=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-/Xb8DT7vSzZPEd+Z+z1BlFnrOeOwGP+nGv2K9iz6lKI=";
  dontNpmBuild = true;

  passthru = {
    tests = {
      version = testers.testVersion { package = uglify-js; };

      simple = testers.testEqualContents {
        actual =
          runCommand "actual"
            {
              nativeBuildInputs = [ uglify-js ];

              base = writeText "base" ''
                console . log  ( ( 1 ) ) ;
              '';
            }
            ''
              uglifyjs $base > $out
            '';

        assertion = "uglify-js minifies a basic js file";

        expected = writeText "expected" ''
          console.log(1);
        '';
      };
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "JavaScript parser / mangler / compressor / beautifier toolkit";
    homepage = "https://github.com/mishoo/UglifyJS";
    changelog = "https://github.com/mishoo/UglifyJS/releases/tag/v" + version;
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ lelgenio ];
    mainProgram = "uglifyjs";
  };
}
