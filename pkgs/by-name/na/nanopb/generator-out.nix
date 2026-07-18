{
  stdenv,
  cmake,
  protobuf,
  python3,
  src,
  version,
  writeTextFile,
}:

let
  pyproject_toml = writeTextFile {
    name = "pyproject.toml";

    text = ''
      [build-system]
      requires = ["setuptools"]
      build-backend = "setuptools.build_meta"

      [tool.setuptools]
      include-package-data = true

      [tool.setuptools.packages.find]
      where = ["src"]

      [tool.setuptools.package-data]
      "*" = ["nanopb.proto"]

      [project]
      name = "nanopb"
      version = "${version}"
      dependencies = [
        "setuptools",
        "protobuf",
        "six"
      ]
    '';
  };
in
stdenv.mkDerivation {
  inherit src version;
  pname = "nanopb-generator-out";

  nativeBuildInputs = [
    cmake
    protobuf
  ];

  cmakeFlags = [
    "-Dnanopb_BUILD_RUNTIME=OFF"
    "-Dnanopb_BUILD_GENERATOR=ON"
    "-Dnanopb_PYTHON_INSTDIR_OVERRIDE=${placeholder "out"}/${python3.sitePackages}"
  ];

  # don't let `find_program` find the bundled `protoc` script, so it will use the system `protoc` instead
  preConfigure = ''
    rm generator/protoc
  '';

  postInstall = ''
    rm -rf $out/include
    rm -rf $out/lib/cmake
    ln -s $out/${python3.sitePackages} $out/src
    ln -s ${pyproject_toml} $out/pyproject.toml
  '';
}
