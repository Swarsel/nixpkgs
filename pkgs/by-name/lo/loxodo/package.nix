{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "loxodo";
  version = "0-unstable-2021-02-08";

  src = fetchFromGitHub {
    owner = "sommer";
    repo = "loxodo";
    rev = "7add982135545817e9b3e2bbd0d27a2763866133";
    sha256 = "1cips4pvrqga8q1ibs23vjrf8dwan860x8jvjmc52h6qvvvv60yl";
  };

  patches = [ ./wxpython.patch ];
  doCheck = false; # Tests are interactive.

  postInstall = ''
    mv $out/bin/loxodo.py $out/bin/loxodo
    mkdir -p $out/share/applications
    cat > $out/share/applications/loxodo.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Exec=$out/bin/loxodo
    Icon=$out/${python3.sitePackages}/resources/loxodo-icon.png
    Name=Loxodo
    GenericName=Password Vault
    Categories=Application;Other;
    EOF
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    six
    wxpython
  ];

  pyproject = true;

  meta = {
    description = "Password Safe V3 compatible password vault";
    homepage = "https://www.christoph-sommer.de/loxodo/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "loxodo";
  };
}
