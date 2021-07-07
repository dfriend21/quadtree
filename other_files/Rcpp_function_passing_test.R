library(quadtree)

do_stuff = function(){
  print("hi there again!")
}
my_fun()

are_btw = function(vals, low, high){
  if(min(vals) >= low && max(vals) <= high){
    return(TRUE)
  } else {
    return(FALSE)
  }
}
are_btw = function(args){
  print(args$vals)
  print(args$low)
  print(args$high)
  if(min(args$vals) >= args$low && max(args$vals) <= args$high){
    return(TRUE)
  } else {
    return(FALSE)
  }
}
are_btw(list(vals = 1:40,low=0,high=20))

fun1(are_btw,list(vals = 1:19,low=0,high=20))


cmb1 = function(num1, num2, args){
  if(num1 <= args$low || num2 <= args$low){
    return(-1);
  } else if(num1 >= args$high || num2 >= args$high){
    return(99999)
  } else {
    return(num1+num2)
  }
}

cmb2 = function(num1, num2, args){
  return(num1*num2)
}
cmb(4,6, 3, 6)
nums1 = c(1,4,3,5,6,4)
nums2 = c(3,4,6,4,3,4)
res1 = checkNumsRcpp(nums1, nums2, cmb1, list(low=3, high=6))
res2 = checkNumsRcpp(nums1, nums2, cmb2, list(NULL))

res1
res2
cbind(nums1,nums2,res1,res2)


















