class Mpich < Formula
  desc "Implementation of the MPI Message Passing Interface standard"
  homepage "https://www.mpich.org/"
  url "https://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2.tar.gz"
  mirror "https://fossies.org/linux/misc/mpich-3.3.2.tar.gz"
  sha256 "4bfaf8837a54771d3e4922c84071ef80ffebddbb6971a006038d91ee7ef959b9"
  license "mpich2"
  revision 1

  bottle do
    cellar :any
    sha256 "3927047d7322310cef941a5e790c43b858a29716bea54d493bd1901b8d0bcb3d" => :catalina
    sha256 "44511bb2ad213ccc7e47a505895cf6aa4dbdd1a7dbba468095a130e83ca7bff3" => :mojave
    sha256 "0498e1ee125ed94a3822179663e552ecf29bdca1ae3837520284fadae3782cef" => :high_sierra
  end

  head do
    url "https://github.com/pmodels/mpich.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  conflicts_with "open-mpi", because: "both install MPI compiler wrappers"

  def install
    if build.head?
      # ensure that the consistent set of autotools built by homebrew is used to
      # build MPICH, otherwise very bizarre build errors can occur
      ENV["MPICH_AUTOTOOLS_DIR"] = HOMEBREW_PREFIX + "bin"
      system "./autogen.sh"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-fortran",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"

    system "make"
    #system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"hello.c").write <<~EOS
      #include <mpi.h>
      #include <stdio.h>

      int main()
      {
        int size, rank, nameLen;
        char name[MPI_MAX_PROCESSOR_NAME];
        MPI_Init(NULL, NULL);
        MPI_Comm_size(MPI_COMM_WORLD, &size);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        MPI_Get_processor_name(name, &nameLen);
        printf("[%d/%d] Hello, world! My name is %s.\\n", rank, size, name);
        MPI_Finalize();
        return 0;
      }
    EOS
    system "#{bin}/mpicc", "hello.c", "-o", "hello"
    system "./hello"
    system "#{bin}/mpirun", "-np", "4", "./hello"
  end
end
