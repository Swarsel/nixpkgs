{
  buildDunePackage,
  landmarks,
  ppxlib,
}:

buildDunePackage {
  inherit (landmarks) src version;
  pname = "landmarks-ppx";
  buildInputs = [ ppxlib ];
  propagatedBuildInputs = [ landmarks ];
  doCheck = true;
  minimalOCamlVersion = "5.3";

  meta = landmarks.meta // {
    description = "Preprocessor instrumenting code using the landmarks library";

    longDescription = ''
      Automatically or semi-automatically instrument your code using
      landmarks library.
    '';
  };
}
