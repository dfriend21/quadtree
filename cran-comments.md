## Update - quadtree 0.1.9

After quadtree 0.1.8 was accepted to CRAN , 'valgrind' detected a memory leak. It was occurring in an unnecessary function - I simply removed that function.

## Test environments

* local OS X install, R 4.1.2
* R-hub: Debian Linux, R-devel, GCC ASAN/UBSAN
* R-hub: Fedora Linux, R-devel, clang, gfortran
* R-hub: Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub: Oracle Solaris 10, x86, 32 bit, R-release
* R-hub: Windows Server 2022, R-devel, 64 bit
* win-builder (devel, release, oldrelease)

## R CMD check results

The local OS X install, Oracle Solaris 10, Windows Server 2022, and win-builder (devel, release, and oldrelease) had 0 errors, 0 warnings, and 0 notes.

Fedora Linux, Ubuntu Linux and Debian Linux had the following NOTE:

```
* checking installed package size ... NOTE
  installed size is 10.7Mb
  sub-directories of 1Mb or more:
    doc    1.6Mb
    libs   8.0Mb
```

It is my understanding that this is not a significant issue (for example, see Dirk Eddelbuettel's comment on this StackOverflow question: https://stackoverflow.com/questions/53819970/r-package-libs-directory-too-large-after-compilation-to-submit-on-cran)
