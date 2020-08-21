class Go < Formula
  desc "Open source programming language to build simple/reliable/efficient software"
  homepage "https://golang.org"
  license "BSD-3-Clause"

  stable do
<<<<<<< Updated upstream
    url "https://golang.org/dl/go1.15.src.tar.gz"
    mirror "https://fossies.org/linux/misc/go1.15.src.tar.gz"
    sha256 "69438f7ed4f532154ffaf878f3dfd83747e7a00b70b3556eddabf7aaee28ac3a"
=======
<<<<<<< Updated upstream
    url "https://golang.org/dl/go1.14.7.src.tar.gz"
=======
    url "https://dl.google.com/go/go1.14.7.src.tar.gz"
>>>>>>> Stashed changes
    mirror "https://fossies.org/linux/misc/go1.14.7.src.tar.gz"
    sha256 "064392433563660c73186991c0a315787688e7c38a561e26647686f89b6c30e3"
>>>>>>> Stashed changes

    go_version = version.to_s.split(".")[0..1].join(".")
    resource "gotools" do
      url "https://go.googlesource.com/tools.git",
          branch: "release-branch.go#{go_version}"
    end
  end

  bottle do
    sha256 "36ef2e4cc3ecc84e0c1e98580a63f8d417efc8831f0c59b0a7e13d517c61353b" => :catalina
    sha256 "ea373dd668c31caa9816a5028028694425635cc3871783709381d872906fa78e" => :mojave
    sha256 "a29ea808ffac13d3967dee44f30a9f72709b941f7e82836715f939970e6cb222" => :high_sierra
  end

  head do
    url "https://go.googlesource.com/go.git"

    resource "gotools" do
      url "https://go.googlesource.com/tools.git"
    end
  end

  depends_on macos: :sierra

  # Don't update this unless this version cannot bootstrap the new version.
  resource "gobootstrap" do
    on_macos do
      url "https://storage.googleapis.com/golang/go1.14.7.darwin-amd64.tar.gz"
      sha256 "9a71abeb3de60ed33c0f90368be814d140bc868963e90fbb98ea665335ffbf9a"
    end

    on_linux do
      url "https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz"
      sha256 "702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95"
    end
  end

  def install
    (buildpath/"gobootstrap").install resource("gobootstrap")
    ENV["GOROOT_BOOTSTRAP"] = buildpath/"gobootstrap"
    ENV["GOARCH"]       = "arm64"

    cd "src" do
      ENV["GOROOT_FINAL"] = libexec
      ENV["GOOS"]         = "darwin"
      ENV["GOARCH"]       = "arm64"
      system "./make.bash", "--no-clean"
    end

    (buildpath/"pkg/obj").rmtree
    rm_rf "gobootstrap" # Bootstrap not required beyond compile.
    libexec.install Dir["*"]
    bin.install_symlink Dir[libexec/"bin/go*"]

    system bin/"go", "install", "-race", "std"

    # Build and install godoc
    ENV.prepend_path "PATH", bin
    ENV["GOPATH"] = buildpath
    (buildpath/"src/golang.org/x/tools").install resource("gotools")
    cd "src/golang.org/x/tools/cmd/godoc/" do
      system "go", "build"
      (libexec/"bin").install "godoc"
    end
    bin.install_symlink libexec/"bin/godoc"
  end

  test do
    (testpath/"hello.go").write <<~EOS
      package main

      import "fmt"

      func main() {
          fmt.Println("Hello World")
      }
    EOS
    # Run go fmt check for no errors then run the program.
    # This is a a bare minimum of go working as it uses fmt, build, and run.
    system bin/"go", "fmt", "hello.go"
    assert_equal "Hello World\n", shell_output("#{bin}/go run hello.go")

    # godoc was installed
    assert_predicate libexec/"bin/godoc", :exist?
    assert_predicate libexec/"bin/godoc", :executable?

    ENV["GOOS"] = "freebsd"
    ENV["GOARCH"] = "amd64"
    system bin/"go", "build", "hello.go"
  end
end
