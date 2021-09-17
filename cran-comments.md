## Resubmission - 0.1.2 (9/17/2021)

I have made changes according to the feedback I received. I have addressed each concern as follows.

* "If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file"
    - I don't believe that there are any sources I need to cite. I have not personally published anything that is relevant to include. If deemed necessary, I can add a reference to a paper that summarizes region quadtrees - I have not referenced it yet, but I can include if you would like me to.
* "Please make sure that you do not change the user's options, par or working directory. If you really have to do so within functions, please ensure with an *immediate* call of on.exit() that the settings are reset when the function is exited."
    - I have added code (in 'plot_Quadtree.R') resetting the parameters using `on.exit()`.
* "Please always make sure to reset to user's options(), working directory or par() after you changed it in examples and vignettes and demos."
    - I have added code resetting `par()` in all the examples and vignettes that modified `par()`.
* "Please always add all authors, contributors and copyright holders in the Authors@R field with the appropriate roles."
    - Upon inspection of the copyright holders I had missed, I noticed that the 'cereal' library included two other libraries ('rapidxml' and 'rapidjson') that I don't use. Most of the copyright holders I had missed were from these two libraries. I decided to remove these two libraries entirely since I don't use them. I also added one more copyright holder that I had missed (Juan Pedro Bolivar Puente).

Thanks for reviewing and for the comments.

## Resubmission - 0.1.1 (9/16/2021)

* The initial submission failed `R CMD check` on CRAN. I believe the problem was because of a missing `#include` in one of my C++ files. I have added the missing `#include`.
* I also cleaned up the C++ code and comments.

## Test environments

* local OS X install, R 4.1.1
* R-hub: Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* R-hub: Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub: Fedora Linux, R-devel, clang, gfortran
* R-hub: Debian Linux, R-devel, GCC ASAN/UBSAN
* R-hub: Oracle Solaris 10, x86, 32 bit, R-release
* win-builder (devel, release, oldrelease)

## R CMD check results

R CMD check on all platforms ran with 0 ERRORS and 0 WARNINGS.

Debian Linux (R-hub) and Oracle Solaris (R-hub) had 0 NOTES.

OS X, Debian Linux (R-hub), and win-builder (devel, release, and oldrelease) had 1 NOTE: `new submission`. In addition, it identified 'quadtree' as a potentially misspelled word, but it is spelled correctly.

Windows Server (R-hub), Ubuntu Linux (R-hub), Fedora Linux (R-hub) all had the following additional NOTE (although the size of 'libs' varied from 2.9Mb to 13.3Mb):

```
checking installed package size ... NOTE
  installed size is 10.2Mb
  sub-directories of 1Mb or more:
    doc    1.6Mb
    libs   7.8Mb
```

Based on some searching that I've done, it is my understanding that the large size of 'libs' is not a significant issue (for example, see Dirk Eddelbuettel's comment on this StackOverflow question: https://stackoverflow.com/questions/53819970/r-package-libs-directory-too-large-after-compilation-to-submit-on-cran)

The 'doc' folder is large because the vignettes contain quite a few images, which I believe are important in explaining the package's functionality. In addition, the 'CRAN Repository Policy' states that "neither data nor documentation should exceed 5MB", and the folder is significantly smaller than 5MB.
