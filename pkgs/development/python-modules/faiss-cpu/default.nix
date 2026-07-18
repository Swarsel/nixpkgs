{
  faiss,
  mkPythonMetaPackage,
}:

mkPythonMetaPackage {
  inherit (faiss) version;
  pname = "faiss-cpu";
  dependencies = [ faiss ];

  meta = {
    inherit (faiss.meta) description homepage;
  };
}
