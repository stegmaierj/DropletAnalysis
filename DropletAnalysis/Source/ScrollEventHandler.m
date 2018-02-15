%% scroll event handler
function ScrollEventHandler(src,evnt)
    global settings;

    %% get the modifier keys
    modifiers = get(gcf,'currentModifier');        %(Use an actual figure number if known)
    shiftPressed = ismember('shift',modifiers);
    ctrlPressed = ismember('control',modifiers);
    altPressed = ismember('alt',modifiers);
    
    %% if control pressed increase/decrease the gfp contrast
    if (ctrlPressed == true)

        
    %% if alt pressed increase/decrease the rfp contrast
    elseif (altPressed == true)

    elseif (shiftPressed == true)
 
        
    %% if no modifier is pressed perform scrolling through the stack
    else

    end
    
    %% finally update the visualization
	updateVisualization;
end