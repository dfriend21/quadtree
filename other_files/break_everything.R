library(quadtree)
library(raster)

#BREAK EVERYTHING!!!

data(habitat)
r = habitat
qt_plot(qt_create(r, .1))

bench::mark(qt_create(r,.01, validate_arguments = TRUE),
            qt_create(r,.01, validate_arguments = FALSE),
            check=FALSE)
#=============================================
# give the incorrect classes to parameters

#-------- x
df = data.frame(x=1:2, y=2:3)
class(df) = c("thingy", "stuff", "hithere")
qt_create(df, 1)

r_s = stack(r,r)
qt_create(r_s, 1)

qt_create("hi there!", 5)

qt_create(NULL, 1)

#what about an all-NA raster?
r2 = r
r2[!is.na(r2)] = NA
qt = qt_create(r2, .1)
qt_plot(qt)

#-------- split_threshold
qt_create(r, "a")
qt_create(r, list("a",1))
qt_create(r, numeric(0))

#-------- split_method
qt_create(r, 1, split_method = FALSE)
qt_create(r, 1, split_method = "hello")
qt_create(r, 1, split_method = c("sd", "range"))
qt_create(r, 1, split_method = list("hi there",1,2,3,4))
qt_create(r, 1, split_method = data.frame())
qt_create(r, 1, split_method = function(){})
qt_create(r, 1, split_method = "custom")
qt_create(r, 1, split_method = character(0))

#-------- split_fun
qt_create(r,1,split_fun="a")
qt_create(r,1,split_fun=mean)
qt_create(r,1,split_fun=function(){}, split_method="custom")
qt_create(r,1,split_fun=function(hi){return(TRUE)}, split_method="custom")
qt_create(r,1,split_fun=function(vals, args){return("a")}, split_method="custom") #!!! breaks qt$createTree()
qt = qt_create(r,1,split_fun=function(vals, args){return(NA)}, split_method="custom")
qt_plot(qt)
qt_create(r,1,split_fun=function(vals, args){return(NULL)}, split_method="custom") #!!! breaks qt$createTree()
qt_create(r,1,split_fun=function(thing1, thing2){return(TRUE)}, split_method="custom")

#--------  split_args
split_fun = function(vals, args){
  if(mean(vals, na.rm=TRUE) > args$limit){
    return(TRUE)
  }
  return(FALSE)
}
qt_create(r, split_method="custom", split_fun=split_fun) #!!! breaks qt$createTree()
qt_create(r, split_method="custom", split_fun=split_fun, split_args=list(thing=.5)) #!!! breaks qt$createTree()
qt = qt_create(r, split_method="custom", split_fun=split_fun, split_args=list(limit="a")) #it's weird that this works - it looks like it's because num > "a" is always FALSE
qt_plot(qt)
qt_create(r, split_method="custom", split_fun=split_fun, split_args=NA)

#-------- split_if_any_NA
qt_create(r, 1, split_if_any_NA=NULL)
qt_create(r, 1, split_if_any_NA=NA)
qt_create(r, 1, split_if_any_NA="a")
qt_create(r, 1, split_if_any_NA=1)
qt_create(r, 1, split_if_any_NA=logical(0))

#-------- split_if_all_NA
qt_create(r, 1, split_if_all_NA=NULL)
qt_create(r, 1, split_if_all_NA=NA)
qt_create(r, 1, split_if_all_NA="c")
qt_create(r, 1, split_if_all_NA=-1)
qt_create(r, 1, split_if_all_NA=logical(0))

#-------- combine_method
qt_create(r,.1, combine_method="hi")
qt_create(r,.1, combine_method=-1)
qt_create(r,.1, combine_method=c("hi", "there"))
qt_create(r,.1, combine_method="custom")
qt_create(r,.1, combine_method=character(0))

#-------- combine_fun
qt_create(r,.1, combine_method="custom", combine_fun=function(){})
qt_create(r,.1, combine_method="custom", combine_fun="hi there")
qt_create(r,.1, combine_method="custom", combine_fun=NULL)
qt_create(r,.1, combine_method="custom", combine_fun=NA)
qt = qt_create(r,.1, combine_method="custom", combine_fun=function(vals, args){return(NA)})
qt_plot(qt)
qt_create(r,.1, combine_method="custom", combine_fun=function(vals, args){return(NULL)}) #!!! breaks qt$createTree()
qt_create(r,.1, combine_method="custom", combine_fun=function(vals, args){return("a")}) #!!! breaks qt$createTree()
qt = qt_create(r,.1, combine_method="custom", combine_fun=function(vals, args){return(Inf)})
qt_plot(qt)
qt_create(r,.1, combine_method="custom", combine_fun=function(vals, args){return(vals)}) #!!! breaks qt$createTree()

#-------- combine_args
combine_fun = function(vals, args){ return(.4) }
qt = qt_create(r,.1,combine_method="custom", combine_fun=combine_fun, combine_args=list(test=.1))
qt_plot(qt)
combine_fun = function(vals, args){
  if(all(is.na(vals))) return(NA)
  if(mean(vals, na.rm=TRUE) > args$value) return(1)
  return(0)
}
qt = qt_create(r,.1,combine_method="custom", combine_fun=combine_fun, combine_args=list()) #!!! breaks qt$createTree()
qt = qt_create(r,.1,combine_method="custom", combine_fun=combine_fun, combine_args=list(test=.1)) #!!! breaks qt$createTree()
qt = qt_create(r,.1,combine_method="custom", combine_fun=combine_fun, combine_args=list(value=list("hi", 1))) #!!! breaks qt$createTree()
qt = qt_create(r,.1,combine_method="custom", combine_fun=combine_fun, combine_args=list(value=c(.5,2,3,4)))
qt = qt_create(r,.1,combine_method="custom", combine_fun=combine_fun, combine_args="hi")
qt_plot(qt)

#-------- max_cell_length
qt_create(r,.1,max_cell_length="a")
qt_create(r,.1,max_cell_length=list(1,2,3,4))
qt_create(r,.1,max_cell_length=TRUE)
qt_create(r,.1,max_cell_length=c(1,2,3,4))
qt_create(r,.1,max_cell_length=numeric(0))
qt = qt_create(r,.1,max_cell_length = -100)
qt_plot(qt)
qt = qt_create(r,.1,max_cell_length = Inf)
qt_plot(qt)
qt = qt_create(r,.1,max_cell_length = -Inf) #shouldn't this cause weird behavior, like 'min_cell_length=Inf' does?
qt_plot(qt)

#-------- min_cell_length
qt_create(r,.1,min_cell_length="a")
qt_create(r,.1,min_cell_length=list(1,2,3,4))
qt_create(r,.1,min_cell_length=TRUE)
qt_create(r,.1,min_cell_length=c(1,2,3,4))
qt_create(r,.1,min_cell_length=numeric(0))
qt = qt_create(r,.1,min_cell_length = 1000)
qt = qt_create(r,.1,min_cell_length = -100)
qt_plot(qt)
qt = qt_create(r,.1,min_cell_length = Inf)
qt_plot(qt)
qt = qt_create(r,.1,min_cell_length = -Inf)
qt_plot(qt)

#-------- adj_type
qt_create(r,.1,adj_type="hithere")
qt_create(r,.1,adj_type="resample")
qt_create(r,.1,adj_type=c("hithere", "hello"))
qt_create(r,.1,adj_type=list(1,2,3))
qt_create(r,.1,adj_type=NULL)
qt_create(r,.1,adj_type=character(0))

#-------- resample_n_side
qt_create(r,.1,adj_type="resample", resample_n_side=.4) 
qt_create(r,.1,adj_type="resample", resample_n_side=numeric())# !!!
qt_create(r,.1,adj_type="resample", resample_n_side="abc")
qt_create(r,.1,adj_type="resample", resample_n_side=NULL)
qt_create(r,.1,adj_type="expand", resample_n_side=NULL)

#-------- resample_pad_NAs
qt = qt_create(r,.1,adj_type="resample", resample_n_side=128, resample_pad_NAs=FALSE)
qt_plot(qt)
qt = qt_create(r,.1,adj_type="resample", resample_n_side=128, resample_pad_NAs="hi")
qt = qt_create(r,.1,adj_type="resample", resample_n_side=128, resample_pad_NAs=NULL)

#-------- extent
qt_create(r,.1,extent=extent(1,2,3,4))
qt_create(as.matrix(r), .1, extent=1)
qt_create(as.matrix(r), .1, extent=c(1.1,2,3,4))
qt_create(as.matrix(r), .1, extent="")
qt_create(as.matrix(r), .1, extent=NA)

#-------- proj4string
qt_create(r,1,proj4string=9)
qt = qt_create(as.matrix(r),.1,proj4string="hi there")
qt = qt_create(r,.01,proj4string="hi there")
qt_plot(qt)

#-------- template_quadtree
qt2 = qt_create(r,template_quadtree = qt)
qt_plot(qt2)
qt_create(r, template_quadtree=qt)
#=============================================
# use correct classes, but use nonsense values

#-------- x
#empty matrix
qt = qt_create(matrix(),1)

test = cbind(c(1,2,3,4), c(1,2,3,4))
qt = qt_create(test,1, adj_type="resample", resample_n_side=4)
qt_plot(qt)

#-------- split_threshold
qt = qt_create(r, NA)
qt_plot(qt)

qt = qt_create(r, -1)
qt_plot(qt)
