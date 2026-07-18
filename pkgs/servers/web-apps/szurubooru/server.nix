{
  lib,
  fetchPypi,
  ffmpeg_4-full,
  nixosTests,
  python3,
  src,
  szurubooru,
  version,
}:

let
  overrides = [
    (self: super: {
      alembic = super.alembic.overridePythonAttrs (oldAttrs: rec {
        version = "1.14.1";

        src = fetchPypi {
          inherit version;
          sha256 = "sha256-SW6IgkWlOt8UmPyrMXE6Rpxlg2+N524BOZqhw+kN0hM=";
          pname = "alembic";
        };

        doCheck = false;
      });
    })
  ];

  python = python3.override {
    packageOverrides = lib.composeManyExtensions overrides;
    self = python;
  };
in

python.pkgs.buildPythonApplication {
  inherit version;
  pname = "szurubooru-server";
  src = "${src}/server";

  patches = [
    ./001-server-pillow-heif.patch
  ];

  nativeBuildInputs = with python.pkgs; [ setuptools ];

  propagatedBuildInputs = with python.pkgs; [
    certifi
    coloredlogs
    legacy-cgi
    numpy
    pillow
    pillow-heif
    psycopg2-binary
    pynacl
    pyrfc3339
    pytz
    pyyaml
    sqlalchemy_1_3
    yt-dlp
  ];

  postInstall = ''
    mkdir $out/bin
    install -m0755 $src/szuru-admin $out/bin/szuru-admin
  '';

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg_4-full ]}"
  ];

  pyproject = true;

  # Database migration. Needs the szurubooru server in its environment for the
  # migration to complete successfully.
  passthru.alembic = python.pkgs.alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      szurubooru.server
    ];
  });

  passthru.tests.szurubooru = nixosTests.szurubooru;

  # Waitress is used to run the serer.
  passthru.waitress = python.pkgs.waitress.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      szurubooru.server
    ];
  });

  meta = {
    description = "Server of szurubooru, an image board engine for small and medium communities";
    homepage = "https://github.com/rr-/szurubooru";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ratcornu ];
  };
}
