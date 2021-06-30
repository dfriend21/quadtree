

getCoords <- function(pos = 1.1, side = 1, input = "p") {
  p <- par()
  if (input == "p") {
    x.width = p$usr[2] - p$usr[1]
    y.width = p$usr[4] - p$usr[3]
    out <- rep(NA, length(pos))
    if (length(side) == 1) {
      side <- rep(side, length(pos))
    }
    out[which(side %in% c(1, 3))] <- pos[which(side %in% c(1, 3))] * x.width + p$usr[1]
    out[which(side %in% c(2, 4))] <- pos[which(side %in% c(2, 4))] * y.width + p$usr[3]
    return(out)
  } else if (input == "f") {
    gfc <- getFigCoords("f")
    x.width = gfc[2] - gfc[1]
    y.width = gfc[4] - gfc[3]
    out <- rep(NA, length(pos))
    if (length(side) == 1) {
      side <- rep(side, length(pos))
    }
    out[which(side %in% c(1, 3))] <- pos[which(side %in% c(1, 3))] * x.width + gfc[1]
    out[which(side %in% c(2, 4))] <- pos[which(side %in% c(2, 4))] * y.width + gfc[3]
    return(out)
  }
}



lgd = grDevices::as.raster(rainbow(100))







x = 1.1
y = .5

plot(l_c2)
p = par()


#get range of x and y axes
x_range = p$usr[2] - p$usr[1]
y_range = p$usr[4] - p$usr[3]



p$usr
p$plt
x1 = p$usr[1]
x2 = p$usr[2]
p1 = p$plt[1]
p2 = p$plt[2]

a = (x2*p1 - x1*p2)/(p1-1)
b = (x1 + p1*a - a)/p1
a
b
p1*(b-a) + a
x1
p2*(b-a) + a
x2

b_a = (x2-x1)/(p2-p1)
a = x1 - p1*b_a
b = x2 + p2*b_a
b = x2 + (1-p2)*b_a
a
b

plot(l_c2)
rasterImage(lgd, a, p$usr[3], b, p$usr[4],xpd=TRUE)











get_axis_coords = function(usr, plt){
  b_a = (usr[2]-usr[1])/(plt[2]-plt[1])
  a = usr[1] - plt[1]*b_a
  b = usr[2] + (1-plt[2])*b_a
  return(c(a,b))
}

#usr - output from par("usr")
#plt - output from par("plt")
get_coords = function(usr,plt){
  x = get_axis_coords(usr[1:2], plt[1:2])
  y = get_axis_coords(usr[3:4], plt[3:4])
  return(c(x,y))
}

z_lims = cellStats(l, "range")

box_col = NULL #color of the border around the entire legend - if NULL, no border is plotted
x_pct = .5 #location of the X-CENTER of the legend, as a proportion (0 to 1) - relative to the right margin width! (not the entire plot width)
y_pct = .5 #location of the Y-CENTER of the legend, as a proportion (0 to 1) - relative to the plot height
wd_pct = .5 #width of the entire legend, as a proportion (0 to 1) - relative to the right margin width
ht_pct = .5 #height of the entire legend, as a proportion (0 to 1) - relative to the plot height

bar_box_col = "black" #color of the border around the color bar - if NULL, no border is plotted
bar_wd_pct = .3 #width of the color bar, as a proportion of the width of the LEGEND AREA
bar_ht_pct = 1 #height of the color bar, as a proportion of the height of the LEGEND AREA
cols = terrain.colors(100) #colors used by the legend

n_ticks = 5
txt_x = 1 #the x location of the labels, as a proportion of the width of the LEGEND AREA - this is the location of the RIGHTMOST characters (i.e. right-justified)

plot(l_c2, legend=FALSE)

p = par()
crds = get_coords(p$usr, p$plt) #get the x and y limits of the ENTIRE plot area, in the units used in the plot
mar_crds = c(p$usr[2], crds[2], crds[3], crds[4]) #get the x and y limits of the right margin area
wd_crd = wd_pct*(diff(mar_crds[1:2])) #get the width of the legend area relative to the right margin width
ht_crd = ht_pct*(mar_crds[4]-mar_crds[3]) #get the height of the legend area relative to the right margin height


#get the coordinates for the legend area
lgd_x0 = mar_crds[1] + x_pct*diff(mar_crds[1:2]) - wd_crd*.5
lgd_x1 = mar_crds[1] + x_pct*diff(mar_crds[1:2]) + wd_crd*.5
lgd_y0 = mar_crds[3] + y_pct*diff(mar_crds[3:4]) - ht_crd*.5
lgd_y1 = mar_crds[3] + y_pct*diff(mar_crds[3:4]) + ht_crd*.5

if(!is.null(box_col)){
  rect(lgd_x0,lgd_y0,lgd_x1,lgd_y1,xpd=TRUE, border=box_col)
}

bar_x0 = lgd_x0
bar_x1 = lgd_x0+bar_wd_pct*wd_crd
bar_y0 = lgd_y0
bar_y1 = lgd_y0+bar_ht_pct*ht_crd
rast = grDevices::as.raster(cols)
rasterImage(rast, bar_x0, bar_y0, bar_x1, bar_y1, xpd=TRUE)
if(!is.null(bar_box_col)){
  rect(bar_x0, bar_y0, bar_x1, bar_y1, xpd=TRUE, border=bar_box_col)  
}

ticks = pretty(z_lims, n_ticks)
ticks = ticks[ticks >= z_lims[1] & ticks <= z_lims[2]]
ticks_pct = ticks/diff(z_lims)


ticks_x = rep(lgd_x0 + txt_x*wd_crd,length(ticks))
ticks_y = lgd_y0 + ticks_pct*ht_crd
text(ticks_x, ticks_y, labels=ticks,xpd=TRUE, adj=1)

txt_bar_gap = (ticks_x - max(strwidth(ticks))) - bar_x1
seg_x0 = rep(bar_x1, length(ticks))
seg_x1 = seg_x0 + txt_bar_gap*.5
seg_y0 = ticks_y
seg_y1 = seg_y0
segments(seg_x0, seg_y0, seg_x1, seg_y1,xpd=TRUE)





plot(l_c2)




