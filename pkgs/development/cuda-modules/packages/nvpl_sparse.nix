{ buildRedist }:
buildRedist {
  pname = "nvpl_sparse";

  outputs = [
    "out"
    "dev"
    "include"
    "lib"
  ];

  redistName = "nvpl";

  meta = {
    description = "Provides a set of CPU-accelerated basic linear algebra subroutines used for handling sparse matrices";
    homepage = "https://developer.nvidia.com/nvpl";
    changelog = "https://docs.nvidia.com/nvpl/latest/sparse/release_notes.html";
  };
}
