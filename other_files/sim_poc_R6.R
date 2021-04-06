#============================
#FILE INFO
#============================
#<head>

###BASIC DESCRIPTION 
# In this script I created a very basic, but functioning, ABM in which the
# agents are born, move, reproduce, and die. This was originally translated from
# 'sim_poc.R' in order to make it object-oriented (using R6). This is the one
# I'll be working in for now.

###MORE INFO
# 

#</head>
#============================
#BEGIN CODE
#============================

#8/18/2020
#Got it working with the movt alg - some thoughts:
# - REALLY slow - even 100 agents takes a few seconds
# - so many parameters!
# - barriers work (they don't cross cells with resistance == 1)



library(raster)
library(purrr)
library(parallel)
library(quadtreeNew)
#setwd("/Users/dfriend/Documents/clark_county_project/abm_poc")
#source("fx_rand_surf.R")

ABM = R6::R6Class("ABM", public = list(
   #===========================
   #FIELDS
   #===========================
   #initialization params
   n_init = integer(),
   init_val_cutoff = numeric(),
   prob_disperse = numeric(),
   max_disperse_dist = numeric(),
   max_resistance = numeric(),
   max_cells = integer(),
   step1_dist = numeric(),
   n_points = integer(),
   max_steps = integer(),
   max_substeps = integer(),
   max_total_dist = numeric(),
   max_straight_line_dist = numeric(),
   max_total_dist_substep = numeric(),
   attract_pt_dist = numeric(),
   #attract_pt_weight = numeric(), 
   #quality_weight = numeric(),
   #direction_weight = numeric(),
   attract_pt_exp1 = numeric(),
   quality_exp1 = numeric(),
   direction_exp1 = numeric(),
   attract_pt_exp2 = numeric(),
   quality_exp2 = numeric(),
   direction_exp2 = numeric(),
   prob_reproduce = numeric(),
   max_age = integer(),
   max_cell_capacity = integer(),
   landscape_n_side = integer(),
   quadtree_range_lim = numeric(),
   
   sim_length = integer(),
   
   
   #storage params
   live_agents = matrix(),
   dead_agents = matrix(),
   landscape = NULL,
   qtree = NULL,
   current_year = integer(),
   last_id = integer(),
   move_hist = data.frame(),
   
   #===========================
   #METHODS
   #===========================
   #just sets the fields necessary to intialize the simulation, doesn't actually "initialize" it (i.e. doesn't populate 'agents' matrix, etc - that's done in "prepare()"
   initialize = function(n_init, init_val_cutoff, prob_disperse, max_disperse_dist, max_resistance, max_cells, step1_dist, n_points, max_steps, max_substeps, max_total_dist, max_straight_line_dist, max_total_dist_substep, attract_pt_dist, attract_pt_exp1, quality_exp1, direction_exp1, attract_pt_exp2, quality_exp2, direction_exp2, prob_reproduce, max_age, max_cell_capacity, landscape_n_side, landscape, quadtree_range_lim,  sim_length){
      self$n_init = n_init
      self$init_val_cutoff = init_val_cutoff
      self$prob_disperse = prob_disperse
      self$max_disperse_dist = max_disperse_dist
      self$max_resistance = max_resistance
      self$max_cells = max_cells
      self$step1_dist = step1_dist
      self$n_points = n_points
      self$max_steps = max_steps
      self$max_substeps = max_substeps
      self$max_total_dist = max_total_dist
      self$max_straight_line_dist = max_straight_line_dist
      self$max_total_dist_substep = max_total_dist_substep
      self$attract_pt_dist = attract_pt_dist
      self$attract_pt_exp1 = attract_pt_exp1
      self$quality_exp1 = quality_exp1
      self$direction_exp1 = direction_exp1
      self$attract_pt_exp2 = attract_pt_exp2
      self$quality_exp2 = quality_exp2
      self$direction_exp2 = direction_exp2
      self$prob_reproduce = prob_reproduce
      self$max_age = max_age
      self$max_cell_capacity = max_cell_capacity
      self$landscape_n_side = landscape_n_side
      self$landscape = landscape
      self$quadtree_range_lim = quadtree_range_lim
      self$sim_length = sim_length
      
      invisible(self)
   },
   
   prepare = function(){
      #----------------
      #set.seed(15)
      print("1")
      if(is.null(self$landscape)){
         self$landscape = raster(private$rand_surf_diag(self$landscape_n_side, 0, 1, 0.05))
         extent(self$landscape) = extent(0, self$landscape_n_side, 0, self$landscape_n_side)
      } else {
         if(nrow(self$landscape) != ncol(self$landscape)) stop("landscape raster must be perfectly square")
         crs(self$landscape) = NA
         extent(self$landscape) = extent(0,nrow(self$landscape), 0, nrow(self$landscape))
         #extent(self$landscape) = extent(-1000,nrow(self$landscape)-1000, -1000, nrow(self$landscape)-1000) ######FOR TESTING ONLY!!!!!!!!!! DELETE ME!!!!!!!!
         #extent(self$landscape) = extent(100,nrow(self$landscape)+100, 100, nrow(self$landscape)+100) ######FOR TESTING ONLY!!!!!!!!!! DELETE ME!!!!!!!!
         self$landscape_n_side = nrow(self$landscape)
      }
      self$qtree = new(quadtree2, as.matrix(self$landscape), extent(self$landscape)[1:2], extent(self$landscape)[3:4], self$quadtree_range_lim)
      
      print("2")
      #----------------
      #initialize tort storage matrices 
      #NOTE - still not sure is separating them like this is worthwhile. In a way it bothers me to have to separate them - I'd almost rather have a "is_alive" column. But then I'd have
      #to make sure I only operated on the live tortoises, which could be annoying to code and probably make it more likely that I'd make coding errors
      self$live_agents = matrix(nrow = self$n_init, ncol=7, dimnames = list(NULL, c("id", "x", "y", "cell_id", "sex", "birth_year", "age"))) #idea - make a "agent_matrix" object? not sure if I'm crazy about the idea, but it's an option
      self$dead_agents = self$live_agents[FALSE,]
      
      self$live_agents[,"id"] = 1:self$n_init
      print("3")
      if(is.na(self$init_val_cutoff)){
         print("3a")
         self$live_agents[,"x"] = runif(self$n_init, 0, self$landscape_n_side)
         self$live_agents[,"y"] = runif(self$n_init, 0, self$landscape_n_side)
      } else {
         print("3b.1")
         pts = private$sample_pts_cond(self$landscape, self$n_init, self$init_val_cutoff)
         print("3b.2")
         #print(pts)
         self$live_agents[,"x"] = rbind(pts)[,1] # do rbind in case pts has only 1 row, in which case it's a vector not a matrix
         self$live_agents[,"y"] = rbind(pts)[,2]
      }
      print("4")
      
      #self$live_agents[,"x"] = sample(1:self$landscape_n_side, self$n_init, replace=TRUE)
      #self$live_agents[,"y"] = sample(1:self$landscape_n_side, self$n_init, replace=TRUE)
      self$live_agents[,"cell_id"] = private$get_cell_id(floor(self$live_agents[,"x"]), floor(self$live_agents[,"y"]))
      self$live_agents[,"sex"] = sample(0:1, size=self$n_init, replace=TRUE)
      self$live_agents[,"birth_year"] = -1*sample(0:self$max_age, size=self$n_init, replace=TRUE)
      self$live_agents[,"age"] = -1*self$live_agents[,"birth_year"] + 1 #since we'll start with current_year = 1, that means the age of the init animals will be -1*birth_year + 1
      
      self$move_hist = data.frame(id=self$live_agents[,"id"])
      self$move_hist$x = vector(mode="list", length = nrow(self$move_hist))
      self$move_hist$y = vector(mode="list", length = nrow(self$move_hist))

      #----------------
      #set current year to one
      self$current_year = 1
      self$last_id = self$n_init
      
      invisible(self)
   },
   
   move_to_a_neighbor = function(){
      will_move = rbinom(nrow(self$live_agents), 1, self$prob_disperse) #vector specifying whether each tortoise will move - 0 is no, 1 is yes 
      #if I want a probability of dispersal that is dependent on other variables, then I could make a function that calculates the probability for each tortoise and uses this to replace 'params$prob_disperse'
      move_opts = expand.grid(x = -1:1, y = -1:1)
      #move_opts
      move_opts = move_opts[!(move_opts$x == 0 & move_opts$y == 0),]
      
      
      opt_indices = sample(1:nrow(move_opts), sum(will_move), replace=TRUE)
      movts = as.matrix(move_opts[opt_indices,])
      #movts
      #print("1")
      #print(self$live_agents)
      self$live_agents[as.logical(will_move), c("x", "y")] = self$live_agents[as.logical(will_move), c("x", "y")] + movts
      
      #print("2")
      #print(self$live_agents)
      
      self$live_agents[self$live_agents[,"x"] > self$landscape_n_side,"x"] = self$landscape_n_side #this will produce weird results if tortoises are ever allowed to move more than one cell
      self$live_agents[self$live_agents[,"x"] < 0,"x"] = 0
      self$live_agents[self$live_agents[,"y"] > self$landscape_n_side,"y"] = self$landscape_n_side
      self$live_agents[self$live_agents[,"y"] < 0,"y"] = 0
      self$live_agents[,"cell_id"] = private$get_cell_id(floor(self$live_agents[,"x"]), floor(self$live_agents[,"y"]))
      invisible(self)
   },
   
   move_runif_dist = function(){
      x_ranges = cbind(self$live_agents[,"x"]-self$max_disperse_dist, self$live_agents[,"x"]+self$max_disperse_dist)
      x_ranges[x_ranges < 0] = 0
      x_ranges[x_ranges > self$landscape_n_side] = self$landscape_n_side
      
      y_ranges = cbind(self$live_agents[,"y"]-self$max_disperse_dist, self$live_agents[,"y"]+self$max_disperse_dist)
      y_ranges[y_ranges < 0] = 0
      y_ranges[y_ranges > self$landscape_n_side] = self$landscape_n_side
      
      self$live_agents[,"x"] = runif(nrow(self$live_agents), x_ranges[,1], x_ranges[,2])
      self$live_agents[,"y"] = runif(nrow(self$live_agents), y_ranges[,1], y_ranges[,2])
      invisible(self)
   },
   
   move_cell_by_cell = function(debug=FALSE){
      will_move_inds = which(as.logical(rbinom(nrow(self$live_agents), 1, self$prob_disperse))) #decide which agents will move based on the previously set 'prob_disperse'
      private$print_var(will_move_inds, debug)
      lapply(1:length(will_move_inds), function(i){ #loop over the tortoises that are going to move this time
         private$print_var("=================================================================================", debug)
         private$print_var("=================================================================================", debug)
         private$print_var("=================================================================================", debug)
         private$print_var("=================================================================================", debug)
         private$print_var(i, debug)
         #if(i%%50 == 0){
         #   private$print_var(i)
         #}
         ind_i = will_move_inds[i] #get the index for this iteration 
         agent_i = self$live_agents[ind_i,] #get the agent info
         
         private$print_var(agent_i, debug)
         
         
         locs_i = rbind(agent_i[c("x", "y")]) #get a matrix where we'll store the locations it travels to
         private$print_var(locs_i, debug)
         
         cum_res_i = 0 #cumulative resistance it's traveled through
         
         attr_pt_step_i = private$runif_circle_perim(1, self$attract_pt_dist) #get xy coords on a circle's perimeter - we'll add these to the current loc to get the attraction point
         private$print_var(attr_pt_step_i, debug)
         #we need to make sure the attraction point falls within the extent (do we?)
         if(locs_i[,1] + attr_pt_step_i[1] < 0 | locs_i[,1] + attr_pt_step_i[1] > self$landscape_n_side){
            attr_pt_step_i[1] = attr_pt_step_i[1]*-1
         } 
         if(locs_i[,2] + attr_pt_step_i[2] < 0 | locs_i[,2] + attr_pt_step_i[2] > self$landscape_n_side){
            attr_pt_step_i[2] = attr_pt_step_i[2]*-1
         } 
         private$print_var(attr_pt_step_i, debug)
         attr_pt_i = locs_i + attr_pt_step_i
         private$print_var(attr_pt_i, debug)
         #now we'll move it cell by cell
         for(j in 1:self$max_cells){
            private$print_var("-------------------------", debug)
            private$print_var(j, debug)
            cell_opts_j = private$get_move_probs(locs_i[nrow(locs_i),], as.numeric(attr_pt_i), exp=1) #get the cells that we can move through as well as the probability as determined by the angle to the attraction point
            private$print_var(cell_opts_j, debug)
            cell_opts_j[,1:2] = t(apply(cell_opts_j[,1:2], 1, function(row_j){ #move options gives us vals between -1 and 1 - add these to our current loc to get the actual options
               return(row_j + locs_i[nrow(locs_i),])
            }))
            private$print_var(cell_opts_j, debug)
            #eliminate options that fall outside of our extent
            valid_opts_j = 
               cell_opts_j[,1] > 0 & 
               cell_opts_j[,1] < self$landscape_n_side & 
               cell_opts_j[,2] > 0 & 
               cell_opts_j[,2] < self$landscape_n_side
            private$print_var(valid_opts_j, debug)
            cell_opts_j = cell_opts_j[valid_opts_j,]
            private$print_var(cell_opts_j, debug)
            cell_vals_j = extract(1-self$landscape, cell_opts_j[,c(1:2)]) #subtracting .5 should get the center of the cells I want
            private$print_var(cell_vals_j, debug)
            #cell_vals_j
            #extract(landscape, cell_opts_j[,2:1])
            #val_prob = 
            if(j > 1){
               attr_pt_prob_j = private$get_move_probs(locs_i[nrow(locs_i)-1,], locs_i[nrow(locs_i),])#[valid_opts_j,4]
               private$print_var(attr_pt_prob_j, debug)
               private$print_var(attr_pt_prob_j[valid_opts_j, 4], debug)
               cell_probs_j = cell_vals_j^self$quality_weight * cell_opts_j[,4]^self$attract_pt_weight * attr_pt_prob_j[valid_opts_j, 4]^self$direction_weight
            } else {
               cell_probs_j = cell_vals_j^self$quality_weight * cell_opts_j[,4]^self$attract_pt_weight
            }
            private$print_var(cell_probs_j, debug)
            #cell_probs_j = cell_opts_j[,4]
            cell_probs_j = cell_probs_j/sum(cell_probs_j)
            private$print_var(cell_probs_j, debug)
            rand_ind_j = sample(1:nrow(cell_opts_j), 1, prob=cell_probs_j) #pick a random index - this is how we'll choose where to move
            private$print_var(rand_ind_j, debug)
            next_loc_j = cell_opts_j[rand_ind_j,]
            private$print_var(next_loc_j, debug)
            locs_i = rbind(locs_i, next_loc_j[c(1,2)])
            private$print_var(locs_i, debug)
            cum_res_i = cum_res_i + cell_vals_j[rand_ind_j]
            private$print_var(cum_res_i, debug)
            if(cum_res_i > self$max_resistance){ #NOTE - this should probably be changed. This lets it go over the max resistance - it stops once its OVER the max resistance
               break()
            }
         }
         self$live_agents[ind_i,c("x", "y")] = locs_i[nrow(locs_i),]
         private$print_var(self$live_agents, debug)
         
         
         private$print_var(locs_i[,1], debug)
         agent_id_i = as.integer(agent_i["id"])
         private$print_var(agent_id_i, debug)
         private$print_var(self$move_hist[agent_id_i,"x"], debug)
         self$move_hist$x[[agent_id_i]] = c(self$move_hist$x[[agent_id_i]], locs_i[,1])
         self$move_hist$y[[agent_id_i]] = c(self$move_hist$y[[agent_id_i]], locs_i[,2])
         private$print_var(self$move_hist, debug)
      })
      self$current_year = self$current_year + 1 #TEMPORARY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      invisible(self)
   },
   
   # move_quadtree_cpp=function(debug=FALSE){
   #    will_move_inds = which(as.logical(rbinom(nrow(self$live_agents), 1, self$prob_disperse))) #decide which agents will move based on the previously set 'prob_disperse'
   #    private$print_var(will_move_inds, debug)
   #    lapply(1:length(will_move_inds), function(i){ #loop over the tortoises that are going to move this time
   #       private$print_var(i, debug)
   #       #print("check1")
   #       #if(i%%50 == 0){
   #       #   private$print_var(i)
   #       #}
   #       ind_i = will_move_inds[i] #get the index for this iteration 
   #       agent_i = self$live_agents[ind_i,] #get the agent info
   #       
   #       #print("check2")
   #       cum_res_i = 0 #cumulative resistance it's traveled through
   #       
   #       current_pt = agent_i[c("x", "y")]
   #       attr_pt = private$runif_circle_perim(1, self$attract_pt_dist) #get xy coords on a circle's perimeter - we'll add these to the current loc to get the attraction point
   #       attr_pt = attr_pt + current_pt
   #       private$print_var(attr_pt, debug)
   #       #print("check3")
   #       movts = moveAgent(self$qtree, 
   #                         current_pt,
   #                         attr_pt,
   #                         self$n_points,
   #                         self$step1_dist,
   #                         self$max_steps,
   #                         self$max_substeps,
   #                         self$quality_exp1,
   #                         self$attract_pt_exp1,
   #                         self$direction_exp1,
   #                         self$quality_exp2,
   #                         self$attract_pt_exp2,
   #                         self$direction_exp2)
   #       #next_pt_i = private$get_next_pt_qt(current_pt, prev_pt_i, attr_pt, self$n_points, self$step1_dist, self$quality_exp1, self$attract_pt_exp1, self$direction_exp1)
   #       # NumericMatrix moveAgent(QuadtreeWrapper &qt,
   #       #                         NumericVector startPoint,
   #       #                         NumericVector attractPoint,
   #       #                         int nCheckPoints,
   #       #                         double stepSize,
   #       #                         int maxSteps,
   #       #                         int maxSubSteps,
   #       #                         double qualityExp1,
   #       #                         double attractExp1,
   #       #                         double directionExp1,
   #       #                         double qualityExp2,
   #       #                         double attractExp2,
   #       #                         double directionExp2);
   #       
   #       self$live_agents[ind_i,c("x", "y")] = movts[nrow(movts),1:2]
   #       #private$print_var(self$live_agents, debug)
   #       
   #       
   #       #private$print_var(locs_i[,1], debug)
   #       agent_id_i = as.integer(agent_i["id"])
   #       #private$print_var(agent_id_i, debug)
   #       #private$print_var(self$move_hist[agent_id_i,"x"], debug)
   #       self$move_hist$x[[agent_id_i]] = c(self$move_hist$x[[agent_id_i]], movts[,1])
   #       self$move_hist$y[[agent_id_i]] = c(self$move_hist$y[[agent_id_i]], movts[,2])
   #       #private$print_var(self$move_hist, debug)
   #    })
   #    invisible(self)
   # },
   move_quadtree_cpp=function(debug=FALSE){
      will_move_inds = which(as.logical(rbinom(nrow(self$live_agents), 1, self$prob_disperse))) #decide which agents will move based on the previously set 'prob_disperse'
      private$print_var(will_move_inds, debug)
      attr_pts_list = lapply(1:length(will_move_inds), function(i){ #loop over the tortoises that are going to move this time
         #private$print_var(i, debug)
         #print("check1")
         #if(i%%50 == 0){
         #   private$print_var(i)
         #}
         ind_i = will_move_inds[i] #get the index for this iteration 
         agent_i = self$live_agents[ind_i,] #get the agent info
         
         #print("check2")
         cum_res_i = 0 #cumulative resistance it's traveled through
         
         current_pt = agent_i[c("x", "y")]
         #attr_pt = private$runif_circle_perim(1, self$attract_pt_dist) #get xy coords on a circle's perimeter - we'll add these to the current loc to get the attraction point
         #attr_pt = attr_pt + current_pt0
         attr_pt = getRandomPointOnCircle(current_pt, self$attract_pt_dist)
         #print(paste0("attr_pt is: ",attr_pt[1], ", ", attr_pt[2]))
         #points(current_pt, )
         #points(attr_pt[1], attr_pt[2]) #TESTING ONLY
         #Sys.sleep(1.1)         
         private$print_var(attr_pt, debug)
         #print("check3")
         movts = moveTort(self$qtree, 
                           current_pt,
                           attr_pt,
                           self$n_points,
                           self$step1_dist,
                           self$max_total_dist,
                           self$max_straight_line_dist,
                           self$max_total_dist_substep,
                           #self$max_steps,
                           #self$max_substeps,
                           self$quality_exp1,
                           self$attract_pt_exp1,
                           self$direction_exp1,
                           self$quality_exp2,
                           self$attract_pt_exp2,
                           self$direction_exp2,
                           FALSE)
         #next_pt_i = private$get_next_pt_qt(current_pt, prev_pt_i, attr_pt, self$n_points, self$step1_dist, self$quality_exp1, self$attract_pt_exp1, self$direction_exp1)
         # NumericMatrix moveAgent(QuadtreeWrapper &qt,
         #                         NumericVector startPoint,
         #                         NumericVector attractPoint,
         #                         int nCheckPoints,
         #                         double stepSize,
         #                         int maxSteps,
         #                         int maxSubSteps,
         #                         double qualityExp1,
         #                         double attractExp1,
         #                         double directionExp1,
         #                         double qualityExp2,
         #                         double attractExp2,
         #                         double directionExp2);
         
         self$live_agents[ind_i,c("x", "y")] = movts[nrow(movts),1:2]
         #private$print_var(self$live_agents, debug)
         
         
         #private$print_var(locs_i[,1], debug)
         agent_id_i = as.integer(agent_i["id"])
         #private$print_var(agent_id_i, debug)
         #private$print_var(self$move_hist[agent_id_i,"x"], debug)
         self$move_hist$x[[agent_id_i]] = c(self$move_hist$x[[agent_id_i]], movts[,1])
         self$move_hist$y[[agent_id_i]] = c(self$move_hist$y[[agent_id_i]], movts[,2])
         return(attr_pt)
         #private$print_var(self$move_hist, debug)
      })
      attr_pts = do.call(rbind, attr_pts_list)
      return(attr_pts)
      #invisible(self)
   },
   move_quadtree=function(debug=FALSE){
      will_move_inds = which(as.logical(rbinom(nrow(self$live_agents), 1, self$prob_disperse))) #decide which agents will move based on the previously set 'prob_disperse'
      private$print_var(will_move_inds, debug)
      lapply(1:length(will_move_inds), function(i){ #loop over the tortoises that are going to move this time
         private$print_var(i, debug)
         #print("check1")
         # if(i%%50 == 0){
         #    private$print_var(i)
         # }
         ind_i = will_move_inds[i] #get the index for this iteration 
         agent_i = self$live_agents[ind_i,] #get the agent info
         
         private$print_var(agent_i, debug)
         
         locs_i = rbind(agent_i[c("x", "y")]) #get a matrix where we'll store the locations it travels to
         private$print_var(locs_i, debug)
         
         #print("check2")
         cum_res_i = 0 #cumulative resistance it's traveled through
         
         
         current_pt = agent_i[c("x", "y")]
         attr_pt = private$runif_circle_perim(1, self$attract_pt_dist) #get xy coords on a circle's perimeter - we'll add these to the current loc to get the attraction point
         attr_pt = attr_pt + current_pt
         #points(attr_pt[1], attr_pt[2], col="red", pch=16)
         prev_pt_i = NULL
         prev_pt_j = NULL
         current_cell = self$qtree$getCell(current_pt[1], current_pt[2])
         private$print_var(attr_pt, debug)
         #print("check3")
         for(i in 1:self$max_steps){
            #print("check_i1")
            next_pt_i = private$get_next_pt_qt(current_pt, prev_pt_i, attr_pt, self$n_points, self$step1_dist, self$quality_exp1, self$attract_pt_exp1, self$direction_exp1)
            #print("check_i1a")
            next_cell_i = self$qtree$getCell(next_pt_i[1], next_pt_i[2])
            prev_pt_i = next_pt_i
            #points(next_pt_i[1], next_pt_i[2], col="red")
            #print("check_i2")
            if(!(next_cell_i$id() == current_cell$id() | next_cell_i$id() %in% current_cell$getNeighborIds())){
               for(j in 1:self$max_substeps){
                  #print("check_j1")
                  #print(paste0("check j1 (i:", i, ")"))
                  nb_info = current_cell$getNeighborInfo()
                  cell_dists = private$dists_to_point(rbind(current_pt), nb_info[,c("xMean", "yMean")])
                  next_pt_j = private$get_next_pt_qt(current_pt, prev_pt_j, next_pt_i, self$n_points, min(cell_dists), self$quality_exp2, self$attract_pt_exp2, self$direction_exp2)
                  next_cell_j = self$qtree$getCell(next_pt_j[1], next_pt_j[2])
                  #print("check_j2")
                  prev_pt_j = current_pt
                  current_pt = next_pt_j
                  current_cell = self$qtree$getCell(current_pt[1], current_pt[2])
                  #print("check_j3")
                  if(next_cell_i$id() == next_cell_j$id()){
                     current_pt = next_pt_i; #make it so that the next point is the actual point selected in the first part (rather than being in the center of the cell that the point from part 1 is contained in)
                     current_cell = self$qtree$getCell(current_pt[1], current_pt[2])
                     #locs_i = rbind(locs_i, c(current_pt, 1))
                     locs_i = rbind(locs_i, current_pt)
                     break;
                  } else {
                     #locs_i = rbind(locs_i, c(next_pt_j, 0))
                     locs_i = rbind(locs_i, next_pt_j)
                  }
               } 
            } else {
               current_pt = next_pt_i
               current_cell = self$qtree$getCell(current_pt[1], current_pt[2])
               #locs_i = rbind(locs_i, c(next_pt_i, 1))
               locs_i = rbind(locs_i, next_pt_i)
            }
         }
         self$live_agents[ind_i,c("x", "y")] = locs_i[nrow(locs_i),]
         private$print_var(self$live_agents, debug)
         
         
         private$print_var(locs_i[,1], debug)
         agent_id_i = as.integer(agent_i["id"])
         private$print_var(agent_id_i, debug)
         private$print_var(self$move_hist[agent_id_i,"x"], debug)
         self$move_hist$x[[agent_id_i]] = c(self$move_hist$x[[agent_id_i]], locs_i[,1])
         self$move_hist$y[[agent_id_i]] = c(self$move_hist$y[[agent_id_i]], locs_i[,2])
         private$print_var(self$move_hist, debug)
      })
      invisible(self)
   },
   # move_multiscale(){
   #    
   #    
   #    will_move_inds = which(as.logical(rbinom(nrow(self$live_agents), 1, self$prob_disperse))) #decide which agents will move based on the previously set 'prob_disperse'
   #    private$print_var(will_move_inds, debug)
   #    lapply(1:length(will_move_inds), function(i){ #loop over the tortoises that are going to move this time
   #       private$print_var("=================================================================================", debug)
   #       private$print_var("=================================================================================", debug)
   #       private$print_var("=================================================================================", debug)
   #       private$print_var("=================================================================================", debug)
   #       private$print_var(i, debug)
   #       if(i%%50 == 0){
   #          private$print_var(i)
   #       }
   #       ind_i = will_move_inds[i] #get the index for this iteration 
   #       agent_i = self$live_agents[ind_i,] #get the agent info
   #       
   #       private$print_var(agent_i, debug)
   #       
   #       
   #       locs_i = rbind(agent_i[c("x", "y")]) #get a matrix where we'll store the locations it travels to
   #       private$print_var(locs_i, debug)
   #       
   #       cum_res_i = 0 #cumulative resistance it's traveled through
   #       
   #       attr_pt_step_i = private$runif_circle_perim(1, self$attract_pt_dist) #get xy coords on a circle's perimeter - we'll add these to the current loc to get the attraction point
   #       private$print_var(attr_pt_step_i, debug)
   #       #we need to make sure the attraction point falls within the extent (do we?)
   #       if(locs_i[,1] + attr_pt_step_i[1] < 0 | locs_i[,1] + attr_pt_step_i[1] > self$landscape_n_side){
   #          attr_pt_step_i[1] = attr_pt_step_i[1]*-1
   #       } 
   #       if(locs_i[,2] + attr_pt_step_i[2] < 0 | locs_i[,2] + attr_pt_step_i[2] > self$landscape_n_side){
   #          attr_pt_step_i[2] = attr_pt_step_i[2]*-1
   #       } 
   #       private$print_var(attr_pt_step_i, debug)
   #       attr_pt_i = locs_i + attr_pt_step_i
   #       private$print_var(attr_pt_i, debug)
   #       #l_x_lim = extent(l)[1:2]
   #       #l_y_lim = extent(l)[3:4]
   #       #init_loc = c(quantile(l_x_lim, prob=.15), quantile(l_y_lim, prob=.15))
   #       #init_loc = c(quantile(l_x_lim, prob=.2), quantile(l_y_lim, prob=.71))
   #       
   #       # ind_i = will_move_inds[i] #get the index for this iteration 
   #       # agent_i = self$live_agents[ind_i,] #get the agent info
   #       # 
   #       # current_pt = init_loc
   #       # prev_pt_i = NULL
   #       # prev_pt_j = NULL
   #       # attr_pt_step_i = private$runif_circle_perim(1, self$attract_pt_dist) #get xy coords on a circle's perimeter - we'll add these to the current loc to get the attraction point
   #       # #attr_pt = c(quantile(l_x_lim, prob=.95), quantile(l_y_lim, prob=.95))
   #       # #attr_pt = c(quantile(l_x_lim, prob=.80), quantile(l_y_lim, prob=.2))
   #       # 
   #       # 
   #       # plot_tf = FALSE
   #       # plot(l, asp=1)
   #       # points(current_pt[1], current_pt[2], pch=16)
   #       # points(attr_pt[1], attr_pt[2], pch=16, col="blue")
   #       #begin loop 1
   #       for(j in 1:max_steps){
   #          
   #          #get the possible next step locations
   #          circ_pts0_j = get_n_points_on_circle(n_points, points_dist) #this gets points on a circle centered at 0
   #          circ_pts_j = t(apply(circ_pts0_j, MARGIN=1, function(row_i){ #use that to make it centered on our point
   #             return(row_i + current_pt)
   #          }))
   #          
   #          #if(plot_tf) points(circ_pts_j, col="red", asp=1, pch=16)
   #          #points(current_pt[1], current_pt[2], pch=16)
   #          
   #          circ_vals_j = extract(l, circ_pts_j) #get the value of each of the possible destinations
   #          val_probs_j = scale_sum_1(1-circ_vals_j) #scale this to sum to 1 (subtract one since we want lower resistance values to have a higher probability of being selected)
   #          
   #          angle_probs_j = get_angle_move_probs(current_pt, attr_pt, circ_pts_j) #get the probability of movt for each point based on the attraction point (i.e. points in the direction of the attraction point have a higher probability of being selected)
   #          
   #          
   #          if(is.null(prev_pt_j)){ #if there is no previous pt (i.e. this is the first step) don't include the autocorrelated direction term
   #             probs_j = val_probs_j^quality_exp1 * angle_probs_j^attract_pt_exp1 #probability of movement is product of resistance a
   #          } else { 
   #             cor_probs_j = get_angle_move_probs(prev_pt_j, current_pt, circ_pts_j) #get the probability of movement to each point based on autocorrelation of movement direction (i.e. more likely to travel in the same direction it was going before)
   #             probs_j = val_probs_j^quality_exp1 * angle_probs_j^attract_pt_exp1 * cor_probs_j^direction_exp1
   #          }
   #          probs_j = scale_sum_1(probs_j) #scale the probability to 1
   #          #if(plot_tf) text(circ_pts_j, labels=round(probs_j,2), cex=.9)
   #          #cbind(circ_coords, circ_vals, circ_probs)
   #          
   #          next_pt_j = circ_pts_j[sample(1:length(probs_j), 1, prob=probs_j),] #pick the next point based on the probabilities we calculated
   #          next_pt_id_j = extract(l, rbind(next_pt_j), cellnumbers=TRUE)[,"cells"] #get the cell id of the next point
   #          prev_pt_j = next_pt_j
   #          
   #          #if(plot_tf) points(next_pt_j[1], next_pt_j[2], col="deepskyblue", pch=16)
   #          
   #          #begin loop 2
   #          for(k in 1:max_substeps){
   #             nb_k = t(apply(get_move_opts(), 1, function(row_i){
   #                row_i + current_pt
   #             }))
   #             #nb_k
   #             
   #             angle_probs_k = get_angle_move_probs(current_pt, next_pt_j, nb_k)
   #             
   #             nb_vals = 1-extract(l, nb_k[,1:2])
   #             val_probs_k = scale_sum_1(nb_vals)
   #             
   #             if(is.null(prev_pt_k)){
   #                probs_k = val_probs_k^quality_exp2 * angle_probs_k^attract_pt_exp2
   #             } else {
   #                cor_probs_k = get_angle_move_probs(prev_pt_k, current_pt, nb_k)
   #                probs_k = val_probs_k^quality_exp2 * angle_probs_k^attract_pt_exp2 * cor_probs_k^direction_exp2
   #             }
   #             probs_k = scale_sum_1(probs_k)
   #             next_pt_k = nb_k[sample(1:length(probs_k), 1, prob = probs_k),]
   #             next_pt_id_k = extract(l, rbind(next_pt_k), cellnumbers=TRUE)[,"cells"]
   #             lines(rbind(current_pt, next_pt_k))
   #             #lines(rbind(current_pt, next_pt_k))
   #             #points(next_pt_k[1], next_pt_k[2])
   #             prev_pt_k = current_pt
   #             current_pt = next_pt_k
   #             
   #             
   #             if(plot_tf) points(nb_k, pch=16, cex=.9, col="red")
   #             if(plot_tf) text(nb_k, labels=round(probs_k,2), cex=.8)
   #             #points(rbind(next_pt_k), col="deepskyblue", pch=16)
   #             lines(rbind(current_pt, next_pt_k))
   #             
   #             
   #             if(next_pt_id_j == next_pt_id_k){
   #                break;
   #             }
   #          }
   #       }
   #    })
   #    self$current_year = self$current_year + 1 #TEMPORARY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   #    invisible(self)
   # }
   
   reproduce = function(){
      cell_ids = unique(self$live_agents[,"cell_id"])
      
      new_agents_list = lapply(1:length(cell_ids), function(i){
         agents_i = self$live_agents[self$live_agents[,"cell_id"] == cell_ids[i],, drop=FALSE]
         sex_tab = table(agents_i[,"sex"])
         if(length(sex_tab) > 1){
            n_pairs = min(sex_tab)
            n_babies = sum(rbinom(n_pairs, 1, self$prob_reproduce))
            if(n_babies > 0){
               #babies = matrix(nrow=n_babies, ncol=ncol(self$live_agents), dimnames = list(NULL, colnames(self$live_agents)))
               babies = agents_i[1:n_babies,,drop=FALSE] #copy from the agents in the same cell, so that we don't have to change x, y, or cell_id. This might not be a great idea to do it this way. But we should be guaranteed that there is at least 2*n_babies in agents_i.
               #print(babies)
               babies[,"id"] = (self$last_id + 1):(self$last_id + n_babies)
               cell_coords = private$decompose_cell_id(cell_ids[i])
               #babies[,"x"] = cell_coords[1] + runif(n_babies,0,1)
               #babies[,"y"] = cell_coords[2] + runif(n_babies,0,1)
               babies[,"x"] = ceiling(agents_i[1,"x"])-1 + runif(n_babies,0,1)
               babies[,"y"] = ceiling(agents_i[1,"y"])-1 + runif(n_babies,0,1)
               babies[,"sex"] = rbinom(n_babies, 1, .5)
               babies[,"birth_year"] = self$current_year
               babies[,"age"] = 0
               
               self$last_id = self$last_id + n_babies
               return(babies)
            }
         }
      })
      new_agents = do.call(rbind, new_agents_list)
      self$live_agents = rbind(self$live_agents, new_agents)
      invisible(self)
   },
   
   kill_old_agents = function(){
      old_agents_bool = self$live_agents[,"age"] > self$max_age
      self$dead_agents = rbind(self$dead_agents, self$live_agents[old_agents_bool,]) #Also I REALLY dislike this - I just want to append, not have to rbind them together and reassign it to 'dead_torts'
      self$live_agents = self$live_agents[!old_agents_bool,] #NOTE - this might be a spot where I can speed things up. I don't like how this is done right now - I think it's copying the entire set of not-old agents (most of them) - any way to do this by modify-in-place?
      invisible(self)
   },
   
   kill_saturated_agents = function(){
      cell_tab = table(self$live_agents[,"cell_id"])
      saturated_cells = names(cell_tab)[cell_tab > self$max_cell_capacity]
      #print(cell_tab)
      #print(saturated_cells)
      if(length(saturated_cells) > 0){
         agent_indices_to_kill_list = lapply(1:length(saturated_cells), function(i){
            agent_ids_i = which(self$live_agents[,"cell_id"] == saturated_cells[i])
            #print(agent_ids_i)
            #print(length(agent_ids_i) - self$max_cell_capacity)
            agent_indices_to_kill_i = sample(agent_ids_i, length(agent_ids_i) - self$max_cell_capacity, replace=FALSE)
            return(agent_indices_to_kill_i)
         })
         agent_indices_to_kill = do.call(c, agent_indices_to_kill_list)
         
         #print(agent_indices_to_kill)
         self$dead_agents = rbind(self$dead_agents, self$live_agents[agent_indices_to_kill,])
         self$live_agents = self$live_agents[-1*agent_indices_to_kill,]
      }
      invisible(self)
   },
   
   advance_year = function(){
      self$live_agents[,"age"] = self$live_agents[,"age"] + 1
      self$current_year = self$current_year + 1
      invisible(self)
   },
   
   plot = function(){
      raster::plot(self$landscape)
      #abline(v = 0:self$landscape_n_side, col="gray")
      #abline(h = 0:self$landscape_n_side, col="gray")
      points(x = self$live_agents[,"x"], y = self$live_agents[,"y"], xlim = c(0, self$landscape_n_side), ylim = c(0, self$landscape_n_side))
      invisible(self)
   },
   
   plot_movt_history = function(type="raster", points=FALSE){
      if(type=="raster") {
         raster::plot(self$landscape)
      } else if(type=="quadtree"){
         qtplot(self$qtree, border_col="gray60")
      }
      #abline(v = 0:self$landscape_n_side, col="gray")
      #abline(h = 0:self$landscape_n_side, col="gray")
      #points(x = self$live_agents[,"x"], y = self$live_agents[,"y"], xlim = c(0, self$landscape_n_side), ylim = c(0, self$landscape_n_side))
      lapply(1:nrow(self$move_hist), function(i){
         lines(self$move_hist$x[[i]], self$move_hist$y[[i]])
         if(points) points(self$move_hist$x[[i]], self$move_hist$y[[i]], pch=16, cex=.4)
      })
      invisible(self)
   }
), private = list(
   #fields
   #AGENT_ATTS = c("id", "x", "y", "cell_id", "sex", "birth_year", "age"),
   #DESCRIPTION:
   #convenience function for use in 'kmeans_alt()'. Given a single "focus point"
   #(as a matrix) and a matrix of other points, calculates the distances between
   #the focus point and each of the points in the matrix.
   #PARAMETERS:
   #pt_mat -> a matrix with one row and two columns, where the first column
   #is the x coordinate and the second column in the y coordinate
   #other_pts_mat -> a matrix with two columns, where the first column contains
   #x coordinates for the points and the second column contains the y
   #coordinates for the points
   #RETURNS:
   #a vector with the same length as the number of rows in 'other_pts_mat', 
   #where the 'i'th element represents the distance between the focus point
   #and the point represented in row 'i' of 'other_pts_mat'.
   dists_to_point = function(pt_mat, other_pts_mat){
      dists = apply(other_pts_mat, MARGIN=1, FUN=function(row_i){
         return(sqrt((pt_mat[1,1]-row_i[1])^2 + (pt_mat[1,2]-row_i[2])^2))
      })
      return(dists)
   },
   
   #DESCRIPTION:
   #given a and b, finds the value of c using the Pythagorean theorem (a^2 + b^2
   #= c^2)
   #PARAMETERS:
   #a, b -> numbers
   #RETURNS:
   #a number - the value of c
   pythag = function(a,b){ sqrt(a^2 + b^2) },
   
   #DESCRIPTION:
   #Calculates the straight-line distance between two points
   #PARAMETERS:
   #pt1, pt2 -> two-element numeric vectors, where the first element is the 
   #x-coordinate and the second element is the y-coordinate
   #RETURNS:
   #A number - the straight line distance between the two points
   dist_btw_points = function(pt1, pt2){ private$pythag(pt1[1]-pt2[1], pt1[2]-pt2[2]) },
   #methods
   get_cell_id = function(x, y){
      return(y*self$landscape_n_side + x + 1)
   },
   
   decompose_cell_id = function(cell_id){
      return(cbind(x = (cell_id-1)%%self$landscape_n_side, y = floor(cell_id-1)/self$landscape_n_side))
   },
   
   get_angle = function(pt1, pt2){
      angle = atan2(pt2[2]- pt1[2], pt2[1] - pt1[1])
   },
   get_angles = function(pt1, pts){
      angles = vapply(1:nrow(pts), FUN.VALUE = numeric(1), function(i){
         private$get_angle(pt1, pts[i,])
      })
      return(angles)
   },
   # get_angle_move_probs = function(start_pt, end_pt, opt_pts, exp=1){
   #    angle = private$get_angle(start_pt, end_pt) # get the angle between the start point and the end point
   #    opt_angles = private$get_angles(start_pt, opt_pts)
   #    cos_vals = cos(opt_angles-angle) # get the values of cos when it's centered on 'angle'
   #    prob = (cos_vals + 1)/sum(cos_vals + 1) # standardize the #s to be non-negative and sum to 1
   #    prob = prob^exp/sum(prob^exp) # we can use an exponent to adjust the probs - the higher exp, the more weighted the prob will be towards the closest angle. The lower exp, the more even the probabilities
   #    return(prob)
   # },
   get_angle_move_probs = function(start_pt, angle, opt_pts){
      opt_angles = private$get_angles(start_pt, opt_pts)
      cos_vals = cos(opt_angles-angle) # get the values of cos when it's centered on 'angle'
      prob = (cos_vals + 1)/sum(cos_vals + 1) # standardize the #s to be non-negative and sum to 1
      prob = prob/sum(prob) # we can use an exponent to adjust the probs - the higher exp, the more weighted the prob will be towards the closest angle. The lower exp, the more even the probabilities
      return(prob)
   },
   get_all_move_opts = function(){
      all_move_opts = cbind(x = c(-1,-1,-1,0,1,1,1,0), y = c(-1,0,1,1,1,0,-1,-1)) #in CLOCKWISE order, starting from lower left corner
      angles = apply(all_move_opts, 1, function(row_i){
         return(private$get_angle(c(0,0), row_i))
      })
      #cbind(all_move_opts, angles)
      all_move_opts = cbind(all_move_opts, angle = angles)
      return(all_move_opts)
   },
   
   get_move_probs = function(start_pt, end_pt, exp=1){
      move_opts = private$get_all_move_opts()
      angle = private$get_angle(start_pt, end_pt) # get the angle between the start point and the end point
      cos_vals = cos(move_opts[,3]-angle) # get the values of cos when it's centered on 'angle'
      prob = (cos_vals + 1)/sum(cos_vals + 1) # standardize the #s to be non-negative and sum to 1
      prob = prob^exp/sum(prob^exp) # we can use an exponent to adjust the probs - the higher exp, the more weighted the prob will be towards the closest angle. The lower exp, the more even the probabilities
      move_opts = cbind(move_opts, prob = prob)
      return(move_opts)
   },
   runif_circle_perim = function(n,radius){
      angle = runif(n, 0,2*pi)
      x = cos(angle)*radius;
      y = sin(angle)*radius;
      return(cbind(x,y))
   },
   sample_pts_cond = function(rast, n, cutoff){
      #print("3a1")
      ################ <TEMPORARY> #########################
      poly = rasterToPolygons(rast, dissolve=TRUE)
      pts = spsample(poly,n, type="random")
      return(pts@coords)

      ################ </TEMPORARY> #########################
      
      # rast[rast > cutoff] = NA
      # pts = raster::sampleRandom(rast, n, xy=TRUE)
      # return(pts[,1:2])
   },
   get_n_points_on_circle = function(n, radius){
      angle = seq(from=0, by = 2*pi/n, length.out=n)
      x = cos(angle)*radius;
      y = sin(angle)*radius;
      return(cbind(x,y))
   },
   scale_sum_1 = function(vec){
      return(vec/sum(vec))
   },
   get_next_pt_qt = function(current_pt, prev_pt, attr_pt, n_points, dist, quality_exp, attract_pt_exp, direction_exp){
      #print("checkf1")
      circ_pts0 = private$get_n_points_on_circle(n_points, dist)
      circ_pts = t(apply(circ_pts0, MARGIN=1, function(row_i){
         return(row_i + current_pt)
      }))
      #print("checkf2")
      circ_vals = self$qtree$getValues(circ_pts[,1], circ_pts[,2])
      circ_pts = circ_pts[!is.na(circ_vals),] #remove NaN vals (from pts that fell outside of the extent)
      circ_vals = circ_vals[!is.na(circ_vals)]
      #print("checkf3")
      
      val_probs = private$scale_sum_1(1-circ_vals)
      #angle_probs = private$get_angle_move_probs(current_pt, attr_pt, circ_pts)
      angle_probs = private$get_angle_move_probs(current_pt, private$get_angle(current_pt, attr_pt), circ_pts)
      #print("checkf4")
      if(is.null(prev_pt)){
         probs = val_probs^quality_exp * angle_probs^attract_pt_exp
      } else {
         #cor_probs = private$get_angle_move_probs(prev_pt, current_pt, circ_pts)
         cor_probs = private$get_angle_move_probs(current_pt, private$get_angle(prev_pt, current_pt), circ_pts)
         probs = val_probs^quality_exp * angle_probs^attract_pt_exp * cor_probs^direction_exp
      }
      #print("checkf5")
      probs = private$scale_sum_1(probs)
      
      next_pt = circ_pts[sample(1:length(probs), 1, prob=probs),]
      #print("checkf6")
      return(next_pt)
      #next_pt_id = qt$getCell(next_pt[1], next_pt[2])$id()
      #prev_pt = next_pt
      #next_cell = qt$getCell(next_pt[1], next_pt[2])
   },
   print_var = function(thing, prnt=TRUE){
      if(prnt){
         var_name = deparse(substitute(thing))
         print(paste0(var_name, ":"))
      }
   },
   rand_surf_diag = function(n_side, surf_min, surf_max, step_sd){
      #-----
      #initialize diagonal
      #-----
      vals = runif(1,surf_min, surf_max) #initialize the first value
      for(i in 2:n_side){ #using the first value as a starting value, create the values of the diagonal of the matrix
         step_i = rnorm(1,0, sd=step_sd) #randomly generate the size of the "step" - that is, how much we'll add/subtract to the previous value
         if(vals[i-1] + step_i < surf_min | vals[i-1] + step_i > surf_max){ #make sure the next step falls within our max and min values
            step_i = step_i*-1 #if it doesn't, change the direction of the step
         }
         vals[i] = vals[i-1] + step_i #use the step size to get the next value
      }
      
      #-----
      #generate rest of matrix
      #-----
      surf = matrix(nrow=n_side, ncol=n_side) #initialize the matrix
      diag(surf) = vals #assign the diagonal to be the values we just calculated
      #image(surf)
      
      #diag_ind = cbind(1:n_side, 1:n_side)
      #diag_ind
      
      all_ind = expand.grid(r = 1:n_side, c = 1:n_side) #get all the indices of the matrix
      all_ind$dif = abs(all_ind[,1] - all_ind[,2]) #calculate the difference, which we'll use for removing the diagonal indices and for ordering the indices
      all_ind2 = all_ind[all_ind$dif != 0,] #remove the indices of the diagonal
      
      all_ind2 = all_ind2[order(all_ind2$dif),] #order them by the difference so that the onces right next to the diagonal are first
      #nrow(all_ind2)
      for(i in 1:nrow(all_ind2)){ #loop over the indices
         if(i %% 10000 == 0) print(i)
         #depending on which side of the diagonal we're on, the "parent" cells will be either "above" or "below" the cell - use 'coef' to account for that
         coef = 1
         if(all_ind2$r[i] < all_ind2$c[i]){
            coef = -1
         }
         parent_inds = rbind(c(all_ind2$r[i] - 1*coef, all_ind2$c[i]),
                             c(all_ind2$r[i], all_ind2$c[i] + 1*coef)) #get the indices of the two "parents"
         parent_vals = apply(parent_inds, MARGIN=1, FUN = function(row_i){ #get the values of the parents based on the indices we just calculated
            return(surf[row_i[1], row_i[2]])
         })
         base_val = mean(parent_vals) #get the "base value", which is the mean of the two parents
         step_i = rnorm(1,mean = 0,sd = step_sd) #get the step size
         if(base_val + step_i < surf_min | base_val + step_i > surf_max){ #make sure the next step falls within our max and min values
            step_i = step_i*-1 #if it doesn't, change the direction of the step
         }
         surf[all_ind2$r[i], all_ind2$c[i]] = base_val + step_i #add the step to the base value to get the new values
      }
      return(surf)
   }
))

# decompose_cell_id = function(cell_id, n){
#    return(cbind(x = (cell_id-1)%%n, y = floor((cell_id-1)/n)))
# }
# cbind(test$live_agents[,c("cell_id", "x", "y")], decompose_cell_id(test$live_agents[,"cell_id"], 2))

