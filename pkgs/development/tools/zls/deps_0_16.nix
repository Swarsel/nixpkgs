{
  fetchzip,
  linkFarm,
}:
linkFarm "zig-packages" [
  {
    name = "known_folders-0.0.0-Fy-PJk3KAACzUg2us_0JvQQmod1ZA8jBt7MuoKCihq88";

    path = fetchzip {
      hash = "sha256-8LlAnEwuoeQuN9V5nUuh2UwXRhS5KOwDkpm6yuOfClk=";
      url = "https://github.com/ziglibs/known-folders/archive/d6d03830968cca6b7b9f24fd97ee348346a6905d.tar.gz";
    };
  }
  {
    name = "diffz-0.0.1-G2tlISzNAQCldmOcINavGmF1zdt20NFPXeM8d07jp_68";

    path = fetchzip {
      hash = "sha256-mmgaOXFpoBYMsNdVkoFa7wJKkiXtzXIbSxRUgWLdVUc=";
      url = "https://github.com/ziglibs/diffz/archive/b39fe07e7fdbcf56e43ba2890b9f484f16969f90.tar.gz";
    };
  }
  {
    name = "lsp_kit-0.1.0-bi_PL3IyDACfp1xdTnkiOHEok2YpPCCCJHuuOcNzjl1D";

    path = fetchzip {
      hash = "sha256-367wPydvnpl9RYlTrXwk4bZ/ui9DbYjeY/VDYs7ZJRs=";
      url = "https://github.com/zigtools/lsp-kit/archive/b886a2b0d5cee85ecbcc3089b863f7517cc9ff7f.tar.gz";
    };
  }
]
