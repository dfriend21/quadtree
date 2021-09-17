### Note:

I removed the XML and JSON components of the 'cereal' library. I was very reluctant to do this, as I hate removing pieces of a library - it feels wrong. It also makes updating the 'cereal' library much more of a hassle. Because of this, I wanted to document exactly what I did and why I did it, so that in the future I can examine the reasons why - it may be that in the future I decide these reasons aren't valid, and I may go back to including the entire libary.

This involved removing the following files and folders:

* cereal/archives/json.hpp
* cereal/archives/xml.hpp
* cereal/external (I removed the entire foler) 

I investigated the code (in particular the '#include' statements) and found that I could safely remove these files. The code builds successfully and all tests pass with these files removed.

My reasons for removing the files are as follows:

* I don't use the JSON and XML functionality.
* The code for the JSON and XML functionality is the largest part of the 'cereal' library. On the file system, the cereal library is 1.4 MB with this functionality and 492 KB without it. I investigated the size of the .tar.gz file resulting from R CMD build - with the JSON and XML functionality, it was 1.69 MB. Without, it was 1.51 MB. However, I am not sure if comparing the size in this way is meaningful.
* The JSON and XML functionality use the 'rapidjson' and 'rapidxml' libraries (which are in 'cereal/external'). These have their own authors and copyright holders, and it felt weird to include authors and copyright holders for libraries that I'm not actually using. So removing them simplified the process of figuring out how to properly document the copyright holders. I'll admit this seems like a rather feeble reason.
* I had already modified one of the files in the 'external' folder - the 'cereal/external/base64.hpp' included some #pragma directives that were causing a note from R CMD check, and I had commented these out. Removing the entire 'externals' folder gets rid of this file entirely.