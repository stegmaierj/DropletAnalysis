function [ind_neighbor,all_neighbor_list] = solve_tracking_conflict(ind_neighbor,i_dat_conflict,all_neighbor_list)

%conflict resultion for the nearest one
ind_used_neighbors = find(ind_neighbor);

%break if empty
if isempty(ind_used_neighbors)
   return;
end;

%break if no remaining candidate
if isempty(all_neighbor_list{i_dat_conflict}.neighbor_list_ind)
   ind_neighbor(i_dat_conflict) = 0;
   return;
end;

%look for the nearest one
while 1
   
   %break if no remaining candidate
   if isempty(all_neighbor_list{i_dat_conflict}.neighbor_list_ind)
      ind_neighbor(i_dat_conflict) = 0;
      return;
   end;
   
   %any conflict?
   tmp_ind_conflict_partner = find(ind_neighbor(ind_used_neighbors) == all_neighbor_list{i_dat_conflict}.neighbor_list_ind(1));
   ind_conflict_partner = ind_used_neighbors(tmp_ind_conflict_partner);
   
   %break if not
   if isempty(ind_conflict_partner)
      return;
   end;
   
   %break if no alternative left
   if isempty(all_neighbor_list{ind_conflict_partner}) || ...
      isempty(all_neighbor_list{ind_conflict_partner}.neighbor_list_dist)
      return;
   end;
   
   
   if all_neighbor_list{i_dat_conflict}.neighbor_list_dist(1) > ...
         all_neighbor_list{ind_conflict_partner}.neighbor_list_dist(1)
      
      %delete the first alternative, continue with the next one
      all_neighbor_list{i_dat_conflict}.neighbor_list_dist(1) = [];
      all_neighbor_list{i_dat_conflict}.neighbor_list_ind(1) = [];
      
      
   else
      
      ind_neighbor(i_dat_conflict) =  all_neighbor_list{i_dat_conflict}.neighbor_list_ind(1);
      if length(all_neighbor_list{ind_conflict_partner}.neighbor_list_ind) >= 1
         
         %delete the first old match
         all_neighbor_list{ind_conflict_partner}.neighbor_list_dist(1) = [];
         all_neighbor_list{ind_conflict_partner}.neighbor_list_ind(1) = [];
         ind_neighbor(ind_conflict_partner) = 0;    
        
         %look for next alternatives (recursive call!!!)
         [ind_neighbor,all_neighbor_list] = solve_tracking_conflict(...
            ind_neighbor,ind_conflict_partner,all_neighbor_list);
         
      else
         %delete the old match
         ind_neighbor(ind_conflict_partner) = 0;
      end;
      
   end;
end;


