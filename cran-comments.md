## Test environments

* local OS X install, R 4.2.2
* R-hub: Debian Linux, R-devel, GCC ASAN/UBSAN
* R-hub: Fedora Linux, R-devel, clang, gfortran
* R-hub: Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub: Windows Server 2022, R-devel, 64 bit
* win-builder (devel, release, oldrelease)

## R CMD check results

The local OS X install, Windows Server 2022, and win-builder (devel and release) had 0 errors, 0 warnings, and 0 notes.

win-builder (oldrelease) had one note identifying the following words as potentially misspelled: Quadtrees, quadtree, quadtree's, and quadtrees. These words are not misspelled.

Fedora Linux, Ubuntu Linux and Debian Linux had the following note:

```
* checking installed package size ... NOTE
  installed size is 10.7Mb
  sub-directories of 1Mb or more:
    doc    1.7Mb
    libs   8.0Mb
```

It is my understanding that this is not a significant issue (for example, see Dirk Eddelbuettel's comment on this StackOverflow question: https://stackoverflow.com/questions/53819970/r-package-libs-directory-too-large-after-compilation-to-submit-on-cran)
